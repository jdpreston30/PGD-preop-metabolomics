# Copilot Instructions

## Purpose
You are assisting in a reproducible R/Tidyverse analysis workflow for scientific research. Prioritize clean, modular, production-ready code that follows established patterns for collaborative academic projects.

## Project Architecture Philosophy

### Modular Pipeline Structure
- **Sequential numbered scripts** (00_setup.R, 01_analysis.R, etc.) that build upon each other
- **Utility functions** organized by purpose in `R/Utilities/` with subdirectories:
  - `Analysis/` - Statistical and computational functions  
  - `Preprocessing/` - Data cleaning and transformation functions
  - `Visualization/` - Plotting and figure generation functions
  - `Helpers/` - Small utility functions and calculations
- **Configuration-driven** analysis using YAML files for paths, parameters, and study-specific settings
- **DESCRIPTION file** for dependency management (R package standard)
- **Containerization** support via Dockerfile for full reproducibility

### Reproducibility Standards
- All file paths, parameters, and study-specific variables must be externalized to `config.yaml`
- Scripts should be environment-agnostic and work across different systems
- Use `here::here()` for robust path construction
- Package dependencies managed through DESCRIPTION file, loaded once at startup
- Support for DESCRIPTION-based dependency management and container-based environments

## Code Style & Structure

### General Style
- Use tidyverse verbs (dplyr, tidyr, stringr, purrr, forcats) and piping exclusively
- Objects in snake_case; never overwrite base R names
- Constants and parameters at the top of each script section
- **Never include library() calls** in scripts - packages preloaded via environment setup
- Functions should be self-contained with clear inputs/outputs and comprehensive documentation

### Comment Hierarchy System
Use this exact hierarchy for organizing R scripts:
- `#!` Issues/bookmarks/critical notes/warnings
- `#*` Major sections (numbered: `#* 1:`, `#* 2:`, etc.)
- `#+` Subsections (numbered: `#+ 1.1:`, `#+ 2.1:`, etc.)  
- `#-` Sub-subsections (numbered: `#- 1.1.1:`, `#- 2.1.1:`, etc.)
- `#_` Verification/check steps

**Critical Rules for Functions & Pipelines:**
- Within function definitions or long pipeline chains, use ONLY simple `# comment` lines
- Do NOT use hierarchical comments (`#*`, `#+`, `#-`, `#_`) inside functions or pipelines
- Functions belong to a single surrounding section - no nested subsections

### Formatting Standards
**NO BLANK LINES POLICY:**
- Never insert blank lines anywhere in R code
- No empty lines between sections, subsections, statements, or within functions/pipelines
- Maintains compact, scannable code structure

### Example (Proper Style)
```r
#* 1: Data Loading and Initial Processing
config <- yaml::read_yaml(here::here("config.yaml"))
#+ 1.1: Load raw data
raw_data <- readr::read_csv(config$paths$raw_data)
#- 1.1.1: Verify data integrity  
stopifnot(nrow(raw_data) > 0, ncol(raw_data) > 1)
#+ 1.2: Data transformation function
process_metabolomics_data <- function(data, patient_col = "Patient") {
  # Remove missing samples
  data <- data[!is.na(data[[patient_col]]), ]
  # Log transform features
  feature_cols <- setdiff(names(data), patient_col)
  data[feature_cols] <- lapply(data[feature_cols], log2)
  return(data)
}
#- 1.2.1: Apply processing
processed_data <- process_metabolomics_data(raw_data)
```

## Repository Structure Reference

