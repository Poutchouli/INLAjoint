# Simple Enhanced INLAjoint loader
# First tries to use the installed INLAjoint package, then falls back to mock

message("Starting Enhanced INLAjoint loader...")

# Check if INLAjoint package is available
inlajoint_package_available <- FALSE
tryCatch({
  library(INLAjoint, warn.conflicts = FALSE, quietly = TRUE)
  inlajoint_package_available <- TRUE
  message("Using installed INLAjoint package version ", packageVersion("INLAjoint"))
}, error = function(e) {
  message("INLAjoint package not available: ", e$message)
})

# Check if INLA is available
inla_available <- FALSE
tryCatch({
  if (require(INLA, quietly = TRUE)) {
    inla_available <- TRUE
    message("INLA package is available")
  }
}, error = function(e) {
  message("INLA package not available: ", e$message)
})

if (inlajoint_package_available) {
  if (inla_available) {
    message("Using real INLAjoint with INLA backend")
    # The joint function is already available from the package
  } else {
    message("Using INLAjoint package without INLA - enhanced mode")
    
    # Create enhanced joint function that provides better feedback
    joint_enhanced <- function(formLong = NULL, formSurv = NULL, 
                             dataLong = NULL, dataSurv = NULL, 
                             id = NULL, timeVar = NULL, family = "gaussian",
                             basRisk = "rw1", NbasRisk = 20, assoc = NULL,
                             silentMode = FALSE, dataOnly = FALSE, ...) {
      
      message("Using simplified joint model (INLA not available)")
      
      # Try to use the original joint function, but catch errors gracefully
      tryCatch({
        result <- joint(formLong = formLong, formSurv = formSurv,
                       dataLong = dataLong, dataSurv = dataSurv,
                       id = id, timeVar = timeVar, family = family,
                       basRisk = basRisk, NbasRisk = NbasRisk, assoc = assoc,
                       silentMode = silentMode, dataOnly = dataOnly, ...)
        return(result)
      }, error = function(e) {
        message("Error with INLAjoint function, using mock: ", e$message)
        # Fallback to mock
        source("/srv/shiny-server/utils/mock_inla.R", local = TRUE)
        return(mock_joint_model(formLong = formLong, formSurv = formSurv,
                               dataLong = dataLong, dataSurv = dataSurv,
                               id = id, timeVar = timeVar, family = family,
                               basRisk = basRisk, NbasRisk = NbasRisk, assoc = assoc,
                               silentMode = silentMode, dataOnly = dataOnly, ...))
      })
    }
    
    # Override the joint function
    assign("joint", joint_enhanced, envir = .GlobalEnv)
  }
  
  # Try to load the data from the package
  tryCatch({
    data("LongMS", package = "INLAjoint", envir = .GlobalEnv)
    data("SurvMS", package = "INLAjoint", envir = .GlobalEnv)
    data("Longsim", package = "INLAjoint", envir = .GlobalEnv)
    data("Survsim", package = "INLAjoint", envir = .GlobalEnv)
    message("INLAjoint data loaded successfully")
  }, error = function(e) {
    message("Could not load INLAjoint data: ", e$message)
  })
  
} else {
  # Final fallback to mock if package not available
  message("Using mock INLAjoint implementation")
  source("/srv/shiny-server/utils/mock_inla.R", local = TRUE)
  assign("joint", mock_joint_model, envir = .GlobalEnv)
}

message("Enhanced INLAjoint loader completed successfully")
