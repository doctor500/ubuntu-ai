# Documentation Maintenance Context

## Goal
To keep the `README.md` file accurate and up-to-date as the project evolves. The `README.md` serves as the primary entry point and must accurately reflect the directory structure and available procedures.

## Triggers
- A new file or directory is created in `context/`.
- A new procedure is added to `context/procedures/`.
- A new installation bundle is added to `context/installation_bundles/`.
- Significant changes to existing file purposes.

## Logic
1.  **Detect Change:** Identify that a structural change has occurred during the current task.
2.  **Review README:** Read the current `README.md` to see if the new item is listed.
3.  **Update:** If missing, update the "Project Structure" section to include the new file or directory with a brief description.
4.  **Verify Sensitive Data:** Ensure no personalized data (IPs, specific hostnames) is introduced during the update.
