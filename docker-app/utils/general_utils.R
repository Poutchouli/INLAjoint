# General utility functions

#' Null coalescing operator
#' Returns the left-hand side if not NULL, otherwise returns the right-hand side
#' @param x Left-hand side value
#' @param y Right-hand side value (default)
#' @return x if not NULL, otherwise y
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' Safe default value assignment
#' @param x Value to check
#' @param default Default value if x is NULL or empty
#' @return x if valid, otherwise default
safe_default <- function(x, default = NULL) {
  if (is.null(x) || length(x) == 0 || (is.character(x) && nzchar(x) == FALSE)) {
    return(default)
  }
  return(x)
}

#' Check if value is valid (not NULL, not empty, not NA)
#' @param x Value to check
#' @return TRUE if valid, FALSE otherwise
is_valid <- function(x) {
  if (is.null(x) || length(x) == 0) return(FALSE)
  if (is.character(x) && nzchar(x) == FALSE) return(FALSE)
  if (any(is.na(x))) return(FALSE)
  return(TRUE)
}

#' Create a safe formula from text
#' @param formula_text Character string containing formula
#' @return Formula object or NULL if invalid
safe_formula <- function(formula_text) {
  if (!is_valid(formula_text)) return(NULL)
  
  tryCatch({
    as.formula(formula_text)
  }, error = function(e) {
    warning(paste("Invalid formula:", e$message))
    return(NULL)
  })
}

#' Validate model inputs
#' @param data Data frame
#' @param formula_text Formula as text
#' @param id_var ID variable name
#' @return List with validation results
validate_model_inputs <- function(data, formula_text, id_var) {
  errors <- character(0)
  
  if (is.null(data) || nrow(data) == 0) {
    errors <- c(errors, "No data provided")
  }
  
  if (!is_valid(formula_text)) {
    errors <- c(errors, "No formula provided")
  }
  
  if (!is_valid(id_var)) {
    errors <- c(errors, "No ID variable specified")
  } else if (!is.null(data) && !id_var %in% names(data)) {
    errors <- c(errors, paste("ID variable", id_var, "not found in data"))
  }
  
  return(list(
    valid = length(errors) == 0,
    errors = errors
  ))
}
