// -------------------------
// Parameters
// -------------------------

n = 10;            // Number of subintervals
a = 0;             // Starting z-coordinate
b = 0.75;          // Ending z-coordinate
sample_type = "mid"; // Sampling method: "left", "mid", or "right"
show_solid = false;  // true = render full solid surface; false = stacked disks/washers
printedheight = 30;  // Desired printed height in millimeters

// Scaling factor to match printed height
scalefactor = printedheight / (b - a);

// -------------------------
// Functions defining the solid
// -------------------------

// Outer function: defines outer radius as a function of z
function f(z) = sqrt(z) + 1;

// Inner function: defines inner radius as a function of z
// Set g(z) = 0 to automatically switch to disk method (no hole)
function g(z) = 1 - z;

// -------------------------
// Model resolution
// -------------------------

$fn = 200; // Number of facets to approximate circles

// -------------------------
// Modules
// -------------------------

// Washer Module: creates a washer at a given z position
module washer(z_bottom, r_outer, r_inner, thickness) {
    translate([0, 0, z_bottom * scalefactor])
        difference() {
            cylinder(h = thickness * scalefactor, r = r_outer * scalefactor, center = false);
            translate([0, 0, -0.1 * scalefactor])
                cylinder(h = (thickness + 0.2) * scalefactor, r = r_inner * scalefactor, center = false);
        }
}

// Solid Surface Module: creates a full continuous solid of revolution
module solid_surface() {
    rotate_extrude() {
        polygon(points = [
            for (z = [a : (b - a) / 100 : b])
                [f(z) * scalefactor, z * scalefactor],
            for (z = [b : -(b - a) / 100 : a])
                [g(z) * scalefactor, z * scalefactor]
        ]);
    }
}

// Sample point selection based on sampling method
function sample_z(i, interval, a) =
    (sample_type == "left") ? (a + i * interval) :
    (sample_type == "right") ? (a + (i + 1) * interval) :
    (a + (i + 0.5) * interval); // Default to midpoint

// -------------------------
// Main Logic
// -------------------------

interval = (b - a) / n;

if (show_solid) {
    solid_surface();
} else {
    for (i = [0 : n-1]) {
        z_start = a + i * interval;
        z_sample = sample_z(i, interval, a);
        r_outer = f(z_sample);
        r_inner = g(z_sample);

        // If g(z) = 0, use a solid disk
        if (r_inner == 0) {
            washer(z_bottom = z_start, r_outer = r_outer, r_inner = 0, thickness = interval);
        } 
        // Otherwise, create a washer
        else if (r_outer > r_inner) {
            washer(z_bottom = z_start, r_outer = r_outer, r_inner = r_inner, thickness = interval);
        }
    }
}
