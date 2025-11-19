# Dockerfile for Reproducible R Environment
# For maximum reproducibility across different systems
# R version 4.5.1 (2025-06-13)

FROM rocker/r-ver:4.5.1

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# Based on requirements from R/Utilities/Helpers/check_system_dependencies.R
RUN apt-get update && apt-get install -y \
    # Core build tools
    build-essential \
    gfortran \
    # Required system tools (from check_system_dependencies.R)
    ghostscript \
    pandoc \
    pandoc-citeproc \
    imagemagick \
    # XML and networking
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libgit2-dev \
    # Graphics and fonts
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libcairo2-dev \
    libxt-dev \
    # LaTeX/PDF generation dependencies
    wget \
    perl \
    # HDF5 for bioinformatics (MSnbase, xcms)
    libhdf5-dev \
    libnetcdf-dev \
    # Additional dependencies for Bioconductor packages
    libfftw3-dev \
    libgsl-dev \
    libgmp-dev \
    libglpk-dev \
    # GraphViz for network plots
    graphviz \
    libgraphviz-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
WORKDIR /analysis
COPY DESCRIPTION .
COPY NAMESPACE .
COPY R/ R/
COPY All_Run/ All_Run/
COPY Databases/ Databases/
COPY Outputs/ Outputs/
COPY ["Supporting Information/", "Supporting Information/"]

# Install remotes and BiocManager first
RUN Rscript -e "install.packages(c('remotes', 'BiocManager'), repos='https://cloud.r-project.org/')"

# Install Bioconductor packages explicitly (these can fail with remotes::install_deps)
RUN Rscript -e "BiocManager::install(c(\
    'RBGL', 'Rgraphviz', 'fgsea', 'globaltest', 'GlobalAncova', \
    'Rsamtools', 'edgeR', 'siggenes', 'BiocParallel', 'MSnbase', \
    'xcms', 'CAMERA', 'multtest' \
    ), ask=FALSE, update=FALSE)"

# Install GitHub remotes explicitly
RUN Rscript -e "remotes::install_github('jdpreston30/TernTablesR', dependencies=FALSE)"
RUN Rscript -e "remotes::install_github('xia-lab/MetaboAnalystR', dependencies=FALSE)"

# Install remaining CRAN packages from DESCRIPTION
RUN Rscript -e "remotes::install_deps('.', dependencies=TRUE, repos='https://cloud.r-project.org/')"

# Install tinytex for PDF generation
RUN Rscript -e "tinytex::install_tinytex()"
ENV PATH="${PATH}:/root/bin"

# Verify key packages are installed
RUN Rscript -e "packageVersion('MetaboAnalystR')" && \
    Rscript -e "packageVersion('mixOmics')" && \
    Rscript -e "packageVersion('xcms')"

# Default command runs the full pipeline
CMD ["Rscript", "All_Run/run.R"]