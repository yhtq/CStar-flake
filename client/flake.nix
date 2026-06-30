{
  description = "A cstar client development / runtime environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
      iceoryx2 = pkgs.callPackage ./iceoryx2.nix { };
      bdwgc = pkgs.callPackage ./bdwgc.nix { };
      packages = (with pkgs; [
        (capnproto.overrideAttrs (oldAttrs: {
          cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DBUILD_SHARED_LIBS=OFF" ];
        }))
        clang
        git
        pkg-config
        llvmPackages.bintools
        cmake
        gdb
        ninja
      ]) ++ [ iceoryx2 bdwgc ];
<<<<<<< HEAD
    in {
      cPackages = packages;
      devShells.default = pkgs.mkShell {
        buildInputs = packages;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        shellHook = ''
          export LD=${pkgs.llvmPackages.bintools}/bin/ld.lld
          export PATH=/home/yhtq/.cstar/bin:$PATH
          # https://github.com/NixOS/nixpkgs/issues/415892
          export NIX_LDFLAGS=$(echo $NIX_LDFLAGS | sed 's|-rpath .*outputs/out/lib||g')
        '';
      };
    });
=======
    in pkgs.mkShell {
      buildInputs = packages;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      shellHook = ''
        export LD=${pkgs.llvmPackages.bintools}/bin/ld.lld
        export PATH=/home/yhtq/.cstar/bin:$PATH
        # https://github.com/NixOS/nixpkgs/issues/415892
        export NIX_LDFLAGS=$(echo $NIX_LDFLAGS | sed 's|-rpath .*outputs/out/lib||g')
      '';
    };
  };
>>>>>>> 8a65125cddccefc4384f0a0a966d423beea409c3
}
