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

Eleventh audit found PowerGraph distribution status math was source-backed and individually exposed, but runtime still lacked one MCP-friendly proof package for live consumer coverage and `power.status`. Runtime summary now exposes `placed_power_distribution_runtime` so MCP can prove source-backed `update` and `distributePower` behavior directly.

Twelfth audit found the factory loop advanced in the broader runtime proof, but runtime still lacked one MCP-friendly proof package tying Drill output, Conveyor progress, and Core inventory together. Runtime summary now exposes `factory_runtime` so MCP can prove the source-backed drill/conveyor/core production loop directly.

Thirteenth audit found enemy unit source fields and core damage were exposed as separate summary values, but runtime still lacked one MCP-friendly proof package tying selected enemy health, speed, hit size, weapon damage, live enemy count, and core damage together. Runtime summary now exposes `enemy_runtime` so MCP can prove the source-backed enemy/core loop directly.

Fourteenth audit found all major runtime slices had MCP proof packages, but runtime still lacked one broader playthrough proof package tying generated load health, content/world initialization, factory, enemy/core, power, turret, bullet, mend, and overdrive telemetry together. Runtime summary now exposes `playthrough_runtime` so MCP can prove a source-backed end-to-end runtime package directly.

Fifteenth audit found core destruction could reduce `core_health` to zero but did not expose the source-backed `Logic.checkGameState()` game-over branch through a dedicated MCP proof package. Runtime summary now exposes `game_over_runtime`, and core damage now routes through `apply_core_damage()` so MCP can prove `state.gameOver = true` and `GameOverEvent(state.rules.waveTeam)` semantics from `core/src/mindustry/core/Logic.java`.

Sixteenth audit found player placement was proven as direct placement, but Java-style builder queued construction progress was not MCP-visible. Runtime now exposes `builder_runtime`, `queue_builder_plan()`, and `step_builder_runtime()` so MCP can prove `BuilderComp` plan state, `ConstructBlock` progress, and source-backed build speed/cost formulas.

Seventeenth audit found builder construction was proven, but Java-style block deconstruction/removal was not MCP-visible. Runtime now exposes `builder_deconstruct_runtime`, `queue_builder_deconstruct_plan()`, and `step_builder_deconstruct_runtime()` so MCP can prove `ConstructBlock.setDeconstruct(...)`, `ConstructBuild.deconstruct(...)`, refund multiplier, finish threshold, and `tile.remove()` behavior.

Eighteenth audit found runtime state was visible and mutable, but save/load persistence semantics from Java `SaveIO`, `SaveVersion`, `SaveMeta`, `Saves`, and `WorldContext` were not MCP-visible. Runtime now exposes `runtime_persistence`, `runtime_save_snapshot()`, and `runtime_load_snapshot()` so MCP can prove the source-backed save header/version/region metadata and live runtime restore path directly.

Nineteenth audit found save/load persistence was proven in memory, but no Godot file slot path proved Java `Saves.SaveSlot.save()`/`load()` file ownership at runtime. Runtime now exposes `runtime_save_slot_file`, `runtime_write_save_slot()`, and `runtime_load_save_slot()` so MCP can prove a file-backed runtime slot round trip. This is a Godot JSON runtime slot wrapper around the source-backed snapshot, not a claim of `.msav` binary compatibility.

Twentieth audit found file save/load worked for a known slot name, but Java `Saves.load()` save-directory walking and backup filtering were not MCP-visible. Runtime now exposes `runtime_save_slots`, `runtime_list_save_slots()`, and `runtime_save_slot_valid_state()` so MCP can prove valid runtime slot discovery, source-backed meta packaging, and backup-name exclusion.

Twenty-first audit found liquid transfer helper state was source-backed in `Building.moveLiquid(...)` and `Building.transferLiquid(...)`, but no MCP-visible runtime wrapper exposed a live transfer step. Runtime now exposes `liquid_transfer_runtime`, `reset_liquid_transfer_runtime()`, and `step_liquid_transfer_runtime()` so MCP can prove the source-backed liquid flow, capacity clamp, acceptance guard, and before/after amounts directly.

Twenty-second audit found the factory loop used source-backed drill item dumping into the core, but the accept/handle/remove/cdump proof was only implicit inside broader factory telemetry. Runtime now exposes `item_dump_runtime`, `reset_item_dump_runtime()`, and `step_item_dump_runtime()` so MCP can prove `Building.dump(Item)`, core `acceptItem`, core `handleItem`, source item removal, and dump cursor behavior directly.

Twenty-third audit found liquid transfer was MCP-visible for building-to-building flow, but the `Building.moveLiquidForward(...)` leak branch that deposits puddles and removes leaked liquid was not MCP-visible. Runtime now exposes `liquid_leak_runtime`, `reset_liquid_leak_runtime()`, and `step_liquid_leak_runtime()` so MCP can prove leak amount, `Puddles.deposit(...)`, liquid removal, and remaining source liquid directly.

Twenty-fourth audit found item dumping into the core was MCP-visible, but `Building.put(Item)` proximity handoff was not separately MCP-visible. Runtime now exposes `put_item_runtime`, `reset_put_item_runtime()`, and `step_put_item_runtime()` so MCP can prove proximity scan order, `incrementDump(...)`, accept/canDump guard, `handleItem(...)`, and resulting `cdump` directly.

Twenty-fifth audit found `Building.movePayload(Payload)` and `Building.dumpPayload(Payload)` helpers were source-backed and statically tested, but not separately MCP-visible through runtime summary. Runtime now exposes `payload_runtime`, `reset_payload_runtime()`, `step_payload_move_runtime()`, and `step_payload_dump_runtime()` so MCP can prove forward offset, next-build/team/accept gate, `handlePayload(...)`, proximity dump index, `incrementDump(...)`, and resulting `cdump` directly.

Twenty-sixth audit found the default `Building.getPayload()`, `takePayload()`, and `getPayloads()` null-return methods were source-backed and statically tested, but not visible as a grouped runtime proof. Runtime now exposes `payload_default_runtime`, `reset_payload_default_runtime()`, and `step_payload_default_runtime()` so MCP can prove default payload absence, nullable contract, no take side effect, and `return null;` behavior directly.

Twenty-seventh audit found `UnitType.targetable(...)` and `UnitType.hittable(...)` payload-vulnerability paths were source-backed and statically tested, but not visible as a grouped runtime proof. Runtime now exposes `unit_payload_targeting_runtime`, `reset_unit_payload_targeting_runtime()`, and `step_unit_payload_targeting_runtime()` so MCP can prove `vulnerableWithPayloads && unit instanceof Payloadc p && p.hasPayload()` makes otherwise non-targetable/non-hittable units targetable and hittable.

Twenty-eighth audit found `UnitType.killable(Unit)` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_killable_runtime`, `reset_unit_killable_runtime()`, and `step_unit_killable_runtime(...)` so MCP can prove `return killable;` for both killable and non-killable unit type states.

Twenty-ninth audit found `UnitComp.playerControllable()` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_player_controllable_runtime`, `reset_unit_player_controllable_runtime()`, and `step_unit_player_controllable_runtime(...)` so MCP can prove the default controllable path and the privileged `LogicAI` block guard from `core/src/mindustry/entities/comp/UnitComp.java`.

Thirtieth audit found `UnitComp.afterSync()` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_after_sync_runtime`, `reset_unit_after_sync_runtime()`, and `step_unit_after_sync_runtime(...)` so MCP can prove the post-sync `setType(this.type)` then `controller.unit(self())` call order from `core/src/mindustry/entities/comp/UnitComp.java`.

Thirty-first audit found `UnitComp.afterRead()` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_after_read_runtime`, `reset_unit_after_read_runtime()`, and `step_unit_after_read_runtime(...)` so MCP can prove the controller reset guard and the keep-state branch from `core/src/mindustry/entities/comp/UnitComp.java`.

