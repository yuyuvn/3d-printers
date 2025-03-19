/* START main.scad*/
/**
 * Simple case for a ESP32-Wroom-32D DevKitc V4
 */

/* START primitives.scad*/
/**
 * A centered cube, but flat on the Z-Surface
 *
 * Negative z will create a cube flat under the surface
 */
module ccube(v) {
    trans = v.z/2;
    translate([0, 0, trans]) cube([v.x, v.y, abs(v.z)], true);
}

/**
 * An upright standing centered cylinder, flat on the Z-Surface
 */
module ccylinder_y(h, d) {
    translate([h/-2, 0, d/2])
        rotate([0, 90, 0])
            cylinder(h=h, d=d);
}

/**
 * Creates a rounded cube
 *
 * @param {vector} v The size of the cube
 * @param {number} r The radius of the rounding
 * @param {bool} flatcenter centered but flat on Z
 */
module roundedCube(v, r=1, flatcenter=true) {
    mv = flatcenter ? [0,0,0] : [v.x/2, v.y/2 ,0];

    translate(mv) hull() {
        // right back bottom
        translate([v.x/2 - r, v.y/2 - r, r])
            sphere(r=r);

        // right front bottom
        translate([v.x/2 - r, v.y/-2 + r, r])
            sphere(r=r);

        // left back bottom
        translate([v.x/-2 + r, v.y/2 - r, r])
            sphere(r=r);

        // left front bottom
        translate([v.x/-2 + r, v.y/-2 + r, r])
            sphere(r=r);


        // right back top
        translate([v.x/2 - r, v.y/2 - r, v.z - r])
            sphere(r=r);

        // right front top
        translate([v.x/2 - r, v.y/-2 + r, v.z - r])
            sphere(r=r);

        // left back top
        translate([v.x/-2 + r, v.y/2 - r, v.z - r])
            sphere(r=r);

        // left front top
        translate([v.x/-2 + r, v.y/-2 + r, v.z - r])
            sphere(r=r);
    }
}

/**
 * Similar to the rounded cube, but the top and bottom are flat
 * @param {vector} v The size of the cube
 * @param {number} r The radius of the rounding
 * @param {bool} flatcenter centered but flat on Z
 */
module curvedCube(v, r=1, flatcenter=true) {
    mv = flatcenter ? [v.x/-2, v.y/-2 ,0] : [0,0,0];

    translate(mv) hull() {
        // right back
        translate([v.x - r, v.y - r, 0])
            cylinder(h=v.z, r=r);
        
        // right front
        translate([v.x - r, r, 0])
            cylinder(h=v.z, r=r);

        // left back
        translate([r, v.y - r, 0])
            cylinder(h=v.z, r=r);

        // left front
        translate([r, r, 0])
            cylinder(h=v.z, r=r);
    }
}
/* END primitives.scad*/
/* START honeycomb.scad*/
/**
 * @link http://forum.openscad.org/Beginner-Honeycomb-advice-needed-td4556.html
 * @author Przemo Firszt
 */

module honeycomb_column(length, cell_size, wall_thickness)
{
    no_of_cells = floor(length / (cell_size + wall_thickness));

    for (i = [0:no_of_cells]) {
        translate([ 0, (i * (cell_size + wall_thickness)), 0 ])
            circle($fn = 6, r = cell_size * (sqrt(3) / 3));
    }
}

module honeycomb(length, width, height, cell_size, wall_thickness)
{
    no_of_rows = floor(1.2 * length / (cell_size + wall_thickness));

    tr_mod = cell_size + wall_thickness;
    tr_x = sqrt(3) / 2 * tr_mod;
    tr_y = tr_mod / 2;
    off_x = -1 * wall_thickness / 2;
    off_y = wall_thickness / 2;
    linear_extrude(
        height = height, center = true, convexity = 10, twist = 0, slices = 1)
        difference()
    {
        square([ length, width ]);
        for (i = [0:no_of_rows]) {
            translate([ i * tr_x + off_x, (i % 2) * tr_y + off_y, 0 ])
                honeycomb_column(width, cell_size, wall_thickness);
        }
    }
}

module choneycomb(v, size, walls) {
    translate([v.x/-2, v.y/-2, v.z/2]) {
        honeycomb(v.x, v.y, v.z, size, walls);
    }
}
/* END honeycomb.scad*/

pcb = [48.5, 28.5, 2]; // size of the PCB
walls = 1; // wallthickness
pinrow = [38.5, 3, 20]; // size of the pin rows
antenna = 18.5; // width of the antenna
usb = 10; // width of the usb (a little wider to accomodate fat plugs)
tolerance = 0.23; // tolerance for the snap fit

