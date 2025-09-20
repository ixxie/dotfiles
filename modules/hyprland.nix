{ pkgs, ... }:

{
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    kitty # required for the default Hyprland config
  ];
}
