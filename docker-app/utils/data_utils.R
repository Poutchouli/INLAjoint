# Data processing utilities

#' Validate longitudinal data structure
#' @param data Data frame
#' @param id_var ID variable name
#' @param time_var Time variable name
#' @param outcome_var Outcome variable name
#' @return List with validation results
validate_longitudinal_data <- function(data, id_var, time_var, outcome_var) {
  errors <- character(0)
  warnings <- character(0)
  
  # Check if required variables exist
  if (!id_var %in% names(data)) {
    errors <- c(errors, paste("ID variable", id_var, "not found in data"))
  }
  
  if (!time_var %in% names(data)) {
    errors <- c(errors, paste("Time variable", time_var, "not found in data"))
  }
  
  if (!outcome_var %in% names(data)) {
    errors <- c(errors, paste("Outcome variable", outcome_var, "not found in data"))
  }
  
  if (length(errors) == 0) {
    # Check data types
    if (!is.numeric(data[[time_var]])) {
      warnings <- c(warnings, "Time variable should be numeric")
    }
    
    if (!is.numeric(data[[outcome_var]])) {
      warnings <- c(warnings, "Outcome variable should be numeric for gaussian family")
    }
    
    # Check for missing values
    if (any(is.na(data[[id_var]]))) {
      errors <- c(errors, "Missing values found in ID variable")
    }
    
    if (any(is.na(data[[time_var]]))) {
      warnings <- c(warnings, "Missing values found in time variable")
    }
    
    # Check for sufficient observations per individual
    obs_per_id <- table(data[[id_var]])
    if (any(obs_per_id < 2)) {
      warnings <- c(warnings, "Some individuals have fewer than 2 observations")
    }
  }
  
  return(list(
    valid = length(errors) == 0,
    errors = errors,
    warnings = warnings
  ))
}

#' Validate survival data structure
#' @param data Data frame
#' @param id_var ID variable name
#' @param time_var Time variable name
#' @param event_var Event variable name
#' @return List with validation results
validate_survival_data <- function(data, id_var, time_var, event_var) {
  errors <- character(0)
  warnings <- character(0)
  
  # Check if required variables exist
  if (!id_var %in% names(data)) {
    errors <- c(errors, paste("ID variable", id_var, "not found in data"))
  }
  
  if (!time_var %in% names(data)) {
    errors <- c(errors, paste("Time variable", time_var, "not found in data"))
  }
  
  if (!event_var %in% names(data)) {
    errors <- c(errors, paste("Event variable", event_var, "not found in data"))
  }
  
  if (length(errors) == 0) {
    # Check data types
    if (!is.numeric(data[[time_var]])) {
      errors <- c(errors, "Time to event variable must be numeric")
    }
    
    # Check event variable values
    event_values <- unique(data[[event_var]])
    if (!all(event_values %in% c(0, 1))) {
      warnings <- c(warnings, "Event variable should contain only 0 (censored) and 1 (event)")
    }
    
    # Check for missing values
    if (any(is.na(data[[id_var]]))) {
      errors <- c(errors, "Missing values found in ID variable")
    }
    
    if (any(is.na(data[[time_var]]))) {
      errors <- c(errors, "Missing values found in time to event variable")
    }
    
    # Check for negative times
    if (any(data[[time_var]] <= 0, na.rm = TRUE)) {
      errors <- c(errors, "Time to event must be positive")
    }
  }
  
  return(list(
    valid = length(errors) == 0,
    errors = errors,
    warnings = warnings
  ))
}

#' Prepare data for INLAjoint
#' @param long_data Longitudinal data
#' @param surv_data Survival data (optional)
#' @param id_var ID variable name
#' @return List with prepared data
prepare_inlajoint_data <- function(long_data, surv_data = NULL, id_var) {
  
  # Ensure ID is consistent across datasets
  if (!is.null(surv_data)) {
    # Check if IDs match
    long_ids <- unique(long_data[[id_var]])
    surv_ids <- unique(surv_data[[id_var]])
    
    if (!all(surv_ids %in% long_ids)) {
      warning("Some survival IDs not found in longitudinal data")
    }
    
    if (!all(long_ids %in% surv_ids)) {
      warning("Some longitudinal IDs not found in survival data")
    }
  }
  
  return(list(
    longitudinal = long_data,
    survival = surv_data
  ))
}

#' Create summary statistics for data
#' @param data Data frame
#' @return Data frame with summary statistics
create_data_summary <- function(data) {
  numeric_vars <- sapply(data, is.numeric)
  
  if (any(numeric_vars)) {
    numeric_data <- data[, numeric_vars, drop = FALSE]
    summary_stats <- data.frame(
      Variable = names(numeric_data),
      Mean = sapply(numeric_data, mean, na.rm = TRUE),
      SD = sapply(numeric_data, sd, na.rm = TRUE),
      Min = sapply(numeric_data, min, na.rm = TRUE),
      Max = sapply(numeric_data, max, na.rm = TRUE),
      Missing = sapply(numeric_data, function(x) sum(is.na(x))),
      stringsAsFactors = FALSE
    )
    
    return(summary_stats)
  }
  
  return(data.frame())
}

#' Detect data structure and suggest model components
#' @param data Data frame
#' @return List with suggestions
suggest_model_structure <- function(data) {
  suggestions <- list()
  
  # Look for common variable patterns
  var_names <- tolower(names(data))
  
  # ID variables
  id_candidates <- var_names[grep("id|subject|patient", var_names)]
  if (length(id_candidates) > 0) {
    suggestions$id_var <- id_candidates[1]
  }
  
  # Time variables
  time_candidates <- var_names[grep("time|visit|week|month|year|day", var_names)]
  if (length(time_candidates) > 0) {
    suggestions$time_var <- time_candidates[1]
  }
  
  # Event variables
  event_candidates <- var_names[grep("event|status|death|failure", var_names)]
  if (length(event_candidates) > 0) {
    suggestions$event_var <- event_candidates[1]
  }
  
  # Outcome variables (numeric, not ID or time)
  numeric_vars <- names(data)[sapply(data, is.numeric)]
  outcome_candidates <- setdiff(numeric_vars, c(suggestions$id_var, suggestions$time_var, suggestions$event_var))
  if (length(outcome_candidates) > 0) {
    suggestions$outcome_var <- outcome_candidates[1]
  }
  
  return(suggestions)
}
