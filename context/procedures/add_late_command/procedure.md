# Add Late-Command to Autoinstall Configuration

## 1. Verify Prerequisites

### Check autoinstall.yaml exists
```bash
if [ ! -f context/autoinstall.yaml ]; then
  echo "❌ autoinstall.yaml not found"
  echo "→ Run init_autoinstall procedure first"
  exit 1
fi
```

### Confirm user has script or goal
```
Option A: User provides specific script/command
Option B: User provides goal, we build script together
```

---

## 2. Script Acquisition

### Option A: User-Provided Script

```bash
# Save user's script to temporary file
cat > /tmp/late_command_candidate.sh << 'EOF'
[USER'S SCRIPT HERE]
EOF

echo "✅ Script received"
```

### Option B: Script Builder (Interactive)

If user knows goal but not script, gather requirements:

**Questions to ask:**
1. What is the desired end state?
2. What specific configuration needs to change?
3. Are there any tools/packages required?
4. Should this run every boot or just during install?
5. Are there dependencies on other commands?

**Example interaction:**
```
User: "I want to enable automatic security updates"

AI: "Let me help build that script. Questions:
1. Which update method? (unattended-upgrades recommended)
2. Email notifications? (yes/no)
3. Auto-reboot if needed? (yes/no)

Based on your answers, I'll create the appropriate late-command."
```

**Analysis after gathering requirements:**
```bash
# Check if requirement maps to existing autoinstall section
if requirement_is_package_installation; then
  echo "→ This can be handled by packages section"
  echo "   Use: packages list instead of late-commands"
  ask_user_preference
elif requirement_is_snap_installation; then
  echo

 "→ This can be handled by snaps section"
  ask_user_preference  
elif requirement_maps_to_existing_procedure; then
  echo "→ We have [procedure_name] that handles this"
  offer_existing_procedure
else
  echo "→ Custom late-command needed"
  build_script_with_user
fi
```

---

## 3. Security Validation (MANDATORY)

**CRITICAL: ALWAYS run verify_script procedure**

### Run Security Analysis

```bash
echo "=== SECURITY VALIDATION ==="
echo "Running verify_script procedure..."
echo ""

# Use verify_script procedure
# See: context/procedures/verify_script/procedure.md

# Download script to temp (if from URL)
# OR save user script to temp

# Run automated analysis
/tmp/analyze_script.sh /tmp/late_command_candidate.sh

# Present results to user
echo "Security Analysis Results:"
echo "  Risk Level: [SAFE/MEDIUM/HIGH/DANGEROUS]"
echo "  Concerns: [list any issues found]"
echo ""

# Get explicit approval
read -p "Approve this script for autoinstall? (yes/no): " approval

if [ "$approval" != "yes" ]; then
  echo "❌ Script not approved - aborting"
  exit 1
fi

echo "✅ Script approved by user"
```

### Security Checklist

Verify script does NOT contain:
- [ ] Destructive commands (`rm -rf /`, `dd`, `mkfs`)
- [ ] Data exfiltration (unauthorized network uploads)
- [ ] Credential theft (reading unauthorized files)
- [ ] Malicious obfuscation (base64, hex encoding)
- [ ] Unnecessary privilege escalation
- [ ] Backdoor installation

If ANY of these are found: **RECOMMEND ALTERNATIVES**

---

## 4. Dependency Analysis

### Check Package Requirements

```bash
echo "=== CHECKING DEPENDENCIES ==="
echo ""

# Analyze script for command usage
REQUIRED_PACKAGES=()

# Check common commands
if grep -q "curl" /tmp/late_command_candidate.sh; then
  if ! grep -q "curl" context/autoinstall.yaml; then
    REQUIRED_PACKAGES+=("curl")
  fi
fi

if grep -q "jq" /tmp/late_command_candidate.sh; then
  if ! grep -q "jq" context/autoinstall.yaml; then
    REQUIRED_PACKAGES+=("jq")
  fi
fi

if grep -q "git " /tmp/late_command_candidate.sh; then
  if ! grep -q "^    - git$" context/autoinstall.yaml; then
    REQUIRED_PACKAGES+=("git")
  fi
fi

# Add more checks as needed...

if [ ${#REQUIRED_PACKAGES[@]} -gt 0 ]; then
  echo "📦 Required packages detected:"
  for pkg in "${REQUIRED_PACKAGES[@]}"; do
    echo "   - $pkg"
  done
  echo ""
  echo "These will be added to packages section"
else
  echo "✅ No additional packages needed"
fi
```

### Add Packages to autoinstall.yaml

