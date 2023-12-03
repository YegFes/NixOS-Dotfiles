# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ 
  config, 
  pkgs,
  final,
  prev,
  inputs,
  packages,
  ... 
}: {
  imports = [ 
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot = {
    #initrd.luks.devices."luks-b6d3dd68-88b0-4e7f-a1e5-3642bfba1e8e".device = "/dev/disk/by-uuid/b6d3dd68-88b0-4e7f-a1e5-3642bfba1e8e";
    # Kernel Modules
    kernelModules = ["v4l2loopback"]; # Autostart kernel modules on boot
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback]; # loopback module to make OBS virtual camera work
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable = false;
      timeout = 10;
      efi = {
        # canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiInstallAsRemovable = true; # Otherwise /boot/EFI/BOOT/BOOTX64.EFI
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 3;

	extraEntriesBeforeNixOS = true;
	extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';


        theme =
          pkgs.fetchFromGitHub
          {
            owner = "Lxtharia";
            repo = "minegrub-theme";
            rev = "193b3a7c3d432f8c6af10adfb465b781091f56b3";
            sha256 = "1bvkfmjzbk7pfisvmyw5gjmcqj9dab7gwd5nmvi8gs4vk72bl2ap";
          };

        # theme = pkgs.fetchFromGitHub {
        #   owner = "shvchk";
        #   repo = "fallout-grub-theme";
        #   rev = "80734103d0b48d724f0928e8082b6755bd3b2078";
        #   sha256 = "sha256-7kvLfD6Nz4cEMrmCA9yq4enyqVyqiTkVZV5y4RyUatU=";
        # };
      };
    };
  };

  # Change systemd stop job timeout in NixOS configuration (Default = 90s)
  systemd = {
    services.NetworkManager-wait-online.enable = false;
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

  # Enable networking
  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
    # no need to wait interfaces to have an IP to continue booting
    dhcpcd.wait = "background";
    # avoid checking if IP is already taken to boot a few seconds faster
    dhcpcd.extraConfig = "noarp";
    hostName = "NixOS-PC_Kyiv-Home"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Set your time zone.
  time.timeZone = "Europe/Kyiv";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable programs
  programs = {
    zsh.enable = true;
    steam.enable = true;
    dconf.enable = true;
    hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
      # enableNvidiaPatches = true;
    };
  };

  # Use overlays
  nixpkgs.overlays = [
    (
      final: prev: {
        sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation rec {
          pname = "sf-mono-liga-bin";
          version = "dev";
          src = inputs.sf-mono-liga-src;
          dontConfigure = true;
          installPhase = ''
            mkdir -p $out/share/fonts/opentype
            cp -R $src/*.otf $out/share/fonts/opentype/
          '';
        };
      }
    )
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      sf-mono-liga-bin
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Times, Noto Serif"];
        sansSerif = ["Helvetica Neue LT Std, Helvetica, Noto Sans"];
        monospace = ["Courier Prime, Courier, Noto Sans Mono"];
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Enables docker in rootless mode
  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    # Enables virtualization for virt-manager
    libvirtd.enable = true;
  };


  environment = {
    variables = {
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "0"; # Controls if Adaptive Sync should be used. Recommended to set as “0” to avoid having problems on some games.
      XCURSOR_THEME = "macOS-BigSur";
      XCURSOR_SIZE = "32";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
      WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor rendering issue on wlr nvidia.
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox"; # Set default browser
    };
  };

  hardware = {
    nvidia = {
      open = true;
      powerManagement.enable = true;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [nvidia-vaapi-driver];
    };
  };

  # Configure keymap in X11
  services = {
    # Enable CUPS to print documents.
    # printing.enable = true;
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      displayManager = {
        gdm.enable = true;
      };
      desktopManager = {
        # xfce.enable = true;
        gnome.enable = true;
      };
      # windowManager = {
        # xmonad = {
          # enable = true;
          # enableContribAndExtras = true;
        # };
      # };
      videoDrivers = ["nvidia"];
      layout = "us";
      xkbVariant = "";
      # Enable touchpad support (enabled default in most desktopManager).
      libinput = {
        enable = true;
        mouse = {
          accelProfile = "flat";
        };
        touchpad = {
          accelProfile = "flat";
        };
      };
    };
    logmein-hamachi.enable = false;
    flatpak.enable = false;
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users = {
      yegfes = {
        isNormalUser = true;
        description = "YegFes";
        shell = pkgs.zsh;
        extraGroups = [ "networkmanager" "wheel" "input" "docker" "libvirtd" ];
      };
    };
  };

  # Use doas instead-of sudo
  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = [
        {
          users = ["yegfes"];
          keepEnv = true;
          persist = true;
        }
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    wget
    playerctl
    inputs.xdg-portal-hyprland.packages.${system}.xdg-desktop-portal-hyprland
  ];


  # Enables flakes + garbage collector
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      auto-optimise-store = true;
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  
  system.stateVersion = "24.05"; # Did you read the comment?

}
