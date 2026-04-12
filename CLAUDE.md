# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy Commands

- **`just switch`** — deploy local macOS (aarch64-darwin) config via `darwin-rebuild switch`
- **`just update`** — update flake.lock
- Cannot run `nixos-rebuild` directly from macOS; always use the Justfile commands

## Formatting

- Nix formatter: `nixfmt` (nixfmt-tree variant). Run `nix fmt` to format all Nix files.
- Pre-commit hook runs nixfmt automatically (configured via git-hooks.nix in flake)

## Architecture

Two host configurations managed by a single flake:

- **`rnn` (macOS/nix-darwin):** Local machine. Config lives under `hosts/rnn/`. Uses homebrew module for GUI apps (casks).
- **`rtk` (macOS/nix-darwin):** Remote Mac. Config lives under `hosts/rtk/`.

Both hosts use home-manager integrated as a system module (not standalone). Changes deploy via the respective `just` commands.

### Key Files

- `flake.nix` — flake inputs and host definitions
- `hosts/rnn/configuration.nix` / `hosts/rnn/home.nix` — macOS (rnn) system and home-manager config
- `modules/` — shared config modules (currently just zsh/p10k theme)
- `justfile` — all build/deploy commands