Thirty-second audit found `UnitComp.afterReadAll()` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_after_read_all_runtime`, `reset_unit_after_read_all_runtime()`, and `step_unit_after_read_all_runtime(...)` so MCP can prove `controller.afterRead(self())` from `core/src/mindustry/entities/comp/UnitComp.java`.

Thirty-third audit found `UnitComp.add()` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_add_runtime`, `reset_unit_add_runtime()`, and `step_unit_add_runtime(...)` so MCP can prove `team.data().updateCount(type, 1)`, the unit-cap guard, `Call.unitCapDeath(self())`, and rollback `team.data().updateCount(type, -1)` from `core/src/mindustry/entities/comp/UnitComp.java`.

Thirty-fourth audit found `UnitComp.remove()` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_remove_runtime`, `reset_unit_remove_runtime()`, and `step_unit_remove_runtime(...)` so MCP can prove `team.data().updateCount(type, -1)`, `controller.removed(self())`, and optional trail fade `Fx.trailFade.at(...)` from `core/src/mindustry/entities/comp/UnitComp.java`.

Thirty-fifth audit found `UnitComp.landed()` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_landed_runtime`, `reset_unit_landed_runtime()`, and `step_unit_landed_runtime(...)` so MCP can prove the `type.mechLandShake > 0f` shake guard and the always-run `type.landed(self())` call from `core/src/mindustry/entities/comp/UnitComp.java`.

