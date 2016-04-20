difference(){
    union(){
        cube([25.6, 51.4, 1.5]);
        translate(v=[25.6/2-7/2, -9, 0]){
            union(){
                cube([7, 9, 1.5]);
                translate([7/2, 9/2, 1.5]){
                        cylinder(r=3, h=3);
                };
            };
        };
        translate([4.8, 51.4-2, 1.49]){
            cube([4, 3.7, 1.2]);
        };
        translate([25.6-4.8-4, 51.4-2, 1.49]){
            cube([4, 3.7, 1.2]);
        };
    };
    translate([25.6/2, -9/2, -1]){
        cylinder(r=2.5/2, h=10);
    };
};