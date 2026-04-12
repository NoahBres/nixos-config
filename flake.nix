{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:NoahBres/nix-darwin/defaults-add-nsmenuenableactionimages-with-target-host";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    googleworkspace-cli.url = "github:googleworkspace/cli";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      googleworkspace-cli,
      disko,
      llm-agents,
      determinate,
      git-hooks,
      ...
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#rnn
      darwinConfigurations."rnn" = nix-darwin.lib.darwinSystem {
        modules = [
          { nixpkgs.overlays = [ llm-agents.overlays.default ]; }
          determinate.darwinModules.default
          ./hosts/rnn/configuration.nix
          home-manager.darwinModules.home-manager
        ];
        specialArgs = { inherit inputs; };
      };

      darwinConfigurations."rtk" = nix-darwin.lib.darwinSystem {
        modules = [
          { nixpkgs.overlays = [ llm-agents.overlays.default ]; }
          determinate.darwinModules.default
          ./hosts/rtk/configuration.nix
          home-manager.darwinModules.home-manager
        ];
        specialArgs = { inherit inputs; };
      };

      # Deploy to Hetzner server using:
      # $ nixos-rebuild switch --flake .#hetzner --target-host root@hetzner --use-remote-sudo
      nixosConfigurations."hetzner" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = [ llm-agents.overlays.default ]; }
          disko.nixosModules.disko
          ./hosts/hetzner/configuration.nix
          ./hosts/hetzner/disk-config.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.noah = import ./hosts/hetzner/home.nix;
          }
        ];
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;

      checks.aarch64-darwin.pre-commit-check = git-hooks.lib.aarch64-darwin.run {
        src = ./.;
        hooks.nixfmt.enable = true;
      };

      devShells.aarch64-darwin.default =
        let
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        in
        pkgs.mkShell {
          inherit (self.checks.aarch64-darwin.pre-commit-check) shellHook;
        };
    };
}
