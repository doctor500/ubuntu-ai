# Docker Installation Procedure

**Reference:** https://docs.docker.com/engine/install/ubuntu/

## 1. Clean Up Old Versions
Ensure no conflicting packages are installed.
```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

## 2. Set Up Repository
Install prerequisites and add the official Docker GPG key and repository.

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

## 3. Install Docker Engine
Install the latest version.
```bash
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 4. Post-Install Configuration (Manage Docker as non-root)
Add the current user to the `docker` group.
```bash
sudo usermod -aG docker $USER
```
*Note: User needs to log out and back in for this to take effect, or use `newgrp docker` temporarily.*

## 5. Verification
Run the hello-world image.
```bash
sudo docker run --rm hello-world
```

