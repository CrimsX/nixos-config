---
name: nixos-dendritic-flakes
description: Design, implement, migrate, review, and troubleshoot NixOS flake repositories using the dendritic pattern. Use for feature-oriented flake-parts repositories where top-level modules are automatically discovered, reusable NixOS or Home Manager modules are exposed through flake outputs, and hosts compose those modules. The primary structure follows Vimjoyer's flake-parts and import-tree approach, with advanced guidance for class-aware and custom deferred-module registries.
compatibility: Requires Nix with flakes enabled. The primary workflow assumes flake-parts and optionally vic/import-tree. Home Manager, nix-darwin, wrapper-modules, and custom deferred-module registries are optional and should only be introduced when required.
metadata:
  version: "2.0.0"
  domain: nixos
  pattern: dendritic
---

# NixOS Dendritic Flakes

Use this skill when working on a Nix or NixOS repository that follows, or should be migrated toward, the dendritic pattern.

The default practical implementation in this skill follows the structure demonstrated by Vimjoyer:

- `flake-parts` evaluates the top-level flake configuration.
- `github:vic/import-tree` discovers top-level modules.
- `modules/hosts/` contains concrete machine definitions.
- `modules/features/` contains reusable features.
- reusable NixOS modules are exposed through `flake.nixosModules`;
- concrete machines are exposed through `flake.nixosConfigurations`;
- system-indexed packages, applications, checks, formatters, and development shells are defined under `perSystem`.

More advanced repositories may replace or supplement `flake.nixosModules` with class-aware `flake.modules.<class>` outputs or explicitly declared `lib.types.deferredModule` options.

Do not mix these approaches without a clear reason.

## Core definition

The dendritic pattern is an application of the Nixpkgs module system in which the repository has a top-level module configuration.

As a default rule, every non-entry-point `.nix` file inside the automatically imported module tree is a module of that same top-level configuration.

Each top-level module:

1. implements one feature or concern;
2. may contribute to every configuration class affected by that feature;
3. stores lower-level NixOS, Home Manager, nix-darwin, or other modules as values;
4. may also define packages, applications, checks, or development shells;
5. is named and located according to the feature it owns.

A dendritic repository is not merely a large `flake.nix` split into smaller files.

The defining property is that the files share the same top-level module type and are organised by feature.

## Required workflow

Before changing a repository, inspect it.

Determine:

- whether it already uses flakes;
- whether `flake-parts` is present;
- whether modules are explicitly imported or automatically discovered;
- whether the importer is `vic/import-tree`, Haumea, a custom importer, or something else;
- whether the imported tree contains only top-level modules;
- whether reusable modules use `flake.nixosModules`, `flake.homeModules`, `flake.modules`, or custom options;
- how hosts are instantiated;
- whether Home Manager is standalone or nested inside NixOS;
- whether wrapper-modules or another package-wrapping system is present;
- how packages are accessed from lower-level modules;
- which formatter, checks, and rebuild commands the repository uses;
- whether `AGENTS.md`, local documentation, or repository skills define additional constraints.

Preserve the existing architecture unless the task explicitly requests a migration.

Do not add a second importer, module registry, host constructor, naming system, or formatter without a concrete need.

## Primary repository structure

Use this as the baseline structure for a new or Vimjoyer-style dendritic repository:

```text
.
├── flake.lock
├── flake.nix
└── modules
    ├── hosts
    │   └── atlas
    │       ├── default.nix
    │       ├── configuration.nix
    │       └── hardware.nix
    └── features
        ├── audio.nix
        ├── git.nix
        ├── niri.nix
        ├── openssh.nix
        └── packages.nix
```

The two primary categories are:

- `hosts/`: concrete machines and machine-specific configuration;
- `features/`: reusable operating-system, user, package, service, desktop, or development features.

Larger repositories may subdivide features:

```text
modules/
├── hosts/
├── features/
│   ├── desktop/
│   ├── development/
│   ├── hardware/
│   ├── programs/
│   ├── services/
│   └── users/
└── framework/
```

Directory names are organisational. They should not change the semantic type of the files.

Every automatically discovered `.nix` file should still be a top-level module unless it is deliberately excluded.

## Flake entry point

Keep `flake.nix` small.

For the primary structure:

```nix
{
  description = "Dendritic NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
      { inherit inputs; }
      (inputs.import-tree ./modules);
}
```

Use:

