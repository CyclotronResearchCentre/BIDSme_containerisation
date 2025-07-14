# BIDSme Containerization Project

This repository contains all the files and configurations necessary to containerize the BIDSme project using Docker and Docker Compose. The goal is to provide a reproducible and portable environment for the BIDSme application, facilitating deployment and development.

## Project Overview

BIDSme is a tool designed to simplify working with BIDS-formatted neuroimaging datasets. Containerizing the project ensures that all dependencies and environments are consistent across different machines and platforms.

## Repository Structure

- `Docker/`  
  Contains Docker-related files including the `Dockerfile`, `docker-compose.yaml`, `.dockerignore`, and other scripts.
- `rawdata/`, `prepared/`, `bidsified/`, `configuration/`
Data and configuration folders expected to be present at the same level as the Docker files. You may rename the folders as you like — just make sure to update the corresponding volume paths in your docker run or docker-compose commands accordingly.

## Getting Started

### Prerequisites

- Docker installed on your machine ([Get Docker](https://docs.docker.com/get-docker/))  
- The working directory must contain the following folders:
  - `bidsme/` — clone of the [BIDSme app](https://github.com/CyclotronResearchCentre/BIDSme) that you may pull 
  - `rawdata/` — original source files
  - `prepared/` — files that are ready to be BIDSified
  - `bidsified/` — files that have already been BIDSified
  - `configuration/` — configuration files and plugins

### Setup and Building the Docker Image

1. **Clone this repository**:

```bash
git clone https://github.com/CyclotronResearchCentre/BIDSme_containerisation.git
cd BIDSme_containerisation
```
2. **Make sure the folders `bidsme/`, `rawdata/`, `prepared/`, `bidsified/` and `configuration/` are at the same level as the Docker files for volume mounting to work correctly**

3. **Then, build the docker image from the Docker folder** : 

```bash
docker compose build 
```

## Usage 
You can use the container in different ways:

### Option 1 : Using Docker Compose 

It is necessary to use the docker-compose run or docker-compose up command because the volumes are automatically mounted thanks to the docker-compose.yml file.

This option is ideal for development or when working in a local cloned repository.

- Interactive mode:

```bash
docker compose run -it bidsme 
```
- Run BIDSme prepare command directly to quickly initialize your data processing:

```bash
docker compose run bidsme prepare <options>
```
- Run Jupyter Lab inside the container:

```bash
docker compose run -p 8888:8888 bidsme lab
```
Then connect to the JupyterLab interface by opening your browser and navigating to:  
  `http://localhost:8888`  
  (Make sure to use the appropriate token if set)

- To stop and remove the containers :
```bash
docker compose down
```

### Option 2 : Using docker run with mounted folders

It is also possible to use docker run directly, but in this case you must manually mount the required folders using the -v flag:

- Interactive mode
```bash
docker run -it \
  -v "$PWD/rawdata:/mnt/rawdata:ro" \
  -v "$PWD/prepared:/mnt/prepared" \
  -v "$PWD/bidsified:/mnt/bidsified" \
  -v "$PWD/configuration:/mnt/configuration" \
  bidsme
```


- Run BIDSme prepare
```bash
docker run \
  -v "$PWD/rawdata:/mnt/rawdata:ro" \
  -v "$PWD/prepared:/mnt/prepared" \
  -v "$PWD/bidsified:/mnt/bidsified" \
  -v "$PWD/configuration:/mnt/configuration" \
  bidsme prepare
```
- Launch JupyterLab (http://localhost:8888)
```bash
docker run \
  -v "$PWD/rawdata:/mnt/rawdata:ro" \
  -v "$PWD/prepared:/mnt/prepared" \
  -v "$PWD/bidsified:/mnt/bidsified" \
  -v "$PWD/configuration:/mnt/configuration" \
  -p 8888:8888 \
  bidsme lab
```


## Additional Tools 
A small helper script, `bidsme_prepare.sh`, is also provided to simplify runiing the BIDS prepare command inside the container. It wraps the typical `docker run bidsme prepare rawdata/ prepared/` call, so you don't need to manually specify the full command with all the arguments each time. 

## Documentation 

For more details on BIDSme usage and features, visit the [BIDSme GitHub repository](https://github.com/CyclotronResearchCentre/BIDSme).
