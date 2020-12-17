with (import <nixpkgs> {});
let
  env = bundlerEnv {
    name = "mesophotic-bundler-env";
    ruby = ruby_2_5;
    gemdir = ./.;
  };
in stdenv.mkDerivation {
  name = "mesophotic";
  buildInputs = [ env env.wrappedRuby nodejs imagemagick ghostscript ];
}