### Essential File Structure Template
```
project-name/
├── DESCRIPTION              # Package dependencies (standard R format)
├── config.yaml             # All paths, parameters, study variables
├── run.R                   # Main analysis execution 
├── Dockerfile              # Container reproducibility
├── R/
│   ├── Scripts/
│   │   ├── 00a_environment_setup.R  # DESCRIPTION → packages
│   │   ├── 00b_setup.R             # config.yaml → environment
│   │   ├── 00c_metadata.R          # Clinical/sample data
│   │   ├── 00d_features.R          # Feature data preprocessing
│   │   ├── 01_analysis.R           # Main statistical analysis
│   │   ├── 02_pathway.R            # Enrichment/pathway analysis
│   │   └── 03_visualization.R      # Plot generation
│   └── Utilities/
│       ├── Analysis/        # Statistical functions (PCA, t-tests)
│       ├── Preprocessing/   # Data cleaning functions
│       ├── Visualization/   # Plot generation functions
│       └── Helpers/         # Small utility functions
├── Databases/              # Reference data, libraries
├── Outputs/               # Generated results
│   ├── Tables/
│   ├── Figures/
│   └── Analysis/
└── Figures/               # Final publication figures
```

### YAML Configuration Pattern
```yaml
# config.yaml template
paths:
  # Raw data (absolute paths for cross-system compatibility)
  raw_data: "/path/to/data.csv"
  clinical_metadata: "/path/to/clinical.xlsx"
  # Output paths (relative to project root)
  output: "./Outputs" 
  figures: "./Figures"
  scripts: "R/Scripts/"
  utils: "R/Utilities/"

analysis:
  project_name: "ProjectName_YYYY"
  description: "Brief study description"
  
  # Study-specific groupings
  cohort:
    patient_range: [1, 100]
    excluded: [22, 49]
    
  # Publication table variables (organized by table)
  table_variables:
    T1: [var1, var2, var3]  # Demographics
    T2: [var4, var5, var6]  # Clinical characteristics
    
  # Analysis parameters
  statistical_params:
    alpha: 0.05
    fold_change_threshold: 1.5
    
  # R environment preferences
  tibble_options:
    print_max: 100
    sigfig: 3
```

### Environment Setup Pattern
```r
# 00a_environment_setup.R - Package management from DESCRIPTION
desc_lines <- readLines("DESCRIPTION")
imports_start <- which(grepl("^Imports:", desc_lines))
# Extract and install packages from DESCRIPTION
required_packages <- extract_packages_from_description()
install_missing_packages(required_packages)

# 00b_setup.R - Configuration and environment 
config <- yaml::read_yaml(here::here("config.yaml"))
.GlobalEnv$CONFIG <- config
# Set paths from config
output_path <- config$paths$output
# Configure R options from config
options(tibble.print_max = config$analysis$tibble_options$print_max)
# Resolve package conflicts
conflicts_prefer(dplyr::filter, purrr::map)
# Load all utility functions recursively
purrr::walk(list.files("R/Utilities/", pattern = "\\.[rR]$", 
                      full.names = TRUE, recursive = TRUE), source)
```

### Key Patterns
- **00a**: DESCRIPTION → packages (system dependencies)
- **00b**: config.yaml → environment (project configuration)  
- **00c/d**: Data loading using config paths
- **01+**: Analysis using loaded utilities and config parameters
- **Utilities**: Modular functions organized by purpose
- **config.yaml**: Single source of truth for all parameters/paths

### Script Naming Convention
- `00a_environment_setup.R` - Package loading from DESCRIPTION file
- `00b_setup.R` - Configuration loading, path setup, conflicts resolution  
- `00c_metadata.R` - Clinical/sample metadata processing
- `00d_features.R` - Feature data preprocessing
- `01_clustering.R` - Dimensionality reduction, clustering analysis
- `02_pathway_analysis.R` - Enrichment/pathway analysis
- `03_visualization.R` - Plot generation (separate computation from visualization)
- `04_tables.R` - Statistical tables and summaries
- `05_figures.R` - Figure compilation and arrangement
- `06_supplementary.R` - Additional analyses and supplementary materials

### Configuration Management
**config.yaml Structure:**
```yaml
paths:
  raw_data: "path/to/data"
  output: "./Outputs"
  figures: "./Figures" 
  scripts: "R/Scripts/"
  utils: "R/Utilities/"

analysis:
  project_name: "Study_Name_YYYY"
  description: "Brief study description"
  
  # Study-specific parameters
  cohort:
    patient_range: [1, 100]
    excluded: [22, 49]
    
  # Analysis parameters
  statistical_params:
    alpha: 0.05
    fold_change_threshold: 1.5
    
  # Output preferences
  figure_params:
    dpi: 300
    format: "png"
```

