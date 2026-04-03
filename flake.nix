{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows= "nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        defaultPackage = naersk-lib.buildPackage ./.;
        # Instrumented build that logs per-frame byte counts to
        # ~/.cache/tuicr/frame.log; needs the vendored ratatui patch.
        packages.debug = pkgs.callPackage ./debug.nix { };
        devShell = with pkgs; mkShell {
          buildInputs = [ cargo rustc rustfmt rustPackages.clippy jj git ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
        };
      }
    );
}
