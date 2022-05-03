# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  nix = {
    autoOptimiseStore = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    
    binaryCaches = [ "https://cache.nixos.org/" "https://nixcache.reflex-frp.org" ];
    binaryCachePublicKeys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
    ];
  
  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    supportedFilesystems = [ "ntfs" ];
  };

  hardware.opengl.enable = true;
  
  networking = {
    hostName = "lainix";
    firewall.checkReversePath = "loose";
    
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [ 6923 9909 6600 57274 3333 5567 50001 1338 27312 80 ];
    firewall.allowedUDPPorts = [ 6923 51820 4444 ];

    useDHCP = false;
    interfaces.enp0s25.useDHCP = true;
    interfaces.wlan0.useDHCP = true;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  };


  virtualisation.podman.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };
  
  powerManagement.enable = true;

  virtualisation.libvirtd.enable = true;
  
  services = {
    urxvtd.enable = true;
    picom.enable = true;
    
    xserver = {
	    enable = true;

      layout = "us,apl";
      xkbVariant = ",dyalog";
      xkbOptions = "grp:switch";

      desktopManager.session = [
        {
          name = "home-manager";
          start = ''${pkgs.runtimeShell} $HOME/.hm-xsession & 
                    waitPID=$!
                  '';
        }
      ];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      
      config.pipewire = {
        "context.properties" = {
          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 768;
        };
      };
      
      media-session.config.alsa-monitor = {
        rules = [
          {
            matches = [ { "node.name" = "alsa_output.usb-GuangZhou_FiiO_Electronics_Co._Ltd_FiiO_K3-00.analog-stereo"; } ];
            actions = {
              update-props = {
                "audio.format" = "S32LE";
                #"audio.rate" = 192000; # for USB soundcards it should be twice your desired rate
                "api.alsa.period-size" = 128; # defaults to 1024, tweak by trial-and-error
                #"api.alsa.disable-batch" = true; # generally, USB soundcards use the batch mode

                "resample.quality" = 10;
                "resample.disable" = false;

                "api.alsa.headroom" = 1024;
              };
            };
          }
        ];
      };
    };

    # Enable touchpad support (enabled default in most desktopManager).
    xserver.libinput.enable = true;

    thinkfan = {
      enable = true;
      levels =
        [
          [0  0   42]
          [1	40	47]
          [2	45	52]
          [3	50	57]
          [4	55	62]
          [5	60	67]
          [6	65	72]
          [7	70	77]
          [127	75	32767]
        ];
      sensors = [{
        type = "hwmon";
        query = "/sys/devices/virtual/thermal/thermal_zone0/temp";
      }];
    };

    mpdscribble = {
      enable = true;
      host = "localhost";
      
      endpoints = {
        "last.fm" = {
          username = "IDF04";
          passwordFile = "/home/idf/.lastfm";
        };
      };
    };

    udev.extraRules =
      "ATTRS{idVendor}==\"0483\", ATTRS{idProduct}==\"df11\", MODE=\"664\", GROUP=\"plugdev\"";

    tlp = {
      enable = true;
      settings = {
        WIFI_PWR_ON_BAT="off";
      };
    };

    emacs = {
      enable = true;
      defaultEditor = true;
      package = pkgs.emacsNativeComp;
    };
    
    yggdrasil = {
      enable = false;
      package = pkgs.yggdrasil_unstable;
      group = "wheel";
      config = {
        Listen = [
          "tcp://0.0.0.0:1338"
        ];
        Peers = [
          "tcp://185.165.169.234:8880"
          "tcp://[2001:67c:2db8:9::138]:801"
          "tcp://54.37.137.221:37145"
          "tcp://y4.rivchain.org:4040"
          "tcp://y4.zbin.eu:7743"
        ];
      };
    };

    power-profiles-daemon.enable = false;

  };

  security = {
    sudo.enable = false;
    doas = {
	    enable = true;
	    extraRules = [ { groups = ["wheel"]; noPass = false; keepEnv = true;} ];
    };
  };

  programs = {
    gamemode.enable = true;
    steam.enable = true;
    
    light.enable = true;

    command-not-found.enable = false;
    zsh.enable = true;
    ssh.startAgent = true;

    dconf.enable = true;
    adb.enable = true;
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    groups = {
      plugdev = {};
      fuse = {};
    };
    
    users.idf = {
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "audio" "jackaudio" "plugdev" "libvirtd" "networkmanager" "fuse" "adbusers" ]; # Enable ‘sudo’ for the user.
    };
  };
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPackages = with pkgs; [
    alsaUtils
    git wget ffmpeg-full w3m-full
    powertop acpi telnet screen
    rclone unzip unrar glxinfo
  ];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "IBMPlexMono" "JetBrainsMono" ]; })
    ibm-plex
    dejavu_fonts
    noto-fonts
    noto-fonts-emoji
    emacs-all-the-icons-fonts
  ];
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
