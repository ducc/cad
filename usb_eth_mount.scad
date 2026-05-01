// USB ETH receiver mount for OpenGrid Lite (underside-of-desk).
// Snaps protrude +Z into the desk grid; the cradle hangs below.
// Build env: `nix develop` then `openscad usb_eth_mount.scad`.

include <BOSL2/std.scad>
use <openGrid/opengrid-snap.scad>

// ---- Device & build parameters ----
device_w = 58;   // X (between the two cable-cutout end walls)
device_l = 54;   // Y (between back wall and slide-in opening)
device_d = 23;   // Z (between floor and snap baseplate)

clearance       = 0.75;
wall            = 2;
floor_thickness = 2;
top_thickness   = 4;

retention_lip_depth = 1.5;
retention_lip_h     = 2;

cavity_w = device_w + 2 * clearance;
cavity_l = device_l + 2 * clearance;
// Extra Z room so the device can lift over the retention lip while sliding in/out.
cavity_h = device_d + clearance + retention_lip_h;

outer_w = cavity_w + 2 * wall;
outer_l = cavity_l + 2 * wall;
outer_h = cavity_h + floor_thickness + top_thickness;

// ---- Snap layout: 4× lite snaps, 2x2, 28 mm pitch, centered on top ----
snap_pitch  = 28;
snap_h_lite = 3.4;

snap_x1 = (outer_w - snap_pitch) / 2;
snap_x2 = snap_x1 + snap_pitch;
snap_y1 = (outer_l - snap_pitch) / 2;
snap_y2 = snap_y1 + snap_pitch;

// ---- Cutout sizes ----
// Cable cutouts are sized so the surrounding frame is at most this wide on
// every edge, leaving the cables maximum room.
cable_window_edge_clearance = 4;
cable_hole_w = outer_l - 2 * cable_window_edge_clearance;
cable_hole_h = outer_h - 2 * cable_window_edge_clearance;

side_window_w = 50;
side_window_h = 18;

floor_window_w = 50;
floor_window_l = 46;

device_z_center = floor_thickness + device_d / 2;

module shell() {
    cube([outer_w, outer_l, outer_h]);
}

module cavity() {
    translate([wall, wall, floor_thickness])
        cube([cavity_w, cavity_l, cavity_h]);
}

module cable_holes() {
    eps = 1;
    for (x = [-eps, outer_w - wall - eps])
        translate([x, cable_window_edge_clearance, cable_window_edge_clearance])
            cube([wall + 2 * eps, cable_hole_w, cable_hole_h]);
}

module side_window() {
    eps = 1;
    x_c = outer_w / 2;
    z_c = floor_thickness + cavity_h / 2;
    translate([x_c - side_window_w / 2, -eps, z_c - side_window_h / 2])
        cube([side_window_w, wall + 2 * eps, side_window_h]);
}

module floor_window() {
    eps = 1;
    translate([(outer_w - floor_window_w) / 2,
               (outer_l - floor_window_l) / 2,
               -eps])
        cube([floor_window_w, floor_window_l, floor_thickness + 2 * eps]);
}

module slide_opening() {
    eps = 1;
    translate([wall, outer_l - wall, floor_thickness])
        cube([cavity_w, wall + eps, cavity_h]);
}

// Triangular prism on the floor at the open (front) edge: vertical inner
// face catches the seated device, sloped outer face ramps up so it can be
// pushed in/out with a slight lift.
module retention_lip() {
    translate([wall, outer_l - wall - retention_lip_depth, floor_thickness])
    rotate([90, 0, 90])
        linear_extrude(cavity_w)
            polygon([
                [0, 0],
                [retention_lip_depth, 0],
                [0, retention_lip_h],
            ]);
}

module snaps() {
    for (cx = [snap_x1, snap_x2], cy = [snap_y1, snap_y2])
        translate([cx, cy, outer_h])
            openGridSnap(lite=true, anchor=BOTTOM);
}

difference() {
    shell();
    cavity();
    cable_holes();
    side_window();
    floor_window();
    slide_opening();
}
retention_lip();
snaps();