// RJ45 extension parameters
enable_head_extension = true; // Enable extension at the head (antenna side)
enable_tail_extension = false; // Enable extension at the tail (USB side)
rj45_pcb = [28, 34, 2];
rj45_port_size = [18, 16, 13];
extension_space = [rj45_pcb.x+20, rj45_pcb.y, rj45_port_size.z+rj45_pcb.z]; // Size of the extension
// pillar_diameter = 2;

print_part();

/**
 * Prints the selected part
 *
 * @param {string} The part to print
 */
module print_part(part="all") {
    if (part == "bottom_exposed_pins") {
        body(false);
    } else if (part == "bottom_covered_pins") {
        body(true);
    } else if (part == "lid_honeycomb") {
        lid();
    } else {
        translate ([0, 0, 0]) body(true);
        translate ([0, 60, 0]) lid();
    }
}

/**
 * Part of the body, the rim around the PCB with cutouts for the
 * Antenna and USB Port, plus extensions for RJ45
 */
module rimWithAntenna() {
    height = 3.2 + pcb.z;
    width = max(pcb.y, extension_space.y);
    
    difference() {
        union() {
            // Main rim
            ccube([pcb.x + walls*2, width + walls*2, height]);
            
            // Head extension (antenna side)
            if (enable_head_extension) {
                translate([-1 * (pcb.x/2 + extension_space.x/2), 0, 0])
                    ccube([extension_space.x, width + walls*2, height]);
            }
            
            // Tail extension (USB side)
            if (enable_tail_extension) {
                translate([pcb.x/2 + extension_space.x/2, 0, 0])
                    ccube([extension_space.x, width + walls*2, height]);
            }
        }
        
        // Main cutout
        ccube(pcb);
        translate([0,0,pcb.z]) ccube([pcb.x, width, height]);

        // Cutouts for openings
        if (!enable_tail_extension) {
            translate([pcb.x/2,0,rj45_pcb.z]) ccube([walls*2, usb, height-rj45_pcb.z]);
        }
        if (!enable_head_extension) {
            translate([pcb.x/-2,0,rj45_pcb.z]) ccube([walls*2, antenna, height-rj45_pcb.z]);
        }
        
        // Board cutout in head extension
        if (enable_head_extension) {
            translate([
                -1 * (pcb.x/2 + extension_space.x/2 - walls), 0, 0 
            ]) ccube([extension_space.x, extension_space.y, height]);
        }
        
        // Board cutout in tail extension
        if (enable_tail_extension) {
            translate([
                pcb.x/2 + extension_space.x/2 - walls, 0, 0
            ]) ccube([extension_space.x, extension_space.y, height]);
        }

        // RJ45 cutout in head extension
            if (enable_head_extension) {
                translate([-1 * (pcb.x/2 + extension_space.x), 0, 0])
                    ccube([walls*2, rj45_port_size.y, height]);
            }

            // RJ45 cutout in tail extension
            if (enable_tail_extension) {
                translate([pcb.x/2 + extension_space.x, 0, 0])
                    ccube([walls*2, rj45_port_size.y, height]);
            }
    }
}

/**
 * Part of the body, the base under the PCB with cutouts for the pins
 * and extensions for RJ45
 *
 * @param {bool} should the pins be completely covered?
 */
module baseWithPins(cover) {
    height = cover ? (pinrow.z + walls) : walls;
    width = max(pcb.y, extension_space.y);
    pinmv = cover ? walls : pinrow.z/-2;
    liph = 2.3;
    wire_space = 8;
    
