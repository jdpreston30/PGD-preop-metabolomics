# Recipient Plasma Metabolomics as a Predictor of Heart Transplant Severe Primary Graft Dysfunction

**Reproducible analysis code for academic publication**

## 📖 Citation

This code is associated with the analysis presented in the following manuscript:
> Preston et al. (2025). Recipient Plasma Metabolomics as a Predictor of Heart Transplant Severe Primary Graft Dysfunction. *American Journal of Transplantation*. (Submitted)

## 🚀 Quick Start for Reproduction

### Option 1: Using Docker (Recommended for Exact Reproducibility)

**Prerequisites**: 
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
- (Optional) Create free [Docker Hub](https://hub.docker.com) account

#### Method A: Pull Pre-built Image (Fastest - Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/jdpreston30/PGD-preop-metabolomics.git
cd PGD-preop-metabolomics

# 2. Pull the pre-built Docker image (~5-10 minutes)
docker pull jdpreston30/pgd-preop-metabolomics:latest

# 3. Run the complete analysis pipeline
docker run -v $(pwd):/analysis jdpreston30/pgd-preop-metabolomics:latest
```

#### Method B: Build Image Locally

```bash
# 1. Clone the repository
git clone https://github.com/jdpreston30/PGD-preop-metabolomics.git
cd PGD-preop-metabolomics

# 2. Build the Docker image from Dockerfile (~30-45 minutes)
docker build -t pgd-metabolomics .

# 3. Run the complete analysis pipeline
docker run -v $(pwd):/analysis pgd-metabolomics
```

#### What's Included

The Docker container provides a completely isolated, reproducible environment with:
- **R 4.5.1** (2025-06-13) with all required packages at pinned versions
- **Package management**: Uses `renv` to lock exact versions of 211 R packages
- **Bioconductor**: Version 3.21 packages (mixOmis, xcms, CAMERA, etc.)
- **System dependencies**: Ghostscript, ImageMagick, Pandoc, TinyTeX/LaTeX, GraphViz, GDAL
- **Guaranteed identical results** regardless of host system or when the analysis is run
- **Key package versions**: mixOmics 6.32.0, igraph 2.1.4, ggplot2 3.5.2, ggraph 2.2.2, xcms (see `renv.lock` for complete list)
- **Automatic package loading**: All dependencies from `DESCRIPTION` loaded automatically via helper functions

All outputs (figures, tables, pathway results) will be saved to your local workspace.

#### Testing the Container

To verify the Docker image was built correctly before running the full analysis:

```bash
# Quick verification (< 1 minute)
docker run --rm pgd-metabolomics Rscript -e "packageVersion('xcms'); packageVersion('mixOmics')"
```

This should display package versions. If it succeeds, the container is ready for the full analysis.

#### Troubleshooting

**Build fails or is very slow**: 
- This is normal for the first build (30-45 minutes) due to compiling complex packages like xcms
- If build is interrupted, run `docker build` again - it will resume from where it stopped

**"No space left on device" error**:
- The final image is ~3-5 GB
- Check available disk space: `docker system df`
- Clean up old images: `docker image prune`

**Container runs but produces no output**:
- Check the Outputs directory exists and is writable
- Verify the mount path: `ls Outputs/`

### Option 2: Manual Installation (Without Docker)

**Prerequisites**: 
- R >= 4.5.1
- Git (to clone repository)

**Note**: This project uses `renv` for package management to ensure reproducibility. The `renv.lock` file contains exact versions of all packages used in the manuscript.

```r
# 1. Clone the repository
# (from terminal)
git clone https://github.com/jdpreston30/PGD-preop-metabolomics.git
cd PGD-preop-metabolomics

# 2. Start R in the project directory
# (renv automatically activates via .Rprofile)

# 3. Restore all packages at exact versions (first time only, ~10-20 minutes)
renv::restore()

# 4. Check system dependencies
source("R/Utilities/Helpers/check_system_dependencies.R")
check_system_dependencies()

# 5. Run the complete analysis pipeline
source("All_Run/run.R")
```

**What happens during `renv::restore()`**:
- Installs 211 R packages at exact versions from `renv.lock`
- Installs CRAN packages (e.g., ggplot2, dplyr, broom, conflicted)
- Installs Bioconductor 3.21 packages (e.g., xcms, mixOmics, CAMERA)
- Installs GitHub packages (TernTablesR, MetaboAnalystR)
- Creates isolated project library (doesn't affect your system R packages)
- Only needed once per computer; subsequent runs use installed packages
- Packages are automatically loaded from `DESCRIPTION` file during pipeline execution

## 📁 Project Structure

```
├── DESCRIPTION              # R package dependencies (CRAN, Bioconductor, GitHub)
├── Dockerfile              # Docker container for reproducible environment
├── All_Run/
│   ├── config_dynamic.yaml # Analysis configuration and parameters
│   └── run.R              # Main pipeline execution script
├── R/
│   ├── Scripts/           # Analysis workflow scripts (00a-09)
│   └── Utilities/         # Custom analysis functions
│       ├── Analysis/      # Statistical and pathway analysis
│       ├── Helpers/       # Utility functions
│       ├── Preprocessing/ # Data preprocessing
│       └── Visualization/ # Plotting functions
├── Databases/             # Reference databases (IROA, MetaboAnalyst)
├── Outputs/              # Generated results
│   ├── Figures/          # Publication figures (PDF, EPS, PNG)
│   ├── Tables/           # Result tables
│   └── mummichog/        # Pathway enrichment results
└── Supporting Information/ # Supplementary materials and methods
```

## 🔬 Analysis Workflow

The complete pipeline executes in sequence:

1. **00a-00d**: Environment setup, clinical metadata, feature tables
2. **01**: Clustering analysis (PCA, metabolite grouping)
3. **02**: Pathway enrichment (mummichog analysis)
4. **03**: Annotated bar plots
5. **04**: Assignment plots
6. **05**: Render final figures (PDF, EPS)
7. **06**: Generate results tables
8. **07**: Additional analyses
9. **08**: Supporting information document
10. **09**: Session information (documents final package versions)

## 💻 System Requirements

### Computational Requirements
- **R**: Version 4.5.1 or higher
- **Platform**: Developed on macOS but should work well on Windows or Linux
- **Note**: Standard modern computer sufficient; no special hardware required

### System Dependencies
- **Ghostscript**: PDF to EPS conversion
- **Pandoc**: R Markdown rendering
- **ImageMagick**: Image processing
- **TinyTeX/LaTeX**: PDF generation

*Note: All system dependencies are automatically installed in the Docker container. For manual installation, run `check_system_dependencies()` for platform-specific instructions.*

## 📦 Package Dependencies

All R package dependencies are specified in `DESCRIPTION`. Key packages include:

### CRAN Packages (~60 packages)
- **Data manipulation**: tidyverse (dplyr, tidyr, purrr, readr, etc.)
- **Visualization**: ggplot2, ggraph, patchwork, Cairo, magick
- **Statistical modeling**: mixOmics, caret, randomForest, e1071
- **Reporting**: rmarkdown, knitr, officer, flextable

### Bioconductor Packages (Bioconductor 3.21)
- **Metabolomics workflow**: xcms, CAMERA, MSnbase
- **Pathway analysis**: fgsea, globaltest, GlobalAncova
- **Network analysis**: RBGL
- **Data structures**: BiocParallel, multtest

### GitHub Packages
- `jdpreston30/TernTablesR`: Epidemiologic statistics and tables
- `xia-lab/MetaboAnalystR`: Metabolomics analysis and pathway enrichment

*See `DESCRIPTION` file for complete list of all dependencies.*

## 🔄 Reproducibility Features

This project implements best practices for computational reproducibility:

- ✅ **Version Control**: Complete analysis code on GitHub
- ✅ **Package Management**: `renv` with `renv.lock` pinning all 211 packages to exact versions
- ✅ **Dependency Declaration**: All dependencies specified in `DESCRIPTION` with automatic loading
- ✅ **Containerization**: Docker image (R 4.5.1, Bioconductor 3.21) available at `jdpreston30/pgd-preop-metabolomics:latest`
- ✅ **Conflict Resolution**: `conflicted` package ensures predictable function behavior
- ✅ **Docker Hub Distribution**: Pre-built image available at [jdpreston30/pgd-preop-metabolomics](https://hub.docker.com/r/jdpreston30/pgd-preop-metabolomics)
- ✅ **Configuration-Driven**: All parameters in `config_dynamic.yaml`
- ✅ **System Dependency Checking**: Automated validation via `check_system_dependencies()`
- ✅ **Documentation**: Comprehensive function documentation and workflow comments
- ✅ **Session Info**: Timestamped session information in `session_info.txt` documents exact package versions

## 🤝 For Reviewers & Collaborators

**Easiest reproduction method**: Pull the pre-built Docker image from Docker Hub (Option 1A above). This ensures you have the exact same computational environment used to generate all manuscript results.

### Quick Verification (5 minutes)
```bash
# Clone, pull image, and verify it works
git clone https://github.com/jdpreston30/PGD-preop-metabolomics.git
cd PGD-preop-metabolomics
docker pull jdpreston30/pgd-preop-metabolomics:latest
docker run --rm jdpreston30/pgd-preop-metabolomics:latest Rscript -e "packageVersion('igraph')"
# Should output: [1] '2.1.4'
```

### Full Analysis Run (~10-30 minutes)
```bash
docker run -v $(pwd):/analysis jdpreston30/pgd-preop-metabolomics:latest
```

If you encounter any issues:
1. Verify Docker Desktop is installed and running
2. Ensure you're in the repository root directory
3. Check that output directories exist and are writable
4. Review Docker logs: `docker logs <container-id>`

For questions or issues, please open a GitHub issue or contact the corresponding author.

## 📧 Contact

**Corresponding Author**: Joshua D. Preston
- **Email**: joshua.preston@emory.edu  
- **ORCID**: [0000-0001-9834-3017](https://orcid.org/0000-0001-9834-3017)  
- **Institution**: Department of Surgery, Emory University School of Medicine

---

**Repository**: https://github.com/jdpreston30/PGD-preop-metabolomics
