# Common tasks for the CAD repo. Run inside `nix develop`.
# `just` (no args) prints this list.

default:
    @just --list

# Run the image regression suite against the committed baselines.
test:
    tests/run.sh

# Approve current renders as new baselines (use after intentional CAD changes).
approve:
    tests/run.sh --update

# Render production STLs after passing the regression suite.
stl: test
    openscad -o opengrid/usb_eth_mount/usb_eth_mount.stl       opengrid/usb_eth_mount/usb_eth_mount.scad
    openscad -o opengrid/level1_kvm_mount/level1_kvm_mount.stl opengrid/level1_kvm_mount/level1_kvm_mount.scad

# Open a SCAD file in the OpenSCAD GUI for interactive editing.
view file:
    openscad "{{file}}"

# Clear test diff images and the generated report.
clean:
    rm -rf tests/diffs tests/report.md
