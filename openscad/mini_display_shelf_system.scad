/*
Parametric Mini Display Shelf System (Simplified)
Author: Codex

Design goals:
- very simple geometry
- easy to print on home FDM printers
- fully parametric system for multiple scales

System parts:
1) shelf_panel : flat shelf with sockets
2) riser_post  : straight post between shelf levels
3) ground_leg  : straight leg from shelf level to table
4) level0_front_leg : leg that plugs into level-0 bottom sockets (front support)

All parts are box-based and support-free in default print orientation.
*/

// -----------------------------
// View / Modes
// -----------------------------

view_mode = "assembly";
// "assembly", "shelf_panel", "riser_post", "ground_leg", "level0_front_leg", "ground_legs_set", "all_parts"

preview_fast = true;
$fn = preview_fast ? 24 : 64;

part_print_orientation = true; // auto-orient single parts for support-free printing
explode = 0; // assembly-only spacing
eps = 0.01;

// Used by "ground_leg" mode to pick one leg length.
ground_leg_preview_level = 3;

// -----------------------------
// Main Parameters
// -----------------------------

scale_preset = "custom"; // "custom", "lego_minifig", "cars_1_64", "miniatures_32mm"
levels = 4; // >=2

// Used when scale_preset == "custom"
shelf_width_custom = 150;
shelf_depth_custom = 50;
run_pitch_custom = 35;   // horizontal step offset between levels
level_pitch_custom = 50; // vertical offset between levels

shelf_thickness = 3.0;

// Base Z offset for the first physical shelf.
// -1 means "auto": use level_pitch (virtual ground level 0, first shelf at level 1).
// Set to >=0 to force a custom offset.
level0_vertical_offset_override = -1;

// Socket layout
rear_socket_offset = 10; // distance from rear edge for top sockets
step_socket_side_inset = 10;
leg_socket_side_inset = 20;

// Connector fit
peg_x = 5.0;
peg_y = 5.0;
peg_tolerance = 0.15;
socket_clearance = 0.25;
top_socket_depth = 2.0;
bottom_socket_depth = 2.4;
sockets_through_panel = false; // if true, socket cuts go completely through shelf panels

// Straight riser post
riser_body_width = 5;
riser_body_depth = 5;

// Ground legs (to table)
add_ground_legs = true;
ground_legs_all_levels = true;   // true: one pair per upper level
ground_legs_include_level0 = false; // include base level too
ground_leg_setback = 0;          // 0 = vertical, >0 leans backwards
ground_leg_width = 5;
ground_leg_depth = 5;
ground_leg_foot_width = 20;
ground_leg_foot_depth = 20;
ground_leg_foot_height = 5;

// Extra front support on shelf index i=0.
add_level0_front_legs = true;

// -----------------------------
// Presets
// -----------------------------

function use_preset() = scale_preset != "custom";

function preset_width(p) =
    p == "lego_minifig" ? 200 :
    p == "cars_1_64" ? 220 :
    p == "miniatures_32mm" ? 190 :
    shelf_width_custom;

function preset_depth(p) =
    p == "lego_minifig" ? 72 :
    p == "cars_1_64" ? 78 :
    p == "miniatures_32mm" ? 80 :
    shelf_depth_custom;

function preset_run_pitch(p) =
    p == "lego_minifig" ? 38 :
    p == "cars_1_64" ? 42 :
    p == "miniatures_32mm" ? 40 :
    run_pitch_custom;

function preset_level_pitch(p) =
    p == "lego_minifig" ? 46 :
    p == "cars_1_64" ? 38 :
    p == "miniatures_32mm" ? 52 :
    level_pitch_custom;

shelf_width = use_preset() ? preset_width(scale_preset) : shelf_width_custom;
shelf_depth = use_preset() ? preset_depth(scale_preset) : shelf_depth_custom;
run_pitch = use_preset() ? preset_run_pitch(scale_preset) : run_pitch_custom;
level_pitch = use_preset() ? preset_level_pitch(scale_preset) : level_pitch_custom;
level0_vertical_offset =
    level0_vertical_offset_override >= 0 ? level0_vertical_offset_override : level_pitch;