```nix
import-tree.url = "github:vic/import-tree";
```

Do not use `github:denful/import-tree` for the Vimjoyer structure.

If automatic importing is not wanted, use explicit imports:

```nix
{
  description = "Dendritic NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/hosts/atlas/default.nix
        ./modules/hosts/atlas/configuration.nix
        ./modules/hosts/atlas/hardware.nix
        ./modules/features/audio.nix
        ./modules/features/openssh.nix
      ];
    };
}
```

Do not maintain both automatic discovery and a comprehensive manual import list.

## Top-level module shape

A feature file is a flake-parts module, not directly a NixOS module.

Typical arguments are:

```nix
{ inputs, self, config, lib, withSystem, ... }:
{
  # Top-level flake-parts configuration
}
```

Only request arguments that the module uses.

This is a top-level module:

```nix
{ self, ... }:
{
  flake.nixosModules.openssh = { ... }: {
    services.openssh.enable = true;
  };
}
```

This is a lower-level NixOS module:

```nix
{ config, lib, pkgs, ... }:
{
  services.openssh.enable = true;
}
```

Do not place the second form directly in a directory where `import-tree` expects top-level flake-parts modules.

Wrap it in a top-level module or exclude it from automatic discovery.

## Host structure

A host directory should normally contain three responsibilities.

### Host instantiation

`modules/hosts/atlas/default.nix`:

```nix
{ inputs, self, ... }:
{
  flake.nixosConfigurations.atlas =
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.atlas-configuration
      ];
    };
}
```

The host instantiation should remain small.

It creates the concrete `nixosConfigurations.atlas` output and points it at the host's root NixOS module.

### Host configuration

`modules/hosts/atlas/configuration.nix`:

```nix
{ self, ... }:
{
  flake.nixosModules.atlas-configuration = {
    imports = [
      self.nixosModules.atlas-hardware
      self.nixosModules.audio
      self.nixosModules.openssh
      self.nixosModules.workstation-packages
    ];

    networking.hostName = "atlas";

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    system.stateVersion = "25.11";
  };
}
```

The root host module selects reusable features and contains host-level configuration.

Do not copy entire reusable service, desktop, development, or user configurations into this file.

### Hardware configuration

`modules/hosts/atlas/hardware.nix`:

```nix
{ ... }:
{
  flake.nixosModules.atlas-hardware =
    { config, lib, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
      ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/REPLACE-ME";
        fsType = "btrfs";
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
```

Copy actual generated hardware settings from the machine's `hardware-configuration.nix`.

Do not invent UUIDs, filesystems, boot devices, kernel modules, or storage configuration.

## Feature modules

A feature owns one concern and publishes a reusable lower-level module.

### Simple NixOS feature

`modules/features/audio.nix`:

```nix
{ ... }:
{
  flake.nixosModules.audio = { pkgs, ... }: {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = [
      pkgs.pavucontrol
    ];
  };
}
```

### Service feature

`modules/features/openssh.nix`:

```nix
{ ... }:
{
  flake.nixosModules.openssh = { lib, ... }: {
    services.openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    networking.firewall.allowedTCPPorts =
      lib.mkDefault [ 22 ];
  };
}
```

Do not make security-sensitive assumptions silently.

Confirm whether password login, root login, firewall ports, and key deployment match the user's requirements.

### Package-only NixOS feature

`modules/features/packages.nix`:

```nix
{ ... }:
{
  flake.nixosModules.workstation-packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git
      kitty
      ripgrep
      vim
    ];
  };
}
```

### Cross-cutting feature

A key benefit of the dendritic pattern is that one feature file may contribute to multiple outputs.

`modules/features/example-tool.nix`:

```nix
{ self, ... }:
{
  flake.nixosModules.example-tool = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.example-tool
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.example-tool = pkgs.writeShellApplication {
      name = "example-tool";

      text = ''
        echo "example"
      '';
    };
  };
}
```

The file owns the complete `example-tool` feature:

- how the package is built;
- how it is installed into NixOS.

Do not split these solely because one definition is a package and the other is a NixOS module.

## `perSystem`

Use `perSystem` for outputs indexed by a Nix system, including:

- packages;
- applications;
- checks;
- formatters;
- development shells;
- legacy packages.

Example:

