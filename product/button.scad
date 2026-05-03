module base() {
    difference() {
        // base
        translate([-1, -1, 0])
            linear_extrude(1)
                square([8,8]);
        
        // cutouts for leg connections
        linear_extrude(1)
            square([2,2]);
        translate([4, 0, 0])
            linear_extrude(1)
                square([2,2]);
        translate([0, 4, 0])
            linear_extrude(1)
                square([2,2]);
        translate([4, 4, 0])
            linear_extrude(1)
                square([2,2]);
    }
}

module walls() {
    difference() {
        translate([-1, -1, -3])
            linear_extrude(7.5)
                square([8, 8]);
        color("blue")
            translate([-0.25, -0.25, -3])
                linear_extrude(7.5)
                    square([6.5, 6.5]);
    }
}

module button_cap() {
    button_clicker_height = 2.5;
    button_clicker_travel = 0.3;
    
    union() {
        color("orange") translate([-2, -2, 4.5+button_clicker_height])
            linear_extrude(1)
                square([10,10]);
        difference() {
            color("blue") translate([-2, -2, -2])
                linear_extrude(9)
                    square([10, 10]);
            color("green") translate([-1.25, -1.25, -2])
                linear_extrude(9)
                    square([8.5, 8.5]);
        }
    }
}

module button_base() {
    union() {
        base();
        walls();
    }
}

button_base();
button_cap();