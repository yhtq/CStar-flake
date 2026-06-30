{
  description = "Merged cstar development environment (client + server)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    client.url = "path:./client";
    client.inputs.nixpkgs.follows = "nixpkgs";
    client.inputs.flake-utils.follows = "flake-utils";
    server.url = "path:./server";
    server.inputs.nixpkgs.follows = "nixpkgs";
    server.inputs.opam-nix.follows = "opam-nix";
    server.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, client, server, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };

      clientShell = client.devShells.${system}.default;
      serverShell = server.devShells.${system}.default;
    in {
      devShells.default = pkgs.mkShell {
        inputsFrom = [ clientShell serverShell ];
        buildInputs = [
          pkgs.prek
        ];
        shellHook = ''
          ${clientShell.shellHook or ""}
          ${serverShell.shellHook or ""}
          echo "Merged shell loaded (client + server)."
        '';
      };
    });
}