### Utility Function Organization
**Analysis Functions:**
- Statistical analysis functions (PCA, t-tests, pathway analysis)
- Should return structured lists with results and metadata
- Include comprehensive parameter validation
- Support for multiple analysis methods within single function

**Preprocessing Functions:**  
- Data cleaning and transformation utilities
- Feature filtering and normalization
- Sample metadata processing

**Visualization Functions:**
- Plot generation functions that accept analysis results
- Consistent theming and color schemes
- Flexible parameterization for different data types

**Helper Functions:**
- Small, focused utilities (rounding, string cleaning, etc.)
- Input validation functions
- File I/O utilities

### Output Management
- **Structured output directories:** `Outputs/tables/`, `Outputs/figures/`, `Outputs/analysis/`
- **Intermediate results preservation:** Save computational objects for downstream use
- **Version control friendly:** Avoid absolute paths, use relative paths with `here::here()`

## Reproducibility Requirements

### Environment Management
- DESCRIPTION file with all package dependencies
- Version control of analysis environment (DESCRIPTION + Dockerfile)
- Docker support for cross-platform reproducibility
- Clear system requirements documentation

### Data Flow Principles  
- Configuration-driven analysis (no hardcoded values)
- Modular script design allowing selective re-running
- Clear separation of data loading, processing, analysis, and visualization
- Intermediate result caching for computationally expensive steps

### Documentation Standards
- README.md with quick start instructions
- Inline documentation for all utility functions using roxygen2 format
- Configuration file documentation
- Clear citation and attribution requirements

## README Documentation Standards

### Structure Template
Use this exact structure for project README files:

```markdown
# [Project Title] - [Brief Description]

**Reproducible analysis code for academic publication**

## 📖 Citation
If you use this code, please cite:
> [Author et al. (Year). Title. *Journal*. DOI: xxx]

## 🚀 Quick Start for Reproduction
**One command to reproduce all results:**
```r
source("run.R")
```

## 📁 Project Structure
[ASCII tree of key directories and files]

## 🔬 Analysis Workflow
[Numbered steps for running analysis]

## 💻 System Requirements
- **R**: Version X.X.X or higher
- **Platform**: Windows, macOS, or Linux  
- **Memory**: XGB RAM recommended
- **Disk Space**: XGB for packages and outputs

## 📦 Dependencies
[Package management approach]

## 🔄 Reproducibility
[Environment and reproducibility details]

## 🤝 For Collaborators
[Setup instructions for new users]

## 📧 Contact
For questions about the analysis:
- **Author**: Joshua Preston (joshua.preston@emory.edu)
- **ORCID**: [0000-0001-9834-3017](https://orcid.org/0000-0001-9834-3017)
- **Institution**: Emory University

## 📄 License
[License information]
```

### Content Guidelines
- **Title**: Project name + brief descriptive phrase
- **Citation placeholder**: Include even if not yet published
- **One-command setup**: Always provide single entry point (`run.R`)
- **Project structure**: ASCII tree showing key files/directories
- **System requirements**: Specific R version, memory, disk space
- **Contact info**: Include ORCID for academic credibility
- **Emojis**: Use consistently for visual scanning (📖📁🔬💻📦🔄🤝📧📄)

### Reproducibility Section Requirements
- Dependency management approach (DESCRIPTION file)
- Configuration management (YAML files)
- Cross-platform compatibility notes
- Container support if available

## Special Commands
- **CC** (Comment Clean): Clean and update entire code/document to conform exactly to these rules, removing all blank lines and fixing comment hierarchy
- **YAML** (Extract Config): Extract hardcoded values to config.yaml structure
- **MOD** (Modularize): Break monolithic code into appropriate utility functions and scripts
- **README** (Generate README): Create complete README.md following the template structure with project-specific details
