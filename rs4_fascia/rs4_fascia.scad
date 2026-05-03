fascia_top_width = 235;
fascia_bottom_width = 227;
fascia_height = 128;
fascia_depth = 5;

fascia_top_bottom_width_delta = fascia_top_width - fascia_bottom_width;

tablet_width = 211;
tablet_height = 124.7;
tablet_depth = 8;

fascia_bottom_tablet_width_delta = fascia_bottom_width - tablet_width;
fascia_tablet_height_delta = fascia_height - tablet_height;

sony_width = 182;
sony_depth = 133;
sony_front_height = 103;
sony_rear_height = 53;
sony_rear_depth = 110;
sony_front_depth = sony_depth - sony_rear_depth;

fascia_bottom_sony_width_delta = fascia_bottom_width - sony_width;
fascia_sony_front_height_delta = fascia_height - sony_front_height;


// Side flares to fill in the entire gap
module side_flares() {
        translate([0, 0, -fascia_depth+2])
            linear_extrude(fascia_depth+5)
                polygon(points=[
                    [0, 0], // bottom left
                    [fascia_bottom_width, 0], // bottom right
                    [231, fascia_height], // top right
                    [-(fascia_top_bottom_width_delta / 2), fascia_height] // top left
                ]);
}

// Usable area
module fascia_area() {
        translate([0, 0, -fascia_depth+2])
            linear_extrude(fascia_depth+5)
                square([fascia_bottom_width, fascia_height]);
}

difference() {
    difference() {
        union() {   
            difference() {
                union() {
                    side_flares();
                    fascia_area();
                    
                    translate([0, 0, -18])
                        linear_extrude(15)
                            square([fascia_bottom_width, fascia_height]);
                    
                    translate([0, 0, -18])
                        rotate([90, 90, 90])
                            linear_extrude(fascia_bottom_width)
                                polygon(points = [
                                    [0,0],
                                    [11,0],
                                    [0,tablet_height+3]
                                ]);
                        
                     bottom_hook();
                     
                     bolt_mount();
                     translate([214, 0, 0])
                        bolt_mount();
                     
                };
                
                translate([0, 0, -6])
                    tablet();
                
                // Void behind tablet
                translate([12, 2, -27.5])
                    color("green")
                        linear_extrude(50)
                            square([tablet_width-8, tablet_height]);
                
            };
            
            translate([12, 6, 5])
                difference() {
                    color("orange")
                        translate([-4, -5, 0])
                        linear_extrude(2)
                            square([tablet_width, tablet_height+1]);
                    color("red")
                        linear_extrude(2)
                            square([tablet_width-8, tablet_height-8]);
                }
                
                translate([12, 6, -5.5])
                difference() {
                    color("orange")
                        translate([-4, -4, -1.5])
                        linear_extrude(3)
                            square([tablet_width, tablet_height]);
                    color("red")
                        translate([0, 0, -1.5])
                        linear_extrude(3)
                            square([tablet_width-8, tablet_height-8]);
                }
                
        }
        
        bolt_hole();
            translate([fascia_top_width-24, 0, 0])
                bolt_hole();
        
        translate([8, fascia_height-10 ,-3.5])
                color("yellow")
                    linear_extrude(10.5)
                        square([fascia_top_width-24,20]);
        
        
        camera_bump();
        
        cupholder_angle_cutout();
        translate([fascia_top_width-12, 0, 0])
            cupholder_angle_cutout();
    
        // Delete 90% for test print
        /*translate([50, -50, -50])
            linear_extrude(100)
                square([300,300]);
        color("red")
             translate([-25, 0, -35])
                linear_extrude(50)
                    square([500,90]);
        color("red")
             translate([-25, 115, -35])
                linear_extrude(50)
                    square([500,90]);*/
    }
}

module cupholder_angle_cutout() {
    color("green")
            translate([8, fascia_height, 4])
                rotate([270, 180, 90])
                    linear_extrude(12)
                        polygon(points = [
                            [0, 0],
                            [3, 3],
                            [0, 3],
                        ]);
}

