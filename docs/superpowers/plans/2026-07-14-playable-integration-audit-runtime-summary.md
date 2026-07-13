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

Fifth audit found the MendProjector heal loop had source-backed formulas and static tests, but no MCP proof that a placed projector repairs a damaged block in runtime. Runtime summary now exposes the healed target health and max health so MCP can prove the heal side effect directly.

Sixth audit found bullet hit damage was source-backed and turret fire was proven, but runtime still lacked MCP-visible hit telemetry. Runtime summary now exposes bullet hit count and target health before/after so MCP can prove bullet damage directly.

Seventh audit found overdrive projector boost application was source-backed, but runtime still lacked MCP-visible target boost telemetry. Runtime summary now exposes boosted target time scale and duration so MCP can prove boost side effect directly.

Eighth audit found wave spawning was source-backed, but runtime still lacked MCP-visible spawn telemetry. Runtime summary now exposes last spawned wave index, count, and group proof list so MCP can prove wave spawn formula directly.

Ninth audit found PowerGraph producer/consumer math was source-backed and individually exposed, but runtime still lacked one MCP-friendly proof package for a live producer and consumer pair. Runtime summary now exposes `placed_power_runtime` so MCP can prove role counts and power balance values directly.

Tenth audit found PowerGraph battery storage math was source-backed and individually exposed, but runtime still lacked one MCP-friendly proof package for live placed battery charge and discharge. Runtime summary now exposes `placed_power_battery_runtime` so MCP can prove source-backed `chargeBatteries` and `useBatteries` behavior directly.

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
- Added RED test that requires the MendProjector runtime proof to expose target health after healing and target max health.
- Added `last_mend_projector_target_health` and `last_mend_projector_target_max_health` to `PortGame.gd` and runtime summary.
- Added RED test that requires bullet hit runtime proof to expose hit count, hit damage, and target health before/after.
- Added `bullet_hit_count`, `last_bullet_hit_damage`, `last_bullet_target_health_before`, `last_bullet_target_health_after`, and `last_bullet_target_destroyed` to `PortGame.gd` and runtime summary.
- Added RED test that requires overdrive projector runtime proof to expose boosted target time scale and duration.
- Added `last_overdrive_projector_boosted_time_scale` and `last_overdrive_projector_boosted_time_scale_duration` to `PortGame.gd`, `step_overdrive_projectors()`, and runtime summary.
- Added RED test that requires wave spawn runtime proof to expose last spawned wave index, count, and group proof list.
- Added `last_spawned_wave_index`, `last_spawned_wave_count`, and `last_spawned_wave_groups` to `PortGame.gd`, `spawn_enemy_wave()`, and runtime summary.
- Added RED test that requires a PowerGraph runtime proof wrapper.
- Added `placed_power_runtime_state()` and `"placed_power_runtime": placed_power_runtime_state()` to runtime summary. The wrapper only packages source-backed `placed_power_graph_role_counts()`, `placed_power_needed_state()`, `placed_power_produced_state()`, and `placed_power_battery_state()`.
- Added RED test that requires a PowerGraph battery runtime proof wrapper.
- Added `placed_power_battery_runtime_state()` and `"placed_power_battery_runtime": placed_power_battery_runtime_state()` to runtime summary. The wrapper only packages source-backed `source_power_graph_charge_batteries_state()` and `source_power_graph_use_batteries_state()` over placed battery blocks.

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

Fresh MCP MendProjector heal proof on the restarted runtime:

- Seeded core inventory for `mender` requirements through `/root/Main.set_core_item_count`.
- Selected `mender` through `/root/Main.select_build_block_by_id`.
- Placed `mender` through `/root/Main.place_selected_block_at_cell(8, 7)`.
- Damaged conveyor target through `/root/Main.damage_block_at_cell(8, 8, 20.0)`.
- Stepped heal loop through `/root/Main.step_mend_projectors(5.0)`.
- TCP proof:
  - `target_health_max=45.0`
  - `before_health=25.0`
  - `after_health=26.8`
  - `last_mend_projector_healed_amount=1.8`
  - `last_mend_projector_healed_block_id="conveyor"`
  - `last_mend_projector_healed_cell={"x":8,"y":8}`
  - `last_mend_projector_target_health=26.8`
  - `last_mend_projector_target_max_health=45.0`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP bullet-hit proof on the restarted runtime:

- Topped up selected turret ammo through `/root/Main.load_selected_turret_ammo("copper", 15)`.
- Waited for live turret fire in runtime.
- TCP proof:
  - `start_bullet_hit_count=9`
  - `bullet_hit_count=10`
  - `last_bullet_hit_damage=9.0`
  - `last_bullet_target_health_before=150.0`
  - `last_bullet_target_health_after=141.0`
  - `last_bullet_target_destroyed=false`
  - `last_turret_fired_ammo_item="copper"`
  - `selected_turret_ammo_damage=9.0`
  - `turret_shot_count=33`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP overdrive boost proof on the restarted runtime:

