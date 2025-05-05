// Cord case - hollow box with 1mm wall thickness
// Height: 12.7cm (127mm)
// box_length: 6.7cm (67mm)
// back_path_width: 2cm (20mm)

// Parameters
front_path_height = 128;      // Height in mm
bottom_path_height = 10;
box_length = 67;       // box_length in mm
back_path_width = 20;        // back_path_width in mm
front_path_width = 50;        // back_path_width in mm
wall_thickness = 1.6; // Wall thickness in mm
connection_box_length = 10;
tolerance = 0.4;

// Function to create a cube that is centered in x, but not in y and z
module c_cube(size_x, size_y, size_z) {
    translate([0, size_y/2, size_z/2])
        cube([size_x, size_y, size_z], center=true);
}


module rounded_box(size_x, size_y, size_z, round_size) {
    hull() {
            // Main body shortened on positive y side
            c_cube(size_x, size_y-round_size, size_z);
            
            // Round corner cylinders on positive y side with larger radius
            translate([size_x/2 - round_size, size_y - round_size, 0])
                cylinder(r=round_size, h=size_z, $fn=40);
                
            translate([-size_x/2 + round_size, size_y - round_size, 0])
                cylinder(r=round_size, h=size_z, $fn=40);
    }
}

// Front box module
module front_part() {
    difference() {
        // Outer box
        // Outer box with more rounded corners on the positive y side
        rounded_box(box_length, front_path_width, front_path_height, 3*wall_thickness);
        
        // Inner cutout with matching rounded corners
        translate([0, wall_thickness, 0])
           rounded_box(box_length-2*wall_thickness, front_path_width-2*wall_thickness, front_path_height, 2*wall_thickness);

        // Lip cutout
        translate([0, 2*wall_thickness+2*tolerance + back_path_width-2*wall_thickness-(2*wall_thickness+2*tolerance)-wall_thickness, front_path_height - wall_thickness])
            rounded_box(box_length, front_path_width, front_path_height, wall_thickness);

        // Connection cutout
        translate([0, 0, 0])
            c_cube(box_length - 2*connection_box_length, 
                  front_path_width - wall_thickness, 
                  front_path_height);
    }
    
    // Rails
    // Right
    translate([box_length/2-wall_thickness-(wall_thickness+2*tolerance)/2, back_path_width-3*wall_thickness-(2*wall_thickness+2*tolerance)+wall_thickness+2*tolerance, 0])
        c_cube(wall_thickness+2*tolerance, 
                  wall_thickness, 
                  front_path_height);
    translate([box_length/2-wall_thickness-(wall_thickness+2*tolerance)-wall_thickness/2, 2*wall_thickness+2*tolerance, 0])
        c_cube(wall_thickness, 
                  back_path_width-2*wall_thickness-(2*wall_thickness+2*tolerance)-wall_thickness, 
                  front_path_height);
    // Left
    translate([-(box_length/2-wall_thickness-(wall_thickness+2*tolerance)/2), back_path_width-3*wall_thickness-(2*wall_thickness+2*tolerance)+wall_thickness+2*tolerance, 0])
        c_cube(wall_thickness+2*tolerance, 
                  wall_thickness, 
                  front_path_height);
    translate([-(box_length/2-wall_thickness-(wall_thickness+2*tolerance)-wall_thickness/2), 2*wall_thickness+2*tolerance, 0])
        c_cube(wall_thickness, 
                  back_path_width-2*wall_thickness-(2*wall_thickness+2*tolerance)-wall_thickness, 
                  front_path_height);
}

// Back box module
module back_part() {
    base_box_length = wall_thickness*3+tolerance*2;
    
    // Back part
    difference() {
        c_cube(box_length-2*wall_thickness-2*tolerance, wall_thickness*3+tolerance*2, front_path_height);
        
        translate([box_length/2-connection_box_length/2-tolerance, wall_thickness, 0])
            c_cube(connection_box_length+tolerance, wall_thickness+2*tolerance, front_path_height);
        translate([-(box_length/2-connection_box_length/2-tolerance), wall_thickness, 0])
            c_cube(connection_box_length+tolerance, wall_thickness+2*tolerance, front_path_height);
    }
    
    // Front pannel
    c_cube(box_length, wall_thickness, front_path_height);
    
    // Side pannel
    translate([box_length/2-wall_thickness-tolerance-wall_thickness/2,2*wall_thickness+2*tolerance, 0])
        c_cube(wall_thickness, back_path_width-3*wall_thickness-(2*wall_thickness+2*tolerance), front_path_height);
    translate([-(box_length/2-wall_thickness-tolerance-wall_thickness/2),2*wall_thickness+2*tolerance, 0])
        c_cube(wall_thickness, back_path_width-3*wall_thickness-(2*wall_thickness+2*tolerance), front_path_height);

    // Base part
    translate([0,0, -bottom_path_height])
        c_cube(box_length, wall_thickness+tolerance, bottom_path_height);
    translate([0, wall_thickness+tolerance, -bottom_path_height])
        difference() {
            rounded_box(box_length, front_path_width, bottom_path_height, 3*wall_thickness);

            // Open for cord input
            translate([0, base_box_length, 0])
                c_cube(box_length - 8*wall_thickness, front_path_width, bottom_path_height);
        }
}

module lip() {
    // Top
    rounded_box(box_length, front_path_width-back_path_width+3*wall_thickness-tolerance, wall_thickness, 3*wall_thickness);

    // Lip snap path
    translate([0, 0, -wall_thickness]) 
        difference() {
            length = box_length-2*wall_thickness-2*tolerance;
            width = front_path_width-back_path_width+2*wall_thickness-2*tolerance;
            rounded_box(length, width, wall_thickness, 2*wall_thickness-tolerance);
            
            translate([0, wall_thickness, 0])
                rounded_box(length-2*wall_thickness, width-2*wall_thickness, wall_thickness, wall_thickness-tolerance);
        }
}

module render(target="both") {
    if (target=="front") {
        front_part();
    } else if (target=="back") {
        back_part();
    } else if (target=="lip") {
        rotate([0, 180, 0]) lip();
    } else {
        back_part();
        translate([0, wall_thickness+tolerance, 0])
            front_part();
        translate([0, 2*wall_thickness+2*tolerance + back_path_width-2*wall_thickness-(2*wall_thickness+2*tolerance)-wall_thickness + tolerance + wall_thickness + tolerance, front_path_height - wall_thickness])
            lip();
    }
}

// Render all
// render("back");
// render("front");
// render("lip");
render();
