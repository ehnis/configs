{
  inputs = {
    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pipewire-screenaudio.url = "github:IceDBorn/pipewire-screenaudio";
    ags.url = "github:Aylur/ags";
  };

  outputs = {self, nixpkgs, home-manager, ...} @ inputs: let user = "ehnis"; hostname = "nixos"; in { # DON'T FORGET TO CHANGE USERNAME AND HOSTNAME HERE <<<<<<<<<<
    nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs user hostname; };
      modules = [
        ./configuration.nix
	home-manager.nixosModules.home-manager
          {
            home-manager = {
	      extraSpecialArgs = { inherit inputs; }; 
              useGlobalPkgs = true;
              users."${user}" = import ./home.nix;
              useUserPackages = true;
            };
          }
      ];
    };
  };
}
