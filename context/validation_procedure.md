# Autoinstall Validation Procedure

Reference: https://canonical-subiquity.readthedocs-hosted.com/en/latest/howto/autoinstall-validation.html

## Prerequisites
1.  **Python 3** and **Git**.
2.  **System Dependencies** (Install via apt):
    ```bash
    sudo apt update
    sudo apt install -y python3-passlib python3-jsonschema python3-yaml \
                        python3-aiohttp python3-packaging python3-pyudev \
                        python3-requests-unixsocket python3-distro-info \
                        python3-bson python3-urwid python3-more-itertools \
                        python3-prettytable python3-pycountry python3-pyroute2 \
                        python3-debian python3-systemd
    ```

## Setup
1.  Clone the Subiquity repository to a tools directory:
    ```bash
    mkdir -p .tools
    git clone https://github.com/canonical/subiquity.git .tools/subiquity
    ```
2.  Fetch Subiquity external dependencies:
    ```bash
    cd .tools/subiquity
    make gitdeps
    cd ../..
    ```

## Schema Generation
Before validation, you must generate the JSON schema. Run this from the project root:
```bash
(cd .tools/subiquity && \
 export PYTHONPATH=.:curtin:probert && \
 python3 -m subiquity.cmd.schema > ../../autoinstall-schema.json)
```

## Running Validation
To validate `autoinstall.yaml`, run the following command from the project root:

```bash
(cd .tools/subiquity && \
 export PYTHONPATH=.:curtin:probert && \
 python3 scripts/validate-autoinstall-user-data.py \
 --json-schema ../../context/autoinstall-schema.json \
 ../../context/autoinstall.yaml)
```

## Exit Codes
- `0`: Success (Output: "Success: The provided autoinstall config validated successfully")
- `1` or other: Failure

## Notes
- Do NOT run the validation script as sudo.
- The command must be run from within the `.tools/subiquity` directory to resolve internal file paths (like `kbds`), pointing back to the config files in the project root.