Thirty-sixth audit found `UnitComp.heal(float amount)` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_heal_runtime`, `reset_unit_heal_runtime()`, and `step_unit_heal_runtime(...)` so MCP can prove the `health < maxHealth && amount > 0` guard and `wasHealed = true` side effect from `core/src/mindustry/entities/comp/UnitComp.java`.

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
- Added RED test that requires a PowerGraph distribution runtime proof wrapper.
- Added `placed_power_distribution_runtime_state()` and `"placed_power_distribution_runtime": placed_power_distribution_runtime_state()` to runtime summary. The wrapper only packages source-backed `source_power_graph_update_balance_state()` and `source_power_graph_update_battery_distribute_state()` over placed consumer, producer, and battery blocks.
- Added RED test that requires a factory runtime proof wrapper.
- Added `factory_runtime_state()` and `"factory_runtime": factory_runtime_state()` to runtime summary. The wrapper only packages source-backed `source_drill_delay()`, `source_drill_output_delta_for_cell()`, `source_conveyor_path_progress_delta_for_cell()`, and live drill/core counters.
- Added RED test that requires an enemy runtime proof wrapper.
- Added `enemy_runtime_state()` and `"enemy_runtime": enemy_runtime_state()` to runtime summary. The wrapper only packages source-backed `source_unit_weapon_damage()`, `source_unit_world_speed()`, `source_unit_hit_size()`, `source_unit_health()`, and live enemy/core counters.
- Added RED test that requires a playthrough runtime proof wrapper.
- Added `playthrough_runtime_state()` and `"playthrough_runtime": playthrough_runtime_state()` to runtime summary. The wrapper only packages the existing source-backed runtime proof packages and live counters, with `core/src/mindustry/core/Logic.java` as the source update owner.
- Added RED test that requires a source-backed game-over runtime proof wrapper.
- Added `source_game_over_core_destroyed_state()`, `apply_core_damage()`, `game_over_runtime_state()`, and `"game_over_runtime": game_over_runtime_state()` to runtime summary. The wrapper only packages the `Logic.checkGameState()` core-destroyed branch and live core/game-over counters.
- Registered `PortGame.source_game_over_core_destroyed_state` in source-symbol SSOT, API contracts, state schemas, audit report, and canonical mirror shards so the new source owner is not unregistered.
- Added RED test that requires a source-backed builder construction queue runtime proof.
- Added `builder_plans`, `builder_build_counter`, `builder_build_alpha`, `builder_last_active`, `builder_construct_progress`, `queue_builder_plan()`, `step_builder_runtime()`, `builder_runtime_state()`, and `"builder_runtime": builder_runtime_state()` to runtime summary.
- Added source-backed `source_builder_unit_build_range()` using `Vars.buildingRange = 220f`, and registered `PortGame.source_builder_unit_build_range` in source-symbol SSOT and canonical audit mirror shards.
- Added RED test that requires a source-backed builder deconstruct runtime proof.
- Added `builder_deconstruct_progress`, `builder_last_deconstruct_block_id`, `builder_last_deconstruct_cell`, `builder_last_deconstruct_build_cost`, `builder_last_deconstruct_speed_delta`, `builder_last_deconstruct_refund_items`, `queue_builder_deconstruct_plan()`, `step_builder_deconstruct_runtime()`, `builder_deconstruct_runtime_state()`, and `"builder_deconstruct_runtime": builder_deconstruct_runtime_state()` to runtime summary.
- Added placed-block removal and source-backed deconstruct refund handling using `Rules.deconstructRefundMultiplier = 0.5f` and `Block.deconstructThreshold = 0f`.
- Renamed the builder queue rotation argument to `rotation_value` after fresh Godot runtime reported a `Node2D.rotation` shadow warning.
- Added RED test that requires a source-backed runtime save/load persistence proof package.
- Added `runtime_block_snapshot()`, `restore_runtime_blocks()`, `runtime_save_snapshot()`, `runtime_load_snapshot()`, `runtime_persistence_state()`, and `"runtime_persistence": runtime_persistence_state()` to runtime summary. The wrapper packages source facts from `SaveIO`, `SaveVersion`, `SaveMeta`, `Saves`, and `WorldContext` with live core, builder, world-block, and occupancy state.
- Added RED test that requires a file-backed runtime save slot proof package.
- Added `RUNTIME_SAVE_SLOT_DIR`, `runtime_save_slot_path()`, `runtime_write_save_slot()`, `runtime_read_save_slot()`, `runtime_load_save_slot()`, `runtime_save_slot_file_state()`, and `"runtime_save_slot_file": runtime_save_slot_file_state()` to runtime summary. The wrapper uses Godot `FileAccess` over the source-backed snapshot and carries `Saves.SaveSlot.save()`, `Saves.SaveSlot.load()`, and `SaveIO.getMeta(file)` source expressions.
- Added RED test that requires a runtime save slot listing proof package.
- Added `runtime_save_slot_valid_state()`, `runtime_list_save_slots()`, and `"runtime_save_slots": runtime_list_save_slots()` to runtime summary. The wrapper scans `RUNTIME_SAVE_SLOT_DIR`, skips names containing `backup`, reads each valid slot, and packages `Saves.load()`/`SaveIO.isSaveValid(file)`/`SaveIO.getMeta(file)` source expressions.
- Added RED test that requires a source-backed liquid transfer runtime proof package.
- Added `liquid_transfer_liquid`, `liquid_transfer_source_amount`, `liquid_transfer_destination_amount`, `liquid_transfer_source_capacity`, `liquid_transfer_destination_capacity`, `liquid_transfer_pressure`, `liquid_transfer_last_move_state`, `liquid_transfer_last_transfer_state`, `reset_liquid_transfer_runtime()`, `step_liquid_transfer_runtime()`, `liquid_transfer_runtime_state()`, and `"liquid_transfer_runtime": liquid_transfer_runtime_state()` to runtime summary. The wrapper packages the source-backed `moveLiquid(...)` and `transferLiquid(...)` helpers, then exposes the live source and destination amounts after a deterministic transfer step.
- Added RED test that requires a source-backed item dump runtime proof package.
- Added `item_dump_item`, `item_dump_last_state`, `reset_item_dump_runtime()`, `step_item_dump_runtime()`, `item_dump_runtime_state()`, and `"item_dump_runtime": item_dump_runtime_state()` to runtime summary. The wrapper packages the existing source-backed `source_dump_drill_item_to_core()` path and exposes `dump(Item)` source expressions, core accept/handle state, source removal state, and live drill/core item counts.
- Added RED test that requires a source-backed liquid leak runtime proof package.
- Added `liquid_leak_liquid`, `liquid_leak_amount`, `liquid_leak_last_state`, `reset_liquid_leak_runtime()`, `step_liquid_leak_runtime()`, `liquid_leak_runtime_state()`, and `"liquid_leak_runtime": liquid_leak_runtime_state()` to runtime summary. The wrapper packages `source_building_move_liquid_forward_state(...)` and exposes leak branch source strings for `Puddles.deposit(...)` and `liquids.remove(...)`.
- Added RED test that requires a source-backed `Building.put(Item)` runtime proof package.
- Added `put_item_item`, `put_item_dump_cursor`, `put_item_last_state`, `reset_put_item_runtime()`, `step_put_item_runtime()`, `put_item_runtime_state()`, and `"put_item_runtime": put_item_runtime_state()` to runtime summary. The wrapper packages `source_building_put_item_state(...)` and exposes proximity scan indices, handled index, handle call, return value, and resulting dump cursor.
- Added RED test that requires a source-backed move/dump payload runtime proof package.
- Added `payload_runtime_payload`, `payload_runtime_dump_cursor`, `payload_runtime_move_last_state`, `payload_runtime_dump_last_state`, `reset_payload_runtime()`, `step_payload_move_runtime()`, `step_payload_dump_runtime()`, `payload_runtime_state()`, and `"payload_runtime": payload_runtime_state()` to runtime summary. The wrapper packages `source_move_payload_state(...)`, `source_payload_forward_offset(...)`, and `source_dump_payload_state(...)` with source strings from `BuildingComp.java`.
- Added RED test that requires a source-backed default payload runtime proof package.
- Added `payload_default_last_state`, `reset_payload_default_runtime()`, `step_payload_default_runtime()`, `payload_default_runtime_state()`, and `"payload_default_runtime": payload_default_runtime_state()` to runtime summary. The wrapper packages `source_building_get_payload_default_state()`, `source_building_take_payload_default_state()`, and `source_building_get_payloads_default_state()`.
- Added RED test that requires a source-backed unit payload targeting runtime proof package.
- Added `unit_payload_targeting_last_state`, `reset_unit_payload_targeting_runtime()`, `step_unit_payload_targeting_runtime()`, `unit_payload_targeting_runtime_state()`, and `"unit_payload_targeting_runtime": unit_payload_targeting_runtime_state()` to runtime summary. The wrapper packages `source_unit_targetable_state(...)` and `source_unit_hittable_state(...)` over the payload-vulnerability branch.
- Added RED test that requires a source-backed unit killable runtime proof package.
- Added `unit_killable_last_state`, `reset_unit_killable_runtime()`, `step_unit_killable_runtime(...)`, `unit_killable_runtime_state()`, and `"unit_killable_runtime": unit_killable_runtime_state()` to runtime summary. The wrapper packages `source_unit_killable_state(...)` and exposes `SOURCE_UNIT_KILLABLE_TYPE_RETURN`.
- Added RED test that requires a source-backed unit player-controllable runtime proof package.
- Added `unit_player_controllable_last_state`, `SOURCE_UNIT_PLAYER_CONTROLLABLE_DEFAULT`, `reset_unit_player_controllable_runtime()`, `step_unit_player_controllable_runtime(...)`, `unit_player_controllable_runtime_state()`, and `"unit_player_controllable_runtime": unit_player_controllable_runtime_state()` to runtime summary. The wrapper packages `source_unit_player_controllable_state(...)` and exposes `SOURCE_UNIT_PLAYER_CONTROLLABLE_RETURN` plus the `UnitType.playerControllable` default.
- Added RED test that requires a source-backed unit afterSync runtime proof package.
- Added `unit_after_sync_last_state`, `reset_unit_after_sync_runtime()`, `step_unit_after_sync_runtime(...)`, `unit_after_sync_runtime_state()`, and `"unit_after_sync_runtime": unit_after_sync_runtime_state()` to runtime summary. The wrapper packages `source_unit_after_sync_state(...)` and exposes `SOURCE_UNIT_AFTER_SYNC_SET_TYPE_CALL` plus `SOURCE_UNIT_AFTER_SYNC_CONTROLLER_UNIT_CALL`.
- Added RED test that requires a source-backed unit afterRead runtime proof package.
- Added `unit_after_read_last_state`, `reset_unit_after_read_runtime()`, `step_unit_after_read_runtime(...)`, `unit_after_read_runtime_state()`, and `"unit_after_read_runtime": unit_after_read_runtime_state()` to runtime summary. The wrapper packages `source_unit_after_read_state(...)` and exposes `SOURCE_UNIT_AFTER_READ_RESET_GUARD` plus `SOURCE_UNIT_AFTER_READ_CREATE_CONTROLLER_CALL`.
- Added RED test that requires a source-backed unit afterReadAll runtime proof package.
- Added `unit_after_read_all_last_state`, `reset_unit_after_read_all_runtime()`, `step_unit_after_read_all_runtime(...)`, `unit_after_read_all_runtime_state()`, and `"unit_after_read_all_runtime": unit_after_read_all_runtime_state()` to runtime summary. The wrapper packages `source_unit_after_read_all_state(...)` and exposes `SOURCE_UNIT_AFTER_READ_ALL_CALL`.
- Added RED test that requires a source-backed unit add runtime proof package.
- Added `unit_add_last_state`, `reset_unit_add_runtime()`, `step_unit_add_runtime(...)`, `unit_add_runtime_state()`, and `"unit_add_runtime": unit_add_runtime_state()` to runtime summary. The wrapper packages `source_unit_add_state(...)` and exposes `SOURCE_UNIT_ADD_CAP_GUARD` plus `SOURCE_UNIT_ADD_UNIT_CAP_DEATH_CALL`.
- Added RED test that requires a source-backed unit remove runtime proof package.
- Added `unit_remove_last_state`, `reset_unit_remove_runtime()`, `step_unit_remove_runtime(...)`, `unit_remove_runtime_state()`, and `"unit_remove_runtime": unit_remove_runtime_state()` to runtime summary. The wrapper packages `source_unit_remove_state(...)` and exposes `SOURCE_UNIT_REMOVE_CONTROLLER_REMOVED` plus `SOURCE_UNIT_REMOVE_TRAIL_FADE`.
- Added RED test that requires a source-backed unit landed runtime proof package.
- Added `unit_landed_last_state`, `reset_unit_landed_runtime()`, `step_unit_landed_runtime(...)`, `unit_landed_runtime_state()`, and `"unit_landed_runtime": unit_landed_runtime_state()` to runtime summary. The wrapper packages `source_unit_landed_state(...)` and exposes `SOURCE_UNIT_LANDED_SHAKE_CALL` plus `SOURCE_UNIT_LANDED_TYPE_CALL`.
- Added RED test that requires a source-backed unit heal runtime proof package.
- Added `unit_heal_last_state`, `reset_unit_heal_runtime()`, `step_unit_heal_runtime(...)`, `unit_heal_runtime_state()`, and `"unit_heal_runtime": unit_heal_runtime_state()` to runtime summary. The wrapper packages `source_unit_heal_state(...)` and exposes `SOURCE_UNIT_HEAL_GUARD` plus `SOURCE_UNIT_HEAL_WAS_HEALED`.

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
- TCP liquid transfer proof:
  - `source_amount=0.999999999999999`
  - `destination_amount=8`
  - `move_flow=7`
  - `move_return=7`
  - `transfer_guard_passed=true`
  - `handle_liquid_called=true`
  - `remove_liquid_called=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP item dump proof:
  - `item="copper"`
  - `source_count 3 -> 2`
  - `core_count 2 -> 3`
  - `core_capacity=10`
  - `dumped=true`
  - `remove_removed=1`
  - `remove_remaining=2`
  - `can_dump=true`
  - `move_forward_accept_state=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP liquid leak proof:
  - `liquid="water"`
  - `amount 6 -> 2`
  - `leak_amount=4`
  - `leak_guard_passed=true`
  - `puddles_deposit_called=true`
  - `remove_liquid_called=true`
  - `return_value=0`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP put item proof:
  - `item="copper"`
  - `proximity_size=3`
  - `checked_indices=[0, 1]`
  - `handled_index=1`
  - `handle_item_called=true`
  - `put=true`
  - `return_value=true`
  - `cdump=2`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP payload move/dump proof:
  - `payload_content="conveyor"`
  - `move_moved=true`
  - `move_handle_payload_called=true`
  - `move_forward_offset=1`
  - `move_return_value=true`
  - `dump_moved=true`
  - `dump_handled_index=1`
  - `dump_handle_payload_called=true`
  - `dump_return_value=true`
  - `dump_cdump=2`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP payload default proof:
  - `get_payload_has_payload=false`
  - `get_payload_return_null="return null;"`
  - `take_payload_has_payload=false`
  - `take_payload_taken=false`
  - `take_payload_return_null="return null;"`
  - `get_payloads_has_payloads=false`
  - `get_payloads_return_null="return null;"`
  - `summary_has_payload_default_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit payload targeting proof:
  - `targetable=true`
  - `targetable_payload_path=true`
  - `hittable=true`
  - `hittable_payload_path=true`
  - `payload_has_payload_expr="return payloads.size > 0;"`
  - `summary_has_unit_payload_targeting_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit killable proof:
  - `true_killable=true`
  - `true_return_expr="return killable;"`
  - `false_killable=false`
  - `false_return_expr="return killable;"`
  - `summary_has_unit_killable_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit player-controllable proof:
  - `base_controllable=true`
  - `base_blocked=false`
  - `base_return_expr="return type.playerControllable && !(controller instanceof LogicAI ai && ai.controller != null && ai.controller.block.privileged);"`
  - `blocked_controllable=false`
  - `blocked_logic_privileged=true`
  - `blocked_default_expr="playerControllable = true,"`
  - `summary_has_unit_player_controllable_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit afterSync proof:
  - `type_id=7`
  - `controller_exists=true`
  - `call_order=["setType", "controller.unit"]`
  - `set_type_call="setType(this.type);"`
  - `controller_unit_call="controller.unit(self());"`
  - `summary_has_unit_after_sync_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit afterRead proof:
  - `recreate_reset_controller=true`
  - `recreate_call_order=["setType", "controller.unit", "controller(type.createController)"]`
  - `keep_reset_controller=false`
  - `keep_call_order=["setType", "controller.unit"]`
  - `reset_guard="if(!(controller instanceof AIController ai && ai.keepState())){"`
  - `create_controller_call="controller(type.createController(self()));"`
  - `summary_has_unit_after_read_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit afterReadAll proof:
  - `controller_exists=true`
  - `call="controller.afterRead(self());"`
  - `after_read_arg="self()"`
  - `controller_after_read_call="controller.afterRead(self());"`
  - `summary_has_unit_after_read_all_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit add proof:
  - `over_unit_cap_death=true`
  - `over_call_order=["team.data().updateCount(+1)", "Call.unitCapDeath", "team.data().updateCount(-1)"]`
  - `over_rollback={"amount":-1,"call":"team.data().updateCount(type, -1);"}`
  - `ok_unit_cap_death=false`
  - `ok_call_order=["team.data().updateCount(+1)"]`
  - `cap_guard="if(type.useUnitCap && count() > cap() && !spawnedByCore && !dead && !state.rules.editor){"`
  - `unit_cap_death_call="Call.unitCapDeath(self());"`
  - `summary_has_unit_add_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit remove proof:
  - `with_trail_fade=true`
  - `with_call_order=["team.data().updateCount(-1)", "controller.removed", "Fx.trailFade.at"]`
  - `with_trail_color="blue"`
  - `with_trail_fade_call={"call":"Fx.trailFade.at","color":"blue","dataArg":"trail.copy()","rotation":2,"rotationArg":"trail.width()","xArg":"x","yArg":"y"}`
  - `without_trail_fade=false`
  - `without_call_order=["team.data().updateCount(-1)", "controller.removed"]`
  - `without_trail_color="green"`
  - `controller_removed_call="controller.removed(self());"`
  - `trail_fade_call="Fx.trailFade.at(x, y, trail.width(), type.trailColor == null ? team.color : type.trailColor, trail.copy());"`
  - `summary_has_unit_remove_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit landed proof:
  - `shake=true`
  - `shake_call_order=["Effect.shake", "type.landed"]`
  - `shake_call={"call":"Effect.shake(type.mechLandShake, type.mechLandShake, this)","duration":3,"intensity":3,"locArg":"this"}`
  - `no_shake=false`
  - `no_shake_call_order=["type.landed"]`
  - `type_landed={"arg":"self()","call":"type.landed(self())"}`
  - `shake_call_source="Effect.shake(type.mechLandShake, type.mechLandShake, this);"`
  - `type_landed_call_source="type.landed(self());"`
  - `summary_has_unit_landed_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
- TCP unit heal proof:
  - `heal_set_was_healed=true`
  - `heal_was_healed=true`
  - `heal_guard={"amountPositive":true,"healthLessThanMax":true}`
  - `heal_health=95`
  - `full_set_was_healed=false`
  - `full_was_healed=false`
  - `full_guard={"amountPositive":true,"healthLessThanMax":false}`
  - `negative_set_was_healed=false`
  - `negative_was_healed=true`
  - `negative_guard={"amountPositive":false,"healthLessThanMax":true}`
  - `heal_guard_source="if(health < maxHealth && amount > 0){"`
  - `was_healed_assignment="wasHealed = true;"`
  - `summary_has_unit_heal_runtime=true`
  - `generated_load_failures=[]`
  - `generated_instance_failures=[]`
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

Fresh MCP PowerGraph distribution runtime proof on the restarted runtime:

- Seeded source-backed requirements through `/root/Main.set_core_item_count`.
- Placed `combustion-generator` through `/root/Main.select_build_block_by_id` and `/root/Main.place_selected_block_at_cell(1, 1)`.
- Placed `multi-press` through `/root/Main.select_build_block_by_id` and `/root/Main.place_selected_block_at_cell(4, 1)`.
- TCP proof:
  - `placed_generator=true`
  - `placed_consumer=true`
  - `producer_count=1`
  - `consumer_count=1`
  - `battery_count=0`
  - `power_needed=108.0`
  - `power_produced=60.0`
  - `coverage=0.555555555555556`
  - `first_consumer_power_status=0.555555555555556`
  - `power_battery_used=0.0`
  - `power_battery_charged=0.0`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP factory runtime proof on the restarted runtime:

- Stepped source-backed factory loops through `/root/Main.step_factory_drill(2.0)` and `/root/Main.step_factory_transport(2.0)`.
- TCP proof:
  - `drill_ore_cell_count=2`
  - `drill_delay=650.0`
  - `drill_output_rate=0.184615384615385`
  - `drill_output_delta_per_second=120.0`
  - `drill_time_drilled=2753.87585752215`
  - `drill_warmup=1.0`
  - `conveyor_world_speed=52.8`
  - `conveyor_path_progress_rate=0.183333333333333`
  - `conveyor_progress_delta_per_second=0.183333333333333`
  - `produced_total 2 -> 8`
  - `core_inventory 2 -> 8`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP enemy runtime proof on the restarted runtime:

- TCP `/root/Main.get_runtime_summary` before and after `/root/Main.simulate_enemy_units(1.0)`.
- TCP proof:
  - `selected_enemy_health=150.0`
  - `selected_enemy_hit_size=8.0`
  - `selected_enemy_weapon_damage=9.0`
  - `selected_enemy_world_speed=30.0`
  - `core_damage_taken_total=9.0`
  - `core_health=1091.0`
  - `last_spawned_wave_index=1`
  - `last_spawned_wave_count=2`
  - `enemy_count=0` after auto runtime enemy/core contact
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP playthrough runtime proof on the restarted runtime:

- TCP `/root/Main.get_runtime_summary` with `playthrough_runtime`.
- TCP proof:
  - `source_update_owner="core/src/mindustry/core/Logic.java"`
  - `source_update_method="public void update(){"`
  - `loaded_generated_load_failures=[]`
  - `loaded_generated_instance_failures=[]`
  - `content_counts={"items":22,"liquids":11,"blocks":417,"units":56}`
  - `initial_world_block_count=12`
  - `initial_occupied_cell_count=22`
  - `factory_runtime.produced_total=1`
  - `factory_runtime.core_inventory=1`
  - `enemy_runtime.selected_enemy_weapon_damage=9.0`
  - `enemy_runtime.selected_enemy_world_speed=30.0`
  - `enemy_runtime.enemy_count=1`
  - `turret_shot_count=20`
  - `bullet_hit_count=5`
  - `core_damage_taken_total=9.0`
  - `core_health=1091.0`
- Live power exercise through TCP:
  - `select_build_block_by_id("power-source")=true`
  - `place_selected_block_at_cell(1,14)=true`
  - `placed_power_runtime.producer_count=1`
  - `player_placed_block_count=2`
- Godot debug output: `errors=[]`
- Godot stop: `finalErrors=[]`

Fresh MCP game-over runtime proof on the restarted runtime:

- TCP `/root/Main.get_runtime_summary` before damage:
  - `core_health=1091.0`
- TCP `/root/Main.apply_core_damage(1091.0)`:
  - `applied=1091.0`
  - `core_health=0.0`
  - `core_damage_taken_total=1100.0`
  - `game_over=true`
  - `winner="waveTeam"`
- TCP `/root/Main.get_runtime_summary` after damage:
  - `game_over_runtime.game_over=true`
  - `game_over_runtime.last_game_over_winner="waveTeam"`
  - `game_over_runtime.core_health=0.0`
  - `game_over_runtime.core_damage_taken_total=1100.0`
  - `game_over_runtime.source_game_over.source_owner="core/src/mindustry/core/Logic.java"`
  - `game_over_runtime.source_game_over.method="private void checkGameState(){"`
  - `game_over_runtime.source_game_over.core_destroyed_expr="state.teams.playerCores().size == 0"`
  - `game_over_runtime.source_game_over.game_over_expr="state.gameOver = true;"`
  - `game_over_runtime.source_game_over.event_expr="Events.fire(new GameOverEvent(state.rules.waveTeam));"`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
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

MCP builder construction queue proof captured for the current slice:

- Seeded source-backed cost path through `/root/Main.set_core_item_count("copper", 100)`.
- Queued `conveyor` through `/root/Main.queue_builder_plan("conveyor", 2, 2, 0)`.
- Stepped builder runtime through `/root/Main.step_builder_runtime(5.0)`.
- TCP proof:
  - `plan_count=1`
  - `construct_progress=0.125`
  - `last_construct_block_id="conveyor"`
  - `build_speed_formula="1f / entity.buildCost * type.buildSpeed * buildSpeedMultiplier * state.rules.buildSpeed(team)"`
  - `construct_progress_expr="progress = Mathf.clamp(progress + maxProgress);"`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`

