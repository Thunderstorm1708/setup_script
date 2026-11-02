#!/bin/bash

# Welcome message
echo ""
echo " ███╗   ██╗ ██████╗ ████████╗██╗  ██╗██╗███╗   ██╗ ██████╗     ██████╗ ██╗  ██╗ ██████╗ ███╗   ██╗███████╗    ██████╗  "
echo " ████╗  ██║██╔═══██╗╚══██╔══╝██║  ██║██║████╗  ██║██╔════╝     ██╔══██╗██║  ██║██╔═══██╗████╗  ██║██╔════╝    ╚════██╗ "
echo " ██╔██╗ ██║██║   ██║   ██║   ███████║██║██╔██╗ ██║██║  ███╗    ██████╔╝███████║██║   ██║██╔██╗ ██║█████╗       █████╔╝ "
echo " ██║╚██╗██║██║   ██║   ██║   ██╔══██║██║██║╚██╗██║██║   ██║    ██╔═══╝ ██╔══██║██║   ██║██║╚██╗██║██╔══╝      ██╔═══╝  "
echo " ██║ ╚████║╚██████╔╝   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝    ██║     ██║  ██║╚██████╔╝██║ ╚████║███████╗    ███████╗ "
echo " ╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚══════╝ "
echo ""

echo "=========================================================================="
echo "   Welcome to the Custom ROM Cloning Script for Nothing Phone 2 (Pong)!   "
echo "=========================================================================="
echo ""
echo "✨ Happy custom ROM building! ✨"
echo ""
echo "🔧 Build script by: GHOST | ゴースト"
echo ""

# Explain Depth Cloning
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📌 Git Depth Cloning Explanation:"
echo ""
echo "   - **Shallow Clone (--depth=1)**: Only fetches the latest commit, making cloning faster and saving space."
echo "   - **Full Clone**: Fetches the entire repository history, useful for development but slower."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Ask user whether to use depth cloning
echo ""
read -p "Do you want to use depth cloning (--depth=1) for faster cloning? (y/n): " DEPTH_CHOICE
if [[ "$DEPTH_CHOICE" =~ ^[Yy]$ ]]; then
    CLONE_DEPTH="--depth=1"
    echo ""
    echo "✅ Using shallow clone (--depth=1) for faster setup."
    echo ""
else
    CLONE_DEPTH=""
    echo ""
    echo "✅ Using full repository clone."
    echo ""
fi

# Define repositories
# 6.12 kernel built from source (inline, like 5.10) + the sm8450-6.6 HAL stack
# from the LineageOS 24.0 manifest. No KernelSU.
declare -A REPOS=(
    ["device/nothing/Pong"]="https://github.com/Thunderstorm1708/device_nothing_Pong.git|17-6.12-src"
    ["vendor/nothing/Pong"]="https://github.com/Thunderstorm1708/vendor_nothing_Pong.git|17-6.12-redducc"
    ["kernel/nothing/sm8475"]="https://github.com/Thunderstorm1708/kernel_nothing_sm8475.git|17-6.12"
    ["kernel/nothing/sm8475-modules"]="https://github.com/Thunderstorm1708/kernel_nothing_sm8475-modules.git|17-6.12"
    ["kernel/nothing/sm8475-devicetrees"]="https://github.com/Thunderstorm1708/kernel_nothing_sm8475-devicetrees.git|17-6.12"
    ["packages/apps/ParanoidGlyphPhone2"]="https://github.com/Pong-Development/packages_apps_ParanoidGlyph.git|17"
    ["packages/apps/GlyphAdapter"]="https://github.com/Pong-Development/packages_apps_GlyphAdapter.git|16"
    ["hardware/dolby"]="https://github.com/Pong-Development/hardware_dolby.git|16"
)

# The prebuilt kernel package is not used with the source build
rm -rf device/nothing/Pong-kernel

# The kernel build needs rsync and patch on the host (soc-repo staging)
for tool in rsync patch; do
    if ! command -v "$tool" >/dev/null; then
        echo "❌ '$tool' is required by the kernel build: install it first."
        exit 1
    fi
done

# Function to clone a repository with error handling
clone_repo() {
    local target_dir="$1"
    local repo_data="$2"

    IFS='|' read -r repo_url branch <<< "$repo_data"

    echo "Cloning $target_dir..."
    echo "Repository: $repo_url"
    echo "Branch: $branch"

    rm -rf "$target_dir"

    if git clone $CLONE_DEPTH -b "$branch" "$repo_url" "$target_dir"; then
        echo ""
        echo "✅ Successfully cloned ✨ $target_dir"
        echo "🌿 Branch: $branch"
        echo ""
    else
        echo ""
        echo "❌ Failed to clone $target_dir"
        echo "🌿 Branch: $branch"
        echo ""
        exit 1
    fi
}

# Override host metadata for reproducible builds
read -p "Do you want to override BUILD_USERNAME and BUILD_HOSTNAME? (y/n): " OVERRIDE_CHOICE
if [[ "$OVERRIDE_CHOICE" =~ ^[Yy]$ ]]; then
    read -p "Enter your desired BUILD_USERNAME: " BUILD_USERNAME
    read -p "Enter your desired BUILD_HOSTNAME: " BUILD_HOSTNAME
    
    export BUILD_USERNAME="$BUILD_USERNAME"
    export BUILD_HOSTNAME="$BUILD_HOSTNAME"
    
    echo ""
    echo "BUILD_USERNAME is set to: $BUILD_USERNAME"
    echo "BUILD_HOSTNAME is set to: $BUILD_HOSTNAME"
    echo ""
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Using default BUILD_USERNAME and BUILD_HOSTNAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

# Clone repositories
for target_dir in "${!REPOS[@]}"; do
    clone_repo "$target_dir" "${REPOS[$target_dir]}"
done

# Make sure the sm8450-6.6 HAL stack from the LineageOS manifest is synced
if [ ! -d hardware/qcom-caf/sm8450-6.6/display/hal ]; then
    echo "hardware/qcom-caf/sm8450-6.6 is missing: run 'repo sync' on a lineage-24.0 manifest first."
    exit 1
fi

# Join the camera library that is split for GitHub
. device/nothing/Pong/vendorsetup.sh

# setup done
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ✅ Setup completed successfully! "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "🚀 All repositories have been cloned successfully!"
echo ""
echo "🎉 Enjoy building your custom ROM!"

echo ""
echo "✨ Done! Happy flashing! ✨"
echo ""
