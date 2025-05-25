#!/bin/bash
set -euo pipefail

MODULE_NAME="rtw88"
MODULE_VERSION="0.6"
SRC_DIR="$(pwd)"

echo "🛠 Installing $MODULE_NAME DKMS module v$MODULE_VERSION..."
echo

# Step 1: Remove old version (if exists)
if dkms status | grep -q "$MODULE_NAME/$MODULE_VERSION"; then
    echo "➡️ Removing existing DKMS module..."
    sudo dkms remove -m $MODULE_NAME -v $MODULE_VERSION --all || true
fi

# Step 2: Copy source to /usr/src
echo "➡️ Copying source files to /usr/src/${MODULE_NAME}-${MODULE_VERSION}..."
sudo rm -rf "/usr/src/${MODULE_NAME}-${MODULE_VERSION}"
sudo cp -r "$SRC_DIR" "/usr/src/${MODULE_NAME}-${MODULE_VERSION}"

# Step 3: DKMS operations
echo "➡️ Adding module to DKMS..."
sudo dkms add -m $MODULE_NAME -v $MODULE_VERSION

echo "➡️ Building module..."
sudo dkms build -m $MODULE_NAME -v $MODULE_VERSION

echo "➡️ Installing module..."
sudo dkms install -m $MODULE_NAME -v $MODULE_VERSION

# Step 4: Add optional fix for ASPM
if ! grep -q "disable_aspm=1" /etc/modprobe.d/rtw88_pci.conf 2>/dev/null; then
    echo "➡️ Applying ASPM power stability fix..."
    echo "options rtw88_pci disable_aspm=1" | sudo tee /etc/modprobe.d/rtw88_pci.conf
fi

echo
echo "✅ DKMS installation complete."
echo "🔁 Please reboot your system for changes to take effect."
