# nixos-config — Repository Guide

This document walks through every file and folder in this NixOS configuration
repository and explains what it does, how they fit together, and how to work
with them.

## Overview

This is a **dendritic NixOS flake** — a modular, feature-oriented configuration
managed with `flake-parts`. It currently defines three machines:

- **L7490** — main Lenovo laptop
- **desktop** — desktop machine (in progress)
- **exampleIso** — minimal ISO installer image

## Directory layout

```
.
├── flake.nix                     # Entry point
├── flake.lock                    # Pinned input versions (auto-generated)
├── modules/
│   ├── hosts/
│   │   └── L7490/               # L7490 host definition
│   │       ├── default.nix      #   Register the machine (nixosConfigurations)
│   │       ├── configuration.nix #   Compose features into a running system
│   │       └── hardware.nix     #   Hardware-specific settings (disks, kernel modules)
│   └── features/                # Reusable feature modules
│       ├── core.nix             #   Bootloader, kernel, networking, fonts, packages
│       ├── users.nix            #   User account definitions
│       ├── hyprland.nix         #   Hyprland compositor
│       ├── niri.nix             #   Niri compositor
│       ├── stylix.nix           #   Stylix theming for Niri
│       └── virt-manager.nix     #   Virtualization (libvirtd)
├── hosts/                       # Non-dendritic special hosts
│   ├── desktop/                 #   Desktop machine (defined inline in flake.nix)
│   │   └── configuration.nix
│   └── isoimage/                #   ISO installer
│       └── configuration.nix
├── users/
│   └── crimsx/
│       └── home.nix             # Home Manager user configuration
├── docs/                        # This documentation
├── AGENTS.md                    # Instructions for AI coding agents
├── cmds.txt                     # Quick command reference
├── update.sh                    # System update script
└── README.md                    # Project readme
```

## How the dendritic pattern works

Every `.nix` file inside `modules/` is a **top-level flake-parts module**.
Each one publishes reusable NixOS modules through `flake.nixosModules.<name>`.

### Features (`modules/features/`)

A feature owns one concern and exposes a NixOS module:

```nix
{ ... }:
{
  flake.nixosModules.users = { pkgs, ... }: {
    users.users.crimsx = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };
}
```

To add a new feature, create a file in `modules/features/` and add its path
to the `imports` list in `flake.nix`.

### Hosts (`modules/hosts/`)

A host has three responsibilities split into separate files:

1. **`default.nix`** — registers the machine in `flake.nixosConfigurations`
2. **`configuration.nix`** — picks which features to enable and sets
   host-specific values (hostname, state version, etc.)
3. **`hardware.nix`** — hardware-specific settings wrapped as a named module

Host configs consume features via `self.nixosModules.<name>`:

```nix
{ self, ... }:
{
  flake.nixosModules.atlas-configuration = {
    imports = [
      self.nixosModules.core
      self.nixosModules.users
    ];
    networking.hostName = "atlas";
    system.stateVersion = "25.05";
  };
}
```

### Special hosts (`hosts/`)

The `hosts/` directory at the repo root is for configurations that don't follow
the full dendritic pattern (e.g. ISO installers). These are defined inline
in `flake.nix` as separate `nixosSystem` calls.

## Common tasks

### Rebuild the running system

```sh
sudo nixos-rebuild boot --upgrade --flake .#L7490
```

### Update all inputs

```sh
nix flake update
```

### Validate the flake

```sh
nix flake check
```

### Add a new host

1. Create `modules/hosts/<name>/default.nix`, `configuration.nix`, and `hardware.nix`
2. Add all three paths to the `imports` list in `flake.nix`
3. Run `nix flake check` to validate

### Add a new feature

1. Create `modules/features/<name>.nix`
2. Add its path to the `imports` list in `flake.nix`
3. Add `self.nixosModules.<name>` to any host configuration that needs it
4. Run `nix flake check` to validate

## Key things to know

| Thing | Detail |
|---|---|
| **State version** | `25.05` — do not bump during an upgrade without reading the manual |
| **Unfree packages** | Enabled globally via `nixpkgs.config.allowUnfree` |
| **Bootloader** | `systemd-boot` |
| **Display manager** | `ly` |
| **Home Manager** | Inline inside NixOS (not standalone); `home-manager switch` won't work |
| **Auto-generated hardware** | The content of `hardware-configuration.nix` is copied into `modules/hosts/L7490/hardware.nix` — edit that file instead |
| **Editors** | `neovim` is set as the default editor |
