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

# Set up renv for exact package restoration
RUN Rscript -e "install.packages('renv', repos='https://cloud.r-project.org')"

# Copy project files
WORKDIR /analysis
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Restore R packages from renv.lock (this captures exact versions from laptop)
RUN Rscript -e "renv::restore()"

# Copy remaining project files after package installation
COPY DESCRIPTION .
COPY R/ R/
COPY All_Run/ All_Run/
COPY Databases/ Databases/
COPY Outputs/ Outputs/
COPY ["Supporting Information/", "Supporting Information/"]

# Install tinytex for PDF generation
RUN Rscript -e "tinytex::install_tinytex()"
ENV PATH="${PATH}:/root/bin"

# Verify key packages are installed with correct versions
RUN Rscript -e "cat('Installed package versions:\n'); \
    cat('  igraph:', as.character(packageVersion('igraph')), '\n'); \
    cat('  ggplot2:', as.character(packageVersion('ggplot2')), '\n'); \
    cat('  ggraph:', as.character(packageVersion('ggraph')), '\n'); \
    cat('  mixOmics:', as.character(packageVersion('mixOmics')), '\n'); \
    cat('  xcms:', as.character(packageVersion('xcms')), '\n')"

# Default command runs the full pipeline
CMD ["Rscript", "All_Run/run.R"]