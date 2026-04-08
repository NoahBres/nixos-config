update:
  nix flake update

build:
  sudo darwin-rebuild build --flake .

switch:
  sudo darwin-rebuild switch --flake .

build-hetzner:
  nix build .#nixosConfigurations.hetzner.config.system.build.toplevel

switch-hetzner:
  #!/usr/bin/env bash
  set -euo pipefail
  out=$(nix build .#nixosConfigurations.hetzner.config.system.build.toplevel --print-out-paths --no-link)
  nix copy --to ssh-ng://root@hetzner "$out"
  ssh root@hetzner "nix-env -p /nix/var/nix/profiles/system --set '$out' && '$out/bin/switch-to-configuration' switch"