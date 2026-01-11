# Ubuntu Desktop Autoinstall Project

This repository manages automated Ubuntu Desktop installation using Canonical's **autoinstall** format. It includes a complete single-file configuration for deploying a production-ready system.

## Key Features

| Feature | Implementation |
|---------|----------------|
| **Desktop** | ubuntu-desktop-minimal (installed on first boot) |
| **Kubernetes** | kubeadm, kubelet, kubectl v1.31, containerd |
| **Shell Tools** | Homebrew, Oh My Zsh, K9s |
| **Security** | Passwordless sudo, SSH password auth |

## 2-Phase Installation Approach

This project uses a **2-phase approach** for reliable desktop installation:

```
┌─────────────────────────────────────────────────────────┐
│ PHASE 1 (Autoinstall)                                   │
│ • Base Ubuntu Server                                    │
│ • SSH + passwordless sudo                               │
│ • Kubernetes (containerd, kubeadm, kubelet, kubectl)    │
│ • Creates Phase 2 systemd service                       │
└─────────────────────────────────────────────────────────┘
                         ↓ Reboot
┌─────────────────────────────────────────────────────────┐
│ PHASE 2 (First Boot - Automatic)                        │
│ • Installs ubuntu-desktop-minimal                       │
│ • Installs Homebrew, Oh My Zsh, K9s                     │
│ • Reboots into GNOME desktop                            │
└─────────────────────────────────────────────────────────┘
```

**Why 2-Phase?** Installing `ubuntu-desktop-minimal` during autoinstall breaks SSH password authentication. The 2-phase approach installs desktop on first boot after the base system is working.

## Project Structure

### Core Files

| File | Purpose |
|------|---------|
| `context/autoinstall.example.yaml` | Template with all features |
| `context/autoinstall.yaml` | Your personalized config (gitignored) |
| `context/user_data.json` | VM connection info (gitignored) |

### Procedures

| Procedure | Description |
|-----------|-------------|
| `e2e_autoinstall_test/` | End-to-end testing with Packer/QEMU |
| `verify_vm/` | Verify live VM matches configuration |
| `validate_config/` | Validate autoinstall.yaml syntax |

### Installation Bundles

| Bundle | Components |
|--------|------------|
| `kubeadm/` | Kubernetes (integrated into main config) |
| `shell_tools/` | Homebrew, Oh My Zsh, K9s (integrated) |
| `packer_qemu/` | E2E testing infrastructure |

## Quick Start

### 1. Initialize Configuration
```bash
cp context/autoinstall.example.yaml context/autoinstall.yaml
```

### 2. Customize (Required)
Edit `context/autoinstall.yaml`:
```yaml
identity:
  hostname: your-hostname
  username: your-username
  password: "$6$..."  # Generate: echo 'password' | openssl passwd -6 -stdin
```

Replace all `your-username` placeholders in late-commands.

### 3. Validate
```bash
./scripts/validate_config.sh
```

### 4. E2E Test (Optional)
```bash
./context/procedures/e2e_autoinstall_test/files/run-e2e-test.sh
```

### 5. Deploy
Create bootable USB with autoinstall.yaml or use Packer to build VM image.

## Key Learnings

### Heredoc Limitation
Heredocs (`<< EOF`) do NOT work in autoinstall late-commands due to shell escaping issues. Use simple echo commands instead:
```yaml
# ❌ WRONG
- curtin in-target ... -- bash -c 'cat > /file << EOF
content
EOF'

# ✅ CORRECT
- curtin in-target ... -- bash -c 'echo "line1" > /file'
- curtin in-target ... -- bash -c 'echo "line2" >> /file'
```

### Password Hash Escaping
When creating autoinstall.yaml with shell, use single-quoted heredoc to prevent `$` expansion:
```bash
cat > autoinstall.yaml << 'EOF'
password: "$6$salt$hash"
EOF
```

## Post-Installation

After Phase 2 completes and system reboots:

### Initialize Kubernetes
```bash
k8s-init-single-node.sh
```

### Verify Installation
```bash
# Check desktop
dpkg -l ubuntu-desktop-minimal

# Check Kubernetes
kubectl get nodes

# Check shell tools
brew --version
k9s version
```

## Troubleshooting

### Phase 2 Not Running
```bash
# Check status
systemctl status first-boot-phase2.service

# View logs
cat /var/log/phase2.log

# Re-run manually
sudo /usr/local/bin/first-boot-phase2.sh
```

### Re-run Phase 2
```bash
sudo rm /var/lib/phase2-complete
sudo systemctl enable first-boot-phase2.service
sudo reboot
```
