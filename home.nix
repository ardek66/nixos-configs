{ config, lib, pkgs, dotfiles, ... }:
{
  imports = [ dotfiles.nixosModule.x86_64-linux ];
  
  dotfiles.enable = true;
  
  home = {
    homeDirectory = "/home/idf";
    
    packages = with pkgs; [ #TODO: Clean this shit up
      orca-c
      munt
      pavucontrol
      qjackctl
      glava
      audacity
      reaper
      gimp
      puredata
      kdenlive
      youtube-dl
      wineWowPackages.stable
      winetricks
      yabridge
      yabridgectl
      keepassxc
      htop
      tdesktop
      obs-studio
      steam-run-native
      nicotine-plus
      monero monero-gui
      virt-manager
      baobab
      xmobar
      maim xclip
      qbittorrent
      mpc_cli
      discord
      # (dwarf-fortress-packages.dwarf-fortress-full.override {
      #  theme = "mayday";
      # })

      cataclysm-dda-git
      endless-sky
      brogue
      sil

      fritzing
     
    ];
    
  };
  
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };    
  };
  
  xresources = {
    properties = {
      "URxvt.scrollBar" = false;
      "URxvt.font" = "xft:JetBrainsMono Nerd Font:size=10";
      "URxvt.internalBorder" = 5;
      
      "URxvt.background" = "#282828";
      "URxvt.foreground" = "#ebdbb2";
      "URxvt.color0" = "#282828";
      "URxvt.color1" = "#cc241d";
      "URxvt.color2" = "#98971a";
      "URxvt.color3" = "#d79921";
      "URxvt.color4" = "#458588";
      "URxvt.color5" = "#b16286";
      "URxvt.color6" = "#689d6a";
      "URxvt.color7" = "#a89984";
      "URxvt.color8" = "#928374";
      "URxvt.color9" = "#fb4934";
      "URxvt.color10" = "#b8bb26";
      "URxvt.color11" = "#fabd2f";
      "URxvt.color12" = "#83a598";
      "URxvt.color13" = "#d3869b";
      "URxvt.color14" = "#8ec07c";
      "URxvt.color15" = "#ebdbb2";
    };
   
    extraConfig = builtins.readFile (
      pkgs.fetchFromGitHub {
        owner = "morhetz";
        repo = "gruvbox-contrib";
        rev = "150e9ca30fcd679400dc388c24930e5ec8c98a9f";
        sha256 = "181irx5jas3iqqdlc6v34673p2s6bsr8l0nqbs8gsv88r8q066l6";
      } + "/urxvt256/gruvbox-urxvt256.xresources"
    );
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };
  
  services = {
    polybar = {
      enable = false;
      script = "polybar top &";
      config = {
        "bar/top" = {
          monitor = "\${env:MONITOR:LVDS-1}";
          width = "100%";
          height = "5%";
          radius = 0;
          modules-center = "date";
        };

        "module/date" = {
          type = "internal/date";
          internal = 5;
          date = "%d/%m/%y";
          time = "%H:%M:%s";
          label = "%date% - %time%";
        };
      };
    };

    redshift = {
      enable = true;
      temperature.night = 2000;
      latitude = 46.0;
      longitude = 25.0; #lol doxxed
    };
    
    mpd = {
      enable = true;
      network = {
        listenAddress = "0.0.0.0";
        startWhenNeeded = true;
      };
      
      musicDirectory = "/home/idf/music/";
      extraConfig = ''
                  audio_output {
                    type "pipewire"
                    name "Pipewire"
                  }

                  audio_output {
                    type "httpd"
                    name "My HTTP MPD Stream" 
                    port "9909"
                    encoder "wave"
                  }
                  audio_output {
                    type "fifo"
                    name "my_fifo"
                    path "/tmp/mpd.fifo"
                    format  "44100:16:2"
                  }
                  '';
    };
    
  };
  
  programs = {
    home-manager.enable = false;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      
      nix-direnv = {
        enable = true;
        enableFlakes = true;
      };
    };
    
    gpg.enable = true;

    rtorrent = {
      enable = true;
      settings =
        ''
        network.port_range.set = 6923-6923
        network.port_random.set = no

        dht.mode.set = disable
        protocol.pex.set = no

        session.path.set = ~/.rtorrent.session

        dht.mode.set = disable
        protocol.pex.set = no
        trackers.use_udp.set = no

        
        '';
    };
    
    
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    feh.enable = true;
    
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;

      autocd = true;
      defaultKeymap = "emacs";
      cdpath = [ "/etc/nixos" ];

      plugins = [
        {
          name = "zsh-nix-shell";
          
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "f8574f27e1d7772629c9509b2116d504798fe30a";
            sha256 = "0svskd09vvbzqk2ziw6iaz1md25xrva6s6dhjfb471nqb13brmjq";
          };
        }

        {
          name = "doas-zsh-plugin";

          file = "doas.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "Senderman";
            repo = "doas-zsh-plugin";
            rev = "f5c58a34df2f8e934b52b4b921a618b76aff96ba";
            sha256 = "1ni7kmkm1scc6r29q41dnbnspflppajbcnp217pg9gxqh76q6znp";
          };
        }

        {
          name = "zsh-emacs";

          file = "emacs.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "Flinner";
            repo = "zsh-emacs";
            rev = "bf3f3e047563122ed3f02859c96a0dd363ef87b3";
            sha256 = "1x59i85imiggnw1aw7ijar1ldni3x9vff6vf1b79crr094d3g0rl";
          };
        }
      ];
      
    };
      
    rofi = {
      enable = true;
      theme = "gruvbox-dark";
    };
    
    ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    };
    
    mpv.enable = true;
    
    chromium = {
      enable = false;
      extensions = [ { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
                     { id = "oboonakemofpalcgghocfoadofidjkkk"; }
                     { id = "jinjaccalgkegednnccohejagnlnfdag"; }
                     { id = "cmleijjdpceldbelpnpkddofmcmcaknm"; } ];
    };

    qutebrowser = {
      enable = true;
      
      keyBindings = {
        normal = {
          "<Ctrl-v>" = "spawn mpv {url}";
          ",p" = "spawn --userscript qute-pass";
        };
      };

      quickmarks = {
        nixpkgs = "https://github.com/NixOS/nixpkgs";
        home-manager = "https://github.com/nix-community/home-manager";
      };
    };
    
    git = {
      enable = true;
      userEmail = "ardek66@tutanota.com";
      userName = "IDF31";
    };

    alacritty = {
      enable = false; # enable = true;

      settings = {
        window.padding = {
          x = 5;
          y = 5;
        };

        font = {
          normal = {
            family = "IBM Plex Mono";
            style = "Regular";
          };
          italic = {
            family = "IBM Plex Mono";
            style = "Italic";
          };
          bold = {
            family = "IBM Plex Mono";
            style = "Bold";
          };
          size = 9.0;
        };

        colors = {
          primary = {
            background = "0x282828";
            foreground = "0xdfbf8e";
          };

          normal = {
            black = "0x282828";
            red = "0xcc241d";
            green = "0x98971a";
            yellow = "0xd79921";
            blue = "0x458588";
            magenta = "0xb16286";
            cyan = "0x6896da";
            white = "0xebdbb2";
          };

          bright = {
            black = "0x928374";
            red = "0xea6962";
            green = "0xa9b665";
            yellow = "0xe3a84e";
            blue = "0x7daea3";
            magenta = "0xd3869b";
            cyan = "0x89b482";
            white = "0xdfbf8e";
          };
        };
      };
    };
  };
}