```nix
{ ... }:
{
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt-rfc-style;

    devShells.default = pkgs.mkShell {
      packages = [
        pkgs.git
        pkgs.nil
        pkgs.nixfmt-rfc-style
      ];
    };

    checks.basic = pkgs.runCommand "basic-check" { } ''
      touch "$out"
    '';
  };
}
```

Do not define concrete NixOS machines under `perSystem`.

Concrete machines belong in:

```nix
flake.nixosConfigurations
```

## Accessing `perSystem` packages

Inside a NixOS module, the target package system should come from that NixOS configuration's `pkgs`.

The Vimjoyer-style pattern uses:

```nix
self.packages.${pkgs.stdenv.hostPlatform.system}.example
```

Example:

```nix
{ self, ... }:
{
  flake.nixosModules.example = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.example
    ];
  };
}
```

Within `perSystem`, prefer `self'` for the current system:

```nix
{ ... }:
{
  perSystem = { self', ... }: {
    apps.example.program =
      "${self'.packages.example}/bin/example";
  };
}
```

Use `withSystem` when a top-level definition must explicitly evaluate a particular `perSystem` context:

```nix
{ withSystem, ... }:
{
  flake.nixosModules.example = { pkgs, ... }: {
    environment.systemPackages = [
      (withSystem pkgs.stdenv.hostPlatform.system
        ({ config, ... }: config.packages.example))
    ];
  };
}
```

Follow the repository's established style. Do not mix all three access methods arbitrarily.

## Wrapper modules

Wrapper modules are optional.

They are useful when a program supports declarative wrapping that produces a preconfigured package, but they are not required by the dendritic pattern.

A repository can be dendritic without using wrapper-modules.

When using `nix-wrapper-modules`, include it as an input:

```nix
{
  inputs.wrapper-modules.url =
    "github:BirdeeHub/nix-wrapper-modules";
}
```

Example patterned after the Vimjoyer structure:

```nix
{ inputs, self, ... }:
{
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;

      package =
        self.packages.${pkgs.stdenv.hostPlatform.system}.my-niri;
    };
  };

  perSystem = { lib, pkgs, self', ... }: {
    packages.my-niri =
      inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;

        settings = {
          spawn-at-startup = [
            (lib.getExe self'.packages.my-shell)
          ];

          layout.gaps = 5;
        };
      };
  };
}
```

When calling wrappers from `nix-wrapper-modules`, do not omit:

```nix
inherit pkgs;
```

Wrapper configuration should remain in the feature file that owns the wrapped program.

## Home Manager

Home Manager is optional.

Determine whether it is:

- evaluated as standalone `homeConfigurations`;
- imported as a NixOS module;
- imported as a nix-darwin module;
- already integrated through the Home Manager flake-parts module.

To expose `flake.homeModules` and `flake.homeConfigurations`, add the Home Manager input:

```nix
{
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Import its flake-parts integration from a top-level framework module:

```nix
{ inputs, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];
}
```

A reusable Home Manager feature can then be defined as:

```nix
{ ... }:
{
  flake.homeModules.git = { ... }: {
    programs.git = {
      enable = true;

      extraConfig = {
        init.defaultBranch = "main";
      };
    };
  };
}
```

Avoid hard-coding a real person's email address, signing key, home directory, or username in a generic reusable feature.

For Home Manager nested inside NixOS, a NixOS feature may import the official Home Manager NixOS module and select reusable home modules:

```nix
{ inputs, self, ... }:
{
  flake.nixosModules.primary-user = { ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.example = {
      imports = [
        self.homeModules.git
      ];

      home.stateVersion = "25.11";
    };
  };
}
```

Replace placeholder usernames and state versions with repository-specific values.

## Automatic discovery rules

Automatic discovery is safe only when the discovered files have the expected type.

Inside the imported tree:

- `.nix` feature files should be top-level modules;
- host files should be top-level modules;
- ordinary lower-level modules should be wrapped;
- package expressions should be wrapped or excluded;
- generated JSON, TOML, YAML, images, and other data files may remain beside features because they are not `.nix` modules;
- helper `.nix` expressions must be excluded or moved outside the discovered set.

Do not assume that any arbitrary `.nix` expression can be imported as a flake-parts module.

Reasonable exceptions to the every-file rule are allowed, but they must be deliberate.

Possible strategies include:

- storing helpers outside `modules/`;
- giving helpers an identifiable suffix such as `.pkg.nix`;
- applying an importer filter;
- wrapping the helper in a top-level module;
- using a non-Nix data file where appropriate.

Check the installed `import-tree` version and its current filtering API before changing importer expressions.

## Primary practical registry: `flake.nixosModules`

Use `flake.nixosModules` as the default registry when matching the Vimjoyer structure.

Example:

```nix
{ ... }:
{
  flake.nixosModules.bluetooth = { ... }: {
    hardware.bluetooth.enable = true;
  };
}
```

Consume it through `self`:

```nix
{ self, ... }:
{
  flake.nixosModules.atlas-configuration = {
    imports = [
      self.nixosModules.bluetooth
    ];
  };
}
```

This is simple, visible in flake outputs, and suitable for reusable modules.

Use `flake.nixosConfigurations` only for instantiated machines:

```nix
flake.nixosConfigurations.atlas =
  inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.atlas-configuration
    ];
  };
