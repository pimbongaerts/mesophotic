{
  description = "Mesophotic Rails development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-ruby, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nixpkgs-ruby.overlays.default ];
        };

        rubyEnv = pkgs.bundlerEnv {
          name = "mesophotic-dev-env";
          ruby = pkgs."ruby-2.7";
          gemdir = ./.;
        };

        shellBuildInputs = [
          pkgs.awscli
          rubyEnv
          rubyEnv.wrappedRuby
          pkgs.imagemagick
          pkgs.ghostscript
          pkgs.mupdf
          pkgs.v8
        ];
      in
      {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = shellBuildInputs;
          };
        };
      }
    );
}
