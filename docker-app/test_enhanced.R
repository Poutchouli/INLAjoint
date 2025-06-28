# Test script to verify enhanced INLAjoint setup
cat("Testing enhanced INLAjoint setup...\n")

# Test 1: Check if enhanced loader exists
enhanced_loader_exists <- file.exists("utils/enhanced_inlajoint.R")
cat("Enhanced loader file exists:", enhanced_loader_exists, "\n")

# Test 2: Check if INLAjoint source exists
source_exists <- dir.exists("INLAjoint-source")
cat("INLAjoint source directory exists:", source_exists, "\n")

if (source_exists) {
  r_files <- list.files("INLAjoint-source/R", pattern = "\\.R$")
  cat("Found", length(r_files), "R files in source\n")
}

# Test 3: Try to source the enhanced loader
if (enhanced_loader_exists) {
  tryCatch({
    source("utils/enhanced_inlajoint.R")
    cat("Enhanced loader sourced successfully\n")
    
    # Check if safe_joint function is available
    if (exists("safe_joint")) {
      cat("safe_joint function is available\n")
    } else {
      cat("safe_joint function NOT available\n")
    }
    
  }, error = function(e) {
    cat("Error sourcing enhanced loader:", e$message, "\n")
  })
}

cat("Test completed.\n")
