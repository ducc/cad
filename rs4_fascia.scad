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
    color("red")
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
    color("yellow")
        translate([0, 0, -fascia_depth+2])
            linear_extrude(fascia_depth+5)
                square([fascia_bottom_width, fascia_height]);
}





module hook() {
    translate([0, 17, 0])
        rotate([270, 0, 270])
            union() {
                // Base where the triangle hook part sits
                linear_extrude(3)
                    square([11, 53+11]);

                // Thicker part joining to fascia
                color("red")
                    translate([11, 36, 0])
                        rotate([0, 0, 180])
                            linear_extrude(3)
                                polygon(points=[
                                    [0, 0],       
                                    [11, 0],      
                                    [17, 36],    
                                    [-6, 36]     
                                ]);

                // Triangle hook part
                translate([0, 52, 0])
                    rotate([0, 90, 0])
                        linear_extrude(11)
                            polygon(points=[
                                [0, 0],     // bottom-left
                                [3, 0],    // bottom-right
                                [0, 12]    // top (centered)
                            ]);
            }
}


    

module left_hook() {
    translate([0, 41, 0])
        union() {
            translate([0, 0, -2])
                color("blue")
                    linear_extrude(2)
                        square([19, 23]);

            translate([16, 0, 0])
            union() {
                translate([0, 0, -8])    
                    hook();
                
                translate([0, 0, -8])
                    color("green")
                        linear_extrude(8)
                            square([3, 23]);
            }
        }
}

module hooks() {
    union() {
        left_hook();

        translate([208, 41, 0])
            translate([19, 64, 0])
                rotate([0, 0, 180])
                    left_hook();

        // Connecting material for test fits
        /*translate([0, 45, 0])
        color("orange")
            linear_extrude(2)
                square([227, 10]);*/
    }
}


difference() {
    union() {   
        difference() {
            union() {
                side_flares();
                fascia_area();
                
                //sony();
                
                //translate([0, 0, -8])
                //    tablet_back();
                
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
                
                // Top hooks which just get in the way, bolt should secure it better
                 /*top_hook();
                 translate([fascia_top_width - 16, 0, 0])
                    top_hook();*/
                    
                 bottom_hook();
                 
                 
            };
            
            translate([0, 0, -6])
                tablet();
            
            translate([12, 6, -27.5])
                color("green")
                    linear_extrude(50)
                        square([tablet_width-8, tablet_height-8]);
            
            bolt_hole();
            translate([fascia_top_width-27, 0, 0])
                bolt_hole();
            
            
           
            
        };
        
        
        
        //hooks();
        
    }
    
    // Delete 90% for test print
    //translate([50, -50, -50])
     //   linear_extrude(100)
      //      square([300,300]);
    //color("red")
    //     translate([-25, 25, -35])
    //        linear_extrude(50)
    //            square([50,80]);
    
}

module bolt_hole() {
    color("pink")
        translate([2, (fascia_height - 21) - 12, -30])
        linear_extrude(50)
            square([15, 15]);
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

module top_hook() {
        translate([0, (fascia_height-3), -26])
            union() {
                color("blue")
                    linear_extrude(8)
                        square([8, 3]);
                color("yellow")
                    translate([8, 0, 8])
                        rotate([180, 90, 0])
                            linear_extrude(8)
                                polygon(points = [
                                    [0, 0],
                                    [2, 0],
                                    [0, 2],
                                ]);
                color("green")
                    translate([0, 0, 0])
                        rotate([180, 270, 0])
                            linear_extrude(8)
                                polygon(points = [
                                    [0, 0],
                                    [2, 0],
                                    [0, 3.5 ],
                                ]);
            }
}


module tablet() {
    union() {
        // area
        translate([fascia_bottom_tablet_width_delta/2, fascia_tablet_height_delta / 2, 0])
            color("gray")    
                linear_extrude(tablet_depth+50)
                    square([tablet_width, tablet_height]);
        // volume controls
        translate([118, 0, 4])
            linear_extrude(8)
                square([70, 30]);
        // camera bump
        //translate([190, 92, -16])
        //    linear_extrude(20)
        //        square([20, 38]);
        // charging port
        translate([-2, (tablet_height-30)/2, 0]) // TODO: put x back to 0 to not leave gap in fascia
            linear_extrude(20) // TODO: reduce height to not leave a gap in the fascia
                square([30, 30]);
    }
}

module tablet_back() {
    //color("black")
    translate([fascia_bottom_tablet_width_delta/2, fascia_tablet_height_delta / 2, 0])
        union() {
            difference() {
                color("orange")
                translate([-3, -2, 0])
                linear_extrude(5)
                    square([tablet_width+6, tablet_height+4]);
                //color("white")
                //translate([2, 2, 0])
                //    linear_extrude(6)
                //        square([tablet_width-4, tablet_height-4]);
            }
        }
}

module sony() {
    translate([fascia_bottom_sony_width_delta/2, fascia_sony_front_height_delta / 2, 0])
        translate([0, sony_front_height, 0])
                rotate([180, 0, 0])
                    color("purple")
                        union() {    
                            linear_extrude(sony_front_depth)
                                square([sony_width, sony_front_height]);
                            translate([0, 0, sony_front_depth])
                                linear_extrude(sony_rear_depth)
                                    square([sony_width, sony_rear_height]);
                        }
}
    
    
    
    
    