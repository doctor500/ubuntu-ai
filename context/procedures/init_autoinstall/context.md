# Autoinstall Configuration Initialization Context

## Goal
To ensure the `autoinstall.yaml` file exists before attempting to validate, modify, or sync it with a VM. This procedure creates a working configuration file from the example template when needed.

## Triggers
- AI Agent prepares to validate or modify config but detects `autoinstall.yaml` is missing.
- New clone of the repository (fresh installation).
- User accidentally deletes or moves `autoinstall.yaml`.
- Before any operation that requires reading `context/autoinstall.yaml`.

## Logic
1.  **Check Existence:** Verify if `context/autoinstall.yaml` exists.
2.  **Create if Missing:** If it does not exist:
    - Copy from `context/autoinstall.example.yaml`
    - Warn the user that they MUST customize it with their personal details
    - Provide guidance on required customizations
3.  **No-op if Exists:** If it exists, proceed without modifying it.

## Security Note
`autoinstall.yaml` is gitignored by design. It contains personalized information:
- Hostname
- Username  
- Password hash
- Potentially custom package lists

Users MUST customize the copied template before using it for actual VM provisioning.