```

Do not put an instantiated `lib.nixosSystem` result under `flake.nixosModules`.

## Alternative registry: `flake.modules`

The optional flake-parts modules extension provides a class-aware generic registry:

```nix
flake.modules.nixos.<name>
flake.modules.homeManager.<name>
flake.modules.darwin.<name>
```

It adds basic class checking.

Enable it through a top-level module:

```nix
{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];
}
```

Example:

```nix
{ ... }:
{
  flake.modules.nixos.audio = { ... }: {
    services.pipewire.enable = true;
  };
}
```

Use this approach when:

- the repository already uses it;
- class checking is valuable;
- several module classes need one consistent exported registry;
- downstream flakes consume the modules.

Do not introduce it solely because it appears more advanced.

It is an alternative registry, not the definition of the dendritic pattern.

## Advanced canonical registry: custom deferred modules

The most expressive form declares options that reflect the repository's domain model.

Use `lib.types.deferredModule` when multiple feature files should contribute to one meaningful lower-level profile.

Framework module:

```nix
{ lib, ... }:
{
  options.profiles.nixos.base = lib.mkOption {
    type = lib.types.deferredModule;
    description = "Base NixOS configuration shared by all hosts.";
  };

  options.profiles.nixos.workstation = lib.mkOption {
    type = lib.types.deferredModule;
    description = "NixOS configuration shared by workstation hosts.";
  };
}
```

A feature may contribute to the workstation profile:

```nix
{ ... }:
{
  profiles.nixos.workstation = { ... }: {
    services.pipewire.enable = true;
  };
}
```

Another feature may contribute to the same profile:

```nix
{ ... }:
{
  profiles.nixos.workstation = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.kitty
    ];
  };
}
```

Host composition:

```nix
{ config, inputs, ... }:
{
  flake.nixosConfigurations.atlas =
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        config.profiles.nixos.base
        config.profiles.nixos.workstation
        config.profiles.nixos.atlas
      ];
    };
}
```

This approach allows the top-level module system to merge feature contributions under meaningful names.

Use it when:

- several files contribute to one profile;
- the domain has concepts such as `base`, `workstation`, `server`, or `gaming`;
- internal profiles should not necessarily be exported as public flake outputs;
- `flake.nixosModules` names are proliferating;
- long import lists are obscuring the architecture.

Do not add custom deferred-module options to a small repository unless they solve an actual organisation problem.

## Feature granularity

Organise by meaningful concern.

Good feature boundaries include:

- audio;
- Bluetooth;
- Niri;
- development tools;
- gaming;
- OpenSSH;
- Tailscale;
- laptop power management;
- primary user;
- workstation packages.

Avoid creating a uniquely named reusable module for every individual setting when those settings always belong to the same profile.

For example, avoid forcing hosts to import all of these independently:

```nix
self.nixosModules.fonts
self.nixosModules.audio
self.nixosModules.graphics
self.nixosModules.printing
self.nixosModules.desktop-packages
self.nixosModules.bluetooth
```

When appropriate, merge them into:

```nix
self.nixosModules.workstation
```

or contribute them to:

```nix
profiles.nixos.workstation
```

The correct granularity depends on which features are independently reusable.

## Shared values and `specialArgs`

At the top-level flake-parts layer, modules can access:

- `inputs`;
- `self`;
- top-level `config`;
- custom top-level options;
- `withSystem`.

Prefer those mechanisms over passing the entire flake through every lower-level configuration.

Avoid:

```nix
specialArgs = {
  inherit inputs self;
};
```

when it is only being used as a general global-variable mechanism.

A top-level feature can close over values directly:

```nix
{ inputs, ... }:
{
  flake.nixosModules.example = { ... }: {
    environment.systemPackages = [
      inputs.some-package.packages.x86_64-linux.default
    ];
  };
}
```

Use `specialArgs` or `extraSpecialArgs` only when the lower-level module genuinely requires a module argument and lexical capture is unsuitable.

Do not recursively expose every flake input to every nested configuration.

## Enable options

Do not automatically add an `enable` option to every local feature.

In a repository-controlled module set, importing a feature can normally mean enabling that feature.

Prefer:

```nix
imports = [
  self.nixosModules.audio
];
```

over:

```nix
imports = [
  self.nixosModules.audio
];

