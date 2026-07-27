# AGENTS.md — NixOS Config

Personal NixOS **flake** for a single host (`L7490`, Lenovo laptop). User
`crimsx`, state version `25.05`. No application code, tests, linter, or CI —
changes are NixOS configuration only.

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

## Flake structure

Two `nixosConfigurations` in `flake.nix`:

- **`L7490`** — main host. `specialArgs`: `inputs`, `system`, `user`, `hostname`.
  Modules: `configuration.nix`, an inline `programs.neovim.defaultEditor = true`
  override, `home-manager` (inline), `stylix`, `hardware-configuration.nix`.
- **`exampleIso`** — minimal ISO using `./hosts/isoimage/configuration.nix`.
  `specialArgs`: `inputs` only.

Home Manager is configured **inline** as a NixOS module, not as a separate
`homeConfigurations` output — `home-manager switch` cannot be run standalone.
Conflicting dotfiles are backed up with a `.backup` extension.

## Key files

| File | Notes |
|---|---|
| `flake.nix` | Flake entrypoint. Defines both nixosConfigurations. |
| `configuration.nix` | System config for `L7490`. |
| `home.nix` | Home Manager config for `crimsx` (imported by the flake). |
| `hardware-configuration.nix` | **Auto-generated** by `nixos-generate-config`. Do not edit. |
| `stylix.nix` | Standalone Stylix module. **Not imported** — dead code. |
| `cmds.txt` | Reference Nix commands. |
| `update.sh` | System update script (has a typo — see Gotchas). |

Dead-code stubs: `modules/waybar.nix`, `modules/niri.nix`, `hosts/L7490.nix`.

## Inputs

- `nixpkgs` → `nixos-unstable`
- `nixpkgs-stable` → `nixos-25.05`
- `home-manager`, `stylix`, `nix-flatpak`, `niri`, `xwayland-satellite`

## Gotchas

- **`hardware-configuration.nix`** is auto-generated and overwritten by
  `nixos-generate-config`. Edit `configuration.nix` instead.
- **`stylix.nix`** is not imported in `flake.nix`. The Stylix flake input is used
  (`inputs.stylix.nixosModules.stylix`), but the local file is dead code unless
  manually added to the module list.
- **`update.sh`** line 2 has a typo: `suod` should be `sudo`.
- **`system.stateVersion = "25.05"`** must match or be compatible with the
  installed NixOS version. Bumping it during an upgrade can break things.
- **`exampleIso`** references `./hosts/isoimage/configuration.nix`, not
  `./hosts/L7490`.
