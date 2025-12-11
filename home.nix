{ config, pkgs, ... }:

{
  home = {
    username = "user";
    homeDirectory = "/home/user";
    stateVersion = "24.05";

    packages = with pkgs; [
      # Terminal utilities
      fastfetch
      git
      wget
      curl
      tmux

      # Python ecosystem
      python3
      python3Packages.pip
      uv

      # Programming languages
      go
      rustup
      php

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
    userName = "Your Name";
    userEmail = "your.email@example.com";
    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "main";
    };
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-nix
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      copilot-vim
    ];

    extraConfig = '''
      " Basic settings
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set autoindent
      set smartindent
      set hidden
      set ignorecase
      set smartcase
      set incsearch
      set hlsearch
      set splitbelow
      set splitright
      set clipboard=unnamedplus
      
      " Color scheme
      colorscheme habamax
      
      " Key mappings
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
    ''';
  };

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

      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      bind -r H select-window -t :-
      bind -r L select-window -t :+
      
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      set -g mouse on
      set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
      set -g window-status-current-style 'bg=#89b4fa fg=#1e1e2e bold'
    '';
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export EDITOR=nvim
      export PATH=$PATH:$HOME/.cargo/bin
      export PATH=$PATH:$HOME/go/bin
      
      alias ls='eza --icons'
      alias ll='eza -lah --icons'
      alias cat='bat --theme Catppuccin-mocha'
    '';
  };

  # Home-manager state version
  programs.home-manager.enable = true;
}