Fresh MCP builder deconstruct runtime proof on the restarted runtime:

- TCP `/root/Main.get_runtime_summary` before deconstruct:
  - `occupied_cell_count=22`
- Queued deconstruct for live conveyor through `/root/Main.queue_builder_deconstruct_plan(8, 8)`.
- Stepped deconstruct through `/root/Main.step_builder_deconstruct_runtime(40.0)` four times. Source build counter clamps at `10`, so four calls are required for `buildTime=20.0` and `buildSpeed=0.5`.
- TCP proof:
  - `queue_queued=true`
  - `queue_plan_count=1`
  - `queue_block_id="conveyor"`
  - Progress: `1.0 -> 0.75 -> 0.5 -> 0.249999999999999 -> 0.0`
  - `deconstruct_finished_count=1`
  - `last_deconstruct_removed=true`
  - `last_deconstruct_refund_items=[{"amount":1,"item":"copper"}]`
  - `occupied_cell_count 22 -> 21`
  - `all_generated_load_failures=[]`
  - `all_generated_instance_failures=[]`
- Godot debug output after rotation arg fix: `errors=[]`
- Godot stop after rotation arg fix: `finalErrors=[]`

Fresh MCP builder skip/range runtime proof on the restarted runtime:

- Source facts used:
  - `BuilderComp.shouldSkip(...)` guard returns false for infinite resources, breaking plans, null core, rotation, or derelict repair.
  - `shouldSkip(...)` returns true for stuck plans missing all block requirements or when `Structs.contains(plan.block.requirements, i -> !core.items.has(i.item, Math.min(i.amount, 15)) && Mathf.round(i.amount * state.rules.buildCostMultiplier) > 0)`.
  - `BuilderComp.updateBuildLogic()` rotates skipped plans with `plans.removeFirst(); plans.addLast(plan);`.
  - `BuilderComp.activelyBuilding()` returns false when not editor, plan exists, and `within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)` is false.
