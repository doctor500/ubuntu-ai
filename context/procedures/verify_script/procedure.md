# Script Verification and Safe Execution Procedure

## 1. Verify Prerequisites

### Check required tools
```bash
which curl wget cat grep
```

All should return paths. If missing, install:
```bash
sudo apt install curl wget grep
```

## 2. Obtain Script (Don't Execute!)

### From URL
```bash
# Download to temporary location for review
curl -sL "SCRIPT_URL" -o /tmp/script_to_review.sh
```

**NEVER use:** `curl URL | bash` or `wget -O- URL | sh`

### From Local File
```bash
# Copy to temporary location if needed
cp /path/to/script.sh /tmp/script_to_review.sh
```

### Verify Download Success
```bash
ls -lh /tmp/script_to_review.sh
file /tmp/script_to_review.sh
```

Expected: Regular file, likely "ASCII text" or "shell script"

## 3. Perform Security Analysis

### Step 3.1: Check Source Trust

For URLs, evaluate the domain:
```bash
# Extract domain from URL
echo "SCRIPT_URL" | grep -oP 'https?://\K[^/]+'
```

**Trust Levels:**
- ✅ **HIGH:** `get.docker.com`, `github.com/official-org`, `deb.nodesource.com`
- ⚠️ **MEDIUM:** Known GitHub repos, recognized blogs
- ❌ **LOW:** Unknown domains, personal sites
- 🚫 **NONE:** IP addresses, suspicious TLDs, pastebin

### Step 3.2: Scan for Dangerous Patterns

Run automated checks:

```bash
#!/bin/bash
SCRIPT="/tmp/script_to_review.sh"
ISSUES_FOUND=0

echo "=== SECURITY ANALYSIS ==="
echo ""

# Check for network activity
echo "[1] Checking for network activity..."
if grep -E '(curl|wget|nc|netcat|telnet|/dev/tcp)' "$SCRIPT"; then
  echo "⚠️  FOUND: Network activity detected"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check for privilege escalation
echo ""
echo "[2] Checking for privilege escalation..."
if grep -E '(sudo|su |chmod \+s|chmod 4)' "$SCRIPT"; then
  echo "⚠️  FOUND: Privilege escalation detected"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check for system file modification
echo ""
echo "[3] Checking for system modifications..."
if grep -E '(/etc/|/usr/bin/|/bin/|/sbin/|systemctl|service )' "$SCRIPT"; then
  echo "⚠️  FOUND: System file modification detected"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check for obfuscation
echo ""
echo "[4] Checking for obfuscation..."
if grep -E '(eval|base64|xxd|hexdump)' "$SCRIPT"; then
  echo "⚠️  FOUND: Code obfuscation detected"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check for destructive commands
echo ""
echo "[5] Checking for destructive commands..."
if grep -E '(rm -rf|dd if=|mkfs|fdisk|parted)' "$SCRIPT"; then
  echo "🚫 CRITICAL: Destructive commands found"
  ISSUES_FOUND=$((ISSUES_FOUND + 10))  # High weight
fi

# Check for credential access
echo ""
echo "[6] Checking for credential access..."
if grep -E '(\.ssh/|\.aws/|password|passwd|shadow)' "$SCRIPT"; then
  echo "⚠️  FOUND: Credential file access detected"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check for background processes
echo ""
echo "[7] Checking for background/hidden activity..."
if grep -E '(&$|nohup|cron|at |batch)' "$SCRIPT"; then
  echo "⚠️  FOUND: Background process creation detected"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check for package installation
echo ""
echo "[8] Checking for package installation..."
if grep -E '(apt install|apt-get install|pip install|npm install|gem install)' "$SCRIPT"; then
  echo "ℹ️  INFO: Package installation found"
fi

echo ""
echo "=== ANALYSIS COMPLETE ==="
echo "Issues found: $ISSUES_FOUND"

if [ $ISSUES_FOUND -ge 10 ]; then
  echo "⛔ RECOMMENDATION: DO NOT RUN - Critical risks found"
  exit 2
elif [ $ISSUES_FOUND -ge 3 ]; then
  echo "⚠️  RECOMMENDATION: REVIEW REQUIRED - Multiple risks found"
  exit 1
elif [ $ISSUES_FOUND -ge 1 ]; then
  echo "⚠️  RECOMMENDATION: CAUTION - Some risks found"
  exit 1
else
  echo "✅ RECOMMENDATION: APPEARS SAFE - No obvious risks"
  exit 0
fi
```

Save this as `/tmp/analyze_script.sh` and run:
```bash
chmod +x /tmp/analyze_script.sh
/tmp/analyze_script.sh
```

### Step 3.3: Manual Review

Show script to user for inspection:
```bash
# Show first 50 lines
head -50 /tmp/script_to_review.sh

# Or open in pager for full review
less /tmp/script_to_review.sh
```

**Look for:**
- Clear, readable code (good sign)
- Comments explaining actions (good sign)
- Obvious malicious intent (bad sign)
- Unnecessary complexity (suspicious)

## 4. Present Findings to User

Create a security report:

