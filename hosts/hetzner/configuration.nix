{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader — device is set by disko via the EF02 BIOS boot partition
  boot.loader.grub.enable = true;

  networking.hostName = "hetzner";

  # Static IPv6 — Hetzner assigns a /64; gateway is always fe80::1
  # Verify your address with: ip addr show eth0
  networking.interfaces.eth0.ipv6.addresses = [
    {
      address = "2a01:4f9:c014:631c::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "eth0";
  };
  networking.nameservers = [
    "2606:4700:4700::1111" # Cloudflare
    "2001:4860:4860::8888" # Google
  ];

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Add your SSH public key here
  # Retrieve with: op item get "Hetzner" --reveal --fields "public key"
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE4u43fGs4T20iGpg0k3a2uoBLUoNSd5lrqZgK/ZpaAr"
  ];

  # Tailscale — run `tailscale up --auth-key=<key> --ssh --hostname=hetzner` after first boot
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    curl
    htop
  ];

  system.stateVersion = "25.05";
}
