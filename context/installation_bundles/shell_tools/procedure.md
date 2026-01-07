# Shell Tools Installation Procedure

## Pre-Execution: Verify Procedure is Current

**Official Documentation:**
- Homebrew: https://brew.sh/ and https://docs.brew.sh/Homebrew-on-Linux
- Oh My Zsh: https://ohmyz.sh/ and https://github.com/ohmyzsh/ohmyzsh

**Last Verified:** 2026-01-07

**Note:** Both tools use dynamic install scripts that auto-update, so versions are always latest.

**Quick Verification:**
```bash
# Check if Homebrew install script is accessible
curl -I https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh 2>&1 | head -1
# Expected: HTTP/2 200

# Check if OMZ install script is accessible
curl -I https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh 2>&1 | head -1
# Expected: HTTP/2 200
```

**If outdated:** Check official docs for installation method changes.

---

## Quick Install (Current VM)

```bash
# Install Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install zsh
sudo apt-get install -y zsh

# Install Oh My Zsh
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc

# Set zsh as default
sudo chsh -s $(which zsh) $USER
```

---

## Step-by-Step

### 1. Install Prerequisites

```bash
sudo apt-get install -y build-essential curl zsh
```

### 2. Install Homebrew

```bash
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Add Homebrew to PATH

```bash
# For bash
echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
source ~/.bashrc

# Verify
brew --version
```

### 4. Install Oh My Zsh

```bash
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 5. Configure Zsh

```bash
# Add brew to zsh
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc

# Set as default shell
sudo chsh -s $(which zsh) $USER
```

### 6. Verify

```bash
zsh -c "source ~/.zshrc && brew --version && echo OMZ: \$ZSH"
```

---

## Customization

### Change Theme

```bash
nano ~/.zshrc
# Find: ZSH_THEME="robbyrussell"
# Change to preferred theme
```

### Popular Themes
- `robbyrussell` (default)
- `agnoster`
- `powerlevel10k` (requires font)
- `spaceship`

### Install Plugins

```bash
# Edit ~/.zshrc
plugins=(git docker kubectl zsh-autosuggestions zsh-syntax-highlighting)
```

---

## Autoinstall.yaml Late-Commands

```yaml
# Install Homebrew
- |
  curtin in-target --target=/target -- su - USERNAME -c '
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >> ~/.bashrc
  echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> ~/.bashrc
  '

# Install Oh My Zsh
- |
  curtin in-target --target=/target -- su - USERNAME -c '
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> ~/.zshrc
  '

# Set default shell
- curtin in-target --target=/target -- chsh -s /usr/bin/zsh USERNAME
```

---

## Troubleshooting

### brew command not found
```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### OMZ not loading
```bash
source ~/.zshrc
```

### Shell not changing
```bash
# Verify
getent passwd $USER | cut -d: -f7
# Should show /usr/bin/zsh

# Logout and login again
```