// -----------------------------
// Derived Geometry
// -----------------------------

function x_step_sockets() = [-(shelf_width / 2 - step_socket_side_inset), (shelf_width / 2 - step_socket_side_inset)];
function x_leg_sockets() = [-(shelf_width / 2 - leg_socket_side_inset), (shelf_width / 2 - leg_socket_side_inset)];

step_socket_top_y = shelf_depth - rear_socket_offset;
step_socket_bottom_y = step_socket_top_y - run_pitch; // enables straight riser posts (dy=0)
leg_socket_top_y = step_socket_top_y;

socket_w = peg_x + socket_clearance;
socket_d = peg_y + socket_clearance;
peg_w = peg_x - peg_tolerance;
peg_d = peg_y - peg_tolerance;
top_socket_cut_depth = sockets_through_panel ? (shelf_thickness + 2 * eps) : top_socket_depth;
bottom_socket_cut_depth = sockets_through_panel ? (shelf_thickness + 2 * eps) : bottom_socket_depth;

riser_dz = level_pitch - shelf_thickness;

run_pitch_view = run_pitch + explode;
level_pitch_view = level_pitch + explode;
riser_dz_view = level_pitch_view - shelf_thickness;
level0_vertical_offset_view = level0_vertical_offset + explode;

leg_start_level = ground_legs_all_levels ? (ground_legs_include_level0 ? 0 : 1) : (levels - 1);
leg_levels_count = levels - leg_start_level;
min_leg_drop = level0_vertical_offset + leg_start_level * level_pitch + shelf_thickness;
preview_leg_level = max(0, min(ground_leg_preview_level, levels - 1));
preview_leg_drop = level0_vertical_offset + preview_leg_level * level_pitch + shelf_thickness;

// -----------------------------
// Sanity Checks
// -----------------------------

assert(levels >= 2, "levels must be >= 2");
assert(shelf_thickness > 1, "shelf_thickness must be > 1");
assert(top_socket_depth > 0 && top_socket_depth < shelf_thickness, "top_socket_depth must be inside shelf thickness");
assert(bottom_socket_depth > 0 && bottom_socket_depth < shelf_thickness, "bottom_socket_depth must be inside shelf thickness");
assert(step_socket_side_inset + socket_w / 2 < shelf_width / 2, "step_socket_side_inset is out of bounds");
assert(leg_socket_side_inset + socket_w / 2 < shelf_width / 2, "leg_socket_side_inset is out of bounds");
assert(leg_socket_side_inset > step_socket_side_inset + socket_w + 0.8,
    "Increase leg_socket_side_inset to separate leg sockets from riser sockets");
assert(step_socket_top_y > socket_d / 2 && step_socket_top_y < shelf_depth - socket_d / 2,
    "rear_socket_offset gives invalid top socket position");
assert(step_socket_bottom_y > socket_d / 2 && step_socket_bottom_y < shelf_depth - socket_d / 2,
    "run_pitch is too large for straight risers (bottom socket row out of shelf bounds)");
assert(level_pitch > shelf_thickness + 2, "level_pitch too small relative to shelf_thickness");
assert(riser_dz > max(top_socket_depth, bottom_socket_depth),
    "Increase level_pitch or reduce socket depths");
assert(level0_vertical_offset >= 0, "level0_vertical_offset must be >= 0");
assert(!add_ground_legs || leg_start_level < levels, "No levels selected for ground legs");
assert(!add_ground_legs || min_leg_drop > (ground_leg_foot_height + 2),
    "Leg drop too short for current leg settings");
assert(!add_level0_front_legs || level0_vertical_offset > (ground_leg_foot_height + 2),
    "Increase level0_vertical_offset or disable add_level0_front_legs");

