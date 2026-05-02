// Mount for the Level1Techs DisplayPort + USB-C KVM (156 W × 101 D × 58 H mm)
// on an OpenGrid Lite panel mounted to the underside of a desk. The KVM's
// top face mates against the desk; front and rear faces are completely
// unobstructed so all ports remain accessible.
// Build env: `nix develop` then `openscad level1_kvm_mount.scad`.

include <BOSL2/std.scad>
use <openGrid/opengrid-snap.scad>

// ---- Device & build parameters ----
device_w = 156;   // X (between the two end walls)
device_d = 101;   // Y (front to rear; no walls on these faces)
device_h = 58;    // Z (between bottom lip and snap baseplate)

clearance     = 0.5;
clearance_z   = 0.5;   // headroom above the seated device
wall          = 5;     // chunky side legs — they carry the device's weight
top_thickness = 4;
lip_thickness = 2;     // Z height of bottom retention lip
lip_depth     = 7;     // X distance the lip protrudes into the cavity
rim_thickness = 2;     // Y thickness of front/rear retention rims
rim_height    = 2;     // how far the rims rise above the lip top

cavity_w = device_w + 2 * clearance;
cavity_d = device_d + 2 * clearance;
// Extra Z room so the device can lift over the front/rear rims during install.
cavity_h = device_h + rim_height + clearance_z;

outer_w = cavity_w + 2 * wall;
outer_d = cavity_d + 2 * rim_thickness;
outer_h = cavity_h + lip_thickness + top_thickness;

// ---- Snap layout: 5 × 3 lite snaps at 28 mm pitch on the top baseplate ----
snap_pitch  = 28;
snap_h_lite = 3.4;
snaps_nx    = 4;
snaps_ny    = 3;

snap_span_x = (snaps_nx - 1) * snap_pitch;
snap_span_y = (snaps_ny - 1) * snap_pitch;
snap_x0 = (outer_w - snap_span_x) / 2;
snap_y0 = (outer_d - snap_span_y) / 2;

// ---- Honeycomb cutouts on the side walls ----
hex_R     = 6;     // hex outer radius (vertex-to-center)
hex_gap   = 2;     // wall thickness between adjacent hex cells
hc_margin = 6;     // solid frame around the honeycomb area on each side wall

module shell() {
    union() {
        // Top plate (snap baseplate)
        translate([0, 0, outer_h - top_thickness])
            cube([outer_w, outer_d, top_thickness]);

        // Left side wall (up to the underside of the top plate)
        cube([wall, outer_d, outer_h - top_thickness]);

        // Right side wall
        translate([outer_w - wall, 0, 0])
            cube([wall, outer_d, outer_h - top_thickness]);

        // Bottom retention lip — closed rectangular perimeter. Side lips run
        // the full depth and tie into the side walls; front and rear lips
        // span the full cavity width and brace the perimeter so the floor
        // frame stays rigid under the device's weight.
        translate([wall, 0, 0])
            cube([lip_depth, outer_d, lip_thickness]);
        translate([outer_w - wall - lip_depth, 0, 0])
            cube([lip_depth, outer_d, lip_thickness]);
        translate([wall, 0, 0])
            cube([cavity_w, lip_depth, lip_thickness]);
        translate([wall, outer_d - lip_depth, 0])
            cube([cavity_w, lip_depth, lip_thickness]);

        // Front and rear retention rims: rise above the perimeter lip and
        // catch the device's bottom-front and bottom-rear edges so it can't
        // slide out endwise.
        translate([wall, 0, lip_thickness])
            cube([cavity_w, rim_thickness, rim_height]);
        translate([wall, outer_d - rim_thickness, lip_thickness])
            cube([cavity_w, rim_thickness, rim_height]);

        // X brace across the bottom opening — two diagonal struts running
        // corner-to-corner of the lip's inner perimeter. Stiffens the floor
        // frame and adds extra bearing area under the device's centerline.
        x_brace_width = 5;
        x_l = wall + lip_depth;
        x_r = wall + cavity_w - lip_depth;
        y_f = lip_depth;
        y_r = outer_d - lip_depth;
        bx_dx = x_r - x_l;
        bx_dy = y_r - y_f;
        bx_len = sqrt(bx_dx * bx_dx + bx_dy * bx_dy);
        translate([x_l, y_f, 0])
            rotate([0, 0, atan2(bx_dy, bx_dx)])
                translate([0, -x_brace_width / 2, 0])
                    cube([bx_len, x_brace_width, lip_thickness]);
        translate([x_r, y_f, 0])
            rotate([0, 0, atan2(bx_dy, -bx_dx)])
                translate([0, -x_brace_width / 2, 0])
                    cube([bx_len, x_brace_width, lip_thickness]);
    }
}

module honeycomb_2d(width, height, R, gap) {
    pitch_x = R * sqrt(3) + gap;
    pitch_y = R * 1.5 + gap * sqrt(3) / 2;

    n_cols = ceil(width / pitch_x) + 2;
    n_rows = ceil(height / pitch_y) + 2;

    intersection() {
        union() {
            for (row = [-1 : n_rows]) {
                x_offset = (row % 2 != 0) ? pitch_x / 2 : 0;
                for (col = [-1 : n_cols])
                    translate([col * pitch_x + x_offset, row * pitch_y])
                        rotate(30)
                            circle(r=R, $fn=6);
            }
        }
        square([width, height]);
    }
}

module honeycomb_cutout(x_start) {
    eps = 1;
    area_y = outer_d - 2 * hc_margin;
    area_z = (outer_h - top_thickness) - lip_thickness - 2 * hc_margin;

    translate([x_start - eps, hc_margin, lip_thickness + hc_margin])
        rotate([90, 0, 90])
            linear_extrude(wall + 2 * eps)
                honeycomb_2d(area_y, area_z, hex_R, hex_gap);
}

module honeycomb_holes() {
    honeycomb_cutout(0);                // left wall
    honeycomb_cutout(outer_w - wall);   // right wall
}

module snaps() {
    // Cap face down (against panel), gripping nubs up into the grid hole.
    for (i = [0 : snaps_nx - 1], j = [0 : snaps_ny - 1])
        translate([snap_x0 + i * snap_pitch,
                   snap_y0 + j * snap_pitch,
                   outer_h + snap_h_lite])
            rotate([180, 0, 0])
                openGridSnap(lite=true, anchor=BOTTOM);
}

difference() {
    shell();
    honeycomb_holes();
}
snaps();
