#* 0a: Environment Setup: Academic Publication Reproducibility
#+ 0a.1: Initialize renv environment
  #- 0a.1.1: Install renv if missing
    if (!require(renv, quietly = TRUE)) {
      install.packages("renv")
    }
  #- 0a.1.2: Check if this is first-time setup or restoration
    if (!file.exists("renv.lock")) {
      cat("🔧 Setting up reproducible environment...\n")
      renv::init()
      renv::install()
      renv::snapshot()
      cat("✅ Environment setup complete!\n")
    } else {
      cat("🔄 Restoring published environment...\n")
      renv::restore()
      cat("✅ Environment restored!\n")
    }
#+ 0a.2: Load configuration and setup
  source("R/Scripts/00b_setup.R")
  cat("\nSetup complete! All dependencies match original analysis.\nYou can now run the analysis scripts.\nSee README.md for analysis workflow.\n")
