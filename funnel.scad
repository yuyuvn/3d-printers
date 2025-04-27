// Funnel 3D model
// Small radius: 7mm
// Large radius: 25mm

// Parameters
small_radius = 7;  // Small end radius in mm
large_radius = 25; // Large end radius in mm
height = 40;       // Total height of the funnel
thickness = 1;     // Wall thickness
transition_height = 30; // Height of the conical transition section
small_tube_height = 10; // Height of the small tube extension

// Main funnel module
module funnel() {
    difference() {
        // Outer shape
        union() {
            // Top cylinder (large end)
            cylinder(h=height-transition_height, r=large_radius, $fn=100);
            
            // Transition cone
            translate([0, 0, height-transition_height])
                cylinder(h=transition_height, r1=large_radius, r2=small_radius, $fn=100);
            
            // Small tube extension
            translate([0, 0, height])
                cylinder(h=small_tube_height, r=small_radius, $fn=100);
        }
        
        // Inner cutout
        union() {
            // Top cylinder cutout
            translate([0, 0, thickness])
                cylinder(h=height-transition_height-thickness, r=large_radius-thickness, $fn=100);
            
            // Transition cone cutout
            translate([0, 0, height-transition_height])
                cylinder(h=transition_height, r1=large_radius-thickness, r2=small_radius-thickness, $fn=100);
            
            // Small tube cutout
            translate([0, 0, height])
                cylinder(h=small_tube_height, r=small_radius-thickness, $fn=100);
            
            // Bottom opening (if enabled)
            translate([0, 0, ])
                cylinder(h=thickness+1, r=large_radius-thickness, $fn=100);
        }
    }
}

// Render the funnel
funnel();
