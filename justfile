update:
  nix flake update

build:
  sudo darwin-rebuild build --flake .#rnn

switch:
  sudo darwin-rebuild switch --flake .#rnn

build-hetzner:
  nix build .#nixosConfigurations.hetzner.config.system.build.toplevel

switch-hetzner:
  #!/usr/bin/env bash
  set -euo pipefail
  out=$(nix build .#nixosConfigurations.hetzner.config.system.build.toplevel --print-out-paths --no-link --no-warn-dirty)
  nix copy --to ssh-ng://root@hetzner --option require-sigs false --substitute-on-destination "$out"
  ssh root@hetzner "nix-env -p /nix/var/nix/profiles/system --set '$out' && '$out/bin/switch-to-configuration' switch"