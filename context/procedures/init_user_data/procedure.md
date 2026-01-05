# User Data Initialization Procedure

## 1. Verify File Existence
```bash
ls context/user_data.json
```

## 2. Collect Information
If the file is missing, ask the user for the following details (add more as needed for the project):
- **VM IP Address:** (Key: `vm_ip`)
- **VM Hostname:** (Key: `vm_hostname`)
- **VM Username:** (Key: `vm_username`)

## 3. Create/Update JSON
Use `write_file` to save the data.

**Example Content:**
```json
{
  "vm_ip": "10.0.0.5",
  "vm_hostname": "my-ubuntu-server",
  "vm_username": "admin"
}
```

## 4. Usage in Procedures
When following other procedures (e.g., verification), read this file first:
```bash
cat context/user_data.json
```
Then replace placeholders like `{{vm_ip}}` with the actual values.
