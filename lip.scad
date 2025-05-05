// Rounded Box Module for OpenSCAD
// Parameters:
// - size: [width, depth, height] of the box
// - radius: radius of the rounded corners (only for horizontal edges)
// - center: true/false to center the box
// - wall_thickness: thickness of the walls (default 1mm)

// Centered Cube Module
// Creates a cube that is centered in x and y axes but not in z
// Parameters:
// - size: [width, depth, height] of the cube

inner_size = 73.5;
outter_size = 76;
height = 15;

module c_cube(size=[10, 10, 10]) {
    translate([-size[0]/2, -size[1]/2, 0])
        cube(size);
}

module honeycomb() {
    for (i = [-4:4]) {
        for (j = [-4:4]) {
            // Offset every other row for honeycomb effect
            translate([i*7 + (j%2)*3.5, j*6, 0])
                cylinder(h=height-2.5, r=3, $fn=6, center=true); // Hexagonal holes
        }
    }
    
    // Add decorative circular pattern around the edges
    for (angle = [0:45:359]) {
        translate([25*cos(angle), 25*sin(angle), 10-0.5])
            cylinder(h=1, r=2, $fn=12, center=true);
    }
}

module rounded_box(size=[20, 15, 10], radius=10, center=true, wall_thickness=1) {
    // Error checking
    r = min(radius, min(size[0]/2, size[1]/2));
    
    // Adjust dimensions
    width = size[0];
    depth = size[1];
    height = size[2];
    
    // Calculate offsets for centering in x and y
    x_offset = center ? -width/2 : 0;
    y_offset = center ? -depth/2 : 0;
    
    translate([x_offset, y_offset, 0]) {
        difference() {
            // Outer shell
            hull() {
                // Place 4 cylinders at the vertical edges
                for (x = [r, width-r]) {
                    for (y = [r, depth-r]) {
                        translate([x, y, 0])
                            cylinder(h=height, r=r, $fn=30);
                    }
                }
            }
            
            // Inner cutout
            translate([0, 0, wall_thickness]) // Leave bottom with thickness
            hull() {
                // Place 4 cylinders at the vertical edges with reduced radius
                for (x = [r, width-r]) {
                    for (y = [r, depth-r]) {
                        translate([x, y, 0])
                            cylinder(h=height, r=r-wall_thickness, $fn=30);
                    }
                }
            }
        }
    }
}

module lever(wall_thickness=1.5, center=true) {
    // Create a simple lever - a rectangular box with dimensions 8mm x 1mm x 5mm
    // (length x width x height)
    hole_width=2.6;
    extrude_height=1;
    
    // Apply centering transformation if needed - only for x and y, not for z
    translate(center ? [-4, -wall_thickness/2, 0] : [0, 0, 0]) {
        difference() {
            cube([8, wall_thickness, 5-extrude_height]);
            translate([(8-hole_width)/2, 0, 1])
              cube([hole_width, wall_thickness, 4]);
            translate([4, wall_thickness, 1.6])
                rotate([90, 0, 0])
                    cylinder(h=wall_thickness, r=1.5, $fn=30);
            // Chamfer the top edge of the lever by 0.05mm
        }
        translate([(8-hole_width)/2, 0, 5-extrude_height])
            rotate([0, -90, 0])
            linear_extrude(height=(8-hole_width)/2)
            polygon(points=[[0,0], [extrude_height,0], [extrude_height,1], [0,wall_thickness]]);
        translate([8, 0, 5-extrude_height])
            rotate([0, -90, 0])
            linear_extrude(height=(8-hole_width)/2)
            polygon(points=[[0,0], [extrude_height,0], [extrude_height,1], [0,wall_thickness]]);
    }
}

// Example usage:
difference() {
    translate([0, 0, -height+2.5]) {
        difference() {
            union() {
                rounded_box([inner_size, inner_size, height], 25);
                rounded_box([outter_size, outter_size, height-2.5], 25, wall_thickness=2);
            }
    
            // honeycomb();
            // Hole for LED diffuser
            // translate([0, 0, 0])
            //    cylinder(h=20, d=50, center=true, $fn=60);
        }
    }
    translate([8, -inner_size/2+0.4, 0])
        c_cube([8, 1.5, 5]);
    translate([-8, -inner_size/2+0.4, 0])
        c_cube([8, 1.5, 5]);
    translate([0, inner_size/2-0.4, 0])
        c_cube([25, 1.5, 5]);
}
translate([8, -inner_size/2+0.4, 0])
    rotate([0, 0, 180])
        lever();
translate([-8, -inner_size/2+0.4, 0])
    rotate([0, 0, 180])
        lever();
translate([8.5, inner_size/2-0.4, 0])
    lever();
translate([-8.5, inner_size/2-0.4, 0])
    lever();

// translate([0, inner_size/2-0.4+0.3, 10-2.5+2.5-0.7])
//    rotate([-10, 0, 0])
//        cylinder(h=6, d=1, center=true, $fn=30);