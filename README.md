# Ubuntu Server Setup Script

![Bash](https://img.shields.io/badge/-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Ubuntu](https://img.shields.io/badge/-Ubuntu-E95420?logo=ubuntu&logoColor=white)

Automated setup script for Ubuntu servers with developer tools, security hardening, and containerization support.

## Features ✨

- **Menu-driven installation** using `dialog`
- **Neovim from source** with latest stable build
- **Docker & Docker Compose** integration
- **GitHub CLI** official installation
- **Rust toolchain** with rustup
- **Security hardening** (UFW firewall, fail2ban)
- **Zsh configuration** with plugins
- SSH key generation & GitHub integration

## Installation ⚡

```bash
git clone https://github.com/yourusername/ubuntu-server-setup.git
cd ubuntu-server-setup
chmod +x setup.sh
sudo ./setup.sh
```

## Usage 🖥️

1. Select components via interactive menu:
   ![Installation Menu](screenshots/menu.png)

2. Automatic installation of:

   - Base development tools
   - Security packages
   - Containerization stack
   - Modern shell tools (LSD, Bat, FZF)

3. Post-install configurations:

   ```bash
   # For Docker permissions
   newgrp docker

   # For GitHub CLI authentication
   gh auth login
   ```

## Included Components 📦

| Category    | Tools                                |
| ----------- | ------------------------------------ |
| Core        | Zsh, Neovim, Git, Curl, Wget         |
| Development | Rust, Build Essentials, CMake, Ninja |
| Security    | UFW, fail2ban, SSH Key Management    |
| DevOps      | Docker (+Compose), GitHub CLI, Tmux  |
| Utilities   | LSD, Bat, Htop, FZF                  |

## Customization 🔧

1. Edit `setup.sh` to modify:

   ```bash
   # Package selection
   PACKAGES=(
     "docker" "Docker Engine + Compose" "off"
     # ... other entries
   )

   # Configuration repos
   NVIM_REPO="https://github.com/yourusername/nvim-config"
   ```

2. Add custom dotfiles to `configs/` directory

## Security Features 🔒

- Automatic UFW firewall setup
- fail2ban intrusion prevention
- SSH ed25519 key generation
- Non-root user best practices
- Secure package sources verification

## License 📄

MIT License - See [LICENSE](LICENSE)