- TCP proof:
  - Clean `prePlanCount=0`.
  - Set `/root/Main.set_core_item_count("copper", 1)`.
  - Queued `/root/Main.queue_builder_plan("router", 2, 2, 0)` and `/root/Main.queue_builder_plan("conveyor", 3, 2, 0)`.
  - `queuedPlanCount=2`.
  - Before step, live first plan `block_id="router"`, `should_skip=true`, `structs_contains_missing_requirement=true`.
  - After `/root/Main.step_builder_runtime(5.0)`, active plan rotated to `block_id="conveyor"`, `progressAfter=0.125`, `stepPlanCount=2`.
  - After step, live first plan `block_id="conveyor"`, `should_skip=false`.
  - Source range proof: `outOfRangeActive=false`, `outOfRangeBlocked=true`.
  - Source skip guard proof: `breakingSkip=false`, `stuckMissingSkip=true`, `missingRequirementSkip=true`.
  - `all_generated_load_failures=[]`.
  - `all_generated_instance_failures=[]`.
- Godot debug output: `errors=[]`.
- Godot stop output: `finalErrors=[]`.

Fresh MCP runtime save/load persistence proof on the restarted runtime:

- Source facts used:
  - `SaveIO` writes header `{'M', 'S', 'A', 'V'}` then `stream.writeInt(ver.version)`.
  - `SaveVersion` writes `meta`, `patches`, `content`, `map`, `entities`, `markers`, and `custom` regions; load reads regioned `meta`, `content`, `map`, and `entities`.
  - `SaveMeta` stores version/build/timestamp/time played/map/wave/rules/tags/mods metadata.
  - `Saves.SaveSlot.save(...)` calls `SaveIO.save(file)` and `SaveSlot.load(...)` calls `SaveIO.load(file, context)`.
  - `WorldContext` owns `resize`, `create`, `tile`, `begin`, `end`, and `isMap` world load callbacks.
