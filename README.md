# Custom ROM Device Tree & HAL Cloning Script for Nothing Phone 2 (Pong)

Welcome to the **Custom ROM Cloning Script** repository! This script simplifies cloning the necessary repositories for building custom ROMs for the Nothing Phone 2, ensuring an efficient and seamless development process.

## Features

- **Device Tree**: Clone the device tree repository for Nothing Phone 2 (Pong).
- **HAL Repositories**: Clone and set up essential Hardware Abstraction Layer (HAL) components, including display, audio, sepolicy, and more.
- **Kernel Repositories**: Get kernel source, modules, and device trees ready for building.
- **Paranoid Glyph**: Include Paranoid Glyph components for customization.
- **Dolby Support**: Clone Dolby hardware repositories for audio enhancements.
- **Customizable Build Metadata**: Option to override `BUILD_USERNAME` and `BUILD_HOSTNAME` for reproducible builds.

## Getting Started

To get started, run the following command in your terminal:

```bash
wget https://raw.githubusercontent.com/Thunderstorm1708/setup_script/refs/heads/17-6.12-src/setup.sh && bash setup.sh
```

### Prerequisites

- A Linux-based development environment.
- Git installed and configured.
- Basic familiarity with custom ROM development.

### How It Works

- The script clones the required repositories for device tree, vendor, kernel, and HALs.
- Allows you to set custom build metadata (`BUILD_USERNAME` and `BUILD_HOSTNAME`).
- Automatically sets up your development directory for ROM building.

## Repository List

Here are the repositories the script clones:

- **Device Tree**: [device\_nothing\_Pong](https://github.com/Thunderstorm1708/device_nothing_Pong) (`17-6.12-src`)
- **Vendor Tree**: [vendor\_nothing\_Pong](https://github.com/Thunderstorm1708/vendor_nothing_Pong) (`17-6.12-redducc`)
- **Kernel Tree** (6.12, built from source):
  - [kernel\_nothing\_pong](https://github.com/Thunderstorm1708/kernel_nothing_pong) (`17-6.12`, full ACK history)
  - [kernel\_nothing\_sm8475-modules](https://github.com/Thunderstorm1708/kernel_nothing_sm8475-modules) (`17-6.12`)
  - [kernel\_nothing\_pong-devicetree](https://github.com/Thunderstorm1708/kernel_nothing_pong-devicetree) (`17-6.12`)
- **Display HAL**: [android\_hardware\_qcom\_display](https://github.com/Thunderstorm1708/android_hardware_qcom_display) (`17-6.12`, LineageOS `lineage-24.0-caf-sm8450-6.6` with the Pong fixes), cloned to `hardware/qcom-caf/sm8450-6.6/display/hal`
- **Paranoid Glyph**: [packages\_apps\_ParanoidGlyph](https://github.com/Pong-Development/packages_apps_ParanoidGlyph)
- **Glyph Adapter**: [packages\_apps\_GlyphAdapter](https://github.com/Pong-Development/packages_apps_GlyphAdapter)
- **Dolby**: [hardware\_dolby](https://github.com/Pong-Development/hardware_dolby)

The rest of the sm8450-6.6 HAL stack (audio, media, display core/intf, ...)
comes from the ROM's lineage-24.0 based manifest: run `repo sync` first.

## Notes

- For **AOSPA-based ROMs**, use the `clo/caf` branch of tree and vendor and default glyph repo.
- If unsure about branches, the script will use defaults compatible with most builds.

---

Feel free to suggest changes or improvements to the repository!

