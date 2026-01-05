# Exclude Bundles Procedure

## 1. Get Excluded Bundles
The user will provide a list of bundle names (e.g., `['docker', 'nginx']`).

## 2. Identify Packages and APT Sources to Exclude

### A. Extract Packages from Bundles
For each `bundle_name` in the exclusion list:
1.  Read `context/installation_bundles/<bundle_name>/context.md`.
2.  Parse the "Packages Installed:" section to get a list of packages associated with this bundle.

### B. Identify APT Sources to Exclude
Review `context/autoinstall.yaml` for `apt: sources:` entries. If a source comment indicates it belongs *solely* to an excluded bundle (e.g., `# Added by Docker Installation Bundle`), mark it for exclusion.

## 3. Generate Excluded Autoinstall Config

### A. Load Base Config
Load `context/autoinstall.yaml` into a YAML object (e.g., using Python's `yaml` library).

### B. Remove Excluded Packages
Iterate through the `autoinstall: packages:` list in the YAML object. For each package:
1.  Check if it's in the list of packages to exclude.
2.  If it is, remove it from the `packages` list.

### C. Remove Excluded APT Sources
Iterate through the `autoinstall: apt: sources:` dictionary in the YAML object. For each source:
1.  Check if its comment (if available) or the source's name itself is explicitly associated with an excluded bundle.
2.  If it is, remove the source from the `sources` dictionary.

## 4. Save New Configuration
Save the modified YAML object to a new file, e.g., `autoinstall-<variant_name>.yaml`.
The `<variant_name>` should reflect the excluded bundles (e.g., `autoinstall-no-docker.yaml`).

## 5. Validate New Configuration
Run the validation procedure (`context/validation_procedure.md`) on the newly generated `autoinstall-<variant_name>.yaml`.