- TCP proof:
  - Clean `beforePlanCount=0`.
  - Queued `/root/Main.queue_builder_plan("conveyor", 2, 2, 0)` and stepped `/root/Main.step_builder_runtime(5.0)`.
  - Snapshot through `/root/Main.runtime_save_snapshot("proof-slot")`.
  - Snapshot values: `header="MSAV"`, `version=13`, `core_items.copper=25`, `builder_plan_count=1`, `block_count=12`, `occupied_cell_count=22`.
  - Mutated live state through `/root/Main.set_core_item_count("copper", 3)` and `/root/Main.queue_builder_plan("router", 4, 2, 0)`.
  - Restored through `/root/Main.runtime_load_snapshot(snapshot)`.
  - Restore values: `restored_block_count=12`, `restored_occupied_cell_count=22`, `after_load_copper=25`, `after_load_plan_count=1`, `after_load_block_count=12`, `after_load_occupied_cell_count=22`.
  - Match checks: copper, builder plan count, block count, and occupied cell count all restored to snapshot values.
  - `all_generated_load_failures=[]`.
  - `all_generated_instance_failures=[]`.
- Godot debug output: `errors=[]`.
- Godot stop output: `finalErrors=[]`.

Fresh MCP runtime save slot file proof on the restarted runtime:

- Source facts used:
  - `Saves.SaveSlot.save()` calls `SaveIO.save(file)` and then `meta = SaveIO.getMeta(file)`.
  - `Saves.SaveSlot.load(WorldContext context)` calls `SaveIO.load(file, context)`, then `meta = SaveIO.getMeta(file)`, sets `current`, restores `totalPlaytime`, and saves preview.
  - `SaveIO.save(Fi file, SaveOptions options)` moves an existing file to `backupFileFor(file)` before writing.
  - `SaveIO.write(...)` writes header `{'M', 'S', 'A', 'V'}` and writer version before delegating to `ver.write(stream, options)`.
  - Runtime wrapper stores the already source-backed snapshot as a Godot JSON slot file and does not claim `.msav` binary compatibility.
- TCP proof:
  - Clean `beforePlanCount=0`.
  - Set `/root/Main.set_core_item_count("copper", 25)`.
  - Queued `/root/Main.queue_builder_plan("conveyor", 2, 2, 0)` and stepped `/root/Main.step_builder_runtime(5.0)`.
  - Wrote slot through `/root/Main.runtime_write_save_slot("proof-file-slot")`.
  - File proof: `saved=true`, `exists=true`, `path="user://runtime-save-slots/proof-file-slot.json"`.
  - Snapshot values: `header="MSAV"`, `version=13`, `core_items.copper=25`, `builder_plan_count=1`, `block_count=12`, `occupied_cell_count=22`.
  - Mutated live state through `/root/Main.set_core_item_count("copper", 3)` and `/root/Main.queue_builder_plan("router", 4, 2, 0)`.
  - Loaded slot through `/root/Main.runtime_load_save_slot("proof-file-slot")`.
  - Restore values: `loaded=true`, `after_copper=25`, `after_plan_count=1`, `after_block_count=12`, `after_occupied_cell_count=22`.
  - Match checks: copper, builder plan count, block count, and occupied cell count all restored to file snapshot values.
  - `all_generated_load_failures=[]`.
  - `all_generated_instance_failures=[]`.
- Godot debug output: `errors=[]`.
- Godot stop output: `finalErrors=[]`.

Fresh MCP runtime save slot listing proof on the restarted runtime:

- Source facts used:
  - `Saves.load()` walks `saveDirectory` with `saveDirectory.walk(file -> {`.
  - `Saves.load()` excludes backup saves and requires `SaveIO.isSaveValid(file)` before creating a `SaveSlot`.
  - `Saves.load()` reads slot metadata with `slot.meta = SaveIO.getMeta(file)`.
- TCP proof:
  - Wrote `/root/Main.runtime_write_save_slot("proof-list-a")` with copper `25`.
  - Wrote `/root/Main.runtime_write_save_slot("proof-list-b")` with copper `31`.
  - Wrote `/root/Main.runtime_write_save_slot("proof-list-backup")` to prove backup-name filtering.
  - Listed slots through `/root/Main.runtime_list_save_slots`.
  - `proof_names=["proof-list-a","proof-list-b"]`.
  - `includes_a=true`, `includes_b=true`, `excludes_backup_named=true`.
  - First proof slot: `slot_name="proof-list-a"`, `header="MSAV"`, `version=13`, `core_inventory=25`, `valid=true`, `path="user://runtime-save-slots/proof-list-a.json"`.
  - `all_valid=true`.
- Godot debug output: `errors=[]`.
- Godot stop output: `finalErrors=[]`.

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
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_power_graph_distribution_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `placed_power_distribution_runtime_state()`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_factory_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `factory_runtime_state()`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_enemy_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `enemy_runtime_state()`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_enemy_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with untyped `first_enemy` proof variable after Godot parser rejected inference.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_playthrough_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `playthrough_runtime_state()`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_game_over_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var game_over := false`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected before implementation with missing builder queue runtime state and APIs.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_deconstruct_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var builder_deconstruct_progress := 1.0`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected when the test required `rotation_value` instead of shadowing `Node2D.rotation`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_skip_range_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `func builder_plan_requirement_state(block) -> Dictionary:`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_load_persistence_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `func runtime_block_snapshot() -> Array:`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_slot_file_persistence_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `const RUNTIME_SAVE_SLOT_DIR := "user://runtime-save-slots"`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_slot_listing_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `func runtime_save_slot_valid_state(snapshot: Dictionary) -> Dictionary:`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_liquid_transfer_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var liquid_transfer_source_amount := 8.0`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_item_dump_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var item_dump_item := "copper"`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_liquid_leak_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var liquid_leak_amount := 6.0`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_put_item_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var put_item_item := "copper"`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_move_dump_payload_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var payload_runtime_payload := {"kind": "block", "content": "conveyor", "size": 1}`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_payload_default_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var payload_default_last_state: Dictionary = {}`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_payload_targeting_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_payload_targeting_last_state: Dictionary = {}`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_killable_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_killable_last_state: Dictionary = {}`.
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
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_power_graph_distribution_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_factory_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_enemy_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_playthrough_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_game_over_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.18s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_deconstruct_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.40s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_skip_range_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.40s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_load_persistence_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.40s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_slot_file_persistence_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.46s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_slot_listing_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.40s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_liquid_transfer_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_item_dump_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.46s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_liquid_leak_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_put_item_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.44s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_move_dump_payload_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_payload_default_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.45s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_payload_targeting_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_killable_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_player_controllable_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_player_controllable_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_player_controllable_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.41s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_sync_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_after_sync_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_sync_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.41s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_after_read_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.41s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_all_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_after_read_all_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_all_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.41s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_add_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_add_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_add_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_remove_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_remove_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_remove_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.41s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_landed_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_landed_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_landed_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_heal_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_heal_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_heal_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- Focused regression after deconstruct slice and rotation warning fix:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_deconstruct_runtime_proof -q -p no:cacheprovider`
  - Result: `2 passed in 0.42s`.
- Focused regression after builder skip/range slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_deconstruct_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_skip_range_runtime_proof -q -p no:cacheprovider`
  - Result: `3 passed in 0.24s`.
