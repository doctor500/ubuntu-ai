# Update System Procedure

## Quick Reference

```bash
# Full update (APT + Homebrew + cleanup)
ssh user@vm 'sudo apt update && apt list --upgradable'
ssh user@vm 'brew update && brew outdated'

# Apply updates
ssh user@vm 'sudo apt upgrade -y'
ssh user@vm 'brew upgrade'

# Cleanup
ssh user@vm 'sudo apt autoremove -y && sudo apt clean'
```

---

## Phase 1: Scan Available Updates

### 1.1 APT Packages
```bash
# Check for updates
ssh {{USER}}@{{IP}} 'sudo apt update -qq 2>/dev/null'

# List upgradable (parse for changelog)
ssh {{USER}}@{{IP}} 'apt list --upgradable 2>/dev/null | grep -v "^Listing"'
```

**Output format:** `package/source current_ver -> new_ver arch [upgradable from: old]`

### 1.2 Held Packages (Skip by Default)
```bash
ssh {{USER}}@{{IP}} 'apt-mark showhold'
```

**Expected:** `kubelet`, `kubeadm`, `kubectl` — document if updating these.

### 1.3 Homebrew Packages
```bash
ssh {{USER}}@{{IP}} 'brew update >/dev/null 2>&1 && brew outdated'
```

### 1.4 Bundle Version Check
Run verification step from each bundle's `procedure.md`:

| Bundle | Version Check Command |
|--------|----------------------|
| shell_tools | `brew --version && k9s version --short` |
| kubeadm | `kubectl version --client --short` |
| packer_qemu | `packer --version && qemu-system-x86_64 --version` |

---

## Phase 2: Report & Approve

### Summary Template
```
📦 Update Summary for {{HOSTNAME}}

APT Updates (N packages):
| Package | Current | Available |
|---------|---------|-----------|
| pkg1    | 1.0.0   | 1.1.0     |

Homebrew Updates (N packages):
| Package | Current | Available |
|---------|---------|-----------|
| k9s     | 0.50.16 | 0.50.20   |

Held (skipped): kubelet, kubeadm, kubectl

Proceed with updates? (yes/no/selective)
```

---

## Phase 3: Execute Updates

### 3.1 APT Update
```bash
# Capture before versions for changelog
ssh {{USER}}@{{IP}} 'dpkg -l | grep "^ii" | awk "{print \$2, \$3}"' > /tmp/before_versions.txt

# Apply updates
ssh {{USER}}@{{IP}} 'sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y'

# Capture after versions
ssh {{USER}}@{{IP}} 'dpkg -l | grep "^ii" | awk "{print \$2, \$3}"' > /tmp/after_versions.txt

# Diff for changelog
diff /tmp/before_versions.txt /tmp/after_versions.txt | grep "^>" | awk '{print $2, $3}'
```

### 3.2 Homebrew Update
```bash
ssh {{USER}}@{{IP}} 'brew upgrade 2>&1 | tee /tmp/brew_upgrade.log'
```

### 3.3 Cleanup
```bash
ssh {{USER}}@{{IP}} 'sudo apt autoremove -y 2>&1 | grep -E "^Removing|freed"'
ssh {{USER}}@{{IP}} 'sudo apt clean'
ssh {{USER}}@{{IP}} 'brew cleanup -s 2>&1 | grep -E "^Removing|freed"'
```

---

## Phase 4: Verify & Track

### 4.1 Verify Updates Applied
```bash
# Check no pending updates
ssh {{USER}}@{{IP}} 'apt list --upgradable 2>/dev/null | wc -l'
# Expected: 1 (header line only)
```

### 4.2 Check Reboot Required
```bash
ssh {{USER}}@{{IP}} '[ -f /var/run/reboot-required ] && cat /var/run/reboot-required || echo "No reboot required"'
```

### 4.3 Update Update Log
Add entry to `context/vm_update_log.md`:

```markdown
## YYYY-MM-DD

### APT Packages Updated (N packages)
- `package-name` X.X.X → Y.Y.Y

### Homebrew Packages Updated
- `tool-name` X.X.X → Y.Y.Y

### Cleaned Up (N unused packages removed)
- `package-name` (XX MB freed)

### Notes
- Held packages: kubelet, kubeadm, kubectl (v1.31.X)
- Reboot required: [yes/no]
```

**Note:** Only update `context/change_log.md` if you also made structural changes to the project (e.g., modified autoinstall.yaml templates).

---

## Bundle-Specific Updates

### Kubernetes (kubeadm bundle)
**⚠️ CAUTION:** Requires cluster drain and version compatibility check.

```bash
# Check available versions
apt-cache madison kubeadm

# Upgrade procedure (ASK FIRST)
sudo apt-mark unhold kubelet kubeadm kubectl
sudo apt update && sudo apt install -y kubeadm=X.X.X-*
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply vX.X.X
sudo apt install -y kubelet=X.X.X-* kubectl=X.X.X-*
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

### nerdctl (kubeadm bundle)
```bash
# Check latest version
curl -s https://api.github.com/repos/containerd/nerdctl/releases/latest | grep tag_name

# Install new version
NERDCTL_VERSION="X.X.X"
curl -sSL https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz | sudo tar -xz -C /usr/local/bin
```

---

## Troubleshooting

| Issue | Check | Fix |
|-------|-------|-----|
| dpkg lock | `lsof /var/lib/dpkg/lock-frontend` | Wait or kill process |
| Broken packages | `apt --fix-broken install` | Run fix command |
| Homebrew permission | `ls -la $(brew --prefix)` | `sudo chown -R $(whoami) $(brew --prefix)` |
| Held package conflict | `apt-mark showhold` | Unhold if intentional update |
