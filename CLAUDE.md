# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

`desktop-bud` is a Godot 4.7 (GL Compatibility renderer) desktop pet application. The game window is
configured (in `project.godot` under `[display]`) to be transparent, always-on-top, non-focusable, and
non-resizable/minimizable, so the running app appears as a borderless sprite sitting on the user's desktop
rather than a normal windowed game. Per-pixel window transparency is enabled, and the actual click-through
region is computed at runtime (see Architecture) so only the character sprite itself is clickable/draggable —
everywhere else on screen, clicks pass through to whatever is behind the window.

## Commands

This is a Godot Editor project, not a CLI-driven build. There is no package manager, linter, or test suite.

- Open/run: open `project.godot` in the Godot 4.7 editor, or run headlessly via
  `godot --path .` (requires the Godot 4.7 executable on PATH).
- The main scene is `Scenes/global.tscn` (referenced by `run/main_scene` in `project.godot`).

## Architecture

Scene tree, root to leaf: `Scenes/global.tscn` (`Global Manager`, script `Scenes/global.gd`) →
`Scenes/Player/player.tscn` instanced as `Player` (`Node2D`, script `player.gd`) → `PhysicsBody`
(`CharacterBody2D`, script `physics_body.gd`) with children `Animation` (`AnimatedSprite2D`, script
`animator.gd`), `Hitbox` (`CollisionShape2D`, script `hitbox.gd`), and `Clickable Area` (`Polygon2D`,
script `clickable_area.gd`).

- **`Scenes/global.gd`** (root `Global Manager`, `Node2D`, `class_name GlobalManager`) wires up two
  static-instance manager nodes on `_ready` and adds them as children: `viewport_manager_instance`
  (`ViewportManager`, built from the player's `clickable_area`) and `task_manager_intsance`
  (`PlayerTaskManager`, built from the `player`). Each frame, once the player's state is
  `WAITING_FOR_NEW_TASK`, it asks the task manager for a new random task
  (`task_manager_intsance.give_random_task_to_player()`).
- **`Scenes/viewport_manager.gd`** (`ViewportManager`, `Node2D`) owns the click-through behavior: each
  frame, for every `ClickableArea` it was constructed with, it calls
  `DisplayServer.window_set_mouse_passthrough(area.get_polygons_in_screen_transform())` so mouse input
  only hits the window inside those polygons — everywhere else is click-through to the desktop/apps
  behind it. Also exposes `screen_size` (`@onready` from `get_viewport_rect().size`), read by
  `PlayerTaskManager` to pick random on-screen targets.
- **`Scenes/Player/clickable_area.gd`** (`ClickableArea`, `Polygon2D`) computes its own polygon in
  screen space via `get_viewport().get_screen_transform()` — this is what `ViewportManager` reads.
  `adapt_to_shape()` is an unfinished stub (`#TODO`) meant to derive the polygon from a `Shape2D`.
- **`player.gd`** (`Player`, `Node2D`, `class_name Player`) is the behavior driver: a state machine
  (`State` enum: `WALKING, WAITING_FOR_NEW_TASK, SITTING, WAITING, TALKING`) that each `_process` frame
  delegates to `body` (`PhysicsBody`) for movement and `animator` (`AnimatedPlayerSprite`) for
  animation/timers. Public entry points called from outside (currently by `PlayerTaskManager` via
  signals): `go_to_target(pos)`, `wait(seconds)`, `say_something(message, seconds)`,
  `get_current_state()`. `SITTING` exists in the enum but has no handling in the `_process` `match` yet.
- **`Scenes/Player/physics_body.gd`** (`PhysicsBody`, `CharacterBody2D`) is pure movement math, called
  by `Player`: `move_towards_target(target, speed)` (sets velocity, calls `move_and_slide()`),
  `has_reached_target(target, target_offset)`, `calculate_direction_to_target(target)`. No knowledge of
  animation or tasks.
- **`Scenes/Player/animator.gd`** (`AnimatedPlayerSprite`, `AnimatedSprite2D`, `class_name
  AnimatedPlayerSprite`) derives which of 8 walk/idle animations to play from a direction vector
  (`animate_walking(direction_to_target)`, via `Util.translate_direction_to_char`), plus
  `animate_idle`/`animate_talking`/`animate_waiting` and self-contained one-shot `Timer`-based
  `wait_x_seconds`/`say_something` (`timer_ellapsed()` polled by `Player`). Speech bubble UI is a
  `#TODO`.
- **`Scenes/Util/util.gd`** (`Util`, no base type, static-only) holds the shared `Direction` enum
  (`NORTH, EAST, SOUTH, WEST`) and `translate_direction_to_char()`, used by `animator.gd`.
- **`Scenes/Tasks/task.gd`** (`PlayerTaskManager`, `Node`) is the placeholder task source: on `_init`
  it connects three signals (`goto`, `wait`, `speak`) directly to the matching `Player` methods, then
  `give_random_task_to_player()` picks one at random each time it's called (random point via
  `ViewportManager.screen_size`, fixed 3-second `wait`/`speak`). This is the extension point for real
  task logic later — `Scenes/Tasks/Task.tscn` exists alongside it but is not yet wired into the scene
  tree.
- **`Scenes/Player/hitbox.gd`** (`Hitbox`, `CollisionShape2D`) is now just a `class_name` tag with no
  logic — the click-through polygon computation that used to live here moved to `clickable_area.gd`.
- **`Scenes/Player/player.tscn`** defines the `SpriteFrames` resource: two spritesheets sliced into
  16x24 `AtlasTexture` regions (6 frames per direction) — `Adam/Adam_idle_anim_16x16.png` →
  `idle_n/e/s/w`, `Adam/Adam_run_16x16.png` → `walk_n/e/s/w`.
- Art assets live under `Adam/` (character spritesheets: idle, run, phone, sit variants) and `Interior/`
  (tileset spritesheet `Interiors_free_16x16.png`), each with a Godot-generated `.import` sidecar — these
  sidecars are regenerated by the editor and shouldn't be hand-edited.
- Physics is configured for Jolt Physics (`[physics] 3d/physics_engine="Jolt Physics"`) even though gameplay
  is 2D (`CharacterBody2D`-based).

## Notes

- `links.md` is a personal scratch list of resources; it currently notes [Velopack](https://velopack.io/) as
  the planned approach for shipping auto-updates from GitHub releases.
