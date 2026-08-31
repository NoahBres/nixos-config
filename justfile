# Auto-detect the current host for local darwin builds
host := `scutil --get LocalHostName`

update:
  nix flake update

# Auto-detect host and build/switch local darwin config
build:
  sudo darwin-rebuild build --flake .#{{host}}

switch:
  sudo darwin-rebuild switch --flake .#{{host}}

# Explicit per-host local commands
build-rnn:
  sudo darwin-rebuild build --flake .#rnn

switch-rnn:
  sudo darwin-rebuild switch --flake .#rnn

build-rtk:
  sudo darwin-rebuild build --flake .#rtk

# NOTE (2026-08-01): used to run remotely via `darwin-rebuild --target-host
# --use-remote-sudo`, which only existed on a NoahBres/nix-darwin fork branch.
# We dropped that fork (it was blocking on an unrelated nixos-render-docs
# incompatibility and we didn't want to maintain it), so this now SSHes into
# rtk and runs `just switch` there instead. Untested since the switch -- rtk
# hasn't been deployed to in a while. If this breaks, the old fork-based
# behavior is in git history (see flake.nix before this commit).
switch-rtk:
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ "$(scutil --get LocalHostName)" == "rtk" ]]; then
    sudo darwin-rebuild switch --flake .#rtk
  else
    ssh noah@rtk.local 'cd ~/Developer/nixos-config && just switch'
  fi
