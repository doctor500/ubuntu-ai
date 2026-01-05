# Autoinstall Configuration Initialization Procedure

## 1. Verify File Existence
Check if the personalized autoinstall config exists.
```bash
ls context/autoinstall.yaml
```

## 2. Action Based on Result

### Case A: File Exists
**Action:** Do nothing. The file is ready to use.
- Proceed with intended operation (validation, modification, VM sync, etc.)

### Case B: File Does NOT Exist (Error or exit code 2)
**Action:** Initialize from template and warn the user.

#### Step 1: Copy from Template
```bash
cp context/autoinstall.example.yaml context/autoinstall.yaml
```

#### Step 2: Inform the User
Display a warning message:

```
⚠️  IMPORTANT: autoinstall.yaml has been created from the template.

You MUST customize it before use:

1. Edit context/autoinstall.yaml
2. Update the following fields:
   - identity.hostname (currently: "ubuntu-desktop-vm")
   - identity.username (currently: "myuser")
   - identity.password (currently: placeholder hash)

3. Generate a real password hash:
   mkpasswd -m sha-512 "YourPassword"

4. Review and adjust the packages list as needed

⚠️  Do NOT use the template values for actual VM provisioning!
```

#### Step 3: Ask User Preference
Ask the user:
- **Option A:** "Would you like me to help you customize it now?"
  - If yes: Prompt for hostname, username, and generate password interactively
- **Option B:** "I'll leave it for you to customize manually"
  - Proceed with current operation using the template (useful for validation testing)

## 3. Post-Condition
The file `context/autoinstall.yaml` exists and is ready for:
- Manual customization by the user, OR
- Interactive customization by the AI agent, OR  
- Use as-is for testing/validation (with template values)

## 4. Example Customization Flow (If User Chooses Interactive)

### Step 1: Collect Information
```
AI: "What hostname would you like for this VM?"
User: "myserver"

AI: "What username?"
User: "admin"

AI: "Please enter your password (it will be hashed):"
User: [provides password]
```

### Step 2: Generate Password Hash
```bash
PASSWORD_HASH=$(mkpasswd -m sha-512 "UserProvidedPassword")
```

### Step 3: Update autoinstall.yaml
Use file editing tools to replace:
- `hostname: ubuntu-desktop-vm` → `hostname: myserver`
- `username: myuser` → `username: admin`  
- `password: "$6$rounds=4096$..."` → `password: "$PASSWORD_HASH"`

### Step 4: Confirm
```
✅ Configuration customized successfully!
   Hostname: myserver
   Username: admin
   Password: [hashed]

You can now proceed with validation or VM provisioning.
```

## Security Reminders
- The `autoinstall.yaml` file is automatically gitignored
- Never commit your personalized configuration
- Password is stored as SHA-512 hash, not plaintext
- The example template is safe for public repositories
