# Dockerfile for Reproducible R Environment
# For maximum reproducibility across different systems

FROM rocker/r-ver:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
WORKDIR /analysis
COPY DESCRIPTION .
COPY R/ R/
COPY config.yaml .

# Install R packages
RUN Rscript -e "install.packages('remotes')"
RUN Rscript -e "remotes::install_deps('.', dependencies = TRUE)"

# Default command
CMD ["R"]