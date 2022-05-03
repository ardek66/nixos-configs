{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    home-manager.url = "github:nix-community/home-manager/release-21.11";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dotfiles.url = "path:/home/idf/dotfiles";
  };
  
  outputs = { self, nixpkgs, home-manager, emacs-overlay, nixos-hardware, dotfiles }: {
    nixosConfigurations.lainix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        { nixpkgs.overlays = [ (import emacs-overlay) ]; }
        
        home-manager.nixosModules.home-manager {
          home-manager.users.idf = import ./home.nix;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit dotfiles; };
        }
        
        nixos-hardware.nixosModules.lenovo-thinkpad-t430
      ];
    };
  };
}
