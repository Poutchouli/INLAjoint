# Use official R image with Shiny
FROM rocker/shiny:4.3.0

# Install system dependencies including curl and unzip for downloading INLAjoint source
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    libmariadb-dev \
    libsqlite3-dev \
    pandoc \
    pandoc-citeproc \
    curl \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /srv/shiny-server

# Copy R package files
COPY . /tmp/INLAjoint

# Install R dependencies
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'plotly', 'RPostgreSQL', 'RMySQL', 'RSQLite', 'readr', 'readxl', 'devtools', 'remotes'), repos='https://cloud.r-project.org/')"

# Install INLA (with fallback if it fails)
RUN R -e "tryCatch(install.packages('INLA', repos=c(getOption('repos'), INLA='https://inla.r-inla-download.org/R/testing'), dep=TRUE), error=function(e) cat('INLA installation failed, will use enhanced loader:', e$message, '\n'))"

# Try to install the INLAjoint package from local source (with fallback)
RUN R -e "tryCatch(devtools::install_local('/tmp/INLAjoint', dependencies=TRUE), error=function(e) cat('INLAjoint installation failed, will use enhanced loader:', e$message, '\n'))"

# Download INLAjoint source code for enhanced loader
RUN cd /srv/shiny-server && \
    curl -L -o main.zip https://github.com/DenisRustand/INLAjoint/archive/refs/heads/main.zip && \
    unzip main.zip && \
    mv INLAjoint-main INLAjoint-source && \
    rm main.zip && \
    echo "INLAjoint source downloaded and extracted successfully"

# Copy Shiny app
COPY docker-app/ /srv/shiny-server/

# Verify enhanced loader setup
RUN cd /srv/shiny-server && \
    ls -la utils/enhanced_inlajoint.R && \
    ls -la INLAjoint-source/R/ && \
    echo "Enhanced loader setup verified"

# Set up enhanced startup script
RUN chmod +x /srv/shiny-server/start_enhanced.sh

# Make sure the app has the right permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Expose port
EXPOSE 3838

# Start with enhanced startup script
CMD ["/srv/shiny-server/start_enhanced.sh"]
