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

build-hetzner:
  nix build .#nixosConfigurations.hetzner.config.system.build.toplevel

switch-hetzner:
  #!/usr/bin/env bash
  set -euo pipefail
  out=$(nix build .#nixosConfigurations.hetzner.config.system.build.toplevel --print-out-paths --no-link --no-warn-dirty)
  nix copy --to ssh-ng://root@hetzner --option require-sigs false --substitute-on-destination "$out"
  ssh root@hetzner "nix-env -p /nix/var/nix/profiles/system --set '$out' && '$out/bin/switch-to-configuration' switch"
