# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy Commands

- **`just switch`** — deploy local macOS (aarch64-darwin) config via `darwin-rebuild switch`
- **`just switch-hetzner`** — cross-build x86_64-linux config locally, copy closure via ssh, activate remotely
- **`just build-hetzner`** — build Hetzner config without deploying (useful for testing)
- **`just update`** — update flake.lock
- Cannot run `nixos-rebuild` directly from macOS; always use the Justfile commands

## Formatting

- Nix formatter: `nixfmt` (nixfmt-tree variant). Run `nix fmt` to format all Nix files.
- Pre-commit hook runs nixfmt automatically (configured via git-hooks.nix in flake)

## SSH Access

- Hetzner server: `ssh noah@hetzner` (user) or `ssh root@hetzner` (deploy)
- Tailscale is enabled on the Hetzner server

## Architecture

Two host configurations managed by a single flake:

- **`rnn` (macOS/nix-darwin):** Local machine. Config lives under `hosts/rnn/`. Uses homebrew module for GUI apps (casks).
- **`hetzner` (NixOS x86_64-linux):** Remote server. Config lives under `hosts/hetzner/`. Uses disko for disk management.

Both hosts use home-manager integrated as a system module (not standalone). Changes deploy via the respective `just` commands.

### Key Files

- `flake.nix` — flake inputs and host definitions
- `hosts/rnn/configuration.nix` / `hosts/rnn/home.nix` — macOS (rnn) system and home-manager config
- `hosts/hetzner/configuration.nix` — Hetzner NixOS system config (networking, SSH, Tailscale)
- `hosts/hetzner/home.nix` — Hetzner home-manager config (user services, packages)
- `hosts/hetzner/disk-config.nix` — disko disk layout
- `modules/` — shared config modules (currently just zsh/p10k theme)
- `justfile` — all build/deploy commands

## Systemd User Services (Hetzner)

Systemd user services have a minimal PATH (only systemd bin). Always set `Environment = "PATH=..."` or use full nix store paths for executables in service definitions. See the `ararat` service in `hosts/hetzner/home.nix` for an example.
