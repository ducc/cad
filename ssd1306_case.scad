screen_width = 28.7;
screen_height = 27.5;

wall_width = 1;
wall_height = 6.6;

floor_height = 1;

pinhole_height = 2.5;

module walls() {
    linear_extrude(wall_height)
        square([
            screen_width+wall_width*2, 
            screen_height+wall_width*2
        ]);
}

module base() {
    translate([0, 0, floor_height])
        linear_extrude(wall_height)
            translate([wall_width, wall_width]) 
                square([screen_width, screen_height], center = false);
}

module pinhole() {
    rotate([0, 0, 0]) 
        translate([8+wall_width*2, (wall_width + 0.5), -wall_width])
            linear_extrude(10) 
                square([10.3, pinhole_height]);
}

module stand() {
    stand_width = 2;
    stand_height = 8;
    
    translate([0, wall_width, 1])
        linear_extrude(2.4)
            square([stand_width, stand_height]);
}



module slide_cutout() {
    //translate([0, 0, wall_height-2])
    color("red")
        translate([-0.5, -0.5, wall_height-2])
            difference() {    
                linear_extrude(1) 
                    square([
                        screen_width+wall_width+2, 
                        screen_height+wall_width+2
                    ]);
                translate([1, 1, -1])
                linear_extrude(2.01)
                    square([
                        screen_width+wall_width, 
                        screen_height+wall_width
                    ]);
            }
}

module wall_cutout() {
    color("blue")
        translate([0, screen_height+wall_width+0.5, wall_height-wall_width])
            linear_extrude(1)
                square([screen_width+wall_width*2, 1]);
}

module case() {
    // Right stand
    translate([wall_width, 13.5, 0]) stand();

    // Left stand
    translate([screen_width-wall_width, 13.5, 0]) stand();
    
    difference() {        
        difference() {
            difference() {
                walls();
                wall_cutout();
            }
            slide_cutout();
        }
        base();
        pinhole();
    }
}

case();

lid_overhang = 1.5;
lid_width = (screen_width+wall_width*2)+lid_overhang;
lid_height = (screen_height+wall_width*2)+lid_overhang;

module lid() {   
    color("red")
        translate([-(lid_overhang/2), -(lid_overhang/2), 10])
            linear_extrude(3)
                square([
                    lid_width, 
                    lid_height
                ]);
}

module lid_walls() {
    color("orange")
        translate([0.5, 0, 0])
        translate([-(lid_overhang/2), -(lid_overhang/2), 10])
            linear_extrude(2)
                square([
                    lid_width-1,
                    lid_height-0.5,
                ]);
    
}

module lid_lip() {
    translate([-0.75, -0.75, 10])
        difference() {
            color("blue")
                linear_extrude(0.5)
                    square([
                        lid_width,
                        lid_height
                    ]);
            color("green")
                translate([0.75, 0, 0])
                    linear_extrude(0.5)
                        square([
                            lid_width-1.5,
                            lid_height-1
                        ]);
        }
}

rotate([0, 180, 0])
    translate([0, 50, -13])
        union() {
            difference() {
                lid();
                lid_walls();
            }
            lid_lip();
        }