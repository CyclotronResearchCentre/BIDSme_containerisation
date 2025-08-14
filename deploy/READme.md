# Deploy - Docker compose and Helper Scripts for BIDSme

This folder contains the files necessary to orchestrate and run the BIDSme container using Docker Compose and helper scripts.

## Contents

- `docker-compose-dev.yaml` — Docker Compose configuration for development mode.
- `docker-compose-prod.yaml` — Docker Compose configuration for production mode.
- `bidsme-prepare.sh` — helper script to simplify running the BIDSme prepare command inside the container.

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed separately if not bundled with Docker ([Install Docker Compose](https://docs.docker.com/compose/install/))
- The working directory **must contain the following folders** (adapted to the chosen mode):
  - `rawdata_<mode>/` — original source files
  - `prepared_<mode>/` — files that are ready to be BIDSified
  - `bidsified_<mode>/` — output BIDSified files
  - `configuration/` — configuration files and plugins

> Replace `<mode>` with either `dev` or `prod` depending on the use case.  
> If you rename these folders, update the names accordingly in the compose files and in the `init_bidsme_lab.py` file.

#### Expected Structure of the `configuration/` Folder
The `configuration/` folder contains BIDSme configuration files, plugins, and templates. When the container starts:

  - If `mnt/configuration/` is empty, the container automatically clones the default template from GitLab : (BIDSme Configuration Template)[https://gitlab.uliege.be/CyclotronResearchCentre/Public/bidstools/bidsme/bidsification-template]
  - If `mnt/configuration/` already contains files, the container leaves them untouched.

The recommended structure looks like this 
```pgsql
configuration/   # Custom lists for participants, sessions, etc.
├── lists/
├── map/         # Mapping configuration for BIDS conversion
├── notebook/
├── plugin/      # Optional BIDsme plugin
└── template/    # Participant template for BIDSification
```

> This is the default recommended structure.
> However, ot can be adjusted to your needs - just ensure you update the paths and logic accordingly in the `init_bidsme_lab.py` script, which loads these files when launching JupyterLab.
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

3. **Choose your usage mode (`dev` or `prod`)** :
   
**Run JupyterLab (recommended interface) :**

```bash
docker compose -f docker-compose-dev.yaml run -p 8888:8888 bidsme lab
# or
docker compose -f docker-compose-prod.yaml run -p 8888:8888 bidsme lab
```
Then open your browser and go to [http://localhost:8888](http://localhost:8888).
The appropriate notebook will be auto-selected by `init_bidsme_lab.py`.

**Run BIDSme `prepare` directly :**

```bash
docker compose -f docker-compose-dev.yaml run bidsme prepare <options>
# or
docker compose -f docker-compose-prod.yaml run bidsme prepare <options>
```
**Run BIDSme in CLI mode :**

```bash
docker compose -f docker-compose-dev.yaml run -it bidsme 
# or
docker compose -f docker-compose-prod.yaml run -it bidsme 
```

**To clean up the containers :**
```bash
docker compose -f docker-compose-prod.yaml down
# or
docker compose -f docker-compose-dev.yaml down
```
## Documentation 
For more details on BIDSme usage and features, visit the [BIDsme GitHub repository](https://github.com/CyclotronResearchCentre/bidsme)

Default Jupyter notebooks (for dev and prod) can be found in the [bidsme-template repository](https://github.com/CyclotronResearchCentre/bidsme-template/tree/main/notebook)
