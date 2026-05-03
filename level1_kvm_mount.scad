// Mount for the Level1Techs DisplayPort + USB-C KVM (156 W × 101 D × 58 H mm)
// on an OpenGrid Lite panel mounted to the underside of a desk. The KVM's
// top face mates against the desk; front and rear faces are completely
// unobstructed so all ports remain accessible.
// Build env: `nix develop` then `openscad level1_kvm_mount.scad`.

include <BOSL2/std.scad>
use <openGrid/opengrid-snap.scad>

// ---- Device & build parameters ----
device_w = 157.5; // X (between the two end walls)
device_d = 101;   // Y (front to rear; no walls on these faces)
device_h = 58;    // Z (between bottom lip and snap baseplate)

clearance     = 0.5;
clearance_z   = 0.5;   // headroom above the seated device
wall          = 5;     // chunky side legs — they carry the device's weight
top_thickness = 3;
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
snaps_nx    = 5;
snaps_ny    = 3;

snap_span_x = (snaps_nx - 1) * snap_pitch;
snap_span_y = (snaps_ny - 1) * snap_pitch;
snap_x0 = (outer_w - snap_span_x) / 2;
snap_y0 = (outer_d - snap_span_y) / 2;

// ---- Side-wall X bracing ----
sw_frame_margin = 6;   // solid frame around the braced area on each side wall
sw_brace_cells  = 3;   // number of side-by-side X-brace cells per side wall
sw_strut_width  = 5;   // strut width for X braces and inter-cell verticals

// ---- Baseplate cutouts: leave only solid pads around the 4 corner snaps ----
baseplate_pad_clearance = 3;   // mm of solid baseplate kept around each snap

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

// 2D X brace inside a w × h rectangle anchored at the origin.
module xbrace_2d(w, h, strut) {
    diag = sqrt(w * w + h * h);
    angle = atan2(h, w);
    rotate(angle)
        translate([0, -strut / 2])
            square([diag, strut]);
    translate([0, h])
        rotate(-angle)
            translate([0, -strut / 2])
                square([diag, strut]);
}

// 2D void shape for one side wall (in the YZ plane, treated here as XY).
// A plain rectangular cutout, with X braces + inter-cell verticals kept
// solid by subtracting them from the cutout.
module side_wall_void_2d() {
    sw_y_span = outer_d;
    sw_z_span = outer_h - top_thickness;
    inner_w = sw_y_span - 2 * sw_frame_margin;
    inner_h = sw_z_span - 2 * sw_frame_margin;
    cell_w  = inner_w / sw_brace_cells;

    difference() {
        translate([sw_frame_margin, sw_frame_margin])
            square([inner_w, inner_h]);
        for (c = [0 : sw_brace_cells - 1])
            translate([sw_frame_margin + c * cell_w, sw_frame_margin])
                xbrace_2d(cell_w, inner_h, sw_strut_width);
        if (sw_brace_cells > 1)
            for (c = [1 : sw_brace_cells - 1])
                translate([sw_frame_margin + c * cell_w - sw_strut_width / 2,
                           sw_frame_margin])
                    square([sw_strut_width, inner_h]);
    }
}

module side_wall_void(x_start) {
    eps = 1;
    translate([x_start - eps, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(wall + 2 * eps)
                side_wall_void_2d();
}

module side_wall_voids() {
    side_wall_void(0);
    side_wall_void(outer_w - wall);
}

// Cuts a "+" shaped void through the snap baseplate so only solid pads
// around the 4 corner snaps remain. Each pad is held by its adjacent
// side wall; the X-braced side walls and bottom lip carry the rigidity.
module baseplate_window() {
    eps = 1;
    snap_w = 24.8;

    snap_x_l = snap_x0;
    snap_x_r = snap_x0 + (snaps_nx - 1) * snap_pitch;
    snap_y_t = snap_y0;
    snap_y_b = snap_y0 + (snaps_ny - 1) * snap_pitch;

    cut_x_lo = snap_x_l + snap_w / 2 + baseplate_pad_clearance;
    cut_x_hi = snap_x_r - snap_w / 2 - baseplate_pad_clearance;
    cut_y_lo = snap_y_t + snap_w / 2 + baseplate_pad_clearance;
    cut_y_hi = snap_y_b - snap_w / 2 - baseplate_pad_clearance;

    z_lo = outer_h - top_thickness - eps;
    z_h  = top_thickness + 2 * eps;

    // Central X strip — between left and right snap columns, full depth.
    translate([cut_x_lo, -eps, z_lo])
        cube([cut_x_hi - cut_x_lo, outer_d + 2 * eps, z_h]);
    // Central Y strip — between front and rear snap rows, full width.
    translate([-eps, cut_y_lo, z_lo])
        cube([outer_w + 2 * eps, cut_y_hi - cut_y_lo, z_h]);
}

// Diagonal X brace across the top plate connecting opposite corner pads.
// Added after the baseplate cuts (otherwise they'd remove it).
module top_x_brace() {
    snap_w = 24.8;
    snap_x_l = snap_x0;
    snap_x_r = snap_x0 + (snaps_nx - 1) * snap_pitch;
    snap_y_t = snap_y0;
    snap_y_b = snap_y0 + (snaps_ny - 1) * snap_pitch;

    pad_inner_x_l = snap_x_l + snap_w / 2 + baseplate_pad_clearance;
    pad_inner_x_r = snap_x_r - snap_w / 2 - baseplate_pad_clearance;
    pad_inner_y_t = snap_y_t + snap_w / 2 + baseplate_pad_clearance;
    pad_inner_y_b = snap_y_b - snap_w / 2 - baseplate_pad_clearance;

    strut_w = 5;
    dx = pad_inner_x_r - pad_inner_x_l;
    dy = pad_inner_y_b - pad_inner_y_t;
    diag = sqrt(dx * dx + dy * dy);
    z = outer_h - top_thickness;

    translate([pad_inner_x_l, pad_inner_y_t, z])
        rotate([0, 0, atan2(dy, dx)])
            translate([0, -strut_w / 2, 0])
                cube([diag, strut_w, top_thickness]);
    translate([pad_inner_x_r, pad_inner_y_t, z])
        rotate([0, 0, atan2(dy, -dx)])
            translate([0, -strut_w / 2, 0])
                cube([diag, strut_w, top_thickness]);
}

module snaps() {
    // Just the 4 corners of the snap grid. Cap face down (against panel),
    // gripping nubs up into the grid hole.
    for (i = [0, snaps_nx - 1], j = [0, snaps_ny - 1])
        translate([snap_x0 + i * snap_pitch,
                   snap_y0 + j * snap_pitch,
                   outer_h + snap_h_lite])
            rotate([180, 0, 0])
                openGridSnap(lite=true, anchor=BOTTOM);
}

difference() {
    shell();
    side_wall_voids();
    baseplate_window();
}
top_x_brace();
snaps();
