{
  inputs = {
    nixpkgs.url  = "nixpkgs/nixos-20.09";
    unstable.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{ self, nixpkgs, unstable, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ hlsOverlay ];
    };

    hsOverrideOverlay =
      override:
      self: super: {
        haskellPackages = super.haskellPackages.override (old: {
          overrides = super.lib.composeExtensions
            (old.overrides or (_: _: {}))
            (override self super);
        });
      };

    hlsOverlay = hsOverrideOverlay (self: super: _: _: {
      haskell-language-server =
        unstable.legacyPackages.${super.system}.haskell-language-server;
    });

  in rec {
    defaultPackage.${system} =
      (pkgs.haskellPackages.callCabal2nix "hascurl" ./. {}).overrideAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [ pkgs.curl.dev ];
      });

    devShell.${system} =
      (pkgs.haskell.lib.overrideCabal defaultPackage.${system} (old: {
        buildTools = (old.buildTools or []) ++ (with pkgs.haskellPackages; [
          cabal-install
          haskell-language-server
          pkgs.clang-tools
        ]);
      })).env.overrideAttrs (old: {

        # GHCi needs this to be able to find libcurl.
        LD_LIBRARY_PATH =
          (old.LD_LIBRARY_PATH or "") + pkgs.lib.makeLibraryPath [ pkgs.curl ];

        # Build inputs needed for cabal build within nix shell.
        buildInputs =
          (old.buildInputs or []) ++ defaultPackage.${system}.buildInputs;
      });
  };
}
