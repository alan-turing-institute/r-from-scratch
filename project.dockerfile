FROM r-base:3.5.1

# install R, and setup CRAN mirror
RUN apt-get update && apt-get install -y software-properties-common pandoc gnupg
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile

# install needed R packages

RUN Rscript -e "install.packages('shiny')"
RUN Rscript -e "install.packages('shinythemes')"
RUN Rscript -e "install.packages('ggplot2')"
RUN Rscript -e "install.packages('learnr')"

RUN Rscript -e "install.packages('tools')"
RUN Rscript -e "install.packages('rmarkdown')"

ADD . LearnRWebApp
WORKDIR LearnRWebApp

# azure config
ENV AZURE_STORAGE_ACCOUNT rshinytest16102018
ENV AZURE_STORAGE_ACCESS_KEY haFJsUOeYbeW+MOrv47OJu0aSw0BsHTuJ4ZU9wvOLrm3LKynmZrIKsDMZ2PISUA81LS4FeAXds67PhBUG9oxkw==
ENV AZURE_CONTAINER rshinytest16102018container

# expose R Shiny port
EXPOSE 1111

CMD ["./shiny.sh"]
