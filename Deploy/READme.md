# Deploy - Docker compose and Helper Scripts for BIDSme

This folder contains the files necessary to orchestrate and run the BIDSme container using Docker Compose and helper scripts.

## Contents

- `docker-compose.yml` — defines the service configuration, volume mounts, and environment variables.
- `bidsme-prepare.sh` — helper script to simplify running the BIDSme prepare command inside the container.

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed separately if not bundled with Docker ([Install Docker Compose](https://docs.docker.com/compose/install/))
- The working directory **must contain the following folders**:
  - `rawdata/` — original source files
  - `prepared/` — files that are ready to be BIDSified
  - `bidsified/` — files that have already been BIDSified
  - `configuration/` — configuration files and plugins

> You can rename these folders as you wish to fit your project structure.  
> However, if you do so, **make sure to update the corresponding folder paths** in this repository (e.g., in the `docker-compose.yml` file or helper scripts) to ensure everything works as expected.

## Building with Docker Compose 
1. **Clone this repository**:

```bash
git clone https://github.com/CyclotronResearchCentre/BIDSme_containerisation.git
cd BIDSme_containerisation
```

2. **Export yout user and group ID to avoid root-owned files** :
```bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
```
3. Export the BIDSme version (fetched form the official repository):
```bash
export BIDSME_VERSION=$(curl -s https://raw.githubusercontent.com/CyclotronResearchCentre/bidsme/dev/bidsme/version.txt)
```

4. **Build the Docker image using Docker Compose** :

```bash
docker compose build 
```
### Usage

You can run the container with `docker compose run` command 

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
