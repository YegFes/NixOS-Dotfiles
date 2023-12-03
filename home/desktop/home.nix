
{ 
  config, 
  pkgs, 
  inputs, 
  lib, 
  ... 
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "yegfes";
    homeDirectory = "/home/yegfes";
    stateVersion = "24.05";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.

  # Let Home Manager install and manage itself.

  programs = {
    home-manager = {
      enable = true;
    };
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    zsh = {
      enable = true;
      oh-my-zsh= {
        enable = true;
        plugins = ["git" "python" "docker" "fzf"];
        theme = "dpoggi";
      };
    };
  };

  home.packages = with pkgs; [
    bat
    fzf
    ripgrep
    jq
    tree
    eza
    neofetch
    (nerdfonts.override { fonts = ["JetBrainsMono" "Inconsolata"]; })
    ];

  home.sessionVariables = {
    EDITOR="nvim";
  };

  home.shellAliases = {
    l = "eza";
    ls = "eza";
    cat = "bat";
  };

  imports = [
   # ./alacritty.nix
   # ./cli
   # ./dev
   # ./pkgs
   # ./system
   # ./themes
   # ./services
   # ./graphical
  ];

  # Overlays
  nixpkgs = {
    overlays = [
      (self: super: {
        discord = super.discord.overrideAttrs (
          _: {
            src = builtins.fetchTarball {
              url = "https://discord.com/api/download?platform=linux&format=tar.gz";
            };
          }
        );
      })
      # (import (builtins.fetchTarball {
      #   url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
      # }))
      (import ../../overlays/firefox-overlay.nix)
    ];
    config = {
      allowUnfreePredicate = (_: true);
      packageOverrides = pkgs: {
        # integrates nur within Home-Manager
        nur =
          import
          (builtins.fetchTarball {
            url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
            sha256 = "sha256:1gr3l5fcjsd7j9g6k9jamby684k356a36h82cwck2vcxf8yw8xa0";
          })
          {inherit pkgs;};
      };
    };
  };

  fonts.fontconfig.enable = true;

  # Add support for .local/bin
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