- Seeded `lead`, `titanium`, `silicon`, and `plastanium` through `/root/Main.set_core_item_count`.
- Selected `overdrive-projector` through `/root/Main.select_build_block_by_id`.
- Placed `overdrive-projector` through `/root/Main.place_selected_block_at_cell(5, 9)`.
- Stepped boost loop through `/root/Main.step_overdrive_projectors(2.0)`.
- TCP proof:
  - `step_last_overdrive_projector_boost=1.5`
  - `step_last_overdrive_projector_boost_duration=61.0`
  - `step_last_overdrive_projector_boosted_block_id="mechanical-drill"`
  - `step_last_overdrive_projector_boosted_cell={"x":7,"y":8}`
  - `step_last_overdrive_projector_boosted_time_scale=1.5`
  - `step_last_overdrive_projector_boosted_time_scale_duration=61.0`
  - `summary_last_overdrive_projector_boosted_time_scale=1.5`
  - `summary_last_overdrive_projector_boosted_time_scale_duration=59.3333333333333`
  - `drill_time_scale=1.5`
  - `drill_time_scale_duration=57.25`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP wave spawn proof on the restarted runtime:

- Observed live spawn telemetry through `/root/Main.get_runtime_summary`.
- TCP proof:
  - `wave_index=4`
  - `last_spawned_wave_index=4`
  - `last_spawned_wave_count=3`
  - `spawned_sum=3`
  - `first_spawned_wave_group={"begin":0,"end":10,"max":30,"spacing":1,"spawned":2,"unit":"dagger","unitAmount":1,"unitScaling":2.0}`
  - `spawned_wave_group_count=29`
  - `enemy_count_after_live_turret_updates=0`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP PowerGraph runtime proof on the restarted runtime:

- Seeded source-backed requirements through `/root/Main.set_core_item_count`.
- Placed `combustion-generator` through `/root/Main.select_build_block_by_id` and `/root/Main.place_selected_block_at_cell(1, 1)`.
- Placed `multi-press` through `/root/Main.select_build_block_by_id` and `/root/Main.place_selected_block_at_cell(4, 1)`.
- TCP proof:
  - `placed_producer=true`
  - `placed_consumer=true`
  - `producer_count=1`
  - `consumer_count=1`
  - `power_produced=60.0`
  - `power_needed=108.0`
  - `placed_power_graph_roles={"all":14,"batteries":0,"consumers":1,"producers":1}`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP PowerGraph battery runtime proof on the restarted runtime:

- Seeded source-backed requirements through `/root/Main.set_core_item_count`.
- Placed `combustion-generator` through `/root/Main.select_build_block_by_id` and `/root/Main.place_selected_block_at_cell(1, 1)`.
- Placed `battery` through `/root/Main.select_build_block_by_id` and `/root/Main.place_selected_block_at_cell(4, 1)`.
- TCP proof:
  - `placed_generator=true`
  - `placed_battery=true`
  - `producer_count=1`
  - `battery_count=1`
  - `charge_excess=60.0`
  - `charged=60.0`
  - `charged_battery_stored=60.0`
  - `used=60.0`
  - `used_battery_stored=0.0`
  - `charged_battery_capacity=3940.0`
  - `used_battery_capacity=4000.0`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
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
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_mend_projector_heal_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `last_mend_projector_target_health` and `last_mend_projector_target_max_health`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_bullet_hit_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `bullet_hit_count` and related hit telemetry.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_overdrive_projector_boost_target_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `last_overdrive_projector_boosted_time_scale` in `step_overdrive_projectors()`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_wave_spawn_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `last_spawned_wave_index`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_power_graph_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `placed_power_runtime_state()`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_power_graph_battery_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `placed_power_battery_runtime_state()`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_runtime_summary_for_mcp`
  - Result: `1 passed, 1544 deselected`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_player_placement_cost_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_mend_projector_heal_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_bullet_hit_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_overdrive_projector_boost_target_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_wave_spawn_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_power_graph_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_power_graph_battery_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- SSOT validator:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4025 passed, 39290 subtests passed in 365.87s (0:06:05)`.

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
- [x] MendProjector heal loop proven: damaged conveyor `25.0 -> 26.8`, healed amount `1.8`, max health `45.0`.
- [x] Bullet hit loop proven: `bullet_hit_count=10`, `last_bullet_hit_damage=9.0`, `last_bullet_target_health_before=150.0`, `last_bullet_target_health_after=141.0`.
- [x] Overdrive boost loop proven: `step_last_overdrive_projector_boost=1.5`, `step_last_overdrive_projector_boosted_block_id="mechanical-drill"`, `step_last_overdrive_projector_boosted_time_scale=1.5`, `drill_time_scale=1.5`.
- [x] Wave spawn loop proven: `last_spawned_wave_index=4`, `last_spawned_wave_count=3`, `spawned_sum=3`, `enemy_count_after_live_turret_updates=0`.
- [x] PowerGraph runtime loop proven: `producer_count=1`, `consumer_count=1`, `power_produced=60.0`, `power_needed=108.0`.
- [x] PowerGraph battery runtime loop proven: `battery_count=1`, `charge_excess=60.0`, `charged=60.0`, `used=60.0`, `used_battery_stored=0.0`.
- [ ] Full playable completion not claimed until broader playthrough audit closes remaining gameplay surfaces.

## Progress

- Source-slice migration: `100.00%`
- Playable audit: broader runtime still under audit, but turret ammo/fire, placement-cost, MendProjector heal, bullet-hit, overdrive boost, wave spawn, PowerGraph runtime, and PowerGraph battery runtime paths now proven.
- Current blocker for completion claim: broader playthrough coverage, not bullet-hit, MendProjector heal, placement-cost, turret ammo/fire, overdrive boost, wave spawn, PowerGraph runtime, or PowerGraph battery runtime.
