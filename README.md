# BIDSme Containerization Project

This repository contains all the files and configurations necessary to containerize the BIDSme project using Docker and Docker Compose. The goal is to provide a reproducible and portable environment for the BIDSme application, facilitating deployment and development.

## Project Overview

BIDSme is a tool designed to simplify working with BIDS-formatted neuroimaging datasets. Containerizing the project ensures that all dependencies and environments are consistent across different machines and platforms.

## Repository Structure

- `build/`  
  Contains Docker-related files, including the Dockerfile and entrypoint script necessary to build the BIDSme Docker image.

- `deploy/`  
  Contains deployment-related files such as `docker-compose.yml` and helper scripts like `bidsme-prepare.sh` to facilitate container orchestration and common workflows.

- `notebooks/` 
Contains Jupyter notebooks used as interactive interfaces for data processing and analysis in both development and production modes. These notebooks are designed to be mounted inside the container to allow for live editing and persistence of changes.

## Getting Started

Please refer to the README files inside the `build/` and `deploy/` folders for detailed instructions on building the Docker image and deploying the container respectively.

---

For more information about the BIDSme project itself, visit the [BIDSme GitHub repository](https://github.com/CyclotronResearchCentre/BIDSme).
