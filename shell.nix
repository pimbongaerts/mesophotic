{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  env = bundlerEnv {
    name = "mesophotic-development-environment";
    ruby = ruby_2_7;
    gemdir = ./.;
  };

in mkShell {
  buildInputs = [
    awscli
    env
    env.wrappedRuby
    imagemagick
    ghostscript
    mupdf
    v8
  ];
}
