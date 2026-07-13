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
  - Selected enemy health: `150.0`
  - Selected enemy speed: `30.0`
  - Selected enemy weapon damage: `9.0`

## Finding

Runtime audit found `get_runtime_summary()` did not expose `produced_total`, even though the playable HUD and factory loop already tracked it. This blocked reliable MCP proof that factory output advanced over time.

Root cause:

- `produced_total` was incremented in `simulate_factory()`.
- HUD displayed `produced_total`.
- `get_runtime_summary()` omitted the key.

Fix:

- Added RED test that checks `produced_total` inside the `get_runtime_summary()` body.
- Added `"produced_total": produced_total` to `get_runtime_summary()`.

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

## Verification

- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_runtime_summary_for_mcp`
  - Result: failed as expected with missing `"produced_total": produced_total` inside `get_runtime_summary()`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_runtime_summary_for_mcp`
  - Result: `1 passed, 1544 deselected`.
- SSOT validator:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full Python suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 380.99s (0:06:20)`.

## Remaining Gates

- [x] Source slice ledger complete: `1073/1073`.
- [x] Godot project starts through MCP runtime.
- [x] Generated scripts load and instantiate without failures.
- [x] Content registry loads with source-backed counts.
- [x] World initializes with terrain, blocks, core, drill, conveyors, turret, and enemies.
- [x] Factory loop advances: `produced_total` and `core_inventory` increase.
- [x] Enemy loop advances: enemies move/waves progress/core takes damage.
- [ ] Live turret ammo loop not yet proven in audit: `selected_turret_total_ammo=0`, `turret_shot_count` did not increase, `bullet_count` did not increase.
- [ ] Full playable completion not claimed until live turret ammo/fire path is proven or fixed.

## Progress

- Source-slice migration: `100.00%`
- Playable audit: partially proven.
- Current blocker for completion claim: live turret ammo/fire loop proof missing.
