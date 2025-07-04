# BIDSme Containerization Project

This repository contains all the files and configurations necessary to containerize the BIDSme project using Docker and Docker Compose. The goal is to provide a reproducible and portable environment for the BIDSme application, facilitating deployment and development.

## Project Overview

BIDSme is a tool designed to simplify working with BIDS-formatted neuroimaging datasets. Containerizing the project ensures that all dependencies and environments are consistent across different machines and platforms.

## Repository Structure

- `Docker/`  
  Contains Docker-related files including the `Dockerfile`, `docker-compose.yaml`, `.dockerignore`, and other scripts.

## Getting Started

### Prerequisites

- Docker installed on your machine ([Get Docker](https://docs.docker.com/get-docker/))  
- The working directory must contain the following folders:
  - `bidsme/` — clone of the [BIDSme app](https://github.com/CyclotronResearchCentre/BIDSme)
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

- Interactive mode:

```bash
docker compose run -it bidsme 
```
- Run BIDSme prepare command directly to quickly initialize your data processing:

```bash
docker compose run bidsme prepare <options>
```
- Run Jupyter Lab inside the container:
- 
```bash
docker compose run --service-ports bidsme lab
```

