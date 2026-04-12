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

switch-rtk:
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ "$(scutil --get LocalHostName)" == "rtk" ]]; then
    sudo darwin-rebuild switch --flake .#rtk
  else
    darwin-rebuild switch --flake .#rtk --target-host noah@rtk.local --use-remote-sudo
  fi
