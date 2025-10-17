# Postoperative Primary Graft Dysfunct## 🔬 Analysis Workflow

1. **Run complete analysis**: `source("run.R")`
2. **View results**: Check `Outputs/` directory
3. **Individual components**: Source specific scripts from `R/Scripts/`etabolomics Analysis

**Reproducible analysis code for academic publication**

## 📖 Citation

This code is associated with the analysis presented in the following manuscript:
> [Preston et al. (2025). PENDING. *PENDING*. DOI: xxx]

## 🚀 Quick Start for Reproduction

**One command to reproduce all results:**

```r
source("run.R")
```

This will:
1. Set up the analysis environment
2. Load all configurations and dependencies
3. Execute the complete analysis pipeline

## 📁 Project Structure

```
├── DESCRIPTION              # Package dependencies (R standard)
├── config.yaml             # Analysis settings and paths
├── run.R                   # Main analysis execution script
├── R/
│   ├── Scripts/
│   │   ├── setup.R         # Environment configuration  
│   │   └── 01_analysis.R   # Main analysis scripts
│   └── Utilities/          # Custom functions
├── Data/                   # Raw data files
└── Outputs/               # Generated results
```

## � Analysis Workflow

1. **Setup environment**: `source("setup.R")`
2. **Run analysis**: `source("R/Scripts/01_analysis.R")`
3. **View results**: Check `Outputs/` directory

## 💻 System Requirements

- **R**: Version 4.0.0 or higher
- **Platform**: Windows, macOS, or Linux
- **Memory**: 8GB RAM recommended
- **Disk Space**: 2GB for packages and outputs

## 📦 Dependencies

All package dependencies are managed automatically:

- **Core packages**: Listed in `DESCRIPTION`
- **Environment setup**: Managed via environment setup scripts
- **Bioconductor**: Automatic installation
- **Custom packages**: From GitHub repositories

## 🔄 Reproducibility

This project ensures reproducible analysis through:

- **Dependency management**: `DESCRIPTION` file lists all required packages
- **Configuration-driven**: All paths and parameters in `config_dynamic.yaml`
- **Cross-platform**: Works on Windows, macOS, Linux
- **Containerization**: Dockerfile provided for complete environment isolation

## 🤝 For Collaborators

1. Clone this repository
2. Install R packages: `install.packages(readLines("DESCRIPTION")[grep("Imports:", readLines("DESCRIPTION")):length(readLines("DESCRIPTION"))])`
3. Run analysis: `source("run.R")`

## 📧 Contact

For questions about the analysis:
- **Author**: Joshua Preston (joshua.preston@emory.edu)
- **ORCID**: [0000-0001-9834-3017](https://orcid.org/0000-0001-9834-3017)
- **Institution**: Emory University

## 📄 License

This code is available under the MIT License. See LICENSE file for details.
