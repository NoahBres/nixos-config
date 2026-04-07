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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE4u43fGs4T20iGpg0k3a2uoBLUoNSd5lrqZgK/ZpaAr" # Hetzner SSH key (1Password)
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0+P4W+wlSLrF4G1LFrr05G2SIm7Tbn1LhVn/3v594IMugazvQoSI/4hbki+SagWDcO9Awy4ZcJc9YK2uU194kpGd2W9x+eygsFVUl7lxqNxG62vXzjpQjRhZJSioMPloSTjRT2djKilDWPMMU78UiGFBRXj6//Wu8RzFX1h1wyV/ULAZIlblHtb/VnjMw8SZbxhJCkKfIHHCAvDjHRLL6hS7AnpH8leSDu2AUryJLAF7U6w775WVKdeSoa8lN5L2vnRXNi7wrKbjBr3NXNi805oGvrRsEm4WGxed02SdE58eKN4vI5R+wLmqSO1Pp59PgazX6IKZOriSSTZ/4C0hpLlRj86GTvC4FFKNL8Kbvmxisy8ZDhRhMZVrNbt2NqrNIFv9nvxzA7BDkbo1cxidwVd3iVHPJP7Jq2/CPX2TNlGiWYN0MvQCwwfPXxwk2rrt8Jtma7OdsaG4MddIN9r5nqw4jxY/u3v4cGj50TFJynU7hTyB/Z3plKAxInaoXAcM= noah@Rnn.local" # Mac SSH key
  ];

  # Tailscale — run `tailscale up --auth-key=<key> --ssh --hostname=hetzner` after first boot
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    curl
    htop
    ghostty.terminfo # Provides xterm-ghostty terminfo for SSH sessions from Ghostty
  ];

  system.stateVersion = "25.05";
}
