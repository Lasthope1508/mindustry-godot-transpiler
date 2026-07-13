# Playable Integration Audit Runtime Summary

## Scope

- Goal stage: post source-slice ledger completion.
- Godot project: `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`
- Main scene: `res://scenes/Main.tscn`
- Main runtime owner: `PortGame`
- Runtime proof path: `/root/Main.get_runtime_summary`

## Current Evidence

- Source slice ledger:
  - Total tracked slices: `1073`
  - Done: `1073`
  - Not done: `0`
  - Progress: `100.00%`
- Godot project inventory from MCP:
  - Name: `Mindustry Godot Port`
  - Godot version: `4.6.2.stable.official.71f334935`
  - Scenes: `1`
  - Scripts: `831`
  - Assets: `2552`
- Main scene from `scenes/Main.tscn`:
  - Root: `Main` `Node2D`
  - Script: `res://src/game/PortGame.gd`
  - Gameplay layers: `TerrainLayer`, `BlockLayer`, `UnitLayer`, `BulletLayer`
  - Runtime nodes: `GeneratedContent`, `SkinLayer`
  - UI node: `UI/Hud`
- Runtime summary after MCP run:
  - Generated class count: `801`
  - Loaded generated scripts: `801`
  - Instanced generated scripts: `801`
  - Load failures: `[]`
  - Instance failures: `[]`
  - Content counts: `22` items, `11` liquids, `417` blocks, `56` units
  - Build palette size: `416`
  - Initial world blocks: `12`
  - Initial occupied cells: `22`
  - Conveyor world speed: `52.8`
  - Conveyor path progress rate: `0.183333333333333`
  - Drill ore cells: `2`
  - Drill output rate: `0.184615384615385`
  - Core health max: `1100.0`
  - Core damage taken total: `54.0`
  - Core health after damage proof: `1046.0`
  - Selected enemy health: `150.0`
  - Selected enemy speed: `30.0`
  - Selected enemy weapon damage: `9.0`
  - Bootstrapped selected turret ammo load count: `15`
  - Turret shot count: `30`
  - Last turret fired ammo item: `copper`
  - Last turret fired damage: `9.0`

## Finding

Runtime audit first found `get_runtime_summary()` did not expose `produced_total`, even though the playable HUD and factory loop already tracked it. That gap is fixed.

Second audit found live turret ammo started empty even though `duo` was placed in `build_world()`. Java `ItemTurret` only fires after `hasAmmo()`/`peekAmmo()` succeed, so the playable runtime needed a source-backed bootstrap. That gap is fixed too.

Third audit found core damage was asserted in the checklist but not explicitly tracked as a runtime proof counter. The playable enemy loop already subtracted `source_unit_weapon_damage(unit_type)` from `core_health`; runtime summary now exposes `core_damage_taken_total` so MCP can prove damage application directly.

Fourth audit found player placement cost was still only implied by shared occupancy and inventory state. The playable placement path already called `can_afford(block)` and `spend_requirements(block)` from source-backed `block.properties.requirements`; runtime summary now exposes `player_placed_block_count` and `last_placed_block_requirements` so MCP can prove the player placement loop directly.

Root cause:

- `produced_total` was incremented in `simulate_factory()`.
- HUD displayed `produced_total`.
- `get_runtime_summary()` omitted the key.

Fix:

- Added RED test that checks `produced_total` inside the `get_runtime_summary()` body.
- Added `"produced_total": produced_total` to `get_runtime_summary()`.
- Added RED test that checks `build_world()` bootstraps `duo` ammo from source ammo metadata and exposes the bootstrap load count in runtime summary.
- Added `bootstrap_selected_turret_ammo()` and `bootstrapped_selected_turret_ammo_load_count` to seed turret ammo from first source ammo entry without hardcoding item ids.
- Added RED test that requires `core_damage_taken_total` and an explicitly typed `core_damage: float` derived from `source_unit_weapon_damage(unit_type)`.
- Added `"core_damage_taken_total": core_damage_taken_total` to `get_runtime_summary()`.
- Added RED test that requires `player_placed_block_count` and `last_placed_block_requirements` to be exposed in runtime summary.
- Added `player_placed_block_count` and `last_placed_block_requirements` to `PortGame.gd` so placement telemetry tracks player-built blocks and source-backed costs separately from initial world blocks.

