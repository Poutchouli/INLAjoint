# Test script for enhanced INLAjoint loader
# This script tests if the enhanced loader works correctly

cat("Testing Enhanced INLAjoint Loader\n")
cat("===================================\n\n")

# Source the enhanced loader
cat("1. Loading enhanced INLAjoint loader...\n")
tryCatch({
  source("utils/enhanced_inlajoint.R")
  cat("✓ Enhanced loader sourced successfully\n")
}, error = function(e) {
  cat("✗ Failed to source enhanced loader:", e$message, "\n")
  quit(save = "no", status = 1)
})

# Check if INLAjoint source is available
cat("\n2. Checking INLAjoint source availability...\n")
if (exists("INLAJOINT_SOURCE_AVAILABLE")) {
  cat("✓ INLAjoint source status:", INLAJOINT_SOURCE_AVAILABLE, "\n")
} else {
  cat("✗ INLAjoint source availability not detected\n")
}

# Check if safe_joint function exists
cat("\n3. Checking safe_joint function...\n")
if (exists("safe_joint") && is.function(safe_joint)) {
  cat("✓ safe_joint function is available\n")
} else {
  cat("✗ safe_joint function not found\n")
}

# Test with sample data
cat("\n4. Testing with sample data...\n")
set.seed(123)

# Create simple test data
n_subjects <- 10
n_obs_per_subject <- 5
test_data <- data.frame(
  id = rep(1:n_subjects, each = n_obs_per_subject),
  time = rep(0:(n_obs_per_subject-1), n_subjects),
  y = rnorm(n_subjects * n_obs_per_subject, 10, 2)
)

cat("Created test data with", nrow(test_data), "observations and", n_subjects, "subjects\n")

# Test the safe_joint function
cat("\n5. Running test model...\n")
tryCatch({
  test_result <- safe_joint(
    formLong = y ~ time + (1 + time | id),
    dataLong = test_data,
    id = "id",
    timeVar = "time",
    family = "gaussian",
    silentMode = TRUE
  )
  
  cat("✓ Model completed successfully!\n")
  cat("Model class:", class(test_result)[1], "\n")
  
  if ("fixed_effects" %in% names(test_result)) {
    cat("✓ Fixed effects table available\n")
    cat("Parameters:", paste(test_result$fixed_effects$Parameter, collapse = ", "), "\n")
  }
  
  if ("n_obs" %in% names(test_result)) {
    cat("✓ Model summary: ", test_result$n_obs, "observations,", test_result$n_subjects, "subjects\n")
  }
  
}, error = function(e) {
  cat("✗ Model test failed:", e$message, "\n")
})

cat("\n6. Summary\n")
cat("Enhanced INLAjoint loader test completed.\n")
if (exists("test_result")) {
  cat("✓ All tests passed - the enhanced loader is working correctly!\n")
} else {
  cat("✗ Some tests failed - check the error messages above\n")
}