- Focused regression after runtime save/load persistence slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_deconstruct_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_skip_range_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_load_persistence_proof -q -p no:cacheprovider`
  - Result: `4 passed in 0.22s`.
- Focused regression after runtime save slot file slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_deconstruct_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_builder_skip_range_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_load_persistence_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_slot_file_persistence_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.26s`.
- Focused regression after runtime save slot listing slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_load_persistence_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_slot_file_persistence_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_slot_listing_proof -q -p no:cacheprovider`
  - Result: `3 passed in 0.20s`.
- Focused regression after liquid transfer runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_liquid_transfer_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_load_persistence_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_slot_file_persistence_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_slot_listing_proof -q -p no:cacheprovider`
  - Result: `4 passed in 0.24s`.
- Focused regression after item dump runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_item_dump_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_factory_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_liquid_transfer_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_runtime_save_load_persistence_proof -q -p no:cacheprovider`
  - Result: `4 passed in 0.26s`.
- Focused regression after liquid leak runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_liquid_leak_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_liquid_transfer_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_item_dump_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_factory_runtime_proof -q -p no:cacheprovider`
  - Result: `4 passed in 0.23s`.
- Focused regression after put item runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_put_item_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_item_dump_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_liquid_leak_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_factory_runtime_proof -q -p no:cacheprovider`
  - Result: `4 passed in 0.24s`.
- Focused regression after payload runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_move_dump_payload_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_move_payload_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_dump_payload_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_put_item_runtime_proof -q -p no:cacheprovider`
  - Result: `4 passed in 0.23s`.
- Focused regression after payload default runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_payload_default_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_building_get_payload_default_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_building_take_payload_default_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_building_get_payloads_default_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_move_dump_payload_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.26s`.
- Focused regression after unit payload targeting runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_payload_targeting_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_targetable_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_hittable_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_enemy_runtime_proof -q -p no:cacheprovider`
  - Result: `4 passed in 0.22s`.
- Focused regression after unit killable runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_killable_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_killable_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_payload_targeting_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_enemy_runtime_proof -q -p no:cacheprovider`
  - Result: `4 passed in 0.22s`.
- Focused regression after unit player-controllable runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_player_controllable_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_player_controllable_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_killable_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_payload_targeting_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_enemy_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.23s`.
- Focused regression after unit afterSync runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_sync_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_after_sync_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_player_controllable_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_killable_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_payload_targeting_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.25s`.
- Focused regression after unit afterRead runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_after_read_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_sync_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_player_controllable_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_killable_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.24s`.
- Focused regression after unit afterReadAll runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_all_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_after_read_all_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_sync_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_player_controllable_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.23s`.
- Focused regression after unit add runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_add_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_add_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_all_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_sync_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.25s`.
- Focused regression after unit remove runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_remove_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_remove_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_add_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_add_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_after_read_all_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.23s`.
- Focused regression after unit landed runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_landed_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_landed_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_remove_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_remove_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_add_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.25s`.
- Focused regression after unit heal runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_heal_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_heal_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_landed_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_landed_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_remove_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.26s`.
- Focused regression:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_uses_source_unit_weapon_damage_against_core tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_game_over_runtime_proof tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_audit_reports_whole_godot_source_surface tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_audit_report_file_matches_current_godot_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_game_over_core_destroyed_symbol_is_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `5 passed`.
- SSOT validator:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after builder queue slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after builder deconstruct slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after builder skip/range slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after runtime save/load persistence slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after runtime save slot file slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after runtime save slot listing slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after liquid transfer runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after item dump runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after liquid leak runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after put item runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after payload runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after payload default runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit payload targeting runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit killable runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit player-controllable runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit afterSync runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit afterRead runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit afterReadAll runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit add runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit remove runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit landed runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit heal runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4031 passed, 39300 subtests passed in 360.86s (0:06:00)`.
- Full Python suite after builder queue slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4032 passed, 39303 subtests passed in 381.43s (0:06:21)`.
- Full Python suite after builder deconstruct slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4033 passed, 39303 subtests passed in 390.26s (0:06:30)`.
- Full Python suite after builder skip/range slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4034 passed, 39303 subtests passed in 417.07s (0:06:57)`.
- Full Python suite after runtime save/load persistence slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4035 passed, 39303 subtests passed in 379.49s (0:06:19)`.
- Full Python suite after runtime save slot file slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4036 passed, 39303 subtests passed in 467.19s (0:07:47)`.
- Full Python suite after runtime save slot listing slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4037 passed, 39303 subtests passed in 411.54s (0:06:51)`.
- Full Python suite after liquid transfer runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4038 passed, 39303 subtests passed in 466.32s (0:07:46)`.
- Full Python suite after item dump runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4039 passed, 39303 subtests passed in 453.40s (0:07:33)`.
- Full Python suite after liquid leak runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4040 passed, 39303 subtests passed in 411.47s (0:06:51)`.
- Full Python suite after put item runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4041 passed, 39303 subtests passed in 399.13s (0:06:39)`.
- Full Python suite after payload runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4042 passed, 39303 subtests passed in 398.66s (0:06:38)`.
- Full Python suite after payload default runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4043 passed, 39303 subtests passed in 400.06s (0:06:40)`.
- Full Python suite after unit payload targeting runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4044 passed, 39303 subtests passed in 400.11s (0:06:40)`.
- Full Python suite after unit killable runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4045 passed, 39303 subtests passed in 404.86s (0:06:44)`.
- Full Python suite after unit player-controllable runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4046 passed, 39303 subtests passed in 401.80s (0:06:41)`.
- Full Python suite after unit afterSync runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4047 passed, 39303 subtests passed in 405.50s (0:06:45)`.
- Full Python suite after unit afterRead runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4048 passed, 39303 subtests passed in 373.46s (0:06:13)`.
- Full Python suite after unit afterReadAll runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4049 passed, 39303 subtests passed in 373.74s (0:06:13)`.
- Full Python suite after unit add runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4050 passed, 39303 subtests passed in 404.92s (0:06:44)`.
- Full Python suite after unit remove runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4051 passed, 39303 subtests passed in 389.17s (0:06:29)`.
- Full Python suite after unit landed runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4052 passed, 39303 subtests passed in 393.40s (0:06:33)`.
- Full Python suite after unit heal runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4053 passed, 39303 subtests passed in 406.26s (0:06:46)`.

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
- [x] PowerGraph distribution runtime loop proven: `coverage=0.555555555555556`, `first_consumer_power_status=0.555555555555556`, `power_needed=108.0`, `power_produced=60.0`.
- [x] Factory runtime loop proven: `drill_delay=650.0`, `conveyor_path_progress_rate=0.183333333333333`, `produced_total 2 -> 8`, `core_inventory 2 -> 8`.
- [x] Enemy runtime package proven: `selected_enemy_weapon_damage=9.0`, `selected_enemy_world_speed=30.0`, `selected_enemy_health=150.0`, `core_damage_taken_total=9.0`.
- [x] Playthrough runtime package proven: generated load failures `[]`, generated instance failures `[]`, content/world initialized, factory/enemy/power/turret/bullet/core telemetry visible through `playthrough_runtime`.
- [x] Game-over runtime package proven: core drained `1091.0 -> 0.0`, `game_over=true`, `last_game_over_winner="waveTeam"`, source proof references `Logic.checkGameState()`.
- [x] Builder construction queue runtime proven: `queue_builder_plan("conveyor", 2, 2, 0)`, `step_builder_runtime(5.0)`, `construct_progress=0.125`, `last_construct_block_id="conveyor"`, generated load/instance failures `[]`.
- [x] Builder deconstruct/removal runtime proven: `queue_builder_deconstruct_plan(8, 8)`, four `step_builder_deconstruct_runtime(40.0)` calls, progress `1.0 -> 0.0`, `last_deconstruct_removed=true`, refund `[{"amount":1,"item":"copper"}]`, occupied cells `22 -> 21`, generated load/instance failures `[]`.
- [x] Builder skip/range runtime proven: queued `router` with insufficient copper ahead of affordable `conveyor`, live `router.should_skip=true`, step rotated active plan to `conveyor`, source out-of-range `activelyBuilding=false`, generated load/instance failures `[]`.
- [x] Runtime save/load persistence proven: snapshot `header="MSAV"`, `version=13`, `core_items.copper=25`, builder plan count `1`, block count `12`, occupied cells `22`; mutated copper/plan state restored through `runtime_load_snapshot(snapshot)` with generated load/instance failures `[]`.
- [x] Runtime save slot file proven: `runtime_write_save_slot("proof-file-slot")` saved `user://runtime-save-slots/proof-file-slot.json`, then `runtime_load_save_slot("proof-file-slot")` restored copper `25`, builder plan count `1`, block count `12`, occupied cells `22`; generated load/instance failures `[]`.
- [x] Runtime save slot listing proven: `runtime_list_save_slots()` included `proof-list-a` and `proof-list-b`, skipped `proof-list-backup`, returned `valid=true`, `header="MSAV"`, `version=13`, and source-backed save-directory walk/meta expressions.
- [x] Liquid transfer runtime proven: `reset_liquid_transfer_runtime(8.0, 1.0)`, `step_liquid_transfer_runtime()`, `source_amount=0.999999999999999`, `destination_amount=8`, `move_flow=7`, `move_return=7`, `transfer_guard_passed=true`, `handle_liquid_called=true`, `remove_liquid_called=true`.
- [x] Item dump runtime proven: `reset_item_dump_runtime(3, 2, 10)`, `step_item_dump_runtime()`, source `3 -> 2`, core `2 -> 3`, `dumped=true`, `remove_removed=1`, `can_dump=true`, `move_forward_accept_state=true`.
- [x] Liquid leak runtime proven: `reset_liquid_leak_runtime(6.0)`, `step_liquid_leak_runtime()`, amount `6 -> 2`, `leak_amount=4`, `leak_guard_passed=true`, `puddles_deposit_called=true`, `remove_liquid_called=true`.
- [x] Put item runtime proven: `reset_put_item_runtime(0)`, `step_put_item_runtime()`, checked indices `[0, 1]`, `handled_index=1`, `handle_item_called=true`, `put=true`, `cdump=2`.
- [x] Payload move/dump runtime proven: `reset_payload_runtime(0)`, `step_payload_move_runtime(true, true, true, true)`, `step_payload_dump_runtime()`, `move_moved=true`, `move_forward_offset=1`, `dump_handled_index=1`, `dump_handle_payload_called=true`, `dump_cdump=2`.
- [x] Payload default runtime proven: `reset_payload_default_runtime()`, `step_payload_default_runtime()`, `get_payload_has_payload=false`, `take_payload_taken=false`, `get_payloads_has_payloads=false`, all default returns `"return null;"`.
- [x] Unit payload targeting runtime proven: `reset_unit_payload_targeting_runtime()`, `step_unit_payload_targeting_runtime()`, `targetable_payload_path=true`, `hittable_payload_path=true`, `targetable=true`, `hittable=true`.
- [x] Unit killable runtime proven: `reset_unit_killable_runtime()`, `step_unit_killable_runtime(true)`, `step_unit_killable_runtime(false)`, `true_killable=true`, `false_killable=false`, return expr `"return killable;"`.
- [x] Unit player-controllable runtime proven: `reset_unit_player_controllable_runtime()`, `step_unit_player_controllable_runtime(true, false, false, false)`, `step_unit_player_controllable_runtime(true, true, true, true)`, `base_controllable=true`, `blocked_controllable=false`, privileged LogicAI guard true, return expr `"return type.playerControllable && !(controller instanceof LogicAI ai && ai.controller != null && ai.controller.block.privileged);"`.
- [x] Unit afterSync runtime proven: `reset_unit_after_sync_runtime()`, `step_unit_after_sync_runtime(7, true)`, `call_order=["setType", "controller.unit"]`, `set_type_call="setType(this.type);"`, `controller_unit_call="controller.unit(self());"`.
- [x] Unit afterRead runtime proven: `reset_unit_after_read_runtime()`, `step_unit_after_read_runtime(9, false, false, true)`, `step_unit_after_read_runtime(9, true, true, true)`, recreate branch resets controller, keep-state branch skips reset, guard `"if(!(controller instanceof AIController ai && ai.keepState())){"`.
- [x] Unit afterReadAll runtime proven: `reset_unit_after_read_all_runtime()`, `step_unit_after_read_all_runtime(true)`, `controller.afterRead(self());`, `after_read_arg="self()"`.
- [x] Unit add runtime proven: `reset_unit_add_runtime()`, `step_unit_add_runtime(true, 6, 5, false, false, false)`, over-cap call order `["team.data().updateCount(+1)", "Call.unitCapDeath", "team.data().updateCount(-1)"]`, normal call order `["team.data().updateCount(+1)"]`, cap guard and rollback source strings exposed.
- [x] Unit remove runtime proven: `reset_unit_remove_runtime()`, `step_unit_remove_runtime(true, 3, 2.0, false, "blue", "green")`, `step_unit_remove_runtime(true, 0, 2.0, true, "blue", "green")`, trail branch calls `Fx.trailFade.at`, empty-trail branch skips fade, controller removal source string exposed.
- [x] Unit landed runtime proven: `reset_unit_landed_runtime()`, `step_unit_landed_runtime(3.0)`, `step_unit_landed_runtime(0.0)`, shake branch calls `Effect.shake`, no-shake branch skips it, `type.landed(self())` always exposed.
- [x] Unit heal runtime proven: `reset_unit_heal_runtime()`, `step_unit_heal_runtime(90.0, 100.0, 5.0, false)`, `step_unit_heal_runtime(100.0, 100.0, 5.0, false)`, `step_unit_heal_runtime(80.0, 100.0, -1.0, true)`, guard true sets `wasHealed`, full-health and negative-amount paths skip assignment.
- [ ] Full playable completion not claimed until broader playthrough audit closes remaining gameplay surfaces.