## Runtime Proof

Godot MCP runtime on TCP port `7777`:

- Runtime status: `runtimeAddon=connected`
- TCP `/root/Main.get_runtime_summary` initial:
  - `generated_class_count=801`
  - `all_generated_script_count=801`
  - `all_generated_instance_count=801`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
  - `core_inventory=5`
  - `produced_total=5`
  - `enemy_count=2`
  - `wave_index=4`
- TCP after `3s`:
  - `core_inventory=6`
  - `produced_total=6`
  - `enemy_count=0`
  - `wave_index=4`
- TCP after `10s`:
  - `core_inventory=7`
  - `produced_total=7`
  - `enemy_count=1`
  - `wave_index=5`
- Deltas over proof window:
  - `produced_total +2`
  - `core_inventory +2`
  - `enemy_count -1`
  - `turret_shot_count +0`
  - `bullet_count +0`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP turret proof on the restarted runtime:

- TCP `/root/Main.get_runtime_summary` initial:
  - `bootstrapped_selected_turret_ammo_load_count=15`
  - `selected_turret_total_ammo=0` after full firing cycle
  - `selected_turret_loaded_ammo_item=""`
  - `turret_shot_count=30`
  - `last_turret_fired_ammo_item="copper"`
  - `last_turret_fired_damage=9.0`
  - `last_turret_fired_range=160.0`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP core damage proof on the restarted runtime:

- Drained selected turret ammo through `/root/Main.use_selected_turret_ammo_once`.
- TCP `/root/Main.get_runtime_summary`:
  - Start: `core_damage_taken_total=36.0`, `core_health=1064.0`
  - Post drain: `core_damage_taken_total=45.0`, `core_health=1055.0`
  - End: `core_damage_taken_total=54.0`, `core_health=1046.0`
  - Delta: `core_damage_taken_total +9.0`, `core_health -9.0`
  - `selected_enemy_weapon_damage=9.0`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP placement-cost proof on the restarted runtime:

- TCP `/root/Main.get_runtime_summary` before placement:
  - `player_placed_block_count=0`
  - `core_items.copper=25`
- Selected `conveyor` through `/root/Main.select_build_block_by_id`.
- Placed block through `/root/Main.place_selected_block_at_cell(2, 2)`.
- TCP `/root/Main.get_runtime_summary` after placement:
  - `player_placed_block_count=1`
  - `last_placed_block_id="conveyor"`
  - `last_placed_block_requirements=[{"item":"copper","amount":1}]`
  - `core_items.copper=24`
  - `last_place_blocked=false`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

## Verification

- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_runtime_summary_for_mcp`
  - Result: failed as expected with missing `"produced_total": produced_total` inside `get_runtime_summary()`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_player_placement_cost_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `player_placed_block_count` and `last_placed_block_requirements`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_runtime_summary_for_mcp`
  - Result: `1 passed, 1544 deselected`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_player_placement_cost_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- SSOT validator:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full Python suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4019 passed, 39290 subtests passed in 383.72s (0:06:23)`.

## Remaining Gates

- [x] Source slice ledger complete: `1073/1073`.
- [x] Godot project starts through MCP runtime.
- [x] Generated scripts load and instantiate without failures.
- [x] Content registry loads with source-backed counts.
- [x] World initializes with terrain, blocks, core, drill, conveyors, turret, and enemies.
- [x] Factory loop advances: `produced_total` and `core_inventory` increase.
- [x] Enemy loop advances: enemies move/waves progress/core takes damage: `core_damage_taken_total +9.0`, `core_health -9.0`.
- [x] Live turret ammo loop proven: `bootstrapped_selected_turret_ammo_load_count=15`, `turret_shot_count=30`, `last_turret_fired_ammo_item="copper"`.
- [x] Player placement cost loop proven: `player_placed_block_count=1`, `last_placed_block_requirements=[{"item":"copper","amount":1}]`, `core_items.copper 25 -> 24`.
- [ ] Full playable completion not claimed until broader playthrough audit closes remaining gameplay surfaces.

## Progress

- Source-slice migration: `100.00%`
- Playable audit: broader runtime still under audit, but turret ammo/fire and placement-cost paths now proven.
- Current blocker for completion claim: broader playthrough coverage, not placement-cost or turret ammo/fire.