// -----------------------------
// Bill of Materials (echo)
// -----------------------------

function riser_post_count() = 2 * (levels - 1);
function ground_leg_count() = add_ground_legs ? 2 * leg_levels_count : 0;
function level0_front_leg_count() = add_level0_front_legs ? 2 : 0;

echo(str("Preset: ", scale_preset));
echo(str("levels: ", levels));
echo(str("level0_vertical_offset: ", level0_vertical_offset));
echo(str("sockets_through_panel: ", sockets_through_panel));
echo(str("shelf_panel x", levels));
echo(str("riser_post x", riser_post_count()));
echo(str("ground_leg x", ground_leg_count()));
echo(str("level0_front_leg x", level0_front_leg_count()));
echo(str("leg levels: ", leg_start_level, " to ", levels - 1));

// -----------------------------
// Primitives
// -----------------------------

module peg_up(len) {
    translate([0, 0, len / 2]) cube([peg_w, peg_d, len], center = true);
}

module peg_down(len) {
    translate([0, 0, -len / 2]) cube([peg_w, peg_d, len], center = true);
}

module socket_cut(depth) {
    cube([socket_w, socket_d, depth + eps], center = true);
}

// -----------------------------
// Parts
// -----------------------------

module shelf_panel() {
    difference() {
        translate([-shelf_width / 2, 0, 0]) cube([shelf_width, shelf_depth, shelf_thickness]);

        // Top sockets for risers to the next level
        for (x = x_step_sockets()) {
            translate([x, step_socket_top_y, shelf_thickness - top_socket_cut_depth / 2]) socket_cut(top_socket_cut_depth);
        }

        // Bottom sockets for risers from the previous level
        for (x = x_step_sockets()) {
            translate([x, step_socket_bottom_y, bottom_socket_cut_depth / 2]) socket_cut(bottom_socket_cut_depth);
        }

        // Dedicated top sockets for ground legs
        for (x = x_leg_sockets()) {
            translate([x, leg_socket_top_y, shelf_thickness - top_socket_cut_depth / 2]) socket_cut(top_socket_cut_depth);
        }
    }
}

module riser_post(dz = riser_dz) {
    union() {
        // Lower peg goes into top socket of lower shelf
        peg_down(top_socket_depth - 0.15);

        // Upper peg goes into bottom socket of upper shelf
        translate([0, 0, dz]) peg_up(bottom_socket_depth - 0.15);

        // Straight body
        translate([0, 0, dz / 2]) cube([riser_body_width, riser_body_depth, dz], center = true);
    }
}

module ground_leg(drop = preview_leg_drop) {
    union() {
        // Peg goes into a top leg socket
        peg_down(top_socket_depth - 0.15);

        // Straight stem
        translate([0, ground_leg_setback, -drop / 2]) cube([ground_leg_width, ground_leg_depth, drop], center = true);

        // Table foot
        translate([0, ground_leg_setback, -drop - ground_leg_foot_height / 2])
            cube([ground_leg_foot_width, ground_leg_foot_depth, ground_leg_foot_height], center = true);
    }
}

module level0_front_leg(drop = level0_vertical_offset) {
    union() {
        // Peg goes into a bottom socket of shelf i=0
        peg_up(bottom_socket_depth - 0.15);

        // Straight stem
        translate([0, 0, -drop / 2]) cube([ground_leg_width, ground_leg_depth, drop], center = true);

        // Table foot
        translate([0, 0, -drop - ground_leg_foot_height / 2])
            cube([ground_leg_foot_width, ground_leg_foot_depth, ground_leg_foot_height], center = true);
    }
}

// -----------------------------
// Print-Oriented Helpers
// -----------------------------

module riser_post_print() {
    translate([0, 0, riser_body_width / 2]) rotate([0, 90, 0]) riser_post();
}

module ground_leg_print(drop = preview_leg_drop) {
    // Lift so the foot sits on Z=0.
    translate([0, 0, drop + ground_leg_foot_height]) ground_leg(drop = drop);
}

