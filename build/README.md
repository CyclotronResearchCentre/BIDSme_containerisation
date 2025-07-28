# Build - Docker Image for BIDSme

This folder contains the Dockerfile and the entrypoint script used to build the BIDSme Docker image.

## Contents

- `Dockerfile` — defines the environment and installation steps for BIDSme.  
- `entrypoint.sh` — script that manages container entrypoint logic and command routing.  
- `build.sh` — helper script to automatically fetch the current BIDSme version and build the Docker image with the correct tag.
- `init_bidsme_lab.py` - initialization script automatically loaded when JupyterLab is launched, which prepares paths and settings depending on the mode (dev or prod).


## Getting Started

### Prerequisites

- Docker installed on your machine ([Get Docker](https://docs.docker.com/get-docker/))
- The working directory must contain the following folders - with a suffix specifying the chosen mode (`_dev`) or (`_prod`), whether you wish to wrok in production or development mode:
  - `rawdata_<mode>/` — original source files
  - `prepared_<mode>/` — files that are ready to be BIDSified
  - `bidsified_<mode>/` — files that have already been BIDSified
  - `configuration/` — configuration files and plugins
 
You can rename these folders as you wish to fit your project structure.
However, if you do so, make sure to update the corresponding folder paths accordingly in all relevant files in this repository — such as in the `docker-compose.yml`, volume mounts, `init_bidsme_lab.py` and any helper scripts — to ensure proper functionality.

### Setup and Building the Docker Image

1. **Clone this repository**:

```bash
git clone https://github.com/CyclotronResearchCentre/BIDSme_containerisation.git
cd BIDSme_containerisation
```

2. **Build the Docker image :
You have two options to build the Docker image:
- Manual build: (You need to update the version tag yourself)
```bash
docker build -t bidsme .
```
- Automated build with version tagging:
Use the provided `build.sh ` script which fetches the latest BIDSme version form the GitHub repository and build the Docker image with that version tag automatically.
```bash
./build.sh
```

## Usage 
You can use the container in different ways by using the docker run comand directly, but in this case you must manually mount the required folders using the -v flag :


- Interactive mode
```bash
docker run -it \
  -v "$PWD/rawdata_prod:/mnt/rawdata:ro" \
  -v "$PWD/prepared_prod:/mnt/prepared" \
  -v "$PWD/bidsified_prod:/mnt/bidsified" \
  -v "$PWD/configuration:/mnt/configuration" \
  bidsme:<version>
```

- Run BIDSme prepare
```bash
docker run \
  -v "$PWD/rawdata_prod:/mnt/rawdata:ro" \
  -v "$PWD/prepared_prod:/mnt/prepared" \
  -v "$PWD/bidsified_prod:/mnt/bidsified" \
  -v "$PWD/configuration:/mnt/configuration" \
  bidsme:<version> prepare <options>
```

Replace `_prod` by `_dev` if needed.

- Launch JupyterLab (http://localhost:8888)
```bash
docker run \
  -v "$PWD/rawdata_prod:/mnt/rawdata:ro" \
  -v "$PWD/prepared_prod:/mnt/prepared" \
  -v "$PWD/bidsified_prod:/mnt/bidsified" \
  -v "$PWD/configuration:/mnt/configuration" \
  -p 8888:8888 \
  bidsme:<version> lab prod
```
To use development mode instead: 
```bash
docker run \
  -v "$PWD/rawdata_dev:/mnt/rawdata:ro" \
  -v "$PWD/prepared_dev:/mnt/prepared" \
  -v "$PWD/bidsified_dev:/mnt/bidsified" \
  -v "$PWD/configuration:/mnt/configuration" \
  -p 8888:8888 \
  bidsme:<version> lab dev
```

When launching JupyterLab with `lab`, the container runs the `init_bidsme_lab.py` script automatically.
This script : 
- Detects the mode (`dev` or `prod`) from the command line.
- Sets up the appropriate paths inside the container (/mnt/rawdata_prod, etc.).
- Validates the presence of expected folders.
- Automatically add the corresponding Jupyter Notebooks when Lab starts. 


### Installing Python packages with pip inside the Container
You can install additionnal Python packages inside the container using `pip`, and they will persist as long as you reuse the same container (i.e., you do not delete or recreate it).

This applies both when using the container via terminal or from within jupyterLab notebooks. 

**Example (from Terminal)**

After running your container and installing your module :
```bash
pip install random_module
```
Next time you restart the same container : 
```bash
docker start -ai <container_ID>
```
The package will still be available.
(To see your container ID juste use the `docker ps -a` command.

This principle also applies to Jupyter Notebooks.

## Documentation 

For more details on BIDSme usage and features, visit the [BIDSme GitHub repository](https://github.com/CyclotronResearchCentre/BIDSme).

The default Jupyter notebooks used for both development and production modes are maintained separately and can be found in the [bidsme-template](github.com/CyclotronResearchCentre/bidsme-template/tree/main/notebook) repository.
Feel free to adapt or replace them according to your needs.

