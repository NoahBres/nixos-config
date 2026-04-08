{ pkgs, ... }:
{
  home.username = "noah";
  home.homeDirectory = "/home/noah";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    git
    ripgrep
    fd
    jq
  ];

  programs.bash.enable = true;

  programs.git = {
    enable = true;
    userName = "Noah Bresler";
    userEmail = "noahbres@gmail.com";
  };

  programs.home-manager.enable = true;
}