module camera_bump() {
    color("red")
        translate([fascia_top_width-(20+14+8), fascia_height-18, -8.5])
            linear_extrude(5)
                square([18, 18]);
}

module bolt_hole() {
    color("pink")
        translate([0.5, (fascia_height - 21) - 13, -21.8])
            linear_extrude(50)
                square([15, 15]);
}

module bolt_mount() {
    translate([-0.5, fascia_height-33, -25.5])
        union() {
            bolt_mount_triangle_support();
            
            rotate([6, 0, 0])
                difference() {
                    union() {
                        translate([0, -2, 0])
                            color("blue")
                                linear_extrude(5)
                                        square([15,18]);
                    }
                    color("lightgreen")
                        translate([1, -0.5, 2])
                            linear_extrude(5)
                                    square([13,15]);
                    color("red")
                            translate([7, 7, -2])
                                linear_extrude(6)
                                    circle(6/2);
                }        
        }
}

module bolt_mount_triangle_support() {
    color("red")
        translate([0, 15, 6.5])
            rotate([0, 90, 0])
                linear_extrude(13.5)
                        polygon(points = [
                            [0, 0],
                            [3, 0],
                            [0, 3],
                        ]);
}

module bottom_hook() {
    translate([0, 6, -31])
        difference() {
            union() {
                color("pink")
                    linear_extrude(4.5)
                        square([fascia_bottom_width, 12]);
                color("red")
                    translate([30, -5, -2])
                        linear_extrude(2)
                            square([15,17]);
                color("pink")
                    translate([75, -5, -2])
                        linear_extrude(2)
                            square([15,17]);
                color("pink")
                    translate([(fascia_bottom_width-15)-30, -5, -2])
                        linear_extrude(2)
                            square([15,17]);
                
                bottom_hook_triangle_support_duo();
                translate([45, 0, 0])
                    bottom_hook_triangle_support_duo();
                translate([fascia_bottom_width-75, 0, 0])
                    bottom_hook_triangle_support_duo();
            }
            
            bottom_hook_angled_cutout();
                translate([45, 0, 0])
            bottom_hook_angled_cutout();
                translate([fascia_bottom_width-75, 0, 0])
            bottom_hook_angled_cutout();
        }
}

module bottom_hook_angled_cutout() {
    color("lightgreen")
        rotate([6, 0, 0])
            translate([30, -6, 0])
                linear_extrude(3)
                    square([15, 6]);
}

module bottom_hook_triangle_support_duo() {
    bottom_hook_triangle_support();
    translate([75, 12, 0])
        rotate([180, 180, 0])
            bottom_hook_triangle_support();
}

module bottom_hook_triangle_support() {
    color("yellow")
        translate([30, 0, 0])
            rotate([270, 90, 0])
                linear_extrude(12)
                    polygon(points = [
                        [0, 0],
                        [2, 0],
                        [0, 2],
                    ]);
}

module tablet() {
    union() {
        // area
        translate([fascia_bottom_tablet_width_delta/2, fascia_tablet_height_delta / 2, 0])
            color("gray")    
                linear_extrude(tablet_depth+50)
                    square([tablet_width, tablet_height]);
        // volume controls
        translate([118, 0, 2])
            linear_extrude(8.5)
                square([70, 30]);
        // charging port
        translate([-3, (tablet_height-30)/2, 0]) // TODO: put x back to 0 to not leave gap in fascia
            union() {
                linear_extrude(20) // TODO: reduce height to not leave a gap in the fascia
                    square([11, 26]);
                translate([0, -30, 0])
                    union() {
                        linear_extrude(20)
                            square([30, 30]);
                        color("red")
                            translate([0, -13, -30])
                                linear_extrude(60)
                                    square([10, 23]);
                    }
            }
    }
}

module tablet_back() {
    translate([fascia_bottom_tablet_width_delta/2, fascia_tablet_height_delta / 2, 0])
        union() {
            difference() {
                color("orange")
                    translate([-3, -2, 0])
                        linear_extrude(5)
                            square([tablet_width+6, tablet_height+4]);
            }
        }
}
