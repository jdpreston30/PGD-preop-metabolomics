# Dockerfile for Reproducible R Environment
# For maximum reproducibility across different systems
# R version 4.5.1 (2025-06-13)

FROM rocker/r-ver:4.5.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libgit2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
WORKDIR /analysis
COPY DESCRIPTION .
COPY R/ R/
COPY All_Run/ All_Run/
COPY Databases/ Databases/
COPY Outputs/ Outputs/
COPY ["Supporting Information/", "Supporting Information/"]

# Install R packages
RUN Rscript -e "install.packages('remotes')"
RUN Rscript -e "remotes::install_deps('.', dependencies = TRUE)"
RUN Rscript -e "tinytex::install_tinytex()"

# Default command runs the full pipeline
CMD ["Rscript", "All_Run/run.R"]