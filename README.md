# Parametric Mini Display Shelf System (OpenSCAD)

This project is a simplified, print-first, fully parametric stepped display system for:

- miniatures
- LEGO minifigs
- 1:64 cars

Main file: `openscad/mini_display_shelf_system.scad`

## Design Approach

The geometry is intentionally simple:

1. `shelf_panel` (flat plate with sockets)
2. `riser_post` (straight connector between levels)
3. `ground_leg` (straight leg from shelf level to table)
4. `level0_front_leg` (front support leg for shelf index `i=0`)

No angled or decorative support shapes are required.

## Why This Is Easy to Print

- Shelf panels are flat.
- Posts and legs are straight box-based parts.
- `part_print_orientation = true` auto-orients parts for support-free export in single-part modes.

## Quick Start

1. Open `openscad/mini_display_shelf_system.scad`.
2. Set `view_mode = "assembly"` for full preview.
3. Pick `scale_preset`:
   - `"lego_minifig"`
   - `"cars_1_64"`
   - `"miniatures_32mm"`
   - `"custom"`
4. Tune `levels`, `run_pitch_custom`, `level_pitch_custom`, and shelf size.
5. Export parts by switching `view_mode`:
   - `"shelf_panel"`
   - `"riser_post"`
   - `"ground_leg"`
   - `"level0_front_leg"`
   - `"ground_legs_set"` (one leg length for each required level)
   - `"all_parts"` (one of each part, non-overlapping, print-oriented)
   - `"required_parts"` (full quantity layout for current parameters)

## Core Parameters

- `levels`: number of tiers.
- `shelf_width_custom`, `shelf_depth_custom`: shelf size.
- `run_pitch_custom`: horizontal offset per level.
- `level_pitch_custom`: vertical offset per level.
- `shelf_thickness`: shelf plate thickness.
- `level0_vertical_offset_override`: first shelf Z offset.
  - `-1` (default): auto = `level_pitch` (virtual ground level 0)
  - `>= 0`: force exact first-shelf offset
  - `0`: restores the old behavior (first shelf starts on ground)
- `step_socket_side_inset`: side position of inter-level riser sockets.
- `leg_socket_side_inset`: side position of ground-leg sockets.
- `rear_socket_offset`: rear row position.
- `add_ground_legs`: enable/disable ground legs.
- `ground_legs_all_levels`: one leg pair for each upper level.
- `ground_legs_include_level0`: include bottom level legs too.
- `ground_leg_setback`: leg horizontal shift (0 = straight).
- `add_level0_front_legs`: adds a pair of front legs on shelf index `i=0`.
- `sockets_through_panel`: if `true`, socket cuts are through-holes (full panel thickness).
- `part_print_orientation`: print-oriented single-part previews.

## Important Constraint

Straight risers require this to be valid:

- `step_socket_bottom_y = (shelf_depth - rear_socket_offset) - run_pitch`

The script asserts if this row goes outside the shelf. If it fails:

1. reduce `run_pitch_custom`, or
2. increase `shelf_depth_custom`, or
3. reduce `rear_socket_offset`.

Level indexing behavior with default offset:

- Ground is virtual `level 0` (no shelf printed there).
- First printed shelf (array index `i=0`) starts at `Z = level_pitch`.
- Next shelves keep the same `level_pitch` separation.

## Assembly Workflow

1. Print `shelf_panel x levels`.
2. Print `riser_post x (2 * (levels - 1))`.
3. Print ground legs:
   - easiest: use `view_mode = "ground_legs_set"` and export each leg size
   - quantity from BOM `echo()` in OpenSCAD console
4. Print `level0_front_leg x2` if `add_level0_front_legs = true`.
5. Build staircase by connecting each shelf with two `riser_post` parts.
6. Add `ground_leg` parts at enabled levels for self-standing rigidity.
7. Add the `level0_front_leg` pair into the front bottom sockets of shelf `i=0`.

If you prefer to export everything in one shot, use:

- `view_mode = "required_parts"` to generate the full quantity layout.

## Notes

- If connectors are tight:
  - increase `socket_clearance`, or
  - increase `peg_tolerance`.
- For heavier models:
  - increase `shelf_thickness`,
  - increase `riser_body_width` / `riser_body_depth`,
  - increase `ground_leg_width` / `ground_leg_depth`.
