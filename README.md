# 🦄 My Little Fedora

A personal collection of custom Fedora packages and configurations to quickly set up my computer.

## ⚠️ Note

This script is tailored to personal preferences. Review the package lists before running it to ensure they match your requirements.

## ⚙️ Prerequisites

- A Fedora Linux installation
- **Up-to-date system** (the script will check and exit if updates are needed)
- Internet connection
- Sudo privileges

## 🚀 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Mageas/my-little-fedora.git
   cd my-little-fedora
   ```

2. Make the script executable:
   ```bash
   chmod u+x install_packages.sh
   ```

3. Run the installation script:
   ```bash
   ./install_packages.sh
   ```

## ✨ What the Script Does

- **Checks for Updates**: Verifies system packages are up to date before proceeding
- **COPR Repositories**: Enables custom repositories for additional software
- **RPM Repositories**: Adds third-party repositories
- **Codec Swaps**: Replaces free codecs with full-featured alternatives
- **Package Management**: Removes conflicting packages and installs new ones
- **Flatpak Integration**: Installs selected applications from Flathub

## 🔄 Post-Installation

After running the script, you may need to:

1. Add your user to the Docker group:
   ```bash
   sudo usermod -aG docker $USER
   ```

2. Log out and back in or restart your system for some changes to take effect

## 🛠️ Customization

You can customize the installation by editing the arrays in the script:
- `RPM_SWAPS`: Codec replacements
- `COPR_REPOS`: Custom repositories
- `RPM_REPOS`: Third-party repositories
- `FLATPAK_PACKAGES`: Flatpak applications
- `PACKAGES_TO_REMOVE`: Packages to uninstall
- `PACKAGES_TO_INSTALL`: Main packages to install
- `user_rpm_config`: Executed before the installation of rpm packages