## Progress

- Source-slice migration: `100.00%`
- Playable audit: broader runtime still under audit, but playthrough runtime package, turret ammo/fire, placement-cost, builder construction queue, builder deconstruct/removal, builder skip/range, runtime save/load persistence, runtime save slot file, runtime save slot listing, enemy runtime, factory, item dump runtime, put item runtime, payload move/dump runtime, payload default runtime, unit payload targeting runtime, unit killable runtime, unit player-controllable runtime, unit afterSync runtime, unit afterRead runtime, unit afterReadAll runtime, unit add runtime, unit remove runtime, unit landed runtime, unit heal runtime, MendProjector heal, bullet-hit, overdrive boost, wave spawn, PowerGraph runtime, PowerGraph battery runtime, PowerGraph distribution runtime, liquid transfer runtime, liquid leak runtime, and game-over runtime paths now proven.
- Current blocker for completion claim: full playable coverage across remaining gameplay surfaces, not playthrough runtime package, bullet-hit, MendProjector heal, placement-cost, builder construction queue, builder deconstruct/removal, builder skip/range, runtime save/load persistence, runtime save slot file, runtime save slot listing, enemy runtime, factory, item dump runtime, payload move/dump runtime, payload default runtime, unit payload targeting runtime, unit killable runtime, unit player-controllable runtime, unit afterSync runtime, unit afterRead runtime, unit afterReadAll runtime, unit add runtime, unit remove runtime, unit landed runtime, unit heal runtime, turret ammo/fire, overdrive boost, wave spawn, PowerGraph runtime, PowerGraph battery runtime, PowerGraph distribution runtime, liquid transfer runtime, liquid leak runtime, or game-over runtime.
