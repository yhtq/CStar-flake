{
  description = "A cstar server development / build environment(ocaml part)";

  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";
  };

  outputs =
    { self, flake-utils, opam-nix, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      on = opam-nix.lib.${system};

      # Dev tools
      devPackagesQuery = {
        ocaml-lsp-server = "*";
        ocamlformat = "*";
      };

      # All dependencies with version constraints
      query = devPackagesQuery // {
        # Compiler — pinned to 5.3.0 to match current opam setup
        ocaml-base-compiler = "5.3.0";
        # Base
        zarith = "*";
        ocamlfind = "*";
        camlp5 = "8.03.06";
        dune = "*";
        # PPX & core
        ppx_jane = "*";
        core = "*";
        core_unix = "*";
        ppx_import = "*";
        ppx_deriving = "*";
        ppx_let = "*";
        ppx_yojson_conv = "*";
        # Utilities
        pprint = "*";
        re = "*";
        menhir = "*";
        csv = "*";
        yojson = "*";
        lsp = "*";
        extlib = "*";
        cmdliner = "*";
        # Async / Lwt
        async = "*";
        lwt = "*";
        lwt_ppx = "*";
        # Cap'n Proto (OCaml bindings)
        capnp = "*";
        "capnp-rpc" = "*";
        "capnp-rpc-net" = "*";
        "capnp-rpc-unix" = "*";
        # Eio
        eio = "*";
        eio_main = "*";
      };

      scope = on.buildOpamProject' { } ./. query;

      overlay = final: prev: { };

      scope' = scope.overrideScope overlay;

      devPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope')
        ++ (with pkgs; [
            capnproto
            clang
            (gmp.override { withStatic = true; })
            pkg-config
            pcre2.overrideAttrs (oldAttrs: {
              configureFlags = [ "--disable-shared" ] ++ oldAttrs.configureFlags;
            })
            gnum4
            llvmPackages.libclang
            llvmPackages.bintools
          ]);;
    in {
      ocamlPackages = devPackages;
      devShells.default = pkgs.mkShell {
        buildInputs = devPackages;
        shellHook = ''
          export LIBCLANG_PATH=${pkgs.llvmPackages.libclang.lib}/lib
        '';
      };
    });
}
