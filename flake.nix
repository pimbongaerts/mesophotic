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

        bundler = pkgs.buildRubyGem rec {
          inherit ruby;
          name = "${gemName}-${version}";
          gemName = "bundler";
          version = "2.4.22";
          source = {
            remotes = ["https://rubygems.org"];
            sha256 = "sha256-dHulCw5n3yXL07SPlYMad6TVOlgdVfBjly/LFG0ULF8=";
            type = "gem";
          };
        };

        gems = pkgs.bundlerEnv.override { inherit bundler; } {
          inherit ruby;
          name = "gemset";

          gemConfig = let
            platformSuffix = if system == "aarch64-darwin" then "arm64-darwin" else system;
            withPlatformSuffix = attrs: { version = "${attrs.version}-${platformSuffix}"; };
          in {
            ffi = withPlatformSuffix;
            nokogiri = withPlatformSuffix;
            sqlite3 = withPlatformSuffix;
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
              bundler
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
