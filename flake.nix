{
  description = "Mesophotic Rails development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        ruby = pkgs.ruby_3_4;

        gems = pkgs.bundlerEnv {
          inherit ruby;
          name = "gemset";

          gemConfig = let
            platformSuffix = if system == "aarch64-darwin" then "arm64-darwin" else system;
            withPlatformSuffix = attrs: { version = "${attrs.version}-${platformSuffix}"; };
          in {
            ffi = withPlatformSuffix;
            nokogiri = withPlatformSuffix;
            sqlite3 = withPlatformSuffix;
            psych = attrs: {
              buildInputs = [ pkgs.libyaml ];
            };
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
              libyaml
              ghostscript
              mupdf
              nodejs.libv8
            ];
          };
      }
    );
}
