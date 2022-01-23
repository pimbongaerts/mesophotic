with (import <nixpkgs> {
  overlays = [
    (self: super:
    let pkgs = import <nixpkgs> {};
      in {
        v8 = pkgs.v8_8_x;
      }
    )
  ];
});

let
  env = bundlerEnv {
    name = "mesophotic-bundler-env";
    ruby = ruby_2_7;
    gemdir = ./.;
  };

in mkShell {
  buildInputs = [
    env
    env.wrappedRuby
    imagemagick
    ghostscript
    mupdf
    v8
  ];
}
