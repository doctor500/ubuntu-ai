# Exclude Bundles Procedure Context

## Goal
Generate a variant `autoinstall.yaml` file that excludes packages and configuration sections associated with specified installation bundles. This allows for creating customized autoinstall configurations for different deployment scenarios.

## Logic
1.  **Input:** The user provides a list of `bundle_name`(s) to exclude (e.g., `docker`).
2.  **Identify Excluded Packages:** For each excluded `bundle_name`, the AI Agent will read `context/installation_bundles/<bundle_name>/context.md` to identify the "Packages Installed" by that bundle.
3.  **Identify Excluded `apt: sources`:** The AI Agent must also identify `apt: sources` entries that belong exclusively to the excluded bundles. This will require checking comments in `autoinstall.yaml` or explicit definition in bundle's `context.md`. (The current `autoinstall.yaml` already has `apt: # Added by Docker Installation Bundle` as a comment).
4.  **Create Temporary Config:** Load the main `context/autoinstall.yaml` into a temporary data structure.
5.  **Remove Excluded Items:** Iterate through the identified packages and `apt: sources` and remove them from the temporary configuration.
6.  **Generate New File:** Write the modified configuration to a new `autoinstall-<variant_name>.yaml` file.

## Output
A new `autoinstall-<variant_name>.yaml` file, ready for validation and use.
