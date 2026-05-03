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
          cp -r ${quackworks-src}/openGrid/. $out/openGrid/
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.openscad-unstable
            pkgs.imagemagick      # for tests/run.sh image regression
            pkgs.xvfb-run         # virtual display so openscad can render headless on CI
            pkgs.mesa             # software OpenGL (llvmpipe) for headless rendering
            pkgs.libglvnd         # GL vendor-neutral dispatch
          ];

          shellHook = ''
            export OPENSCADPATH=${scadLibs}
            # libglvnd needs to know where Mesa's GL/EGL implementations live.
            # Without these, openscad on a non-NixOS host fails with EGL_BAD_DISPLAY
            # / "Unable to load GLX" because there's no system GL driver.
            export LIBGL_DRIVERS_PATH=${pkgs.mesa}/lib/dri
            export __EGL_VENDOR_LIBRARY_FILENAMES=${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json
            export LIBGL_ALWAYS_SOFTWARE=1
            export GALLIUM_DRIVER=llvmpipe
            echo "OpenSCAD libraries available at: $OPENSCADPATH"
            echo "  - BOSL2/std.scad"
            echo "  - openGrid/opengrid-snap.scad"
          '';
        };
      });
}