module level0_front_leg_print(drop = level0_vertical_offset) {
    // Lift so the foot sits on Z=0.
    translate([0, 0, drop + ground_leg_foot_height]) level0_front_leg(drop = drop);
}

module ground_legs_set_layout() {
    // One leg for each required level, laid out left-to-right.
    for (i = [leg_start_level : levels - 1]) {
        leg_drop_i = level0_vertical_offset + i * level_pitch + shelf_thickness;
        translate([(i - leg_start_level) * 35, 0, 0]) {
            if (part_print_orientation) {
                ground_leg_print(drop = leg_drop_i);
            } else {
                translate([0, 0, leg_drop_i]) ground_leg(drop = leg_drop_i);
            }
        }
    }
}

// -----------------------------
// Assembly
// -----------------------------

module assembly() {
    // Shelves
    for (i = [0 : levels - 1]) {
        shelf_z_i = level0_vertical_offset_view + i * level_pitch_view;
        color([0.52, 0.34, 0.18])
            translate([0, i * run_pitch_view, shelf_z_i])
                shelf_panel();
    }

    // Riser posts between levels (straight connectors)
    for (i = [0 : levels - 2]) {
        lower_shelf_top_z_i = level0_vertical_offset_view + i * level_pitch_view + shelf_thickness;
        for (x = x_step_sockets()) {
            color([0.10, 0.10, 0.10])
                translate([x, i * run_pitch_view + step_socket_top_y, lower_shelf_top_z_i])
                    riser_post(dz = riser_dz_view);
        }
    }

    // Ground legs for selected levels
    if (add_ground_legs) {
        for (i = [leg_start_level : levels - 1]) {
            leg_drop_i = level0_vertical_offset_view + i * level_pitch_view + shelf_thickness;
            for (x = x_leg_sockets()) {
                color([0.10, 0.10, 0.10])
                    translate([x, i * run_pitch_view + leg_socket_top_y, leg_drop_i])
                        ground_leg(drop = leg_drop_i);
            }
        }
    }

    // Front legs on shelf i=0 (plug into bottom sockets).
    if (add_level0_front_legs) {
        for (x = x_step_sockets()) {
            color([0.10, 0.10, 0.10])
                translate([x, step_socket_bottom_y, level0_vertical_offset_view])
                    level0_front_leg(drop = level0_vertical_offset_view);
        }
    }
}

module all_parts_layout() {
    translate([0, 0, 0]) shelf_panel();

    if (part_print_orientation) {
        translate([0, shelf_depth + 30, 0]) riser_post_print();
        translate([45, shelf_depth + 30, 0]) ground_leg_print();
        translate([90, shelf_depth + 30, 0]) level0_front_leg_print();
    } else {
        translate([0, shelf_depth + 30, 0]) riser_post();
        translate([45, shelf_depth + 30, preview_leg_drop]) ground_leg();
        translate([90, shelf_depth + 30, level0_vertical_offset]) level0_front_leg();
    }
}

// -----------------------------
// Mode Switch
// -----------------------------

if (view_mode == "assembly") {
    assembly();
} else if (view_mode == "shelf_panel") {
    shelf_panel();
} else if (view_mode == "riser_post") {
    if (part_print_orientation) riser_post_print(); else riser_post();
} else if (view_mode == "ground_leg") {
    if (part_print_orientation) ground_leg_print(); else translate([0, 0, preview_leg_drop]) ground_leg();
} else if (view_mode == "level0_front_leg") {
    if (part_print_orientation) level0_front_leg_print(); else translate([0, 0, level0_vertical_offset]) level0_front_leg();
} else if (view_mode == "ground_legs_set") {
    ground_legs_set_layout();
} else if (view_mode == "all_parts") {
    all_parts_layout();
} else {
    echo("Unknown view_mode, falling back to assembly");
    assembly();
}
