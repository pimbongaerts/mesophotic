with (import <nixpkgs> {});
let
  env = bundlerEnv {
    name = "mesophotic-bundler-env";
    ruby = ruby_2_7;
    gemdir = ./.;
  };
in mkShell {
  buildInputs = [ env env.wrappedRuby nodejs imagemagick ghostscript mupdf ];
}