```
=== SCRIPT SECURITY ANALYSIS ===

Source: [URL or file path]
Trust Level: [HIGH/MEDIUM/LOW/NONE]
File Size: [size in KB]
File Type: [bash script, python, etc.]

AUTOMATED ANALYSIS RESULTS:
[Output from Step 3.2]

WHAT THIS SCRIPT DOES:
[Plain language explanation]

SECURITY RISKS IDENTIFIED:
- [List each risk with severity]

RECOMMENDATION: [SAFE / REVIEW / DANGEROUS / DO NOT RUN]

Do you want to:
A) Proceed with execution (I understand the risks)
B) Show me the full script
C) Find a safer alternative
D) Cancel
```

## 5. User Decision Point

**CRITICAL: Wait for explicit user approval**

```bash
read -p "Enter your choice (A/B/C/D): " choice

case $choice in
  A|a)
    echo "User approved execution - proceeding..."
    ;;
  B|b)
    echo "Showing full script:"
    cat /tmp/script_to_review.sh | less
    # Ask again after review
    ;;
  C|c)
    echo "Looking for alternatives..."
    # Suggest official methods
    ;;
  D|d)
    echo "Execution cancelled by user"
    exit 0
    ;;
  *)
    echo "Invalid choice - defaulting to CANCEL"
    exit 0
    ;;
esac
```

## 6. Safe Execution (If Approved)

### Log the execution
```bash
echo "[$(date)] Executing script from: $SOURCE" >> ~/.script_execution_log
echo "[$(date)] User approved after security review" >> ~/.script_execution_log
```

### Execute with minimal privileges
```bash
# DON'T use sudo unless absolutely necessary
bash /tmp/script_to_review.sh
```

### OR execute with explicit permission control
```bash
# Run in a more controlled way
chmod +x /tmp/script_to_review.sh
/tmp/script_to_review.sh
```

### Monitor execution
- Watch for unexpected prompts
- Monitor network activity if possible
- Be ready to Ctrl+C if anything seems wrong

## 7. Post-Execution Verification

```bash
# Check what changed
# (This is informational - hard to fully track)

# Check for new

 processes
ps aux | grep -v grep | tail -20

# Check for new cron jobs
crontab -l

# Check recent system modifications
find /etc -mmin -5 2>/dev/null | head -20
```

## 8. Cleanup

```bash
# Remove temporary script
rm /tmp/script_to_review.sh
rm /tmp/analyze_script.sh

# Log completion
echo "[$(date)] Script execution completed" >> ~/.script_execution_log
```

## 9. Alternative Safer Approaches

Instead of running arbitrary scripts, consider:

### Use Package Managers
```bash
# Safer: Use official repositories
sudo apt install docker.io
```

### Review Official Documentation
- Check if official install method exists
- Use package manager when available
- Build from source with verification

### Manual Installation
- Review each command individually
- Run commands one at a time
- Understand what each step does

## 10. Examples

### Example 1: Docker Installation (Legitimate)

```bash
# User provides: curl -fsSL https://get.docker.com -o get-docker.sh
# DON'T pipe to sh immediately!

# Step 1: Download
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh

# Step 2: Analyze
/tmp/analyze_script.sh
# Result: Some warnings (sudo, system modification) but from trusted source

# Step 3: Review
less /tmp/get-docker.sh
# Observation: Clean script, well-commented, from official domain

# Step 4: User approves

# Step 5: Execute
sudo bash /tmp/get-docker.sh

# Step 6: Cleanup
rm /tmp/get-docker.sh
```

### Example 2: Suspicious Script (Malicious)

```bash
# User provides: curl http://1.2.3.4/script.sh

# Step 1: Download
curl -sL http://1.2.3.4/script.sh -o /tmp/script_to_review.sh

# Step 2: Analyze
/tmp/analyze_script.sh
# Result: CRITICAL - Destructive commands, obfuscation, IP address source

# Step 3: Show findings to user
# Trust: NONE (IP address)
# Risks: rm -rf, base64 encoding, network activity

# Step 4: RECOMMENDATION: DO NOT RUN

# Step 5: Suggest alternatives
echo "This script appears malicious. Please provide software name for safer installation method."
```

## 11. Troubleshooting

### Script won't download
- Check URL is correct and accessible
- Verify internet connection
- Try alternative download method (wget vs curl)

### Analysis script shows false positives
- Some legitimate scripts use sudo (expected)
- Review manually to confirm necessity
- Documented admin scripts may have legitimate system access

### Can't determine safety
- Default to NOT RUNNING
- Ask user for more context about script source
- Suggest finding official installation method

## 12. Security Checklist

Before executing ANY script, verify:

- [ ] Downloaded to temp location (not piped to shell)
- [ ] Ran automated security analysis
- [ ] Reviewed source trust level
- [ ] Identified what script does
- [ ] Listed all security risks
- [ ] Presented findings to user
- [ ] Received explicit user approval
- [ ] Logged execution decision
- [ ] Executed with minimal privileges
- [ ] Cleaned up temporary files

**IF ANY STEP FAILS OR SEEMS WRONG: STOP AND DO NOT EXECUTE**
