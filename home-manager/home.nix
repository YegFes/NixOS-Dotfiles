
{ config, pkgs, inputs, lib, ... }:

{
  home.username = "yegfes";
  home.homeDirectory = "/home/yegfes";
  home.stateVersion = "24.05";
  nixpkgs = {
		config = {
			allowUnfree = true;
			allowUnfreePredicate = (_: true);
		};
	};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
        bat
        fzf
        ripgrep
        jq
        tree
        eza
	];
  
  programs.neovim = {
  	enable = true;
  	viAlias = true;
	vimAlias = true;
  	};

	home.sessionVariables = {
		EDITOR="nvim";
	};
	home.shellAliases = {
		l = "eza";
		ls = "eza";
		cat = "bat";
	};

	programs.zsh = {
		enable = true;
	};

	programs.zsh.oh-my-zsh= {
		enable = true;
		plugins = ["git" "python" "docker" "fzf"];
		theme = "dpoggi";
	};

}

