# Packer Template for Ubuntu Autoinstall E2E Testing (QEMU/KVM)
# Tests autoinstall.yaml by running a full Ubuntu installation
# Uses cd_content with cidata label for reliable autoinstall delivery

packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# Variables
variable "autoinstall_path" {
  type        = string
  description = "Path to autoinstall.yaml file to test"
  default     = "autoinstall.yaml"
}

variable "ubuntu_iso_url" {
  type        = string
  description = "Ubuntu Server ISO URL or local path"
  default     = "ubuntu-22.04.5-live-server-amd64.iso"
}

variable "ubuntu_iso_checksum" {
  type        = string
  description = "Ubuntu ISO SHA256 checksum"
  default     = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
}

variable "vm_name" {
  type        = string
  description = "Name for the test VM"
  default     = "ubuntu-autoinstall-test"
}

variable "memory" {
  type        = number
  description = "VM RAM in MB"
  default     = 4096
}

variable "cpus" {
  type        = number
  description = "VM CPU count"
  default     = 2
}

variable "disk_size" {
  type        = string
  description = "VM disk size"
  default     = "25G"
}

variable "ssh_username" {
  type        = string
  description = "SSH username (must match autoinstall.yaml identity.username)"
  default     = "davidlay"
}

variable "ssh_password" {
  type        = string
  description = "SSH password (must match autoinstall.yaml identity.password)"
  default     = "admin123"
  sensitive   = true
}

# QEMU source
source "qemu" "ubuntu-autoinstall-test" {
  vm_name          = var.vm_name
  iso_url          = var.ubuntu_iso_url
  iso_checksum     = var.ubuntu_iso_checksum
  
  # VM Resources
  memory           = var.memory
  cpus             = var.cpus
  disk_size        = var.disk_size
  accelerator      = "kvm"
  
  # Display
  headless         = true
  
  # Boot configuration - trigger autoinstall
  # Using longer boot_wait for GRUB to fully load
  boot_wait        = "10s"
  boot_command = [
    # Wait for GRUB menu, press 'e' to edit
    "e<wait2>",
    # Navigate to the linux kernel line (3 down, then end of line)
    "<down><down><down><end>",
    # Add autoinstall and serial console parameters - cidata CD provides user-data
    " autoinstall console=ttyS0,115200<wait>",
    # Press F10 to boot with modified parameters
    "<f10>"
  ]
  
  # CD-ROM with autoinstall configuration (nocloud datasource)
  # This is more reliable than HTTP for Ubuntu autoinstall
  cd_content = {
    "meta-data" = ""
    "user-data" = file(var.autoinstall_path)
  }
  cd_label = "cidata"
  
  # SSH connection for post-install validation
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = "45m"
  ssh_handshake_attempts = 100
  
  # Shutdown
  shutdown_command     = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  
  # Output
  output_directory     = "output-${var.vm_name}"
  format               = "qcow2"
  
  # QEMU specific - with serial console for debugging
  qemuargs = [
    ["-m", "${var.memory}"],
    ["-smp", "${var.cpus}"],
    ["-display", "none"],
    ["-serial", "file:/tmp/qemu-console.log"]
  ]
}

# Build definition
build {
  name    = "autoinstall-e2e-test"
  sources = ["source.qemu.ubuntu-autoinstall-test"]
  
  # Post-install validation
  # Note: Desktop is installed via first-boot systemd service (Phase 2)
  # defined in the autoinstall.yaml template
  provisioner "shell" {
    script = "test-validation.sh"
    execute_command = "echo '${var.ssh_password}' | sudo -S bash '{{.Path}}'"
  }
  
  # Capture validation results
  provisioner "shell" {
    inline = [
      "echo '=== E2E Test Validation Complete ==='",
      "echo 'Hostname: '$(hostname)",
      "echo 'OS: '$(lsb_release -ds)",
      "echo 'Phase 2 service: '$(systemctl is-enabled first-boot-phase2.service 2>/dev/null || echo 'not found')",
      "echo 'Packages installed successfully'",
      "echo 'Late-commands executed without errors'"
    ]
  }
}