```bash
if [ ${#REQUIRED_PACKAGES[@]} -gt 0 ]; then
  # Create backup
  cp context/autoinstall.yaml context/autoinstall.yaml.backup-$(date +%Y%m%d-%H%M%S)
  
  # Add packages with comment
  for pkg in "${REQUIRED_PACKAGES[@]}"; do
    # Find packages section and add
    sed -i "/^  packages:/a\    - $pkg  # Required for late-command: [description]" \
      context/autoinstall.yaml
  done
  
  echo "✅ Packages added to configuration"
fi
```

---

## 5. Format Late-Command for YAML

### Prepare Command String

**Single-line command:**
```bash
COMMAND="systemctl enable myservice"

# Format for YAML
LATE_COMMAND="  - curtin in-target --target=/target -- $COMMAND"
```

**Multi-line script:**
```bash
# For complex scripts, use YAML multiline
cat > /tmp/late_command_formatted.yaml << 'EOF'
  - |
    curtin in-target --target=/target -- bash -c '
    # Multi-line script
    command1
    command2
    command3
    '
EOF
```

### Escaping Rules

```bash
# Escape single quotes if using double-quoted string
COMMAND=$(echo "$COMMAND" | sed "s/'/'\\\\''/g")

# Escape dollar signs to prevent variable expansion
COMMAND=$(echo "$COMMAND" | sed 's/\$/\\$/g')

# Add error handling for non-critical commands
if [ "$CRITICAL" != "yes" ]; then
  COMMAND="$COMMAND || true"
fi
```

---

## 6. Add to autoinstall.yaml

### Check if late-commands Section Exists

```bash
echo "=== UPDATING autoinstall.yaml ==="
echo ""

# Create backup
cp context/autoinstall.yaml context/autoinstall.yaml.backup-$(date +%Y%m%d-%H%M%S)

# Check if late-commands exists
if grep -q "^  late-commands:" context/autoinstall.yaml; then
  echo "✅ late-commands section found"
  INSERT_MODE="append"
else
  echo "ℹ️  late-commands section not found - will create"
  INSERT_MODE="create"
fi
```

### Insert Command

**If section exists (append):**
```bash
if [ "$INSERT_MODE" = "append" ]; then
  # Add new command to existing section
  # Add descriptive comment first
  sed -i "/^  late-commands:/a\    # [Description of what this command does]" \
    context/autoinstall.yaml
  
  # Add actual command
  sed -i "/^  late-commands:/a\    - curtin in-target --target=/target -- $COMMAND" \
    context/autoinstall.yaml
fi
```

**If section doesn't exist (create):**
```bash
if [ "$INSERT_MODE" = "create" ]; then
  # Find a good insertion point (after packages section)
  cat >> context/autoinstall.yaml << EOF

  late-commands:
    # [Description of what this command does]
    - curtin in-target --target=/target -- $COMMAND
EOF
fi
```

### Show Diff

```bash
echo ""
echo "=== CHANGES TO autoinstall.yaml ==="
diff -u context/autoinstall.yaml.backup-* context/autoinstall.yaml || true
echo ""
```

---

## 7. Validate Configuration

### Run YAML Validation

```bash
echo "=== VALIDATING CONFIGURATION ==="
echo ""

# Use validate_config procedure
# See: context/procedures/validate_config/procedure.md

# Check YAML syntax
python3 -c "import yaml; yaml.safe_load(open('context/autoinstall.yaml'))" 2>&1

if [ $? -eq 0 ]; then
  echo "✅ YAML syntax valid"
else
  echo "❌ YAML syntax error detected"
  echo "→ Restoring backup"
  mv context/autoinstall.yaml.backup-* context/autoinstall.yaml
  exit 1
fi
```

### Run Subiquity Validation (If Available)

```bash
if [ -d ".tools/subiquity" ]; then
  echo "Running Subiquity validation..."
  # Run full validation
  # See validate_config procedure
fi
```

---

## 8. Update Documentation

### Add to change_log.md

```bash
cat >> context/change_log.md << EOF

### Added
- Added late-command to autoinstall.yaml
  - Purpose: [Description]
  - Command: \`$COMMAND\`
  - Security validated: Yes
  - Package dependencies: [list if any]

EOF

echo "✅ Changelog updated"
```

### Create Documentation (Optional, for complex scripts)

```bash
if [ "$COMPLEX_SCRIPT" = "yes" ]; then
  cat > context/late_commands/[script_name].md << EOF
# Late-Command: [Script Name]

## Purpose
[Why this command exists]

## What It Does
[Step-by-step explanation]

## Dependencies
[Required packages]

## Security Considerations
[Any security notes]

## Testing
[How to test this command]

EOF
fi
```

---

## 9. Summary and Next Steps

