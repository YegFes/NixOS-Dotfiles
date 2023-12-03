{
  description = "YegFes' NixOS Configuration"; #You can change this to whatever

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Hyprland
    hyprland-nvidia.url = "github:hyprwm/hyprland";
    waybar-hyprland.url = "github:hyprwm/hyprland";
    xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    # Other
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nur.url = "github:nix-community/NUR";
    nix-colors.url = "github:misterio77/nix-colors";

    # SFMono w/ patches
    sf-mono-liga-src = {
        url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
        flake = false;
   };
 };

  outputs = { 
    self, 
    nixpkgs, 
    home-manager, 
    hyprland-nvidia,
    utils,
    ... 
  } @ inputs: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'

    nixosConfigurations = {
      # Define your hostname
      NixOS-PC_Kyiv-Home = 
        nixpkgs.lib.nixosSystem 
	{
	  system = "x86_64-linux";
          specialArgs = { 
	    inherit 
              inputs
	      hyprland-nvidia
	      ; 
          }; # Pass flake inputs to our config
        # > Our main nixos configuration file <
          modules = [ 
            ./hosts/NixOS-PC_Kyiv-Home/configuration.nix
	    home-manager.nixosModules.home-manager
	    {
	      home-manager = {
                useUserPackages = true;
                useGlobalPkgs = false;
                extraSpecialArgs = {inherit inputs;};
                users.yegfes = ./home/desktop/home.nix;
            };
            hyprland-nvidia.nixosModules.default
            {programs.hyprland.enable = true;}
        ];
      };
    };

   # home-manager configuration entrypoint
   # Available through 'home-manager --flake .#your-username@your-hostname'
   # homeConfigurations = {
      # Define your username@hostname
   #   "yegfes@NixOS-PC_Kyiv-Home" = home-manager.lib.homeManagerConfiguration {
   #     pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
   #     extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
   #     modules = [./home-manager/home.nix];
   #   };
   # };
  };
}
