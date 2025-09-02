update:
  nix flake update nixpkgs

build:
  sudo darwin-rebuild build --flake .
  
switch:
  sudo darwin-rebuild switch --flake .