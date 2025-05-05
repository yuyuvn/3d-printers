// Centered Cube Module
// Creates a cube that is centered in x axis but not in y and z axes
// Parameters:
// - size: [width, depth, height] of the cube or single value for a cube with equal dimensions

screw_hole_diameter = 5;
hook_length = 110;
hook_width = 20;
hook_height = 1;
hook_small_diameter = 8;
hook_small_length = 5;
hook_big_diameter = 20;
hook_big_length = 0.4;

module c_cube(size) {
    // Handle both array and single value inputs
    width = is_list(size) ? size[0] : size;
    depth = is_list(size) ? size[1] : size;
    height = is_list(size) ? size[2] : size;
    
    // Translate only in x direction to center on that axis
    translate([-width/2, 0, 0])
        cube([width, depth, height]);
}

// Hook

module hook() {
    difference() {
        c_cube([hook_width, hook_length, hook_height]);
        // Add a circular hole with 5mm diameter
        translate([0, hook_length-10, 0])
            cylinder(h=1, d=screw_hole_diameter, $fn=30, center=false);
    }

    translate([0, hook_small_diameter/2, hook_height])
        cylinder(h=hook_small_length, d=hook_small_diameter, $fn=30, center=false);
    translate([0, hook_small_diameter/2, hook_height+hook_small_length])
        cylinder(h=hook_big_length, d=hook_big_diameter, $fn=30, center=false);
}

hook();
