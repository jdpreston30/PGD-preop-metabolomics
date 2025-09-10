# Postoperative Primary Graft Dysfunction Metabolomics Analysis

**Reproducible analysis code for academic publication**

## 📖 Citation

If you use this code, please cite:
> [Author et al. (Year). Title. *Journal*. DOI: xxx]

## 🚀 Quick Start for Reproduction

**One command to reproduce all results:**

```r
source("setup.R")
```

This will:
1. Install all required packages (exact versions)
2. Set up the analysis environment  
3. Load all configurations

## 📁 Project Structure

```
├── DESCRIPTION              # Package dependencies (R standard)
├── renv.lock               # Exact package versions (auto-generated)
├── config.yaml             # Analysis settings and paths
├── setup.R                 # One-command reproducible setup
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
- **Version control**: Managed by `renv`
- **Bioconductor**: Automatic installation
- **Custom packages**: From GitHub repositories

## 🔄 Reproducibility

This project uses `renv` for reproducible package management:

- **Exact versions**: `renv.lock` captures all package versions
- **Isolated environment**: Won't affect other R projects
- **Cross-platform**: Works on Windows, macOS, Linux

## 🤝 For Collaborators

1. Clone this repository
2. Run `source("setup.R")`
3. All dependencies will be installed automatically

## 📧 Contact

For questions about the analysis:
- **Author**: Joshua Preston (joshua.preston@emory.edu)
- **ORCID**: [0000-0001-9834-3017](https://orcid.org/0000-0001-9834-3017)
- **Institution**: Emory University

## 📄 License

This code is available under the MIT License. See LICENSE file for details.