    translate([0,0,-1 * height]) {
        difference() {
            union() {
                // Main base
                ccube([pcb.x + walls*2, width + walls*2, height]);
                
                // Head extension base (antenna side)
                if (enable_head_extension) {
                    translate([-1 * (pcb.x/2 + extension_space.x/2), 0, 0])
                        ccube([extension_space.x, width + walls*2, height]);
                }
                
                // Tail extension base (USB side)
                if (enable_tail_extension) {
                    translate([pcb.x/2 + extension_space.x/2, 0, 0])
                        ccube([extension_space.x, width + walls*2, height]);
                }
            }
            
            // PCB tray cutout
            translate([0,0,pinrow.z + walls]) ccube([pcb.x, width, pcb.z]);
            
            // Pin row cutouts
            translate([0,pcb.y/2 - pinrow.y/2, pinmv])
                ccube([pinrow.x, pinrow.y, pinrow.z]);
            translate([0,(pcb.y/2 - pinrow.y/2)*-1, pinmv])
                ccube([pinrow.x, pinrow.y, pinrow.z]);

            // wire cutout
            translate([0, (pcb.y/2 - 5)/2 + 5, walls])
                ccube([pinrow.x, pcb.y/2 - 5, 5]);
            translate([0, -1 *(pcb.y/2 - 5)/2 - 5, walls])
                ccube([pinrow.x, pcb.y/2 - 5, 5]);
            
            if (enable_head_extension) {
                translate([(pcb.x - pinrow.x)/2 - (wire_space/2) - (pcb.x/2), (pcb.y/2 - 5)/2 + 5, walls])
                    ccube([wire_space + (pcb.x - pinrow.x), pcb.y/2 - 5, 15]);
                translate([(pcb.x - pinrow.x)/2 - (wire_space/2) - (pcb.x/2), -1 *(pcb.y/2 - 5)/2 - 5, walls])
                    ccube([wire_space + (pcb.x - pinrow.x), pcb.y/2 - 5, 15]);
            }

            if (enable_tail_extension) {
                translate([((pcb.x - pinrow.x)/2 - (wire_space/2) - (pcb.x/2))*-1, (pcb.y/2 - 5)/2 + 5, walls])
                    ccube([wire_space + (pcb.x - pinrow.x), pcb.y/2 - 5, 15]);
                translate([((pcb.x - pinrow.x)/2 - (wire_space/2) - (pcb.x/2))*-1, -1 *(pcb.y/2 - 5)/2 - 5, walls])
                    ccube([wire_space + (pcb.x - pinrow.x), pcb.y/2 - 5, 15]);
            }

            // Debug
            // ccube([pcb.x, pcb.y, walls]);

            // Board cutout in head extension
            if (enable_head_extension) {
                translate([
                    -1 * (pcb.x/2 +extension_space.x/2 - walls), 0, height - extension_space.z + rj45_pcb.z
                ]) ccube([extension_space.x, extension_space.y, extension_space.z]);
            }
            
            // Board cutout in tail extension
            if (enable_tail_extension) {
                translate([
                    pcb.x/2 +extension_space.x/2 - walls, 0, height - extension_space.z + rj45_pcb.z
                ]) ccube([extension_space.x, extension_space.y, extension_space.z]);
            }

            // RJ45 cutout in head extension
            if (enable_head_extension) {
                translate([-1 * (pcb.x/2 + extension_space.x), 0, height - rj45_port_size.z + rj45_pcb.z + 3.2])
                    ccube([walls*2, rj45_port_size.y, rj45_port_size.z]);
            }

            // RJ45 cutout in tail extension
            if (enable_tail_extension) {
                translate([pcb.x/2 + extension_space.x, 0, height - rj45_port_size.z + rj45_pcb.z + 3.2])
                    ccube([walls*2, rj45_port_size.y, rj45_port_size.z]);
            }
        }
    }

    // A small lip to keep the PCB in place
    if (enable_head_extension) {
        translate([-1 * (pcb.x/2 + (extension_space.x - rj45_pcb.x) - 5),0,-1 * extension_space.z + rj45_pcb.z]) {
            ccube([10, extension_space.y, rj45_pcb.z]);
        }
    }

    if (enable_tail_extension) {
        translate([pcb.x/2 + (extension_space.x - rj45_pcb.x) - 5,0,-1 * extension_space.z + rj45_pcb.z]) {
            ccube([10, extension_space.y, rj45_pcb.z]);
        }
    }
}

/**
 * Part of the lid, the main cover with extensions for RJ45
 *
 * This uses a honeycomb for air flow
 */
module cover() {
    xoffset = 3;
    yoffset = 3;
    width = max(pcb.y, extension_space.y);
    xspace = 0; // we could use this to make space for buttons and dedicated LED holes
    
    difference(){
        union() {
            // Main cover
            ccube([pcb.x + walls*2, width + walls*2, walls]);
            
            // Head extension cover (antenna side)
            if (enable_head_extension) {
                translate([-1 * (pcb.x/2 + extension_space.x/2), 0, 0])
                    ccube([extension_space.x, width + walls*2, walls]);
            }
            
            // Tail extension cover (USB side)
            if (enable_tail_extension) {
                translate([pcb.x/2 + extension_space.x/2, 0, 0])
                    ccube([extension_space.x, width + walls*2, walls]);
            }
        }
        
        // Cutout to be filled with honeycomb (main area)
        translate([xspace,0,0]) {
            ccube([pcb.x - xoffset*2 - xspace*2, width - yoffset*2, walls]);
        }
        
        // Cutout for honeycomb in head extension
        if (enable_head_extension) {
            translate([-1 * (pcb.x/2 + extension_space.x/2), 0, 0]) {
                ccube([extension_space.x - xoffset*2, width - yoffset*2, walls]);
            }
        }
        
        // Cutout for honeycomb in tail extension
        if (enable_tail_extension) {
            translate([pcb.x/2 + extension_space.x/2, 0, 0]) {
                ccube([extension_space.x - xoffset*2, width - yoffset*2, walls]);
            }
        }
    }
    
