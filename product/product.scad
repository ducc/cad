use <ssd1306_case.scad>;
use <button.scad>;

module zeroed_case() {
    // case_front at 0,0
    translate([-0.75, -49.25, 0])
        case_front();
}

zeroed_case();

//translate([-32.2, 0, 0])
//    zeroed_case();
//
//translate([-64.4, 0, 0])
//    zeroed_case();
//
//translate([10, 0, 0])
//    case_back();
//
//translate([10, 35, 0])
//    case_back();
//
//translate([10, 70, 0])
//    case_back();

color("red")
translate([-12, 35, 3])
    button_base();

color("blue")
    translate([-26, 35, 3])
        button_base();

difference() {
    color("green")
        translate([-32.25, 31, 0])
            linear_extrude(1)
                square([32.25, 14]);
    
    color("red")
        translate([-13, 34, 0])
            linear_extrude(1)
            square([8,8]);
    
    color("blue")
        translate([-27, 34, 0])
            linear_extrude(1)
                square([8, 8]);
}

difference() {
    difference() {
        difference() {
            translate([-32.25, 0, 0])
                linear_extrude(10)
                    square([32.25, 45]);
        
            color("red")
                translate([-21.25, 0, 7.5])
                    linear_extrude(2.5)
                        square([10, 1]);
        }
        
        translate([-31.25, 0, 1])
            linear_extrude(6.8)
                square([30.25, 1]);
    }
    
    color("pink")
        translate([-31.25, 1, 0])
            linear_extrude(10)
                square([30.25, 43]);
}