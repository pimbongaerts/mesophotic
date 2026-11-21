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
            # Ruby platforms that can run on this system, most specific first.
            rubyPlatforms = {
              aarch64-darwin = [ "arm64-darwin" ];
              x86_64-darwin = [ "x86_64-darwin" ];
              x86_64-linux = [ "x86_64-linux-gnu" "x86_64-linux" ];
              aarch64-linux = [ "aarch64-linux-gnu" "aarch64-linux" ];
            }.${system} ++ [ "ruby" ];

            # Fetch the precompiled variant that matches this system, using the
            # hashes in gemset-platforms.nix rather than bundix's single hash.
            withPlatformVariant = name: variants: attrs:
              let
                matches = builtins.filter (platform: variants ? ${platform}) rubyPlatforms;
                variant =
                  if matches == [ ]
                  then throw "Gemfile.lock has no ${name} variant for ${system}"
                  else variants.${builtins.head matches};
              in {
                inherit (variant) version;
                source = attrs.source // { inherit (variant) sha256; };
              };
          in builtins.mapAttrs withPlatformVariant (import ./gemset-platforms.nix) // {
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
