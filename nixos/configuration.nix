# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
    ./ytkeeper/docker-compose.nix
  ];

  wsl.wslConf.network.generateHosts = false;

  wsl.enable = true;
  wsl.defaultUser = "surtsev";
  wsl.docker-desktop.enable = true;
  xdg.mime.enable = true;
  wsl.interop.includePath = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git fish wget curl neovim
    home-manager
    wslu
    zip   unzip
    podman docker compose2nix
    w3m
  ];
  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      noto-fonts
      noto-fonts-emoji
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrains Mono Nerd Font" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };
  
  programs.nix-ld.enable = true;
  programs.fish.enable = true;

  virtualisation = {
    docker.enable = true;
  };

  
  # Локальные домены
  networking = {
    extraHosts = ''
      127.0.0.1
      ytkeeper
      finance
      ::1 
      localhost
      ytkeeper
    '';
    firewall.allowedTCPPorts = [ 
      80 8080 443 5432 5433 
      3000  # <- ytkeeper
      3001  # <- finance
    ];
  };

  services.nginx = {
    enable = true;
    virtualHosts."ytkeeper" = {
      listen = [ { addr = "127.0.0.1"; port = 80; } ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_connect_timeout 60s;
          proxy_send_timeout 60s;
          proxy_read_timeout 60s;
        '';
      };
    };
  };

  users.users.surtsev = {
    isNormalUser = true;
    home = "/home/surtsev";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "podman"];
  };
  users.users.root.shell = pkgs.fish;

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05"; # Did you read the comment?
}
