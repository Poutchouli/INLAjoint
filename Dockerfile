# Use official R image with Shiny
FROM rocker/shiny:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    libmariadb-dev \
    libsqlite3-dev \
    pandoc \
    pandoc-citeproc \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /srv/shiny-server

# Copy R package files
COPY . /tmp/INLAjoint

# Install R dependencies
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'plotly', 'RPostgreSQL', 'RMySQL', 'RSQLite', 'readr', 'readxl', 'devtools', 'remotes'), repos='https://cloud.r-project.org/')"

# Install INLA
RUN R -e "install.packages('INLA', repos=c(getOption('repos'), INLA='https://inla.r-inla-download.org/R/testing'), dep=TRUE)"

# Install the INLAjoint package from local source
RUN R -e "devtools::install_local('/tmp/INLAjoint', dependencies=TRUE)"

# Copy Shiny app
COPY docker-app/ /srv/shiny-server/

# Make sure the app has the right permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Expose port
EXPOSE 3838

# Start Shiny Server
CMD ["/usr/bin/shiny-server"]
