# Passwordless Sudo Procedure

## Quick Setup (Current VM)

### One-Command Setup

```bash
# Replace USERNAME with actual username
echo "USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-nopasswd-USERNAME
sudo chmod 440 /etc/sudoers.d/90-nopasswd-USERNAME
```

### Verify It Works

```bash
# Should NOT prompt for password
sudo -n whoami
# Expected output: root
```

---

## Step-by-Step Procedure

### Step 1: Identify Username

```bash
# Current user
whoami

# Or from user_data.json
cat context/user_data.json | grep username
```

### Step 2: Verify User Has Sudo Access

```bash
# Check if user is in sudo group
groups | grep sudo

# If not in sudo group:
# (requires password, run as root or existing sudo user)
sudo usermod -aG sudo USERNAME
```

### Step 3: Create Sudoers Drop-in File

```bash
# Create the file with NOPASSWD rule
echo "USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-nopasswd-USERNAME

# Alternative: Create with specific commands only (more secure)
# echo "USERNAME ALL=(ALL) NOPASSWD: /usr/bin/apt*, /usr/bin/systemctl" | sudo tee /etc/sudoers.d/90-nopasswd-USERNAME
```

### Step 4: Set Correct Permissions

```bash
# CRITICAL: Must be readable only by root
sudo chmod 440 /etc/sudoers.d/90-nopasswd-USERNAME

# Verify ownership
ls -la /etc/sudoers.d/90-nopasswd-USERNAME
# Expected: -r--r----- 1 root root
```

### Step 5: Verify Configuration

```bash
# Test passwordless sudo (should not prompt)
sudo -n true && echo "✅ Passwordless sudo works!" || echo "❌ Still requires password"

# Test actual command
sudo -n whoami
# Expected: root
```

---

## Autoinstall.yaml Configuration

**Place as FIRST late-command** to enable passwordless sudo before other installation steps:

```yaml
late-commands:
  # === Passwordless Sudo (MUST BE FIRST) ===
  - |
    curtin in-target --target=/target -- bash -c '
    echo "USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-nopasswd-USERNAME
    chmod 440 /etc/sudoers.d/90-nopasswd-USERNAME
    '
  
  # === Other installation steps follow ===
  # - Kubernetes setup...
  # - etc...
```

---

## Remove Passwordless Sudo

If you want to revert to password-required sudo:

```bash
sudo rm /etc/sudoers.d/90-nopasswd-USERNAME

# Verify
sudo whoami  # Should now prompt for password
```

---

## Security Options

### Option 1: Full Passwordless (Default - Least Secure)

```bash
echo "USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-nopasswd-USERNAME
```

### Option 2: Specific Commands Only (More Secure)

```bash
# Only allow passwordless for specific commands
echo "USERNAME ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/sbin/reboot, /bin/systemctl" | sudo tee /etc/sudoers.d/90-nopasswd-USERNAME
```

### Option 3: Time-Limited (Session-Based)

```bash
# Increase sudo timeout instead of removing password
echo "Defaults timestamp_timeout=60" | sudo tee /etc/sudoers.d/timeout
# Password required once per 60 minutes
```

---

## Troubleshooting

### "sudo: /etc/sudoers.d/90-nopasswd-USERNAME is mode 0644, should be 0440"

```bash
sudo chmod 440 /etc/sudoers.d/90-nopasswd-USERNAME
```

### Still prompting for password

```bash
# Check file exists and has correct content
sudo cat /etc/sudoers.d/90-nopasswd-USERNAME

# Check file permissions
ls -la /etc/sudoers.d/90-nopasswd-USERNAME

# Validate sudoers syntax
sudo visudo -cf /etc/sudoers.d/90-nopasswd-USERNAME
```

### Locked out of sudo

```bash
# If password still works, fix the file
sudo rm /etc/sudoers.d/90-nopasswd-USERNAME

# If completely locked out, boot into recovery mode
# Or use another sudo-capable user
```

---

## For AI Agent: Interactive Setup

When assisting user with passwordless sudo:

```bash
# Get username from user_data.json or ask user
USERNAME=$(cat context/user_data.json 2>/dev/null | jq -r .vm_username || echo "YOUR_USERNAME")

echo "Setting up passwordless sudo for: $USERNAME"
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-nopasswd-$USERNAME
sudo chmod 440 /etc/sudoers.d/90-nopasswd-$USERNAME

# Verify
sudo -n whoami && echo "✅ Success!" || echo "❌ Failed"
```
