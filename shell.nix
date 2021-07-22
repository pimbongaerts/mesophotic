with (import <nixpkgs> { 
  overlays = [ 
    (self: super:
      let x86_64 = import <nixpkgs> { system = "x86_64-darwin"; };
      in { v8 = x86_64.v8; }
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
