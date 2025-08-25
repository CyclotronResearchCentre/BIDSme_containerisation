# Build - Docker Image for BIDSme

This folder contains the Dockerfile and the entrypoint script used to build the BIDSme Docker image.

## Contents

- `Dockerfile` — defines the environment and installation steps for BIDSme.  
- `entrypoint.sh` — script that manages container entrypoint logic and command routing.  
- `build.sh` — helper script to automatically fetch the current BIDSme version and build the Docker image with the correct tag.
- `init_bidsme_lab.py` - initialization script automatically loaded when JupyterLab is launched, which prepares paths and settings depending on the mode (dev or prod).
- `notebooks/` 
Contains Jupyter notebooks used as interactive interfaces for data processing and analysis in both development and production modes. These notebooks are designed to be mounted inside the container to allow for live editing and persistence of changes.


## Getting Started

### Prerequisites

- Docker installed on your machine [Get Docker](https://docs.docker.com/get-docker/)
- The working directory must contain the following folders - with a suffix specifying the chosen mode (`_dev`) or (`_prod`), whether you wish to wrok in production or development mode:
  - `rawdata_<mode>/` — original source files
  - `prepared_<mode>/` — files that are ready to be BIDSified
  - `bidsified_<mode>/` — files that have already been BIDSified
  - `configuration/` — configuration files and plugins
  - `notebooks/` — folder containing the Jupyter Notebooks to be used (e.g. `bidsification_prod.ipynb`, `bidsification_dev.ipynb`)
 
You can rename these folders as you wish to fit your project structure.
However, if you do so, make sure to update the corresponding folder paths accordingly in all relevant files in this repository — such as in the `docker-compose.yml`, volume mounts, `init_bidsme_lab.py` and any helper scripts — to ensure proper functionality.

#### Expected Structure of the `configuration/` Folder
The `configuration/` folder contains BIDSme configuration files, plugins, and templates. When the container starts:

  - If `mnt/configuration/` is empty, the container automatically clones the default template from GitLab : [BIDSme Configuration Template](https://gitlab.uliege.be/CyclotronResearchCentre/Public/bidstools/bidsme/bidsification-template)
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

`map`

The map folder is expected to contain `bidsmap.yaml` bidsification map.
This file will be automatically created during map creation step.

`plugin`

The plugin directory is expected to contain plugins files `prepare_plugin.py`
(for preparation step) and `bidsify_plugin.py` (for map and bidsification steps).

`template`

The template directory is expected to contain `participants.json` sidecar JSON
file that used for generation of `participants.tsv `table.
You can place there the JSON files for other tables (e.g. for tasks tsv files).

`notebook`

The notebook directory is expected to contain jupyter-lab notebooks, that runs
bidsification.

> This is the default recommended structure.
> However, ot can be adjusted to your needs - just ensure you update the paths and logic accordingly in the `init_bidsme_lab.py` script, which loads these files when launching JupyterLab.

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
  -v "$PWD/rawdata_prod:/mnt/rawdata_prod:ro" \
  -v "$PWD/prepared_prod:/mnt/prepared_prod" \
  -v "$PWD/bidsified_prod:/mnt/bidsified_prod" \
  -v "$PWD/configuration:/mnt/configuration" \
  -p 8888:8888 \
  bidsme:<version> lab prod
```
To use development mode instead: 
```bash
docker run \
  -v "$PWD/rawdata_dev:/mnt/rawdata_dev:ro" \
  -v "$PWD/prepared_dev:/mnt/prepared_dev" \
  -v "$PWD/bidsified_dev:/mnt/bidsified_dev" \
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

## Quick Tutorial : Running BIDsme in Docker 

1. Launch the container
   
Run the container with your mounted data folders
```bash
docker run -it \
  -v "../rawdata_prod:/mnt/rawdata_prod:ro" \
  -v "../prepared_prod:/mnt/prepared_prod" \
  -v "../bidsified_prod:/mnt/bidsified_prod" \
  -v "../configuration:/mnt/configuration" \
  bidsme:1.9.5
```

2. Run BIDSme prepare
   
Inside the container (/mnt), run :
```bash
bidsme prepare rawdata_prod/ prepared_prod/ -r nii=MRI
```
> The same approach applies to other BIDSme commands such as `process`, `map`, and `bidsify`.
For more details on BIDSme usage, see the [BIDSme GitHub repository](https://github.com/CyclotronResearchCentre/BIDSme).

3. Example logs
   
```text
main(80) - INFO -------------- START bidsme ----------------
main(82) - INFO Mon Aug 25 10:59:02 2025
main(83) - INFO version: 1.9.5
bidsme.schema.BIDSschema(676) - INFO Schema version 1.0.13
bidsme.prepare(192) - INFO -------------- Preparing data -------------
bidsme.prepare(193) - INFO Source directory: rawdata_prod/
bidsme.prepare(194) - INFO Destination directory: prepared_prod/
bidsme.prepare(295) - INFO Scanning folder rawdata_prod/001/s01512
bidsme.prepare(58)  - INFO Processing: sub 'sub-001', ses 'ses-s01512' (28 files)
```
4. Before / After example
   
**Rawdata**
```markdown
001/
 └── s01512/
     ├── inp/
     │   └── *.tsv
     └── nii/
         ├── f1512-0002-00001-000001-01.nii
         ├── f1512-0002-00001-000001-01.json
         └── ...
```

**Prepared**
```lua
sub-001/
 └── ses-s01512/
     └── MRI/
         ├── 001-localizer/
         │   ├── s1512-0001-*.nii
         │   └── s1512-0001-*.json
         ├── 002-cmrr_mbep2d_bold_mb2_invertpe/
         │   ├── f1512-0002-*.nii
         │   └── f1512-0002-*.json
         └── ...
```
The raw files have been reorganized into BIDS-compliant folders, grouped by subject, sessions and modality.
## Documentation 

For more details on BIDSme usage and features, visit the [BIDSme GitHub repository](https://github.com/CyclotronResearchCentre/BIDSme).

The default Jupyter notebooks used for both development and production modes are maintained separately and can be found in the bidsme template's gitlabs repository.
Feel free to adapt or replace them according to your needs.


