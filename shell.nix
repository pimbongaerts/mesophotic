with (import <nixpkgs> { 
  overlays = [ 
    (self: super:
      let talyz = import (builtins.fetchTarball {
        url = https://github.com/talyz/nixpkgs/archive/360abc8e2a66392c016fd1e60db2095cc8a7907e.tar.gz;
      }) {};
    
      in { v8 = talyz.v8; }
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
  buildInputs = [ env env.wrappedRuby v8 imagemagick ghostscript mupdf ];
}
