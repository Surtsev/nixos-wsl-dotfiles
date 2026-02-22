# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelParams = ["i915.enable_guc=3" "i915.force_probe=46a3"];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;


  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.ollama = {
    enable = true;
    package = pkgs.ollama;
  };


  qt = {
    enable = true;
    platformTheme = "kde";  # Автоматически использует тему Plasma (Breeze или твою кастомную)
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.surtsev = {
    isNormalUser = true;
    description = "Tom Surtsev";
    extraGroups = [ "networkmanager" "wheel" "docker" "podman" "video" "audio" "render"];
    shell = pkgs.fish;
    packages = with pkgs; [
      kdePackages.kate
      thunderbird
    ];
  };
  users.users.root.shell = pkgs.fish;


  # Install firefox.
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  programs.amnezia-vpn.enable = true;
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [
      kdePackages.breeze
    ];
    package = pkgs.steam.override {
        extraPkgs = pkgs': with pkgs'; [
          kdePackages.breeze
        ];
        extraEnv = {
          XCURSOR_THEME = "breeze-dark";  # твой вариант, или "breeze_cursors"
          XCURSOR_SIZE  = "24";
        };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim neovim-qt 
    wget curl git fish w3m tldr
    home-manager
    podman docker compose2nix
    w3m
    zip unzip
    wl-clipboard
    linuxPackages_6_12.kernel.dev

    gcc clang lld llvm clang-tools
    gnumake cmake pkg-config binutils binutils-unwrapped bear
    bc flex bison openssl pahole elfutils cpio dwarfdump libelf
    perl python3 gnum4 gengetopt xmlto kmod docbook_xsl docbook_xml_dtd_42 docbook_xml_dtd_44
    strace gdb ltrace valgrind
    rustc cargo 
  ];
  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
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

  environment.etc."kernel-build".source = "${pkgs.linuxPackages_6_12.kernel.dev}/lib/modules";
  environment.variables.KERNEL_DIR = "${pkgs.linuxPackages_6_12.kernel.dev}/lib/modules/6.12.70/build";

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  virtualisation.docker.enable = true;

  systemd.services.amnezia-daemon = {
    description = "AmneziaVPN Daemon";
    serviceConfig = {
      ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";  # путь к бинарнику
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
