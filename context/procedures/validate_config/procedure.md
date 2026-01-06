# Configuration Validation Procedure

**Reference:** https://canonical-subiquity.readthedocs-hosted.com/en/latest/howto/autoinstall-validation.html

## 1. Verify Prerequisites

### Check autoinstall.yaml exists
```bash
ls context/autoinstall.yaml
```

If missing, run the init_autoinstall procedure first.

### Check Python 3 and Git
```bash
python3 --version
git --version
```

Both should return version numbers. If not installed:
```bash
sudo apt install -y python3 git
```

## 2. Install System Dependencies

These Python packages are required for the Subiquity validation tool:

```bash
sudo apt update
sudo apt install -y python3-passlib python3-jsonschema python3-yaml \
                    python3-aiohttp python3-packaging python3-pyudev \
                    python3-requests-unixsocket python3-distro-info \
                    python3-bson python3-urwid python3-more-itertools \
                    python3-prettytable python3-p ycountry python3-pyroute2 \
                    python3-debian python3-systemd
```

**Note:** This step requires sudo privileges. The command is safe - it only installs Python libraries.

**Expected output:** Package installation progress and "Done" message.

## 3. Set Up Subiquity Validation Tools

### Check if tools already exist
```bash
ls .tools/subiquity
```

### If not present, clone the repository
```bash
mkdir -p .tools
git clone https://github.com/canonical/subiquity.git .tools/subiquity
```

**Expected output:** Cloning progress and completion message.

### Fetch Subiquity external dependencies
```bash
cd .tools/subiquity
make gitdeps
cd ../..
```

**Expected output:** Fetching and initialization of external dependencies.

## 4. Generate JSON Schema

The JSON schema defines what a valid autoinstall.yaml looks like. It must be regenerated if Subiquity is updated.

```bash
(cd .tools/subiquity && \
 export PYTHONPATH=.:curtin:probert && \
 python3 -m subiquity.cmd.schema > ../../context/autoinstall-schema.json)
```

**Expected output:** Silent success (no output). The file `context/autoinstall-schema.json` will be created/updated.

### Verify schema was created
```bash
ls -lh context/autoinstall-schema.json
```

**Expected output:** File size should be ~18-20 KB.

## 5. Run Validation

Validate the autoinstall.yaml against the generated schema:

```bash
(cd .tools/subiquity && \
 export PYTHONPATH=.:curtin:probert && \
 python3 scripts/validate-autoinstall-user-data.py \
 --json-schema ../../context/autoinstall-schema.json \
 ../../context/autoinstall.yaml)
```

**Important Notes:**
- The command MUST be run from within `.tools/subiquity/` directory
- Do NOT run as sudo
- Paths are relative to the subiquity directory

## 6. Interpret Results

### Success (Exit Code 0)
```
Success: The provided autoinstall config validated successfully
```

**Action:** Configuration is valid and ready to use.

### Failure (Exit Code 1)
The validation script will output error details showing:
- Which section of the YAML is invalid
- What the error is
- Often includes the JSON path to the problem

**Example error:**
```
Error: Invalid value for packages: expected list, got string
Path: autoinstall.packages
```

## 7. Fix Common Validation Errors

### Error: Missing required fields
```yaml
# Bad
autoinstall:
  version: 1

# Good
autoinstall:
  version: 1
  identity:
    hostname: my-vm
    username: myuser
    password: "$6$..."
```

### Error: Invalid package list format
```yaml
# Bad
packages: "git neofetch"

# Good
packages:
  - git
  - neofetch
```

### Error: Invalid password hash
```yaml
# Bad - plaintext password
password: "mypassword"

# Good - SHA-512 hash
password: "$6$rounds=4096$..."
```

Generate valid hash:
```bash
mkpasswd -m sha-512 "YourPassword"
```

### Error: Invalid boolean value
```yaml
# Bad
allow-pw: "true"

# Good
allow-pw: true
```

### Error: Unrecognized keys
Remove any keys that aren't part of the official schema. Check the reference documentation for valid keys.

## 8. Re-validation After Fixes

After fixing errors, re-run the validation:

```bash
(cd .tools/subiquity && \
 export PYTHONPATH=.:curtin:probert && \
 python3 scripts/validate-autoinstall-user-data.py \
 --json-schema ../../context/autoinstall-schema.json \
 ../../context/autoinstall.yaml)
```

Repeat until validation succeeds.

## 9. Post-Validation Steps

Once validation succeeds:

1. **Update changelog** (if significant changes were made)
2. **Commit changes** to git
   ```bash
   git add context/autoinstall.yaml
   git commit -m "Update autoinstall configuration"
   ```
3. **Consider running verify_vm** to see how config differs from live VM

## 10. Troubleshooting

### "Module not found" errors
- Ensure you're running from within `.tools/subiquity/` directory
- Check PYTHONPATH is set correctly
- Verify external dependencies were fetched (`make gitdeps`)

### "Schema file not found"
- Ensure schema generation step completed successfully
- Check `context/autoinstall-schema.json` exists
- Re-run schema generation if needed

### " Permission denied" errors
- Do NOT run validation as sudo
- Check file permissions on autoinstall.yaml
- Ensure you have read access to context/ directory

### Validation hangs or times out
- Check if `.tools/subiquity/` is complete (not partial clone)
- Verify no network issues during git clone
- Try re-cloning Subiquity repository

### Schema generation fails
- Update Subiquity to latest:
  ```bash
  cd .tools/subiquity
  git pull origin main
  make gitdeps
  cd ../..
  ```
- Check Python 3 is properly installed

## 11. Automation Notes

For automated validation in scripts or CI/CD:

```bash
#!/bin/bash
# Validate autoinstall configuration

set -e  # Exit on error

# Run validation
cd .tools/subiquity
export PYTHONPATH=.:curtin:probert
python3 scripts/validate-autoinstall-user-data.py \
  --json-schema ../../context/autoinstall-schema.json \
  ../../context/autoinstall.yaml

if [ $? -eq 0 ]; then
  echo "✅ Validation passed"
  exit 0
else
  echo "❌ Validation failed"
  exit 1
fi
```