features.audio.enable = true;
```

Add an enable option when:

- the module must always be imported;
- enabling depends on configuration data;
- multiple modes are supported;
- downstream users need explicit control;
- conditional activation is part of the feature's real interface.

## Migration procedure

When migrating an existing configuration:

1. Read `flake.nix`.
2. Read every import aggregator.
3. Identify all concrete hosts.
4. Identify reusable NixOS and Home Manager modules.
5. Record current outputs with `nix flake show`.
6. Record the current host evaluation or build result.
7. Add `flake-parts` without changing host behaviour.
8. Establish either explicit imports or `vic/import-tree`.
9. Convert one existing feature into a top-level module.
10. Publish its lower-level module through `flake.nixosModules`.
11. Import that module from one host configuration.
12. Evaluate and build the host.
13. Repeat feature by feature.
14. Move concrete host creation into `modules/hosts/<host>/default.nix`.
15. Wrap the hardware configuration as a top-level module.
16. Remove obsolete import aggregators only after all consumers have moved.
17. Consider custom deferred-module profiles only after the baseline migration works.
18. Update repository documentation.

Do not reorganise the entire repository before proving the pattern with one small feature.

Preserve:

- host names;
- flake output names;
- `system.stateVersion`;
- Home Manager state versions;
- filesystems;
- bootloader behaviour;
- storage configuration;
- secret paths;
- network interfaces;
- user IDs;
- package overrides.

Do not silently modernise unrelated configuration during a structural migration.

## Validation

Run the narrowest useful validation first.

Inspect outputs:

```bash
nix flake metadata
nix flake show
```

Run repository checks:

```bash
nix flake check
```

Format:

```bash
nix fmt
```

If the repository formatter supports checking without modification, use its documented check command.

Evaluate a host:

```bash
nix eval \
  .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
```

Build without activating:

```bash
nix build \
  .#nixosConfigurations.<host>.config.system.build.toplevel
```

Test the configuration without making it the permanent boot default:

```bash
sudo nixos-rebuild test --flake .#<host>
```

Activate only when requested:

```bash
sudo nixos-rebuild switch --flake .#<host>
```

For a standalone Home Manager configuration:

```bash
nix build \
  .#homeConfigurations.<user>@<host>.activationPackage
