# r-from-scratch
LearnR tutorial, and scripts to deploy on the cloud.

# How to run the RShiny app locally

* Modify the LearnR.Rmd file with your tutorial

* Make the file 'shiny.sh' executable: 

```
chmod +x shiny.sh
```
* Run ./shiny.sh

Where shiny.sh file is:

```
#!/bin/bash
Rscript run.R

```

and run.R (the file "LearnR.Rmd" can be any general learnr tutorial markdown, make sure it is in your working directory):

```
rmarkdown::run(file = "LearnR.Rmd",
               shiny_args = list(port = 1111,host = "0.0.0.0"))

```



# How to deploy a R Shiny app on Azure

## Requiremenets

The following instructions assume that you have:

* Docker Hub Account
* Azure subscription 

and locally intsalled:

* Docker
* Azure CLI

## 1. Azure preparation (local machine)

From a command line run the following commands. Values in <> should be replaced with respect to the set up and project description.

### 1.1. Create a new resource group:

```
az group create \
    --name <project-resource-group> \
    --location uksouth
```

### 1.2. Create a storage account:

```
az storage account create \
    --name <project> \
    --resource-group <project-resource-group> \
    --location uksouth \
    --sku Standard_LRS \
	--encryption blob
```

### 1.3. Specify storage account credentials:

#### 1.3.1. First, display your storage account keys:

```
az storage account keys list \
    --account-name <project> \
    --resource-group <project-resource-group> \
    --output table
```

#### 1.3.2. Now, set the AZURE_STORAGE_ACCOUNT and AZURE_STORAGE_ACCESS_KEY environment variables:

```
export AZURE_STORAGE_ACCOUNT=<project>
export AZURE_STORAGE_ACCESS_KEY="<one of the key values from the previous table>"
```

### 1.4. Create a container

```
az storage container create --name <projectcontainer>
```

## 2. Building the docker image (local machine)

### 2.1. Modify the docker file <project.dockerfile>

setting: storage account name, key, and the name of the container.

**project.dockerfile** must include the following lines:

```
ENV AZURE_STORAGE_ACCOUNT <project (from 1.2.)>
ENV AZURE_STORAGE_ACCESS_KEY "<one of the key values from the previous table (from 1.3.1.)>"
ENV AZURE_CONTAINER <projectcontainer (from 1.4.)>
```

An example of a project.dockerfile

```
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
ENV AZURE_STORAGE_ACCOUNT acountname
ENV AZURE_STORAGE_ACCESS_KEY ====key====
ENV AZURE_CONTAINER containername

# expose R Shiny port
EXPOSE 1111

CMD ["./shiny.sh"]

```

### 2.2. Build the image 

```
docker build -t <dockerhub_username>/<project_dashboard>:latest -f <project.dockerfile> .

```

### 2.3. Push the build to docker hub

```
docker push <dockerhub_username>/<project_dashboard>:latest

```

## 3. Configuring Azure (Azure portal)


### 3.1. WebApp

 * Login to the Azure portal https://portal.azure.com
 * On the left hand bar, click "App Services".
 * Click "+ Add" at the top, then choose "Web App", then "Create" on the bottom right.
 * On the "Create" form, choose an app name (e.g. <project>) - this will form the URL for your app, so needs to be unique.  Choose a subscription and Resource Group (creating one if necessary), and for "OS" choose "Docker".  Then click on
 "Configure container".
 * In the "Container Settings" choose "Docker Hub" as the image source, then
 "Public" or "Private" depending on the settings of your docker hub repo.
 (If it is "Private" you will also need to provide your docker hub login details.)
 * Then click "Create" back on the "Web App create" section.  It will take a
 few minutes to deploy, and after that it will be visible from the "App Services" link on the left of the Azure portal.  If you click on the app here you'll
 get the info for it, including the URL, which should be
 https://<project>/azurewebsites.net

### 3.2. Port

 * Finally, we need to configure the app to use the correct port.  Go to
 the "Application Settings" of the app in the Azure portal, click ```+ Add new setting``` and add a setting called ```PORT``` with value ```80:1111```.   Then go back to the "Overview" and restart the app using the button at the top.
 
 * In practice, even after the Azure portal said it was available and healthy,  it can take a long time (about 5 mins) to respond the first time, as the docker image needs to be downloaded and deployed, but after that it should be more responsive.