    // Main honeycomb
    choneycomb([pcb.x, width, walls], walls*4, walls);
    
    // Head extension honeycomb
    if (enable_head_extension) {
        translate([-1 * (pcb.x/2 + extension_space.x/2), 0, 0]) {
            choneycomb([extension_space.x, width, walls], walls*4, walls);
        }
    }
    
    // Tail extension honeycomb
    if (enable_tail_extension) {
        translate([pcb.x/2 + extension_space.x/2, 0, 0]) {
            choneycomb([extension_space.x, width, walls], walls*4, walls);
        }
    }
}

/**
 * Part of the lid, the lip that makes the snapfit
 */
module lip() {
    width = max(pcb.y, extension_space.y);
    liph = 2.3;
    lipw = 1;
    
    translate([0,0,-1*liph]) {
        difference(){
            union() {
                // Main lip
                ccube([pcb.x-tolerance, width-tolerance, liph]);

                // Head extension lip (antenna side)
                if (enable_head_extension) {
                    translate([-1 * (pcb.x/2 + extension_space.x/2), 0, 0])
                        ccube([extension_space.x-tolerance, width-tolerance, liph]);
                    
                    // Add four pillars at the corners of the head extension
                    // pillar_height = rj45_port_size.z;
                    // pillar_x_offset = extension_space.x/2 - pillar_diameter/2 - 1;
                    // pillar_y_offset = pcb.y/2 - pillar_diameter/2 - 1;
                    
                    // translate([-1 * (pcb.x/2 + extension_space.x/2), 0, -1 * pillar_height]) {
                    //     // Top-left pillar
                    //     translate([-pillar_x_offset, pillar_y_offset, 0])
                    //         cylinder(h=pillar_height, r=pillar_diameter/2);
                        
                    //     // Top-right pillar
                    //     translate([pillar_x_offset, pillar_y_offset, 0])
                    //         cylinder(h=pillar_height, r=pillar_diameter/2);
                        
                    //     // Bottom-left pillar
                    //     translate([-pillar_x_offset, -pillar_y_offset, 0])
                    //         cylinder(h=pillar_height, r=pillar_diameter/2);
                        
                    //     // Bottom-right pillar
                    //     translate([pillar_x_offset, -pillar_y_offset, 0])
                    //         cylinder(h=pillar_height, r=pillar_diameter/2);
                    // }
                }
                
                // Tail extension lip (USB side)
                if (enable_tail_extension) {
                    translate([pcb.x/2 + extension_space.x/2, 0, 0])
                        ccube([extension_space.x-tolerance, width-tolerance, liph]);
                }
            }
            
            // Main inner cutout
            ccube([pcb.x-tolerance-lipw, width-tolerance-lipw, liph]);
            
            // Head extension inner cutout
            if (enable_head_extension) {
                translate([-1 * (pcb.x/2 + extension_space.x/2), 0, 0])
                    ccube([extension_space.x-tolerance-lipw, width-tolerance-lipw, liph]);
            }
            
            // Tail extension inner cutout
            if (enable_tail_extension) {
                translate([pcb.x/2 + extension_space.x/2, 0, 0])
                    ccube([extension_space.x-tolerance-lipw, width-tolerance-lipw, liph]);
            }
            
            // Cutouts for openings
            translate([pcb.x/-2,0,0]) ccube([walls*2, antenna, liph]);
            translate([pcb.x/2,0,0]) ccube([walls*2, usb, liph]);
            
            // RJ45 cutout in head extension
            if (enable_head_extension) {
                translate([-1 * (pcb.x/2 + extension_space.x), 0, 0])
                    ccube([walls*2, rj45_port_size.y, liph]);
            }
            
            // RJ45 cutout in tail extension
            if (enable_tail_extension) {
                translate([pcb.x/2 + extension_space.x, 0, 0])
                    ccube([walls*2, rj45_port_size.y, liph]);
            }
        }
    }
}

/**
 * Assembles the lid
 */
module lid(){
    rotate([180,0,0]) {
        cover();
        lip();
    }
}

/**
 * Assembles the body
 * @param {bool} should the pins be completely covered?
 */
module body(cover){
    baseWithPins(cover);
    rimWithAntenna();
}
/* END main.scad*/

