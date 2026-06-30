{
  description = "A cstar server development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs { inherit system; };
      myPcre2 = pkgs.pcre2.overrideAttrs (oldAttrs: {
        configureFlags = [ "--disable-shared" ] ++ oldAttrs.configureFlags;
      });
      ocamlPackages = "zarith ocamlfind camlp5.8.03.06 dune ppx_jane core core_unix pprint re ppx_import ppx_deriving menhir csv ppx_import yojson ppx_yojson_conv lsp async ppx_let lwt lwt_ppx extlib cmdliner capnp capnp-rpc capnp-rpc-net capnp-rpc-unix eio eio_main";
      cstarServerSetup = pkgs.writeShellScriptBin "cstar-server-setup" ''
        export LIBCLANG_PATH=${pkgs.llvmPackages.libclang.lib}/lib
        export RUSTFLAGS=$RUSTFLAGS" -Clink-self-contained=-linker"
        # opam switch -q create cstar ocaml-base-compiler.5.3.0 || true
        if ! opam switch -q | grep -q cstar; then
          opam switch create cstar ocaml-base-compiler.5.3.0
        fi
        opam switch -q cstar
        eval "$(opam env)"
        opam install ${ocamlPackages} --check || opam install ${ocamlPackages} -y
        opam pin -q camlp5 8.03.06
      '';
      packages = (with pkgs; [
        rustup
        capnproto
        clang
        rsync
        git
        (gmp.override { withStatic = true; })
        pkg-config
        myPcre2
        gnum4
        llvmPackages.libclang
        llvmPackages.bintools
      ]) ++ [ cstarServerSetup ];
    in pkgs.mkShell rec {
      buildInputs = packages;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      shellHook = ''
        export LIBCLANG_PATH=${pkgs.llvmPackages.libclang.lib}/lib
        export RUSTFLAGS=$RUSTFLAGS" -Clink-self-contained=-linker"
        opam switch -q cstar
        eval "$(opam env)"
        echo "Run 'cstar-server-setup' when you need to initialize/update opam dependencies."
      '';
    };
  };
}