#!/bin/bash

# --- Configuration ---
# Modify the lists below to customize the script to your needs.

# 1. Non-Free Codec Swaps
# Format: "package-to-replace replacement-package"
RPM_SWAPS=(
    "ffmpeg-free ffmpeg"
    # Add other swaps here if necessary, e.g., "lame-free lame"
)

# 2. COPR Repositories to Enable
COPR_REPOS=(
    "atim/lazygit"
    "atim/starship"
    "sentry/xpadneo"
)

# 3. RPM Repositories to Add (URLs)
RPM_REPOS=(
    "https://pkg.cloudflare.com/cloudflared-ascii.repo"
    "https://download.docker.com/linux/fedora/docker-ce.repo"
)

# 4. Flatpak Packages to Install from Flathub
FLATPAK_PACKAGES=(
    "com.usebruno.Bruno"
    "io.dbeaver.DBeaverCommunity"
    "com.brave.Browser"
)

# 5. RPM Packages to Remove (if necessary)
PACKAGES_TO_REMOVE=(
    "docker"
    "docker-client"
    "docker-client-latest"
    "docker-common"
    "docker-latest"
    "docker-latest-logrotate"
    "docker-logrotate"
    "docker-selinux"
    "docker-engine-selinux"
    "docker-engine"
)

# 6. Before the install of RPM Packages
user_rpm_config() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    dnf check-update
}

# 7. Main RPM Packages to Install
PACKAGES_TO_INSTALL=(
    # System & Core Utilities
    "dkms"
    "kernel-devel-$(uname -r)"
    "kernel-headers"
    "make"
    "libxcrypt-compat"
    "openssl"
    "lzip"

    # Desktop Environment & GUI Apps
    "calibre"
    "easyeffects"
    "gnome-extensions-app"
    "gnome-shell-extension-appindicator"
    "fastfetch"
    "piper"
    "puddletag"
    "qbittorrent"
    "syncplay"

    # Development Tools
    "android-tools"
    "code"
    "godot"
    "lazygit"
    "npm"

    # Networking & Connectivity
    "bind-utils"
    "bluez"
    "bluez-tools"
    "cloudflared"
    #   "proton-vpn-gnome-desktop"

    # Hardware & Drivers
    "libappindicator-gtk3"
    "rocm-clinfo"
    "rocm-opencl"
    "rocminfo"
    "xpadneo"

    # Shell & Terminal Enhancements
    "starship"

    # Fonts
    "jetbrains-mono-fonts-all"

    # Containerization (Docker CE)
    "docker-ce"
    "docker-ce-cli"
    "containerd.io"
    "docker-buildx-plugin"
    "docker-compose-plugin"
)

# --- Installation Functions ---
# Usually no need to modify this section

# Function to display steps
log_step() {
    echo ""
    echo "-------------------------------------"
    echo ">> Step: $1"
    echo "-------------------------------------"
}

# Perform codec swaps
run_rpm_swaps() {
    log_step "Configuring Codecs"
    if [ ${#RPM_SWAPS[@]} -gt 0 ]; then
        for swap_pair in "${RPM_SWAPS[@]}"; do
            local pkg_from pkg_to

            read -r pkg_from pkg_to <<< "$swap_pair"

            if [[ -n "$pkg_from" && -n "$pkg_to" ]]; then
                echo "Performing swap: Replacing '$pkg_from' with '$pkg_to'"
                sudo dnf swap "$pkg_from" "$pkg_to" --allowerasing -y
            else
                echo "Warning: Skipping invalid swap pair format: '$swap_pair'"
            fi
        done
    else
        echo "No codec swaps configured."
    fi
}


# Enable COPR repositories
enable_copr_repos() {
    log_step "Enabling COPR Repositories"
    if [ ${#COPR_REPOS[@]} -gt 0 ]; then
        for repo in "${COPR_REPOS[@]}"; do
            echo "Enabling COPR repository: $repo"
            sudo dnf copr enable -y "$repo"
        done
    else
        echo "No COPR repositories to enable."
    fi
}

# Add RPM repositories
add_rpm_repos() {
    log_step "Adding RPM Repositories"
    if [ ${#RPM_REPOS[@]} -gt 0 ]; then
        for repo_url in "${RPM_REPOS[@]}"; do
            echo "Adding RPM repository: $repo_url"
            sudo dnf config-manager addrepo --from-repofile="$repo_url" --overwrite
        done
        echo "Updating DNF cache after adding repositories..."
        sudo dnf makecache
    else
        echo "No RPM repositories to add."
    fi
}

# Install Flatpak packages
install_flatpak_packages() {
    log_step "Installing Flatpak Packages"
    if ! command -v flatpak &> /dev/null; then
        echo "Flatpak is not installed. Installing..."
        sudo dnf install -y flatpak
    fi

    if [ ${#FLATPAK_PACKAGES[@]} -gt 0 ]; then
        echo "Installing Flatpak packages from Flathub: ${FLATPAK_PACKAGES[*]}"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak install -y flathub "${FLATPAK_PACKAGES[@]}"
    else
        echo "No Flatpak packages to install."
    fi
}

# Remove specified RPM packages
remove_rpm_packages() {
    log_step "Removing specified RPM Packages"
    if [ ${#PACKAGES_TO_REMOVE[@]} -gt 0 ]; then
        echo "Attempting to remove packages: ${PACKAGES_TO_REMOVE[*]}"
        sudo dnf remove -y "${PACKAGES_TO_REMOVE[@]}"
    else
        echo "No RPM packages specified for removal."
    fi
}

# Install main RPM packages
install_rpm_packages() {
    log_step "Installing main RPM Packages"

    user_rpm_config

    if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
        echo "Attempting to remove packages: ${PACKAGES_TO_INSTALL[*]}"
        sudo dnf install -y --skip-unavailable "${PACKAGES_TO_INSTALL[@]}"
    else
        echo "No RPM packages specified for removal."
    fi
}

# Check for packages update
check_for_update() {
    log_step "Vérification des mises à jour de packages DNF"
    sudo dnf check-update &>/dev/null
    local UPDATE_STATUS=$?

    if [ $UPDATE_STATUS -eq 100 ]; then
        echo "ERROR: Some DNF packages need to be updated before running this script."
        echo "Please run 'sudo dnf upgrade' to update your packages."
        exit 1
    elif [ $UPDATE_STATUS -eq 1 ]; then
        echo "ERROR: An error occurred while checking for package updates."
        echo "Please check your internet connection and repository configuration."
        exit 1
    else
        echo "All DNF packages are up to date. Proceeding with installation..."
    fi
}


# --- Script Execution ---

echo "======================================="
echo " Starting Custom Installation Script   "
echo "======================================="

check_for_update

enable_copr_repos
add_rpm_repos
run_rpm_swaps
remove_rpm_packages
install_rpm_packages
install_flatpak_packages

echo ""
echo "======================================="
echo " Installation completed successfully! 🎉 "
echo "======================================="
echo "Remember to check for any necessary post-installation steps (e.g., adding your user to the 'docker' group)."

exit 0