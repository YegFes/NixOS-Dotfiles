_: {
  programs.git = {
    enable = true;
    userName = "YegFes";
    userEmail = "yegfes@gmail.com";
    extraConfig = {
      init = {defaultBranch = "main";};
      core.editor = "nvim";
      pull.rebase = false;
    };
  };
}
