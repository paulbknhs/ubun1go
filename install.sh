#!/usr/bin/env bash

CONFIG="$HOME/.config"
ZSH="$CONFIG/zsh"
NVIM="$CONFIG/nvim"

TITLE="Installation Setup"
MSG="Wählen Sie die Komponenten aus, die Sie installieren möchten:"

PACKAGES=(
	"ubuntu-server" "Basis-System" "on"
	"build-essential" "Entwicklungswerkzeuge" "on"
	"git" "Git Versionsverwaltung" "on"
	"curl" "Datenübertragungs-Tool" "on"
	"wget" "Datei-Downloader" "on"
	"zsh" "Z-Shell" "on"
	"lsd" "Modernes ls" "on"
	"fzf" "Fuzzy Finder" "on"
	"bat" "cat mit Syntax-Highlighting" "on"
	"neovim" "Neovim (from source)" "on"
	"openssh-server" "SSH-Server" "on"
	"tmux" "Terminal Multiplexer" "on"
	"htop" "Erweiterter Prozess-Viewer" "on"
	"nftables" "Firewall" "on"
	"fail2ban" "Sicherheitstool" "on"
	"docker" "Docker Engine + Compose" "off"
	"gh" "GitHub CLI" "off"
	"rust" "Rust Programming Language" "off"
)

if ! command -v dialog &>/dev/null; then
	sudo apt-get update && sudo apt-get install -y dialog
fi

CHOICES=$(dialog --title "$TITLE" --separate-output --checklist "$MSG" 0 0 0 \
	"${PACKAGES[@]}" 2>&1 >/dev/tty)

clear

if [[ -z $CHOICES ]]; then
	echo "Keine Pakete ausgewählt. Installation wird abgebrochen."
	exit 1
fi

# Pakete und Komponenten trennen
APT_PACKAGES=()
COMPONENTS=()

while IFS= read -r PACKAGE; do
	case "$PACKAGE" in
	"docker" | "gh" | "rust")
		COMPONENTS+=("$PACKAGE")
		;;
	*)
		APT_PACKAGES+=("$PACKAGE")
		;;
	esac
done <<<"$CHOICES"

echo "Aktualisiere System..."
sudo apt-get update && sudo apt-get upgrade -y

echo "Installiere Basis-Pakete..."
sudo apt-get install -y "${APT_PACKAGES[@]}"

# Neovim-Quellinstallation
if printf '%s\n' "${APT_PACKAGES[@]}" | grep -q "neovim"; then
	echo "Installiere Neovim von Quelle..."
	sudo apt remove -y neovim neovim-runtime
	sudo apt install -y ninja-build gettext cmake unzip curl

	git clone https://github.com/neovim/neovim /tmp/neovim
	cd /tmp/neovim
	git checkout stable
	make -j$(nproc) CMAKE_BUILD_TYPE=RelWithDebInfo
	cd build
	cpack -G DEB
	sudo dpkg -i --force-overwrite nvim-linux64.deb
	cd "$HOME"
	rm -rf /tmp/neovim
fi

# Docker Installation
if [[ " ${COMPONENTS[@]} " =~ " docker " ]]; then
	echo "Installiere Docker..."
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo usermod -aG docker $USER
fi

# GitHub CLI Installation
if [[ " ${COMPONENTS[@]} " =~ " gh " ]]; then
	echo "Installiere GitHub CLI..."
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

	sudo apt-get update
	sudo apt-get install -y gh
fi

# Rust Installation
if [[ " ${COMPONENTS[@]} " =~ " rust " ]]; then
	echo "Installiere Rust..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "$HOME/.cargo/env"
	rustup component add rustfmt clippy
fi

# SSH-Schlüssel
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
	echo "Erstelle SSH-Schlüssel..."
	ssh-keygen -t ed25519 -q -N "" -f "$HOME/.ssh/id_ed25519"
	echo "Fügen Sie den folgenden SSH-Schlüssel zu GitHub hinzu:"
	cat "$HOME/.ssh/id_ed25519.pub"
	read -n 1 -p "Drücken Sie RETURN, um fortzufahren."
fi

# Konfigurationen
mkdir -p "$CONFIG"
[[ -d $NVIM ]] || git clone https://github.com/paulbknhs/nvim.git "$NVIM"
[[ -d $ZSH ]] || git clone https://github.com/paulbknhs/zsh.git "$ZSH"

if [[ -d $ZSH ]]; then
	ln -sf "$ZSH"/rc.zsh "$HOME"/.zshrc
	ln -sf "$ZSH"/zsh_plugins.txt "$HOME"/.zsh_plugins.txt
	ln -sf "$ZSH"/.p10k.zsh "$HOME"/.p10k.zsh
fi

for DIR in "$NVIM" "$ZSH"; do
	if [[ -d $DIR ]]; then
		cd "$DIR"
		git remote set-url origin --push "git@github.com:paulbknhs/$(basename $DIR).git"
	fi
done

if command -v zsh &>/dev/null; then
	echo "Wechsle Standard-Shell zu Zsh..."
	sudo chsh -s "$(which zsh)" "$USER"
fi

# Security
echo "Basic Security Hardening:"
sudo ufw allow ssh
sudo ufw enable
sudo systemctl enable fail2ban

echo "Installation abgeschlossen! Beachten Sie:"
echo "- Für Docker-Berechtigungen müssen Sie sich neu anmelden"
echo "- Rust wurde installiert in: ~/.cargo/bin"
echo "- GitHub CLI mit 'gh auth login' konfigurieren"
echo "Ein Neustart wird empfohlen!"
