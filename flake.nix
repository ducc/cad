{
  description = "CAD repo: OpenSCAD + BOSL2 + OpenGrid snap library";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    bosl2-src = {
      url = "github:BelfrySCAD/BOSL2";
      flake = false;
    };

    quackworks-src = {
      url = "github:AndyLevesque/QuackWorks";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, bosl2-src, quackworks-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        scadLibs = pkgs.runCommand "scad-libs" { } ''
          mkdir -p $out/BOSL2 $out/openGrid
          cp -r ${bosl2-src}/. $out/BOSL2/
          cp ${quackworks-src}/openGrid/opengrid-snap.scad $out/openGrid/
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.openscad-unstable ];

          shellHook = ''
            export OPENSCADPATH=${scadLibs}
            echo "OpenSCAD libraries available at: $OPENSCADPATH"
            echo "  - BOSL2/std.scad"
            echo "  - openGrid/opengrid-snap.scad"
          '';
        };
      });
}
