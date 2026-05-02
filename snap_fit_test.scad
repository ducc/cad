// Visual fit check: 2x2 OpenGrid Lite panel + 4 snaps in the same 2x2 layout
// the USB ETH mount uses. Render to look for collisions between the snap
// geometry (especially the nubs) and the panel's screw-hole hardware.
//
// `nix develop` then `openscad -o /tmp/fit.png snap_fit_test.scad`.

include <BOSL2/std.scad>
use <openGrid/openGrid.scad>
use <openGrid/opengrid-snap.scad>

// Switch this to test different panel configurations.
// "Everywhere" puts a screw hole at every tile-corner intersection.
// "Corners" only puts them at the 4 outer corners of the panel.
// "None" disables screw holes entirely.
SCREW_MOUNTING = "Everywhere";

panel_lite_thickness = 4;
snap_lite_height     = 3.4;
tile_size            = 28;

module panel() {
    openGridLite(
        Board_Width   = 2,
        Board_Height  = 2,
        tileSize      = tile_size,
        Screw_Mounting= SCREW_MOUNTING,
        anchor        = CENTER
    );
}

module snaps_2x2() {
    for (cx = [-tile_size/2, tile_size/2],
         cy = [-tile_size/2, tile_size/2])
        translate([cx, cy, -panel_lite_thickness/2 + snap_lite_height])
            rotate([180, 0, 0])
                openGridSnap(lite=true, anchor=BOTTOM);
}

// Display: panel + snaps overlaid (gray + red) to spot collisions visually.
// Set CONFLICT_ONLY = true to render only the intersection volume — the
// material that would have to deform out of the way for the snap to seat.
CONFLICT_ONLY = false;

if (CONFLICT_ONLY) {
    color("Magenta")
        intersection() {
            panel();
            snaps_2x2();
        }
} else {
    color("DimGray", 0.55) panel();
    color("Red", 0.85) snaps_2x2();
}
