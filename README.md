This repository contains a nix flake for [rtk](https://github.com/rtk-ai/rtk). You can install `rtk` into your nix dev shell with:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rtk-nix.url = "github:hypervideo/rtk-nix";
  };

  outputs = { self, nixpkgs, flake-utils, rtk-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rtk-nix.overlays.default
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            rtk
          ];
        };
      }
    );
}
```

This repository has an automatically running CI job that checks for new `rtk` releases and updates the package when a new version is available.