```bash
echo ""
echo "=== LATE-COMMAND ADDITION COMPLETE ==="
echo ""
echo "✅ Script validated for security"
echo "✅ Dependencies added (if any)"
echo "✅ Late-command added to autoinstall.yaml"
echo "✅ Configuration validated"
echo "✅ Documentation updated"
echo ""
echo "Command added:"
echo "  $COMMAND"
echo ""
echo "This will execute during VM provisioning after base install"
echo ""
echo "Next steps:"
echo "  1. Test in a VM provision (recommended)"
echo "  2. Check logs: /var/log/installer/subiquity-curtin-install.log"
echo "  3. Adjust if needed"
echo ""
```

---

## 10. Examples

### Example 1: Enable Service

**User request:** "Add command to enable Docker at boot"

```yaml
late-commands:
  # Enable Docker service at boot
  - curtin in-target --target=/target -- systemctl enable docker
```

### Example 2: Create Directory Structure

**User request:** "Create /opt/myapp directory structure"

```yaml
late-commands:
  # Create application directory structure
  - curtin in-target --target=/target -- mkdir -p /opt/myapp/{bin,config,data}
  - curtin in-target --target=/target -- chown -R 1000:1000 /opt/myapp
```

### Example 3: Download Configuration File

**Requires:** curl package

```yaml
packages:
  - curl  # Required for late-command: config download

late-commands:
  # Download application configuration
  - curtin in-target --target=/target -- curl -o /etc/myapp/config.json https://example.com/config.json
  - curtin in-target --target=/target -- chmod 644 /etc/myapp/config.json
```

### Example 4: Multi-Step Setup Script

```yaml
late-commands:
  # Setup application environment
  - |
    curtin in-target --target=/target -- bash -c '
    # Create directories
    mkdir -p /opt/app/{bin,logs}
    
    # Download binary
    curl -L https://example.com/app -o /opt/app/bin/app
    chmod +x /opt/app/bin/app
    
    # Create systemd service
    cat > /etc/systemd/system/myapp.service << "SERVICE"
    [Unit]
    Description=My Application
    
    [Service]
    ExecStart=/opt/app/bin/app
    
    [Install]
    WantedBy=multi-user.target
    SERVICE
    
    # Enable service
    systemctl enable myapp || true
    '
```

---

## 11. Troubleshooting

### Command Fails During Install

**Check logs:**
```bash
ssh user@vm "sudo cat /var/log/installer/subiquity-curtin-install.log | grep -A 10 'late-commands'"
```

**Common issues:**
- Package not installed yet → Add to packages section
- Permission denied → Use curtin in-target
- Command not found → Check package dependencies
- Syntax error → Check escaping and quoting

### YAML Validation Fails

```bash
# Test YAML syntax
python3 -c "import yaml; print(yaml.safe_load(open('context/autoinstall.yaml')))"

# Common fixes:
# - Check indentation (2 spaces)
# - Check quotes and escaping
# - Validate multiline strings
```

### Script Builder Edge Cases

**User goal maps to existing autoinstall section:**
```
User: "I want to install nginx"
→ This is handled by packages section
→ Offer: "Would you like me to add nginx to packages instead?"
```

**User goal requires multiple procedures:**
```
User: "Setup web server with SSL"
→ Requires: nginx package + late-command for cert generation
→ Explain: "This needs multiple steps:
  1. Add nginx to packages
  2. Add late-command for certbot setup
  Proceed?"
```

---

## 12. Best Practices

### DO:
- ✅ Always validate with verify_script
- ✅ Add descriptive comments
- ✅ Test commands manually first
- ✅ Use `|| true` for non-critical commands
- ✅ Check package dependencies
- ✅ Use curtin in-target for chroot execution
- ✅ Document complex scripts

### DON'T:
- ❌ Add commands without security validation
- ❌ Assume packages are installed
- ❌ Use unescaped special characters
- ❌ Make commands without error handling
- ❌ Skip YAML validation
- ❌ Forget to backup autoinstall.yaml

---

## 13. Integration with Other Procedures

| Procedure | When to Use | How |
|-----------|-------------|-----|
| **verify_script** | ALWAYS | Before adding any command |
| **validate_config** | After changes | Validate YAML syntax |
| **init_autoinstall** | If config missing | Create before adding commands |
| **verify_vm** | After provision | Check command executed |
| **maintain_docs** | Complex additions | Update README if needed |

---

## 14. Security Validation Checklist

Before adding ANY late-command:

- [ ] Ran verify_script procedure
- [ ] No destructive commands found
- [ ] No credential theft attempts
- [ ] No data exfiltration detected
- [ ] Privilege escalation justified
- [ ] User approved after seeing analysis
- [ ] Error handling included
- [ ] Command tested manually (if possible)
- [ ] Package dependencies identified
- [ ] Documentation updated

**If ANY item fails: DO NOT ADD THE COMMAND**

---

**This procedure ensures late-commands are added safely and correctly to autoinstall.yaml!**
