#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display success message
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to display warning message
warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to display error message
error() {
    echo -e "${RED}$1${NC}"
}

# Cleanup
rm -rf device/mediatek/sepolicy_vndr

# Clone repository function
clone_repository() {
    repo_url="$1"
    target_dir="$2"
    args="${@:3}"  # Capture additional arguments

    if [ -d "$target_dir" ]; then
        warning "Directory $target_dir already exists. Skipping clone."
    else
        echo -e "\n${GREEN}Cloning: $repo_url${NC}"
        git clone $args "$repo_url" "$target_dir" || { error "Failed to clone $repo_url"; }
        
        # After cloning, set branch if applicable
        if [[ "$args" == *"-b "* ]]; then
            branch=$(echo "$args" | grep -oP -- "-b \K[^ ]*")
            cd "$target_dir" || return
            git checkout "$branch"
            cd - || return
        fi
    fi
}

# Clone repositories one by one
clone_repository "https://github.com/PixelExperience/hardware_xiaomi" "hardware/xiaomi"
clone_repository "https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_vayu" "vendor/xiaomi/vayu -b thirteen"
clone_repository "https://github.com/PixelExperience-Devices/kernel_xiaomi_vayu" "kernel/xiaomi/vayu" "--depth=1 --single-branch -b thirteen"
clone_repository "https://gitlab.com/AlissonGrizotti/vendor_xiaomi_miuicamera" "vendor/xiaomi/miuicamera" "-b thirteen"

# Set up builder username and hostname
export USES_CCACHE=1
export BUILD_USERNAME=xyradinka
export BUILD_HOSTNAME=$(hostname)

# Display success message
success "Script execution completed successfully."