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
      zsh
      btop
      yazi
      gh
      tldr
      cava
      direnv
      tree
      glow

      p7zip

      qbittorrent

      # Python ecosystem
      python313
      python313Packages.pip
      python313Packages.black
      python313Packages.isort
      python313Packages.pylint
      python313Packages.python-lsp-server
      python313Packages.python-lsp-black
      python313Packages.pylsp-mypy
      pyright
      uv
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

      ollama 	

      qwen-code	vscode

      telegram-desktop
      obsidian
      discord
      zoom-us
      yandex-music	spotify

      libreoffice-qt-fresh

      prismlauncher

      # Конструкторское (ВУЗ)
      freecad	blender kicad

      kdePackages.kwave
    ];
  };

  systemd.user.services.ollama = {
    Unit = {
      Description = "Ollama Service";
      After = ["network-online.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.ollama}/bin/ollama serve";
      Restart = "on-failure";
      RestartSec = 10;
      WorkingDirectory = "/home/surtsev";
      StandardOutput = "journal";
      StandardError = "journal";
    };
    Install = {
	  WantedBy = ["default.target"];
    };
  };

  programs.kitty = {
    enable = true;

    settings = {

      initial_window_width = 950;
      initial_window_height = 550;
      window_padding_width = 10;

      # Прозрачность
      background_opacity = "0.95";
      dynamic_background_opacity = "yes";

      # ========== ПЛАВНЫЙ КУРСОР ==========
      cursor_shape = "block";
      cursor = "#58a6ff";
      cursor_trail = 300;
      cursor_trail_decay = "0.05 0.5";
      cursor_trail_start_treshold = 0;

      cursor_blink_interval = 0;

	  # ========== ТЕМА GITHUB DARK ==========
      background = "#0d1117";
      foreground = "#c9d1d9";
      selection_background = "#3b434b";
      selection_foreground = "#ffffff";
      
      color0 = "#484f58";
      color1 = "#ff7b72";
      color2 = "#7ee787";
      color3 = "#ffa657";
      color4 = "#79c0ff";
      color5 = "#d2a8ff";
      color6 = "#8b949e";
      color7 = "#c9d1d9";
      color8 = "#6e7681";
      color9 = "#ffa198";
      color10 = "#aff5b4";
      color11 = "#ffdfb3";
      color12 = "#a5d6ff";
      color13 = "#e6c6ff";
      color14 = "#79c0ff";
      color15 = "#ffffff";
      
      active_tab_background = "#0d1117";
      active_tab_foreground = "#58a6ff";
      inactive_tab_background = "#21262d";
      inactive_tab_foreground = "#8b949e";
      tab_bar_background = "#010409";

      # Клавиатура
      copy_on_select = true;
      clipboard_control = "write-clipboard write-primary";

      # ========== КОМБИНАЦИИ КЛАВИШ ==========
      font_size_increment = "ctrl+plus";
      font_size_decrement = "ctrl+minus";
      font_size_reset = "ctrl+0";
      
      # Производительность
      renderer = if pkgs.stdenv.isDarwin then "metal" else "opengl";
      sync_to_monitor = "yes";
    };

    extraConfig = ''
	  cursor_stop_blinking_after 0
      disable_ligatures never
    '';
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Surtsev";
      user.email = "surtsev2006@gmail.com";
      core.editor = "nvim";
      init.defaultBranch = "master";
    };
  };

  # SSH configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".addKeysToAgent = "yes";
    extraConfig = ''

      Host github.com
        ControlMaster auto
        ControlPersist 10m

      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519
    '';
  };

  services.ssh-agent.enable = true;

  # Zsh вместо fish
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "jispwoso"; # или "robbyrussell", "agnoster", "agnosterzak", и т.п.
      plugins = [ "git" "direnv" ];
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Аналог interactiveShellInit
    initContent = ''
      # Environment
      export EDITOR=nvim
      export PATH="$PATH:$HOME/.cargo/bin:$HOME/go/bin:$HOME/dotfiles/bin"

      # Аббревиатуры fish → алиасы zsh
      alias ls="eza --icons"
      alias ll="eza -lah --icons"
      alias cat="bat "
      alias cd="z"
      alias vim="nvim"
      alias update="sh update.sh"
      alias ns="sudo nixos-rebuild switch"
      alias hs="home-manager switch --flake ~/.config/home-manager"

      alias ai="ollama run qwen2.5-coder:7b"

      # Приветствие (fish_greeting)
      function greet_fastfetch() {
        fastfetch
      }
      greet_fastfetch

      # mkcd
      function mkcd() {
        mkdir -p "$1"
        cd "$1"
      }

      # extract
      function extract() {
        local filename
        filename="$(basename "$1")"

        case "$filename" in
          *.tar.gz)  tar xzf "$1" ;;
          *.tar.bz2) tar xjf "$1" ;;
          *.tar.xz)  tar xJf "$1" ;;
          *.zip)     unzip "$1" ;;
          *.rar)     unrar x "$1" ;;
          *) echo "Unknown file type for $filename" ;;
        esac
      }

      # fzf интеграция
      if command -v fzf >/dev/null 2>&1; then
        source <(fzf --zsh)
      fi


    '';

    shellAliases = {
      l   = "eza --icons";
      la  = "eza -a --icons";
      lla = "eza -lah --icons";
      lt  = "eza --tree --icons";
      llt = "eza --tree -lah --icons";
      gs  = "git status";
      ga  = "git add";
      gc  = "git commit";
      gp  = "git push";
      gl  = "git log --oneline";
      gd  = "git diff";
    };
  };

  home.file.".oh-my-zsh/custom/themes/jispwoso.zsh-theme".text = ''
    # Патченная jispwoso с venv
    VIRTUAL_ENV_DISABLE_PROMPT=true

    prompt_jispwoso_venv() {
      if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "(%F{green}$(basename "$VIRTUAL_ENV")%f)"
      fi
    }

    PROMPT='%{$fg[cyan]%}%c%{$reset_color%}$(git_prompt_info)$(prompt_jispwoso_venv)%(!.#.$) '

    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}(%{$fg[red]%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}*%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}"
  '';


  programs.zoxide = {
    enable = true;
    enableFishIntegration = false;
    enableBashIntegration = false;
    enableZshIntegration = true;
  };

  # Bash можно оставить как fallback / для скриптов
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export EDITOR=nvim
      export PATH="$PATH:$HOME/.cargo/bin:$HOME/go/bin"

      alias ls="eza --icons"
      alias ll="eza -lah --icons"
      alias cat="bat --theme Catppuccin-mocha"
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  # Home-manager state version
  programs.home-manager.enable = true;
}
