{ pkgs, ... }: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = false;
    signing = {
      key = "589412CE19DF582AE10A3320E421C74191EA186C";
      signByDefault = true;
    };
    userEmail = "meurerbernardo@gmail.com";
    userName = "Bernardo Meurer";
    extraConfig = {
      mergetool.prompt = true;
      difftool.prompt = true;
      github = { user = "lovesegfault"; };
    };
  };
}
