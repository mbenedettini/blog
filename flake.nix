{
  description = "Development environment and build for Astro project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              nodejs = prev.nodejs_22;
            })
          ];
        };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "astro-site";
          version = "0.1.0";
          src = ./.;

          nativeBuildInputs = with pkgs; [
            nodejs
            nodePackages.pnpm
            cacert
          ];

          buildPhase = ''
            export HOME=$(mktemp -d)
            pnpm install --frozen-lockfile
            pnpm run build
          '';

          installPhase = ''
            mkdir -p $out
            cp -r dist $out/
          '';
        });

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            nodePackages.pnpm
          ];

          shellHook = ''
            export PATH=$PWD/node_modules/.bin:$PATH
          '';
        };
      });
}
