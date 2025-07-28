# Deploy - Docker compose and Helper Scripts for BIDSme

This folder contains the files necessary to orchestrate and run the BIDSme container using Docker Compose and helper scripts.

## Contents

- `docker-compose.yml.template` — template file used to generate the final Docker Compose file depending on the selected mode (`dev` or `prod`).
- `bidsme-prepare.sh` — helper script to simplify running the BIDSme prepare command inside the container.
-  `launch.sh` - main launcher script that automatically configures the environment and launches BIDSme in JupyterLab.

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed separately if not bundled with Docker ([Install Docker Compose](https://docs.docker.com/compose/install/))
- The working directory **must contain the following folders** (adapted to the chosen mode):
  - `rawdata_<mode>/` — original source files
  - `prepared_<mode>/` — files that are ready to be BIDSified
  - `bidsified_<mode>/` — output BIDSified files
  - `configuration/` — configuration files and plugins

> Replace `<mode>` with either `dev` or `prod` depending on the use case.  
> If you rename these folders, update the names accordingly in `launch.sh`, `docker-compose.yml.template`, and `init_bidsme_lab.py`.


## Building & Launch with Docker Compose (Recommended) 
1. **Clone this repository**:

```bash
git clone https://github.com/CyclotronResearchCentre/BIDSme_containerisation.git
cd BIDSme_containerisation/deploy
```

2. **Export required environments variables** :
```bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
export BIDSME_VERSION=$(curl -s https://raw.githubusercontent.com/CyclotronResearchCentre/bidsme/dev/bidsme/version.txt)
```

3. **Launch in the desired mode (`dev` or `prod`)** :
This will :
- Generate a docker-compose.generated.yaml file from the template
- Automatically mount the correct folders for the chosen mode
- Start BIDSme in Jupyterlab with the appropriate default notebook

Make sure first that it is executable with the `chmod +x launc.sh` command

```bash
./launch.sh dev
# or
./launch.sh prod
```
JupyterLab will be accessible at:
[http://localhost:8888](http://localhost:8888)

The launched notebook is selected automatically based on the mode, via the `init_bidsme_lab.py` script (inside the build directory).

## Alternative: Manual Use of Docker compose 

You can still use Docker Compose directly by referencing the generated file:  

```bash
docker compose -f docker-compose.generated.yaml run -it bidsme
```
Or to run a specific command like `prepare`:

```bash
docker compose -f docker-compose.generated.yaml run bidsme prepare <options>
```
However, make sure tu run `launch.sh` first to ensure `docker-compose.generated.yaml` is present and up to date.

To clean up the containers :
```bash
docker compose -f docker-compose.generated.yaml down

```
## Documentation 
For more details on BIDSme usage and features, visit the [BIDsme GitHub repository](https://github.com/CyclotronResearchCentre/bidsme)

Default Jupyter notebooks (for dev and prod) can be found in the [bidsme-template repository](https://github.com/CyclotronResearchCentre/bidsme-template/tree/main/notebook)
