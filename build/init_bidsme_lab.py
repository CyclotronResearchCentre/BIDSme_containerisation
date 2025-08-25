import os
import builtins

print("\n[INIT] → Launching init_bidsme_lab.py...\n")

# ───────────────────────────────
# 1) Dataset paths
# ───────────────────────────────
def generate_paths(production=True):
    """
    Define dataset paths depending on the mode (production or development).
    """
    mode = "production" if production else "development"

    base_path = "/mnt"
    suffix = "prod" if production else "dev"

    source = os.path.join(base_path, f"rawdata_{suffix}")
    prepared = os.path.join(base_path, f"prepared_{suffix}")
    bidsified = os.path.join(base_path, f"bidsified_{suffix}")

    print(f"[INFO] Using {mode} dataset paths")
    print(f"[INFO] Dataset paths:\n - source: {source}\n - prepared: {prepared}\n - bidsified: {bidsified}")

    # Checks
    for path in [source, prepared, bidsified]:
        assert os.path.isdir(path), f"[ERROR] Missing: {path}"

    # Inject globals
    globals().update({
        'base_path': base_path,
        'source': source,
        'prepared': prepared,
        'bidsified': bidsified,
    })

    # Inject into builtins
    builtins.source = source
    builtins.prepared = prepared
    builtins.bidsified = bidsified
    builtins.base_path = base_path

    print(f"[INFO] Dataset paths initialized for {mode}.")


# ───────────────────────────────
# 2) Plugins paths
# ───────────────────────────────
def define_plugin_paths(resources=None):
    """
    Define and check paths to plugin scripts (prepare, bidsify).
    """
    if resources is None:
        resources = os.path.join("/mnt", "configuration")

    prepare_plugin = os.path.join(resources, "plugin", "prepare_plugin.py")
    bidsify_plugin = os.path.join(resources, "plugin", "bidsify_plugin.py")

    # Checks
    assert os.path.isdir(resources), f"Missing: {resources}"
    assert os.path.isfile(prepare_plugin), f"Missing: {prepare_plugin}"
    assert os.path.isfile(bidsify_plugin), f"Missing: {bidsify_plugin}"

    # Inject globals
    globals().update({
        'resources': resources,
        'prepare_plugin': prepare_plugin,
        'bidsify_plugin': bidsify_plugin,
    })

    # Inject into builtins
    builtins.resources = resources
    builtins.prepare_plugin = prepare_plugin
    builtins.bidsify_plugin = bidsify_plugin

    print("[INFO] Plugin paths initialized.")


# ───────────────────────────────
# 3) Config files paths
# ───────────────────────────────
def define_config_paths(resources=None):
    """
    Define and check paths to configuration files (bidsmap, participants, curation lists).
    """
    if resources is None:
        resources = os.path.join("/mnt", "configuration")

    bidsmap = os.path.join(resources, "map", "bidsmap.yaml")
    part_template = os.path.join(resources, "template", "participants.json")
    curation_lists = os.path.join(resources, "lists")

    # Checks
    assert os.path.isfile(bidsmap), f"Missing: {bidsmap}"
    assert os.path.isfile(part_template), f"Missing: {part_template}"
    assert os.path.isdir(curation_lists), f"Missing: {curation_lists}"

    # Inject globals
    globals().update({
        'bidsmap': bidsmap,
        'part_template': part_template,
        'curation_lists': curation_lists,
    })

    # Inject into builtins
    builtins.bidsmap = bidsmap
    builtins.part_template = part_template
    builtins.curation_lists = curation_lists

    print("[INFO] Configuration file paths initialized.")


# ───────────────────────────────
# Run setup automatically
# ───────────────────────────────
is_production = os.getenv("BIDSME_PRODUCTION", "true").lower() == "true"
generate_paths(production=is_production)
define_plugin_paths()
define_config_paths()

print("\n[INIT] → BIDSme environment initialized.\n")
