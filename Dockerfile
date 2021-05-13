FROM openanalytics/r-base

MAINTAINER Tobias Verbeke "tobias.verbeke@openanalytics.eu"

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

# system library dependency for the euler app
RUN apt-get update && apt-get install -y \
    libmpfr-dev \
    && rm -rf /var/lib/apt/lists/*

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'rmarkdown'))"

# install dependencies of the euler app
RUN R -e "install.packages(c('Rmpfr','lubridate','PerformanceAnalytics','quantmod','tidyquant','readxl', 'forecast','ggthemes','teries','lubridate','timetk','scales','rlang','sweep','broom','tibble','stringr','highcharter','knitr','quantmod','shinythemes','ggforce','ggplot2'))"

# copy the app to the image
RUN mkdir /root/euler
COPY euler /root/euler

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/euler')"]