```

Prefer repository-provided commands such as:

```text
just check
nh os test
nh os switch
make check
```

when they are documented as authoritative.

## Common failures

### Option does not exist

Confirm which module system is evaluating the file.

This is invalid at the top-level flake-parts layer:

```nix
{
  services.openssh.enable = true;
}
```

It must be inside a stored NixOS module:

```nix
{
  flake.nixosModules.openssh = {
    services.openssh.enable = true;
  };
}
```

Likewise, `perSystem` is a flake-parts option and cannot be set from inside an ordinary NixOS module.

### Raw hardware module imported by `import-tree`

A generated `hardware-configuration.nix` is normally a NixOS module, not a top-level flake-parts module.

Do not place it unwrapped inside an automatically imported tree.

Wrap it:

```nix
{ ... }:
{
  flake.nixosModules.atlas-hardware = {
    # Generated hardware configuration
  };
}
```

Alternatively, exclude it from automatic discovery and import its path from the wrapper module.

### Infinite recursion

Check for:

- a module importing itself;
- a profile referring to its own final value;
- a package referencing a host that references the same package;
- `self` output cycles;
- custom deferred-module options composed recursively;
- a `perSystem` value depending on a NixOS host that consumes that same value.

Separate:

1. option declaration;
2. feature contribution;
3. host composition.

### Missing package for a system

Do not hard-code `x86_64-linux` when the package should follow the host platform.

Prefer:

```nix
self.packages.${pkgs.stdenv.hostPlatform.system}.example
```

Confirm that `systems` or the relevant `perSystem` configuration includes the host platform.

### Duplicate output

Search the whole repository before adding:

```nix
flake.nixosModules.<name>
flake.nixosConfigurations.<name>
perSystem.packages.<name>
```

Top-level module definitions merge. A duplicate may create a conflict rather than replacing the previous value.

### Wrapper-module evaluation error

Confirm that the wrapper call includes:

```nix
inherit pkgs;
```

Also confirm that the wrapper version matches the settings schema being supplied.

### Home Manager option missing

Confirm that the correct integration is imported.

For flake outputs:

```nix
inputs.home-manager.flakeModules.home-manager
```

For Home Manager nested in NixOS:

```nix
inputs.home-manager.nixosModules.home-manager
```

These serve different purposes.

## Anti-patterns

Do not:

- treat dendritic as only a directory naming convention;
- place raw NixOS modules directly in an auto-imported top-level module tree;
- use the wrong `import-tree` input;
- make `flake.nix` a large implementation file;
- duplicate automatic and manual imports;
- organise everything primarily by output type when feature ownership is the goal;
- create one lower-level module name for every trivial setting;
- make concrete hosts reusable modules without a reason;
- place concrete hosts under `perSystem`;
- put generic features directly into host files;
- put host-specific hardware facts into reusable features;
- pass all inputs through every `specialArgs`;
- add enable options by habit;
- introduce `flake.modules` and custom deferred options simultaneously without a clear architecture;
- assume wrapper-modules are required for dendritic configuration;
- omit `inherit pkgs` from wrapper-module calls;
- rely on module import order for behaviour;
- activate a system before evaluation and build validation;
- silently change storage, boot, secrets, networking, state versions, or user identity.

## Completion report

After changing a repository, report:

- files added;
- files modified;
- files moved or removed;
- which files are top-level modules;
- which lower-level modules were added;
- which registry is used;
- which importer is used;
- which hosts were affected;
- which outputs changed;
- validation commands run;
- validation results;
- checks that were not run and why;
- remaining migration work;
- known risks.

## Acceptance checklist

Before completing a dendritic change, verify:

- [ ] `flake.nix` is a thin entry point.
- [ ] `github:vic/import-tree` is used when following the Vimjoyer structure.
- [ ] Every automatically imported `.nix` file has the expected top-level module type.
- [ ] Raw lower-level modules are wrapped or excluded.
- [ ] Files are organised by feature or concrete host.
- [ ] Reusable NixOS modules use the established registry.
- [ ] Concrete machines use `flake.nixosConfigurations`.
- [ ] System-indexed outputs use `perSystem`.
- [ ] Host modules compose reusable features.
- [ ] Hardware configuration remains machine-specific.
- [ ] Wrapper modules are used only where useful.
- [ ] Wrapper calls include `inherit pkgs`.
- [ ] No competing importer or registry was added.
- [ ] Inputs are referenced explicitly.
- [ ] Output names remain stable unless intentionally changed.
- [ ] State versions remain unchanged unless explicitly requested.
- [ ] The affected host evaluates.
- [ ] The affected host builds.
- [ ] Formatter and flake checks pass.
- [ ] Documentation reflects the final architecture.

## References

- Vimjoyer dendritic-pattern video:
  https://www.youtube.com/watch?v=-TRbzkw6Hjs

- Vimjoyer Niri, Noctalia, wrapper-modules, and dendritic-pattern video:
  https://www.youtube.com/watch?v=aNgujRXDTdE

- Vimjoyer companion article and example files:
  https://www.vimjoyer.com/vid79-parts-wrapped

- Vimjoyer example template:
  https://github.com/vimjoyer/flake-parts-wrapped-template

- Canonical dendritic pattern:
  https://github.com/mightyiam/dendritic

- flake-parts:
  https://flake.parts/

- flake-parts core options:
  https://flake.parts/options/flake-parts.html

- flake-parts generic module registry:
  https://flake.parts/options/flake-parts-modules.html

- Home Manager flake-parts integration:
  https://flake.parts/options/home-manager.html

- import-tree:
  https://github.com/vic/import-tree

- nix-wrapper-modules:
  https://birdeehub.github.io/nix-wrapper-modules/md/intro.html

- Nix flakes:
  https://nix.dev/concepts/flakes.html