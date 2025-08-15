{
  description = "Mesophotic Rails development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-ruby, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nixpkgs-ruby.overlays.default ];
        };

        ruby = nixpkgs-ruby.lib.packageFromRubyVersionFile {
          file = ./.ruby-version;
          inherit system;
        };

        gems = pkgs.bundlerEnv {
          inherit ruby;
          name = "gemset";

          gemConfig.nokogiri = attrs: {
            version = attrs.version
              + "-"
              + (
                if system == "aarch64-darwin"
                then "arm64-darwin"
                else system
              );
          };

          gemConfig.sqlite3 = attrs: {
            version = attrs.version
              + "-"
              + (
                if system == "aarch64-darwin"
                then "arm64-darwin"
                else system
              );
          };

          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = ./gemset.nix;
          gemdir = ./.;
          groups = [ "default" "production" "development" "test" ];
        };
      in
      {
        devShell = with pkgs;
          mkShell {
            buildInputs = [
              gems
              ruby
              bundix

              awscli
              imagemagick
              ghostscript
              mupdf
              nodejs.libv8
            ];
          };
      }
    );
}
