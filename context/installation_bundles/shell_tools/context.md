# Shell Tools Installation Bundle Context

## Overview
Install Homebrew and Oh My Zsh for enhanced shell experience and package management.

## Goal
Set up a modern development environment with:
- **Homebrew**: Linux package manager for installing developer tools
- **Oh My Zsh**: Zsh configuration framework with themes and plugins
- **Zsh**: Default shell with better features than bash

## Triggers
When should an AI agent invoke this procedure?
- User requests Homebrew installation
- User wants Oh My Zsh or better shell experience
- Setting up development environment
- Following autoinstall.yaml with shell tools

## Prerequisites
**Common:** See common_patterns.md#standard-prerequisites

**Specific:**
- curl installed
- build-essential for Homebrew
- Internet connectivity

## Components Installed

| Tool | Purpose |
|------|---------|
| **Homebrew** | Linux package manager |
| **Zsh** | Z shell |
| **Oh My Zsh** | Zsh configuration framework |
| **k9s** | Kubernetes CLI TUI |

## Logic
Installation workflow:

1. Install zsh and build-essential
2. Install Homebrew (non-interactive)
3. Add brew to PATH (.bashrc)
4. Install Oh My Zsh (non-interactive)
5. Add brew to PATH (.zshrc)
6. Set zsh as default shell

## Related Files
- `context/autoinstall.yaml` - Late-commands for installation
- `installation_bundles/shell_tools/procedure.md` - Step-by-step

## AI Agent Notes
**Safety:** SAFE | User convenience tools, no system changes

**Common Issues:**
- Homebrew requires build-essential
- OMZ install prompts - use RUNZSH=no
- brew not in PATH - add to .zshrc

**Customization:**
```bash
# Change Oh My Zsh theme
nano ~/.zshrc
# Edit ZSH_THEME="robbyrussell"

# Popular themes: powerlevel10k, agnoster, spaceship
```
