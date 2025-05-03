// Cord case - hollow box with 1mm wall thickness
// Height: 12.7cm (127mm)
// Length: 6.7cm (67mm)
// Width: 2cm (20mm)

// Parameters
height = 127;      // Height in mm
length = 67;       // Length in mm
width = 20;        // Width in mm
wall_thickness = 1; // Wall thickness in mm
connection_length = 10;

// Function to create a cube that is centered in x, but not in y and z
module c_cube(size_x, size_y, size_z) {
    translate([0, size_y/2, size_z/2])
        cube([size_x, size_y, size_z], center=true);
}


// Main box module
module front_part() {
    difference() {
        // Outer box
        // Outer box with more rounded corners on the positive y side
        hull() {
            // Main body shortened on positive y side
            difference() {
                c_cube(length, width, height);

                translate([length/2 - wall_thickness, width - 3*wall_thickness, 0])
                    c_cube(3*wall_thickness, 3*wall_thickness, height);
                
                translate([-(length/2 - wall_thickness), width - 3*wall_thickness, 0])
                    c_cube(3*wall_thickness, 3*wall_thickness, height);
            }
            
            // Round corner cylinders on positive y side with larger radius
            translate([length/2 - 3*wall_thickness, width - 3*wall_thickness, 0])
                cylinder(r=3*wall_thickness, h=height, $fn=40);
                
            translate([-length/2 + 3*wall_thickness, width - 3*wall_thickness, 0])
                cylinder(r=3*wall_thickness, h=height, $fn=40);
        }
        
        // Inner cutout with matching rounded corners
        hull() {
            // Main inner body
            difference() {
                translate([0, wall_thickness, 0])
                    c_cube(length - 2*wall_thickness, width - 2*wall_thickness, height);

                translate([length/2 - 2*wall_thickness, width - 4*wall_thickness, wall_thickness])
                    c_cube(3*wall_thickness, 3*wall_thickness, height - wall_thickness);
                
                translate([-(length/2 - 2*wall_thickness), width - 4*wall_thickness, wall_thickness])
                    c_cube(3*wall_thickness, 3*wall_thickness, height - wall_thickness);
            }
            
            // Round corner cylinders for inner cutout - using same radius as outer corners for consistency
            translate([length/2 - 3*wall_thickness, width - 3*wall_thickness, wall_thickness])
                cylinder(r=3*wall_thickness - wall_thickness, h=height - wall_thickness, $fn=40);
                
            translate([-length/2 + 3*wall_thickness, width - 3*wall_thickness, wall_thickness])
                cylinder(r=3*wall_thickness - wall_thickness, h=height - wall_thickness, $fn=40);
        }

        // Connection cutout
        translate([0, 0, 0])
            c_cube(length - 2*connection_length, 
                  width - wall_thickness, 
                  height);
    }
}

// Render the hollow box
front_part();
