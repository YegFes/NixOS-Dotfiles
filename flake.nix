{
  description = "YegFes' NixOS Configuration"; #You can change this to whatever

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # NixOS-WSL
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 

    # Hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Hyprland
    hyprland.url = "github:hyprwm/hyprland";
    waybar-hyprland.url = "github:hyprwm/hyprland";
    xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    # Other
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nur.url = "github:nix-community/NUR";
    nix-colors.url = "github:misterio77/nix-colors";
    spicetify-nix.url = "github:the-argus/spicetify-nix";

    # SFMono w/ patches
    sf-mono-liga-src = {
        url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
        flake = false;
   };
 };

  outputs = { 
    self, 
    nixpkgs, 
    hyprland,
    home-manager, 
    utils,
    NixOS-WSL,
    spicetify-nix,
    ... 
  } @ inputs: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'

    nixosConfigurations = {
      # Define your hostname
      Nvidia-PC = 
        nixpkgs.lib.nixosSystem 
	{
	  system = "x86_64-lispicetify-nix.nixosModule nux";
          specialArgs = { 
	    inherit 
	      inputs 
	      hyprland
	      spicetify-nix
	      ; 
          }; # Pass flake inputs to our config
        # > Our main nixos configuration file <
          modules = [ 
            ./hosts/Nvidia-PC/configuration.nix
	    home-manager.nixosModules.home-manager
	    {
	      home-manager = {
                useUserPackages = true;
                useGlobalPkgs = false;
                extraSpecialArgs = {inherit inputs spicetify-nix;};
                users.yegfes = ./home/desktop/home.nix;
              };
            }
            hyprland.nixosModules.default
            {programs.hyprland.enable = true;}
          ];
        };
      wsl = 
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {nix.registry.nixpkgs.flake = nixpkgs;}
            ./hosts/wsl/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = false;
                users.yegfes = ./home/wsl/home.nix;
              };
          }
          NixOS-WSL.nixosModules.wsl
        ];
      };
    };
    # home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    # homeConfigurations = {
       # Define your username@hostname
    #   "yegfes@Nvidia-PC" = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
    #     extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to our config
         # > Our main home-manager configuration file <
    #     modules = [./home-manager/home.nix];
    #   };
    # };
  };
}
