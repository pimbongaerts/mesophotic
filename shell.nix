{ nixpkgs ? import <nixpkgs>
, pkgs ? nixpkgs {}
, nixpkgs-ruby ? import (builtins.fetchTarball {
    url = "https://github.com/bobvanderlinden/nixpkgs-ruby/archive/c1ba161adf31119cfdbb24489766a7bcd4dbe881.tar.gz";
  })
, ruby ? nixpkgs-ruby.packages.${builtins.currentSystem}."ruby-3.4"
, bundler ? nixpkgs-ruby.packages.${builtins.currentSystem}."bundler"
}:
pkgs.mkShell {
  buildInputs = [
    ruby
    pkgs.bundix
  ];
}
