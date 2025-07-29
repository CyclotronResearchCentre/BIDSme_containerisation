
# Notebooks Directory

This folder contains the Jupyter notebooks used for running and testing BIDSme workflows in both development and production modes.

## Contents

- `bidsification_dev.ipynb` — Notebook used when working in **development mode**.  
- `bidsification_prod.ipynb` — Notebook used when working in **production mode**.

## Usage

These notebooks are automatically mounted into the container when launching JupyterLab using the `lab dev` or `lab prod` commands.

> 🛠️ To make your edits persistent, make sure this `notebooks/` folder is mounted as a volume in your `docker run` or `docker-compose` command:
>
> ```bash
> -v "$PWD/notebooks:/mnt/notebooks"
> ```

Once JupyterLab is running, you can find the notebooks inside `/mnt/notebooks/`.

Feel free to:
- Edit them to suit your workflow.
- Add new notebooks for custom use cases.
- Remove unused ones.

## Notes

- The default structure and templates come from the [`bidsme-template`](https://github.com/CyclotronResearchCentre/bidsme-template) repository.
- If you rename or move the notebooks, update the corresponding Docker volume paths accordingly.
