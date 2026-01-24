{ config, pkgs, username ? "surtsev", homeDirectory ? "/home/surtsev", ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./modules/neovim.nix
  ];
  home = {
    username = "surtsev";
    homeDirectory = "/home/surtsev";
    stateVersion = "25.05";

    

    packages = with pkgs; [
      # Terminal utilities
      fastfetch
      git
      tmux
      fish
      btop
      yazi

      # Python ecosystem
      uv
      python312
      python312Packages.pip
      python312Packages.black
      python312Packages.pylint
      python312Packages.pytest
      python312Packages.isort

      # Programming languages
      go
      rustup

      # PHP ecosystem
      php84
      phpdocumentor
      php84Packages.composer

      docker  docker-compose
      mycli wp4nix
      mariadb postgresql

      # Additional utilities
      ripgrep
      fzf
      bat
      eza
      jq
    ];
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Surtsev";
      user.email = "surtsev2006@gmail.com";
      core.editor = "nvim";
      init.defaultBranch = "main";
    };
  };

  # SSH configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".addKeysToAgent = "yes";
    extraConfig = ''
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519
    '';
  };

  services.ssh-agent.enable = true;

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    baseIndex = 1;
    keyMode = "vi";
    
    extraConfig = ''
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      bind \| split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      bind -r H select-window -t :-
      bind -r L select-window -t :+
      
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      set -g default-command "exec fish"

      set -g mouse on
      set -g status-style "bg=#1e1e2e fg=#cdd6f4"
      set -g window-status-current-style "bg=#89b4fa fg=#1e1e2e bold"
    '';
  };

  # Fish shell configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Set up environment
      set -gx EDITOR nvim
      set -gx PATH $PATH $HOME/.cargo/bin $HOME/go/bin
      
      # Abbreviations (like aliases but smarter)
      abbr -a ls "eza --icons"
      abbr -a ll "eza -lah --icons"
      abbr -a cat "bat "
      abbr -a cd z
      abbr -a vim nvim
      abbr -a nix-switch "sudo nixos-rebuild switch"
      abbr -a hm-switch "home-manager switch --flake ~/.config/home-manager"
      
      # Functions
      function fish_greeting
        fastfetch
      end
      
      function mkcd
        mkdir -p $argv
        cd $argv
      end
      
      function extract
        set -l filename (basename $argv[1])
        switch $filename
          case "*.tar.gz"
            tar xzf $argv[1]
          case "*.tar.bz2"
            tar xjf $argv[1]
          case "*.tar.xz"
            tar xJf $argv[1]
          case "*.zip"
            unzip $argv[1]
          case "*.rar"
            unrar x $argv[1]
          case "*"
            echo "Unknown file type for $filename"
        end
      end
      
      # fzf integration
      fzf --fish | source
    '';

    shellAliases = {
      l = "eza --icons";
      la = "eza -a --icons";
      lla = "eza -lah --icons";
      lt = "eza --tree --icons";
      llt = "eza --tree -lah --icons";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";
      gd = "git diff";
    };

  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = false;  # Если не используешь bash
    enableZshIntegration = false;   # Если не используешь zsh
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export EDITOR=nvim
      export PATH=$PATH:$HOME/.cargo/bin
      export PATH=$PATH:$HOME/go/bin
      
      alias ls="eza --icons"
      alias ll="eza -lah --icons"
      alias cat="bat --theme Catppuccin-mocha"
    '';
  };

  # Home-manager state version
  programs.home-manager.enable = true;
}
