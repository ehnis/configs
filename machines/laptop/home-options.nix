{ ... }:
{
  home.homeDirectory = "/home/ehnis";
  home.username = "ehnis";
  imports = [ ./home.nix ];
}
