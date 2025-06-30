# BIDSme Containerization Project

This repository contains all the files and configurations necessary to containerize the BIDSme project using Docker and Docker Compose. The goal is to provide a reproducible and portable environment for the BIDSme application, facilitating deployment and development.

## Project Overview

BIDSme is a tool designed to simplify working with BIDS-formatted neuroimaging datasets. Containerizing the project ensures that all dependencies and environments are consistent across different machines and platforms.

## Repository Structure

- `Docker/`  
  Contains Docker-related files including the `Dockerfile`, `docker-compose.yaml`, `.dockerignore`, and helper scripts.

## Getting Started

### Prerequisites

- Docker installed on your machine ([Get Docker](https://docs.docker.com/get-docker/))  
- Docker Compose (usually included with Docker Desktop)
  
Additionally, ensure that your working directory contains the following four folders:

- `rawdata/` — contains the original source files.  
- `prepared/` — contains files that are ready to be BIDSified.  
- `bidsified/` — contains files that have already been BIDSified.  
- `configuration/` — contains configuration files and additional plugins.

### Setup and Building the Docker Image

1. First, clone this repository into your working directory:

```bash
git clone https://github.com/CyclotronResearchCentre/BIDSme_containerisation.git
cd BIDSme_containerisation/Docker
```
2. Then, build the docker image from the Docker folder

```bash
docker compose run –rm -it bidsme 
```

## Usage 
Once the container is running, you can use BIDSme functionalities inside the container environment, ensuring all dependencies are met.

