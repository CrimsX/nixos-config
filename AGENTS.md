# AGENTS.md — NixOS Config

Personal NixOS **flake** for a single host (`L7490`, Lenovo laptop). User
`crimsx`, state version `25.05`. No application code, tests, linter, or CI —
changes are NixOS configuration only.

## Required skill

**Always load the `nixos-dendritic-flakes` skill** before making changes to this
repository. It defines the dendritic pattern conventions, migration procedures,
and anti-patterns used throughout this config.

## Rebuild the running system

```sh
sudo nixos-rebuild boot --upgrade --flake .#L7490
```

Validate and update:

```sh
nix flake check                     # validate the flake
nix flake update                    # update flake.lock
```

Build the ISO image:

```sh
nix build .#nixosConfigurations.exampleIso.config.system.build.isoImage
```

## Flake structure (dendritic pattern)

The repository follows the **dendritic pattern** using `flake-parts` and
explicit top-level module imports:

- `flake.nix` — thin entry point using `flake-parts.lib.mkFlake`.
  Imports all feature and host modules explicitly.
- `modules/hosts/` — concrete machine definitions and instantiation.
- `modules/features/` — reusable NixOS features published through
  `flake.nixosModules.<name>`.
- `users/` (outside the module tree) — Home Manager user configs.

Two `nixosConfigurations`:

- **`L7490`** — main host. Instantiated in
  `modules/hosts/L7490/default.nix`. Configuration in
  `modules/hosts/L7490/configuration.nix` which imports feature modules via
  `self.nixosModules.*`.
- **`desktop`** — desktop host. Configuration in `hosts/desktop/configuration.nix`,
  defined inline in `flake.nix`.
- **`exampleIso`** — minimal ISO defined inline in `flake.nix` using
  `./hosts/isoimage/configuration.nix`.

Home Manager is configured **inline** as a NixOS module, not as a separate
`homeConfigurations` output — `home-manager switch` cannot be run standalone.
Conflicting dotfiles are backed up with a `.backup` extension.

## File tree

| File | Notes |
|---|---|
| `flake.nix` | Thin entry point using `flake-parts.lib.mkFlake`. |
| `modules/hosts/L7490/` | Host L7490: instantiation, config, hardware. |
| `modules/hosts/L7490/default.nix` | Host instantiation (`nixosConfigurations`). |
| `modules/hosts/L7490/configuration.nix` | Host config — imports features + Home Manager + Stylix. |
| `modules/hosts/L7490/hardware.nix` | Hardware wrapped as `nixosModules.L7490-hardware`. |
| `modules/features/core.nix` | Bootloader, kernel, networking, fonts, system packages. |
| `modules/features/users.nix` | User definitions (crimsx). |
| `modules/features/hyprland.nix` | Hyprland enable. |
| `modules/features/niri.nix` | Niri enable. |
| `modules/features/stylix.nix` | Stylix Niri theming. |
| `modules/features/virt-manager.nix` | Virtualization services. |
| `hosts/isoimage/configuration.nix` | Minimal ISO config for exampleIso. |
| `users/crimsx/home.nix` | Home Manager config for crimsx. |
| `cmds.txt` | Reference Nix commands. |
| `update.sh` | System update script (line 2: `suod` typo → `sudo`). |

## Inputs

- `nixpkgs` → `nixos-unstable`
- `nixpkgs-stable` → `nixos-25.05`
- `flake-parts`
- `home-manager`, `stylix`, `nix-flatpak`, `niri`, `xwayland-satellite`
- `zen-browser` → `github:0xc000022070/zen-browser-flake` (not in nixpkgs; used in `core.nix` systemPackages)

## Gotchas

- **`hardware.nix`** at `modules/hosts/L7490/hardware.nix` wraps the auto-generated
  hardware settings. When `nixos-generate-config` produces new values, manually
  update this file — do not edit the generated output directly.
- **`update.sh`** line 2 has a typo: `suod` should be `sudo`.
- **`system.stateVersion = "25.05"`** must match or be compatible with the
  installed NixOS version. Bumping it during an upgrade can break things.
- **`exampleIso`** references `./hosts/isoimage/configuration.nix`, not
  `./modules/hosts/L7490`.
- **Dendritic pattern**: every `.nix` file in `modules/` is a top-level
  flake-parts module. Features publish NixOS modules via
  `flake.nixosModules.<name>`. Host compositions consume them via `self.nixosModules.*`.
  Add new features by adding a file to `modules/features/` and importing it in
  `flake.nix`.
- **`specialArgs` is not used** — flake-parts modules access `inputs` and
  `self` directly. Host-specific NixOS modules receive `pkgs` from the
  `lib.nixosSystem` call.
