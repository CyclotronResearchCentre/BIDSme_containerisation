import os

def generate_paths(production=True):
    mode = "production" if production else "development"
    print(f"[INFO] Using {mode} dataset paths")

    base_path = "/mnt"
    suffix = "prod" if production else "dev"

    source = os.path.join(base_path, f"rawdata_{suffix}")
    prepared = os.path.join(base_path, f"prepared_{suffix}")
    bidsified = os.path.join(base_path, f"bidsified_{suffix}")

    # Vérifications
    for path in [source, prepared, bidsified]:
        assert os.path.isdir(path), f"[ERROR] Missing: {path}"

    # Injection globale
    globals().update({
        'base_path': base_path,
        'source': source,
        'prepared': prepared,
        'bidsified': bidsified,
    })

    print(f"[INFO] Dataset paths initialized for {mode}.")


def define_plugin_paths():
    resources = os.path.join("/mnt", "configuration")

    # Plugin paths
    prepare_plugin = os.path.join(resources, "plugin", "prepare_plugin.py")
    bidsify_plugin = os.path.join(resources, "plugin", "bidsify_plugin.py")

    # Configuration file paths
    bidsmap = os.path.join(resources, "map", "bidsmap.yaml")
    part_template = os.path.join(resources, "template", "participants.json")
    curation_lists = os.path.join(resources, "lists")

    # Assertions
    assert os.path.isdir(resources), f"Missing: {resources}"
    assert os.path.isfile(prepare_plugin), f"Missing: {prepare_plugin}"
    assert os.path.isfile(bidsify_plugin), f"Missing: {bidsify_plugin}"
    assert os.path.isfile(bidsmap), f"Missing: {bidsmap}"
    assert os.path.isfile(part_template), f"Missing: {part_template}"
    assert os.path.isdir(curation_lists), f"Missing: {curation_lists}"

    # Expose as globals
    globals().update({
        'resources': resources,
        'prepare_plugin': prepare_plugin,
        'bidsify_plugin': bidsify_plugin,
        'bidsmap': bidsmap,
        'part_template': part_template,
        'curation_lists': curation_lists,
    })

    print("[INFO] Plugin and configuration paths initialized.")



# Run all setup functions
is_production = os.getenv("BIDSME_PRODUCTION", "true").lower() == "true"
generate_paths(production=is_production)

define_plugin_paths()
# This script initializes paths for the BIDSme project, setting up both dataset and plugin paths.
