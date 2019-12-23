{ config, pkgs, ... }: {
  programs.starship.enableZshIntegration = true;

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      path = "${config.xdg.dataHome}/zsh/history";
      save = 30000;
      share = true;
    };
    initExtra = let editor = "${config.home.sessionVariables.EDITOR}";
    in ''
      bindkey "$${terminfo[khome]}" beginning-of-line
      bindkey "$${terminfo[kend]}" end-of-line
      bindkey "$${terminfo[kdch1]}" delete-char
      bindkey '\eOA' history-substring-search-up
      bindkey '\eOB' history-substring-search-down
      bindkey "^[[A" history-substring-search-up
      bindkey "^[[B" history-substring-search-down
      bindkey "$$terminfo[kcuu1]" history-substring-search-up
      bindkey "$$terminfo[kcud1]" history-substring-search-down
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;3D" backward-word

      bindkey -s "^O" '${editor} $(fzf -m)^M'
    '';
    sessionVariables = { RPROMPT = ""; };
    plugins = [
      {
        # https://github.com/zdharma/fast-syntax-highlighting
        name = "fast-syntax-highlighting";
        file = "fast-syntax-highlighting.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma";
          repo = "fast-syntax-highlighting";
          rev = "634ab246365ef6b465b4cdf7c6f0727ec04759a9";
          sha256 = "19hxd3176m1kz5969hfhgsjk5cjfxiacvzn47wm77vxg8zihrq89";
        };
      }
      {
        # https://github.com/endaaman/lxd-completion-zsh
        name = "lxd-completion-zsh";
        file = "_lxc";
        src = pkgs.fetchFromGitHub {
          owner = "endaaman";
          repo = "lxd-completion-zsh";
          rev = "87d20cb0c5d5261cdc469a2d16a679f577038204";
          sha256 = "1s2l8w4hr8v0r26dqqflqgmqsl3yadq2gddlicpg9vkgwdhrf1lh";
        };
      }
      {
        # https://github.com/zdharma/history-search-multi-word
        name = "history-search-multi-word";
        file = "history-search-multi-word.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma";
          repo = "history-search-multi-word";
          rev = "0713e6dd8a8757d8caa100009487b520c15e94fa";
          sha256 = "0fmsy96f6kvzcnd2shb6s1qmymrf1ddqgf3l1zj1isd1fhzwqsnw";
        };
      }
      {
        # https://github.com/hlissner/zsh-autopair
        name = "zsh-autopair";
        file = "zsh-autopair.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
      }
      {
        # https://github.com/chisui/zsh-nix-shell
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "a65382a353eaee5a98f068c330947c032a1263bb";
          sha256 = "0l41ac5b7p8yyjvpfp438kw7zl9dblrpd7icjg1v3ig3xy87zv0n";
        };
      }
      {
        # https://github.com/hcgraf/zsh-sudo
        name = "zsh-sudo";
        file = "sudo.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "hcgraf";
          repo = "zsh-sudo";
          rev = "d8084def6bb1bde2482e7aa636743f40c69d9b32";
          sha256 = "1dpm51w3wjxil8sxqw4qxim5kmf6afmkwz1yfhldpdlqm7rfwpi3";
        };
      }
      {
        # https://github.com/zsh-users/zsh-history-substring-search
        name = "zsh-history-substring-search";
        file = "zsh-history-substring-search.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "0f80b8eb3368b46e5e573c1d91ae69eb095db3fb";
          sha256 = "0y8va5kc2ram38hbk2cibkk64ffrabfv1sh4xm7pjspsba9n5p1y";
        };
      }
    ];
    shellAliases = {
      # misc
      tupd =
        "rsync -Pav --delete ~/documents/torrents/ viking.whatbox.ca:watch/";
      cat = "bat";
      # rust
      c = "cargo";
      cb = "cargo build";
      cbr = "cargo build --release";
      cc = "cargo check";
      ccl = "cargo clean";
      cdoc = "cargo doc";
      clp = "cargo clippy";
      cr = "cargo run";
      crr = "cargo run --release";
      ct = "cargo test";
      ctr = "cargo test --release";
      # exa
      l = "exa --binary --header --long --classify --git";
      la = "l --all";
      ls = "l";
    };
  };
}
