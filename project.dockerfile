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
RUN Rscript -e "install.packages('remotes')"
RUN Rscript -e "remotes::install_github('datacamp/testwhat')"

RUN Rscript -e "install.packages('tools')"
RUN Rscript -e "install.packages('rmarkdown')"
RUN Rscript -e "remotes::install_github('alan-turing-institute/r-from-scratch', ref='r-package', subdir='rfromscratch')"

ADD . LearnRWebApp
WORKDIR LearnRWebApp

# azure config
ENV AZURE_STORAGE_ACCOUNT rfromscratch
ENV AZURE_STORAGE_ACCESS_KEY kbKzhNszYXHYX/EQcZYEm+wKdTH++s2ooXI4uKDiAH9bmVblzGgCuB74KDvh1y9pSdvNEbrA/fjO2FcFfuyGBA==
ENV AZURE_CONTAINER rfromscratch-container

# expose R Shiny port
EXPOSE 1111

CMD ["./shiny.sh"]
#CMD ["/bin/bash"]
