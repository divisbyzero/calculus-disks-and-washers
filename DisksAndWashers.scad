// Parameters
n = 10; // number of subintervals
a = 0; // starting z
b = 0.75; // ending z
sample_type = "mid"; // "left", "mid", or "right"
show_solid = false; // set to true to show full solid surface of revolution
printedheight = 30; // desired printed height in mm

// Scaling factor
scalefactor = printedheight / (b - a);

// Outer Function x = f(z)
function f(z) = sqrt(z) + 1;

// Inner Function x = g(z)
// Set g(z) = 0 to automatically switch to disk method
function g(z) = 1-z;

// Disk resolution for smoothness
$fn = 200;

// Washer Module (aligned along z-axis)
module washer(z_bottom, r_outer, r_inner, thickness) {
    translate([0, 0, z_bottom * scalefactor])
        difference() {
            cylinder(h = thickness * scalefactor, r = r_outer * scalefactor, center = false);
            translate([0, 0, -0.1 * scalefactor])
                cylinder(h = (thickness + 0.2) * scalefactor, r = r_inner * scalefactor, center = false);
        }
}

// Solid of Revolution Module (full continuous surface)
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

// Sample Point Selection
function sample_z(i, interval, a) =
    (sample_type == "left") ? (a + i * interval) :
    (sample_type == "right") ? (a + (i + 1) * interval) :
    (a + (i + 0.5) * interval); // default to midpoint

// Main
interval = (b - a) / n;

if (show_solid) {
    solid_surface();
} else {
    for (i = [0 : n-1]) {
        z_start = a + i * interval;
        z_sample = sample_z(i, interval, a);
        r_outer = f(z_sample);
        r_inner = g(z_sample);

        // Automatically switch to disk if g(z) = 0
        if (r_inner == 0) {
            washer(z_bottom = z_start, r_outer = r_outer, r_inner = 0, thickness = interval);
        } else if (r_outer > r_inner) {
            washer(z_bottom = z_start, r_outer = r_outer, r_inner = r_inner, thickness = interval);
        }
    }
}
