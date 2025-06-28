# Mock INLAjoint functions for testing the interface
# This file provides mock implementations when INLA is not available

# Check if INLA is available
INLA_AVAILABLE <- FALSE
tryCatch({
  library(INLA)
  INLA_AVAILABLE <- TRUE
}, error = function(e) {
  message("INLA not available, using mock functions")
})

# Mock joint function
mock_joint <- function(formLong = NULL, formSurv = NULL, dataLong = NULL, 
                      dataSurv = NULL, id = NULL, timeVar = NULL, 
                      family = "gaussian", basRisk = "rw1", NbasRisk = 20,
                      assoc = NULL, silentMode = FALSE, dataOnly = FALSE, ...) {
  
  # Simulate model fitting delay
  Sys.sleep(2)
  
  # Create mock result
  result <- list(
    call = match.call(),
    formulas = list(longitudinal = formLong, survival = formSurv),
    data = list(longitudinal = dataLong, survival = dataSurv),
    family = family,
    baseline_risk = basRisk,
    association = assoc,
    
    # Mock fitted values
    fitted_values = if(!is.null(dataLong)) rnorm(nrow(dataLong), mean = mean(dataLong[[all.vars(formLong)[1]]], na.rm = TRUE)) else NULL,
    
    # Mock residuals
    residuals = if(!is.null(dataLong)) rnorm(nrow(dataLong), sd = 0.5) else NULL,
    
    # Mock coefficients
    fixed_effects = data.frame(
      Parameter = c("(Intercept)", "time", "X"),
      Estimate = c(10.2, 1.5, -0.3),
      StdError = c(0.5, 0.1, 0.2),
      Lower = c(9.2, 1.3, -0.7),
      Upper = c(11.2, 1.7, 0.1),
      stringsAsFactors = FALSE
    ),
    
    # Mock random effects
    random_effects = if(!is.null(dataLong)) {
      ids <- unique(dataLong[[id]])
      data.frame(
        ID = ids,
        Intercept = rnorm(length(ids), sd = 0.8),
        Slope = rnorm(length(ids), sd = 0.3),
        stringsAsFactors = FALSE
      )
    } else NULL,
    
    # Mock summary
    summary_text = paste(
      "Mock INLAjoint Model Results",
      "============================",
      "Longitudinal Formula:", deparse(formLong),
      if(!is.null(formSurv)) paste("Survival Formula:", deparse(formSurv)) else "",
      paste("Family:", family),
      paste("Baseline Risk:", basRisk),
      if(!is.null(assoc)) paste("Association:", assoc) else "No association",
      "",
      "Fixed Effects:",
      "  Intercept: 10.2 (SE: 0.5)",
      "  time: 1.5 (SE: 0.1)", 
      "  X: -0.3 (SE: 0.2)",
      "",
      "Random Effects SD:",
      "  Intercept: 0.8",
      "  Slope: 0.3",
      "",
      "Note: This is a MOCK result for interface testing.",
      "Install INLA package for real model fitting.",
      sep = "\n"
    )
  )
  
  class(result) <- c("INLAjoint_mock", "INLAjoint")
  return(result)
}

# Mock methods for INLAjoint objects
summary.INLAjoint_mock <- function(object, ...) {
  cat(object$summary_text)
  invisible(object)
}

print.INLAjoint_mock <- function(x, ...) {
  cat("Mock INLAjoint Model\n")
  cat("===================\n")
  if(!is.null(x$formulas$longitudinal)) {
    cat("Longitudinal:", deparse(x$formulas$longitudinal), "\n")
  }
  if(!is.null(x$formulas$survival)) {
    cat("Survival:", deparse(x$formulas$survival), "\n")
  }
  cat("Family:", x$family, "\n")
  cat("Baseline Risk:", x$baseline_risk, "\n")
  if(!is.null(x$association)) {
    cat("Association:", x$association, "\n")
  }
  cat("\nNote: Mock result - install INLA for real fitting\n")
  invisible(x)
}

coef.INLAjoint_mock <- function(object, ...) {
  return(object$fixed_effects)
}

fixef.INLAjoint_mock <- function(object, ...) {
  return(object$fixed_effects)
}

ranef.INLAjoint_mock <- function(object, ...) {
  return(list(id = object$random_effects))
}

fitted.INLAjoint_mock <- function(object, ...) {
  return(object$fitted_values)
}

residuals.INLAjoint_mock <- function(object, ...) {
  return(object$residuals)
}

predict.INLAjoint_mock <- function(object, newdata = NULL, ...) {
  if(is.null(newdata)) {
    return(data.frame(
      fit = object$fitted_values,
      lwr = object$fitted_values - 1.96 * 0.5,
      upr = object$fitted_values + 1.96 * 0.5
    ))
  } else {
    n <- nrow(newdata)
    pred_mean <- 10 + 1.5 * newdata[[1]]  # Assume first column is time
    return(data.frame(
      fit = pred_mean + rnorm(n, sd = 0.2),
      lwr = pred_mean - 1.96 * 0.5,
      upr = pred_mean + 1.96 * 0.5
    ))
  }
}

# Function to use real joint() if INLA is available, otherwise mock
safe_joint <- function(...) {
  if(INLA_AVAILABLE) {
    return(INLAjoint::joint(...))
  } else {
    return(mock_joint(...))
  }
}
