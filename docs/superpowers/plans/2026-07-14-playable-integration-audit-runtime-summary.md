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

Thirty-seventh audit found `UnitComp.update()` healTime/wasHealed decay was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_heal_time_runtime`, `reset_unit_update_heal_time_runtime()`, and `step_unit_update_heal_time_runtime(...)` so MCP can prove the optional `healTime = 1f` reset, `healTime -= Time.delta / 20f` decay, and `wasHealed = false` reset after `updateDrowning();` from `core/src/mindustry/entities/comp/UnitComp.java`.

Thirty-eighth audit found `UnitComp.update()` captured-sector death was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_captured_sector_death_runtime`, `reset_unit_update_captured_sector_death_runtime()`, and `step_unit_update_captured_sector_death_runtime(...)` so MCP can prove the `team.isOnlyAI() && state.isCampaign() && state.getSector().isCaptured()` guard and `kill();` call from `core/src/mindustry/entities/comp/UnitComp.java`.

Thirty-ninth audit found `UnitComp.update()` loop/move sound state was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_sound_loop_runtime`, `reset_unit_update_sound_loop_runtime()`, and `step_unit_update_sound_loop_runtime(...)` so MCP can prove the `if(!headless)` guard, loop sound call, move sound guard, `Mathf.clamp(vel.len() / type.speed)` progress, `Mathf.lerp(...)` pitch, and move sound loop call from `core/src/mindustry/entities/comp/UnitComp.java`.

Fortieth audit found `UnitComp.update()` unsupported environment death was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_unsupported_env_runtime`, `reset_unit_update_unsupported_env_runtime()`, and `step_unit_update_unsupported_env_runtime(...)` so MCP can prove the `!type.supportsEnv(state.rules.env) && !dead` guard, `Call.unitEnvDeath(self())`, and `team.data().updateCount(type, -1)` rollback from `core/src/mindustry/entities/comp/UnitComp.java`.

Forty-first audit found `UnitComp.update()` ability dispatch was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_abilities_loop_runtime`, `reset_unit_update_abilities_loop_runtime()`, and `step_unit_update_abilities_loop_runtime(...)` so MCP can prove the ordered `for(Ability a : abilities)` dispatch, per-ability `a.update(self())` call records, and update count from `core/src/mindustry/entities/comp/UnitComp.java` without inventing concrete ability internals.

Forty-second audit found `UnitComp.update()` trail position state was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_trail_position_runtime`, `reset_unit_update_trail_position_runtime()`, and `step_unit_update_trail_position_runtime(...)` so MCP can prove the `trail != null` guard, `trail.length = type.trailLength`, engine-elevation scale, engine offset, `Angles.trnsx/trnsy(rotation + 180, offset)` position, and `trail.update(cx, cy)` call from `core/src/mindustry/entities/comp/UnitComp.java`.

Forty-third audit found `UnitComp.update()` drag assignment was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_drag_formula_runtime`, `reset_unit_update_drag_formula_runtime()`, and `step_unit_update_drag_formula_runtime(...)` so MCP can prove `type.drag * (isGrounded() ? floorOn().dragMultiplier : 1f) * dragMultiplier * state.rules.dragMultiplier` for grounded and non-grounded paths from `core/src/mindustry/entities/comp/UnitComp.java`.

Forty-fourth audit found `UnitComp.update()` spawn knockback was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_spawn_knockback_runtime`, `reset_unit_update_spawn_knockback_runtime()`, and `step_unit_update_spawn_knockback_runtime(...)` so MCP can prove the `team != state.rules.waveTeam && state.hasSpawns() && (!net.client() || isLocal()) && hittable()` guard, `relativeSize = state.rules.dropZoneRadius + hitSize/2f + 1f`, in-range spawn filtering, and `velAddNet(Tmp.v1.set(this).sub(spawn.worldx(), spawn.worldy()).setLength(0.1f + 1f - dst(spawn) / relativeSize).scl(0.45f * Time.delta))` knockback vector from `core/src/mindustry/entities/comp/UnitComp.java`.

Forty-fifth audit found `UnitComp.update()` falling drag was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_falling_drag_runtime`, `reset_unit_update_falling_drag_runtime()`, and `step_unit_update_falling_drag_runtime(...)` so MCP can prove the `dead || health <= 0` guard, `drag = 0.01f` assignment while falling/dead, and unchanged drag path while alive from `core/src/mindustry/entities/comp/UnitComp.java`.

Forty-sixth audit found `UnitComp.update()` falling smoke was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_falling_smoke_runtime`, `reset_unit_update_falling_smoke_runtime()`, and `step_unit_update_falling_smoke_runtime(...)` so MCP can prove the falling guard, `Mathf.chanceDelta(0.1)` branch, `Tmp.v1.rnd(Mathf.range(hitSize))`, and `type.fallEffect.at(x + Tmp.v1.x, y + Tmp.v1.y)` effect position from `core/src/mindustry/entities/comp/UnitComp.java`.

Forty-seventh audit found `UnitComp.update()` falling engine trail was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_falling_engine_trail_runtime`, `reset_unit_update_falling_engine_trail_runtime()`, and `step_unit_update_falling_engine_trail_runtime(...)` so MCP can prove the falling guard, `Mathf.chanceDelta(0.2)` branch, `type.engineOffset/2f + type.engineOffset/2f * elevation`, `Mathf.range(type.engineSize)`, `Angles.trnsx/trnsy(rotation + 180, offset)`, and `type.fallEngineEffect.at(...)` effect position/rotation from `core/src/mindustry/entities/comp/UnitComp.java`.

Forty-eighth audit found `UnitComp.update()` falling descent and destroy trigger were source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_falling_descent_runtime`, `reset_unit_update_falling_descent_runtime()`, and `step_unit_update_falling_descent_runtime(...)` so MCP can prove `elevation -= type.fallSpeed * Time.delta`, wreck-health threshold `-maxHealth * type.wreckHealthMultiplier`, grounded destroy, wreck-health destroy, and alive no-op paths from `core/src/mindustry/entities/comp/UnitComp.java`.

Forty-ninth audit found `UnitComp.update()` tile `unitOnAny` callback was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_tile_unit_on_any_runtime`, `reset_unit_update_tile_unit_on_any_runtime()`, and `step_unit_update_tile_unit_on_any_runtime(...)` so MCP can prove `if(tile != null && tile.build != null)` and `tile.build.unitOnAny(self())` callback state from `core/src/mindustry/entities/comp/UnitComp.java`.

Fiftieth audit found `UnitComp.update()` grounded tile `unitOn` callback was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_tile_unit_on_runtime`, `reset_unit_update_tile_unit_on_runtime()`, and `step_unit_update_tile_unit_on_runtime(...)` so MCP can prove `if(tile != null && isGrounded() && !type.hovering)`, `if(tile.build != null)`, and `tile.build.unitOn(self())` callback state from `core/src/mindustry/entities/comp/UnitComp.java`.

Fifty-first audit found `UnitComp.update()` grounded floor damage was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_floor_damage_runtime`, `reset_unit_update_floor_damage_runtime()`, and `step_unit_update_floor_damage_runtime(...)` so MCP can prove `if(tile != null && isGrounded() && !type.hovering)`, `if(floor.damageTaken > 0f)`, `damageContinuous(floor.damageTaken)`, `Time.delta` scaling, and the `hitTime <= -10 + hitDuration` effect gate from `core/src/mindustry/entities/comp/UnitComp.java`.

Fifty-second audit found `UnitComp.update()` solid-tile boost/kill response was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_solid_tile_response_runtime`, `reset_unit_update_solid_tile_response_runtime()`, and `step_unit_update_solid_tile_response_runtime(...)` so MCP can prove `if(tile != null && !canPassOn())`, `type.canBoost`, `elevation = 1f`, `!net.client() && !(!headless && isRemote())`, and `kill()` branch state from `core/src/mindustry/entities/comp/UnitComp.java`.

Fifty-third audit found `UnitComp.update()` AI controller server gate was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_ai_controller_runtime`, `reset_unit_update_ai_controller_runtime()`, and `step_unit_update_ai_controller_runtime(...)` so MCP can prove `if(!net.client() && !dead && shouldUpdateController())`, `controller.updateUnit();`, `shouldUpdateController()` default `return true;`, and `Net.client()` source method state from `core/src/mindustry/entities/comp/UnitComp.java`.

Fifty-fourth audit found `UnitComp.update()` invalid controller reset was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_invalid_controller_reset_runtime`, `reset_unit_update_invalid_controller_reset_runtime()`, and `step_unit_update_invalid_controller_reset_runtime(...)` so MCP can prove `if(!controller.isValidController())`, `resetController();`, `controller(type.createController(self()));`, `UnitController.isValidController()` default `return true;`, and `UnitType.createController(Unit unit)` return state from `core/src/mindustry/entities/comp/UnitComp.java`, `core/src/mindustry/entities/units/UnitController.java`, and `core/src/mindustry/type/UnitType.java`.

Fifty-fifth audit found `UnitComp.update()` spawned-core despawn was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_update_spawned_core_despawn_runtime`, `reset_unit_update_spawned_core_despawn_runtime()`, and `step_unit_update_spawned_core_despawn_runtime(...)` so MCP can prove `if(spawnedByCore && !isPlayer() && !dead)`, `Call.unitDespawn(self());`, `Fx.unitDespawn.at(unit.x, unit.y, 0, unit);`, and `unit.remove();` state from `core/src/mindustry/entities/comp/UnitComp.java`, `core/src/mindustry/entities/Units.java`, and `core/src/mindustry/content/Fx.java`.

Fifty-sixth audit found `UnitComp.icon()` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_icon_runtime`, `reset_unit_icon_runtime()`, and `step_unit_icon_runtime(...)` so MCP can prove `icon()`, `return type.uiIcon;`, the returned `type.uiIcon` value, and the `UnlockableContent.uiIcon` source field/load boundary from `core/src/mindustry/entities/comp/UnitComp.java` and `core/src/mindustry/ctype/UnlockableContent.java`.

Fifty-seventh audit found `UnitComp.destroy()` initial payload guard and formulas were source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_initial_payload_runtime`, `reset_unit_destroy_initial_payload_runtime()`, and `step_unit_destroy_initial_payload_runtime(...)` so MCP can prove `if(!isAdded() || !killable()) return;`, active explosiveness/flammability/power formulas, and guard-return null payload fields from `core/src/mindustry/entities/comp/UnitComp.java`.

Fifty-eighth audit found `UnitComp.destroy()` explosion dispatch was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_explosion_dispatch_runtime`, `reset_unit_destroy_explosion_dispatch_runtime()`, and `step_unit_destroy_explosion_dispatch_runtime(...)` so MCP can prove the `if(!spawnedByCore)` dynamic explosion call arguments, the `damage` and `fire` guards, and the spawned-core `type.deathExplosionEffect.at(...)` branch from `core/src/mindustry/entities/comp/UnitComp.java`.

Fifty-ninth audit found `UnitComp.destroy()` visual effects were source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_visual_effects_runtime`, `reset_unit_destroy_visual_effects_runtime()`, and `step_unit_destroy_visual_effects_runtime(...)` so MCP can prove `float shake = type.deathShake < 0 ? 3f + hitSize / 3f : type.deathShake;`, optional `Effect.scorch(...)`, and `Effect.shake(shake, shake, this);` from `core/src/mindustry/entities/comp/UnitComp.java`.

Sixtieth audit found `UnitComp.destroy()` death sound and destroy event were source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_sound_and_event_runtime`, `reset_unit_destroy_sound_and_event_runtime()`, and `step_unit_destroy_sound_and_event_runtime(...)` so MCP can prove `type.deathSound.at(this, 1f, type.deathSoundVolume);` and `Events.fire(new UnitDestroyEvent(self()));` from `core/src/mindustry/entities/comp/UnitComp.java`.

Sixty-first audit found `UnitComp.destroy()` suicide bomb trigger was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_suicide_bomb_trigger_runtime`, `reset_unit_destroy_suicide_bomb_trigger_runtime()`, and `step_unit_destroy_suicide_bomb_trigger_runtime(...)` so MCP can prove the `if(explosiveness > 7f && (isLocal() || wasPlayer)){` guard and `Events.fire(Trigger.suicideBomb);` event from `core/src/mindustry/entities/comp/UnitComp.java`.

Sixty-second audit found `UnitComp.destroy()` shoot-on-death mounts were source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_shoot_on_death_mounts_runtime`, `reset_unit_destroy_shoot_on_death_mounts_runtime()`, and `step_unit_destroy_shoot_on_death_mounts_runtime(...)` so MCP can prove the `for(WeaponMount mount : mounts){` loop, `if(mount.weapon.shootOnDeath && !(mount.weapon.bullet.killShooter && mount.totalShots > 0)){` guard, optional `shootOnDeathEffect.at(x, y, rotation)` effect branch, `mount.reload = 0f;`, `mount.shoot = true;`, and `mount.weapon.update(self(), mount);` from `core/src/mindustry/entities/comp/UnitComp.java`.

Sixty-third audit found `UnitComp.destroy()` crash landing damage was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_crash_landing_damage_runtime`, `reset_unit_destroy_crash_landing_damage_runtime()`, and `step_unit_destroy_crash_landing_damage_runtime(...)` so MCP can prove the `if(type.flying && !spawnedByCore && type.createWreck && state.rules.unitCrashDamage(team) > 0){` guard, shield lookup/absorb guard, crash damage formula, damage radius formula, and `Damage.damage(team, x, y, Mathf.pow(hitSize, 0.94f) * 1.25f, crashDamage, true, false, true);` call from `core/src/mindustry/entities/comp/UnitComp.java`.

Sixty-fourth audit found `UnitComp.destroy()` wreck decals were source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_wreck_decal_runtime`, `reset_unit_destroy_wreck_decal_runtime()`, and `step_unit_destroy_wreck_decal_runtime(...)` so MCP can prove the `if(!headless && type.createScorch){` guard, `for(int i = 0; i < type.wreckRegions.length; i++){` loop, `if(type.wreckRegions[i].found()){` found guard, `float range = type.hitSize /4f;`, `Tmp.v1.rnd(range);`, and `Effect.decal(type.wreckRegions[i], x + Tmp.v1.x, y + Tmp.v1.y, rotation - 90);` call from `core/src/mindustry/entities/comp/UnitComp.java`.

Sixty-fifth audit found `UnitComp.destroy()` ability death dispatch was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_ability_death_runtime`, `reset_unit_destroy_ability_death_runtime()`, and `step_unit_destroy_ability_death_runtime(...)` so MCP can prove the `for(Ability a : abilities){` loop and ordered `a.death(self());` dispatch from `core/src/mindustry/entities/comp/UnitComp.java`, with the default `public void death(Unit unit){}` hook from `core/src/mindustry/entities/abilities/Ability.java`.

Sixty-sixth audit found `UnitComp.destroy()` type killed/remove tail was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_destroy_type_killed_remove_runtime`, `reset_unit_destroy_type_killed_remove_runtime()`, and `step_unit_destroy_type_killed_remove_runtime(...)` so MCP can prove `type.killed(self());` runs before `remove();` from `core/src/mindustry/entities/comp/UnitComp.java`, with the default `public void killed(Unit unit){}` hook from `core/src/mindustry/type/UnitType.java`, `public void remove(){` boundary from `UnitComp.remove()`, and `<T extends Entityc> T self(){` from `core/src/mindustry/entities/comp/EntityComp.java`.

Sixty-seventh audit found `UnitComp.killed()` was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_killed_runtime`, `reset_unit_killed_runtime()`, and `step_unit_killed_runtime(...)` so MCP can prove `wasPlayer = isLocal();`, `health = Math.min(health, 0);`, `dead = true;`, the `if(!type.flying || !type.createWreck){ destroy(); }else{ type.wreckSound.at(this, 1f, type.wreckSoundVolume); }` branch from `core/src/mindustry/entities/comp/UnitComp.java`, with `boolean isLocal(){` from `core/src/mindustry/entities/comp/EntityComp.java` and `createWreck`, `wreckSound`, and `wreckSoundVolume` defaults from `core/src/mindustry/type/UnitType.java`.

Sixty-eighth audit found `UnitComp.kill()` death sync was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `unit_kill_sync_runtime`, `reset_unit_kill_sync_runtime()`, and `step_unit_kill_sync_runtime(...)` so MCP can prove the `if(dead || net.client() || !killable()) return;` guard, `Call.unitDeath(id);` dispatch, and the remote server bridge `@Remote(called = Loc.server)`, `Groups.unit.getByID(uid)`, `netClient.addRemovedEntity(uid)`, and `unit.killed();` from `core/src/mindustry/entities/comp/UnitComp.java` and `core/src/mindustry/entities/Units.java`.

Sixty-ninth audit found `WeaponsComp.setupWeapons(UnitType def)` mount construction was source-backed and statically tested, but not visible as a runtime proof package. Runtime now exposes `weapons_setup_mounts_runtime`, `reset_weapons_setup_mounts_runtime()`, and `step_weapons_setup_mounts_runtime(...)` so MCP can prove `mounts = new WeaponMount[def.weapons.size];`, `for(int i = 0; i < mounts.length; i++){`, `mounts[i] = def.weapons.get(i).mountType.get(def.weapons.get(i));`, and `WeaponMount(Weapon weapon)` rotation assignment `this.rotation = weapon.baseRotation;` from `core/src/mindustry/entities/comp/WeaponsComp.java` and `core/src/mindustry/entities/units/WeaponMount.java`.

Seventieth audit found `WeaponsComp.setWeaponRotation(float rotation)` was source-backed and statically tested, but not exposed through a playable runtime proof package. Runtime now exposes `weapons_set_rotation_runtime`, `reset_weapons_set_rotation_runtime()`, and `step_weapons_set_rotation_runtime(...)` so MCP can prove the exact `void setWeaponRotation(float rotation){`, `for(WeaponMount mount : mounts){`, and `mount.rotation = rotation;` behavior from `core/src/mindustry/entities/comp/WeaponsComp.java` over empty and active mount arrays.

Seventy-first audit found `WeaponsComp.controlWeapons(...)` pair and `rotateShoot` overload behavior was source-backed and statically tested, but not exposed through a playable runtime proof package. Runtime now exposes `weapons_control_runtime`, `reset_weapons_control_runtime()`, `step_weapons_control_runtime(...)`, and `step_weapons_control_rotate_shoot_runtime(...)` so MCP can prove `controlWeapons(rotateShoot, rotateShoot);`, `if(mount.weapon.controllable){`, `mount.rotate = rotate;`, `mount.shoot = shoot;`, `isRotate = rotate;`, and `isShooting = shoot;` from `core/src/mindustry/entities/comp/WeaponsComp.java`, including a non-controllable mount preserving previous rotate/shoot state.

Seventy-second audit found `WeaponsComp.aim(float x, float y)` and `aim(Position pos)` were source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapons_aim_runtime`, `reset_weapons_aim_runtime()`, `step_weapons_aim_runtime(...)`, and `step_weapons_aim_position_runtime(...)` so MCP can prove `Tmp.v1.set(x, y).sub(this.x, this.y);`, `if(Tmp.v1.len() < type.aimDst) Tmp.v1.setLength(type.aimDst);`, mount `aimX/aimY` assignment guarded by `mount.weapon.controllable`, top-level `aimX/aimY` output, and `aim(pos.getX(), pos.getY());` from `core/src/mindustry/entities/comp/WeaponsComp.java`.

Seventy-third audit found `WeaponsComp.canShoot()` was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapons_can_shoot_runtime`, `reset_weapons_can_shoot_runtime()`, and `step_weapons_can_shoot_runtime(...)` so MCP can prove `boolean canShoot(){`, `return !disarmed;`, `disarmed=false -> can_shoot=true`, `disarmed=true -> can_shoot=false`, and runtime summary exposure from `core/src/mindustry/entities/comp/WeaponsComp.java`.

Seventy-fourth audit found `WeaponsComp.remove()` continuous bullet cleanup was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapons_remove_continuous_bullet_cleanup_runtime`, `reset_weapons_remove_continuous_bullet_cleanup_runtime()`, and `step_weapons_remove_continuous_bullet_cleanup_runtime(...)` so MCP can prove `if(mount.weapon.continuous && mount.bullet != null && mount.bullet.owner == self()){`, `mount.bullet.time = mount.bullet.lifetime - 10f;`, and `mount.bullet = null;` from `core/src/mindustry/entities/comp/WeaponsComp.java`, including non-continuous, owner-mismatch, and no-bullet guard paths.

Seventy-fifth audit found `WeaponsComp.remove()` sound shutdown was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapons_remove_sound_stop_runtime`, `reset_weapons_remove_sound_stop_runtime()`, and `step_weapons_remove_sound_stop_runtime(...)` so MCP can prove `if(mount.sound != null){`, `mount.sound.stop();`, and `SoundLoop.stop()` effects `Core.audio.stop(id);`, `id = -1;`, and `volume = 0f;` from `core/src/mindustry/entities/comp/WeaponsComp.java`, including a no-sound mount preserving `stopCall=null`.

Seventy-sixth audit found `WeaponsComp.update()` dispatch was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapons_update_dispatch_runtime`, `reset_weapons_update_dispatch_runtime()`, and `step_weapons_update_dispatch_runtime(...)` so MCP can prove `/** Update shooting and rotation for this unit. */`, `@Override public void update(){`, `for(WeaponMount mount : mounts){`, and `mount.weapon.update(self(), mount);` from `core/src/mindustry/entities/comp/WeaponsComp.java`, including ordered dispatches over each mount with `unitArg="self()"` and `mountArg="mount"`.

Seventy-seventh audit found `Weapon.update(Unit unit, WeaponMount mount)` passive timers and warmup were source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_passive_timers_runtime`, `reset_weapon_update_passive_timers_runtime()`, and `step_weapon_update_passive_timers_runtime(...)` so MCP can prove `boolean can = unit.canShoot();`, reload decay, recoil/recoils approach, smooth reload lerp, charge update, and linear warmup from `core/src/mindustry/type/Weapon.java` with explicit `Time.delta` and `unit.reloadMultiplier` inputs.

Seventy-eighth audit found `Weapon.update(Unit unit, WeaponMount mount)` mount origin math was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_mount_origin_runtime`, `reset_weapon_update_mount_origin_runtime()`, and `step_weapon_update_mount_origin_runtime(...)` so MCP can prove `mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),` and `mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);` from `core/src/mindustry/type/Weapon.java`, using the source-backed Arc `Angles.trnsx/trnsy(float angle, float x, float y)` Vec2 rotation formulas.

Seventy-ninth audit found `Weapon.update(Unit unit, WeaponMount mount)` auto-target retarget state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_auto_target_retarget_runtime`, `reset_weapon_update_auto_target_retarget_runtime()`, and `step_weapon_update_auto_target_retarget_runtime(...)` so MCP can prove `if(!controllable && autoTarget){`, `if((mount.retarget -= Time.delta) <= 0f){`, `mount.target = findTarget(unit, mountX, mountY, bullet.range, bullet.collidesAir, bullet.collidesGround);`, and `mount.retarget = mount.target == null ? targetInterval : targetSwitchInterval;` from `core/src/mindustry/type/Weapon.java` with explicit `find_target_result_exists` input instead of invented target search internals.

Eightieth audit found `Weapon.update(Unit unit, WeaponMount mount)` auto-target invalidation state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_auto_target_invalidation_runtime`, `reset_weapon_update_auto_target_invalidation_runtime()`, and `step_weapon_update_auto_target_invalidation_runtime(...)` so MCP can prove `if(mount.target != null && checkTarget(unit, mount.target, mountX, mountY, bullet.range)){` and `mount.target = null;` from `core/src/mindustry/type/Weapon.java`, with `checkTarget(...)` source-backed to `Units.invalidateTarget(target, unit.team, x, y, range + Math.abs(shootY))`.

Eighty-first audit found `Weapon.update(Unit unit, WeaponMount mount)` auto-target shoot/aim state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_auto_target_shoot_aim_runtime`, `reset_weapon_update_auto_target_shoot_aim_runtime()`, and `step_weapon_update_auto_target_shoot_aim_runtime(...)` so MCP can prove `boolean shoot = false;`, `shoot = mount.target.within(...) && can;`, `Vec2 to = Predict.intercept(unit, mount.target, bullet);`, `mount.aimX = to.x;`, and `mount.shoot = mount.rotate = shoot;` from `core/src/mindustry/type/Weapon.java`, with explicit `target_within_result` and `predicted_aim` inputs instead of invented target physics.

Eighty-second audit found `Weapon.update(Unit unit, WeaponMount mount)` rotate-toward state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_rotate_toward_runtime`, `reset_weapon_update_rotate_toward_runtime()`, and `step_weapon_update_rotate_toward_runtime(...)` so MCP can prove `if(rotate && (mount.rotate || mount.shoot) && can){`, axis coordinates from `Angles.trnsx/trnsy`, `mount.rotation = Angles.moveToward(...)`, and the `else if(!rotate)` branch from `core/src/mindustry/type/Weapon.java`, with explicit `source_delta` instead of invented frame timing.

Eighty-third audit found `Weapon.update(Unit unit, WeaponMount mount)` bullet origin and shoot-angle state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_bullet_origin_runtime`, `reset_weapon_update_bullet_origin_runtime()`, and `step_weapon_update_bullet_origin_runtime(...)` so MCP can prove `weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),`, `bulletX = mountX + Angles.trnsx(...)`, `bulletY = mountY + Angles.trnsy(...)`, and `shootAngle = bulletRotation(unit, mount, bulletX, bulletY);` from `core/src/mindustry/type/Weapon.java`, including both rotate and non-rotate `bulletRotation(...)` branches.

Eighty-fourth audit found `Weapon.update(Unit unit, WeaponMount mount)` always-shooting assignment state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_always_shooting_runtime`, `reset_weapon_update_always_shooting_runtime()`, and `step_weapon_update_always_shooting_runtime(...)` so MCP can prove `if(alwaysShooting) mount.shoot = true;` from `core/src/mindustry/type/Weapon.java`, including the disabled branch that preserves `mount.shoot=false` and the deferred `if(continuous && mount.bullet != null){` boundary for the next continuous-state slice.

Eighty-fifth audit found `Weapon.update(Unit unit, WeaponMount mount)` continuous bullet invalidation state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_continuous_invalidation_runtime`, `reset_weapon_update_continuous_invalidation_runtime()`, and `step_weapon_update_continuous_invalidation_runtime(...)` so MCP can prove `if(continuous && mount.bullet != null){`, `if(!mount.bullet.isAdded() || mount.bullet.time >= mount.bullet.lifetime || mount.bullet.type != bullet){`, and `mount.bullet = null;` from `core/src/mindustry/type/Weapon.java`, including invalid, expired, live, and no-bullet guard-false branches.

Eighty-sixth audit found `Weapon.update(Unit unit, WeaponMount mount)` continuous live bullet transform/reload/recoil state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_continuous_live_runtime`, `reset_weapon_update_continuous_live_runtime()`, and `step_weapon_update_continuous_live_runtime(...)` so MCP can prove `mount.bullet.rotation(weaponRotation + 90);`, `mount.bullet.set(bulletX, bulletY);`, `mount.reload = reload;`, `mount.recoil = 1f;`, and `unit.vel.add(Tmp.v1.trns(mount.bullet.rotation() + 180f, mount.bullet.type.recoil * Time.delta));` from `core/src/mindustry/type/Weapon.java`, with the sound branch deferred at `if(shootSound != Sounds.none && !headless){`.

Eighty-seventh audit found `Weapon.update(Unit unit, WeaponMount mount)` continuous sound loop state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_continuous_sound_runtime`, `reset_weapon_update_continuous_sound_runtime()`, and `step_weapon_update_continuous_sound_runtime(...)` so MCP/TCP can prove `if(shootSound != Sounds.none && !headless){`, `if(mount.sound == null) mount.sound = new SoundLoop(shootSound, 1f);`, and `mount.sound.update(bulletX, bulletY, true);` from `core/src/mindustry/type/Weapon.java`, including live create/update, existing-sound update, and headless gate-false branches, with the laser-length branch deferred at `//target length of laser`.

Eighty-eighth audit found `Weapon.update(Unit unit, WeaponMount mount)` continuous laser aim length/endpoint state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_continuous_laser_aim_runtime`, `reset_weapon_update_continuous_laser_aim_runtime()`, and `step_weapon_update_continuous_laser_aim_runtime(...)` so MCP/TCP can prove `float shootLength = Math.min(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY), range());`, `float curLength = Mathf.dst(bulletX, bulletY, mount.bullet.aimX, mount.bullet.aimY);`, `float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);`, `Tmp.v1.trns(shootAngle, mount.lastLength = resultLength).add(bulletX, bulletY);`, `mount.bullet.aimX = Tmp.v1.x;`, and `mount.bullet.aimY = Tmp.v1.y;` from `core/src/mindustry/type/Weapon.java`, including live endpoint update and invalid branch preservation, with the always-continuous branch deferred at `if(alwaysContinuous && mount.shoot){`.

Eighty-ninth audit found `Weapon.update(Unit unit, WeaponMount mount)` always-continuous keepalive/time/status state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_always_continuous_keepalive_runtime`, `reset_weapon_update_always_continuous_keepalive_runtime()`, and `step_weapon_update_always_continuous_keepalive_runtime(...)` so MCP/TCP can prove `if(alwaysContinuous && mount.shoot){`, `mount.bullet.time = mount.bullet.lifetime * mount.bullet.type.optimalLifeFract * mount.warmup;`, `mount.bullet.keepAlive = true;`, and `unit.apply(shootStatus, shootStatusDuration);` from `core/src/mindustry/type/Weapon.java`, including active keepalive, immune status-apply guard, and mount-shoot gate-false branches.

Ninetieth audit found `Weapon.update(Unit unit, WeaponMount mount)` continuous idle heat decay and sound-stop state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_continuous_idle_heat_sound_runtime`, `reset_weapon_update_continuous_idle_heat_sound_runtime()`, and `step_weapon_update_continuous_idle_heat_sound_runtime(...)` so MCP/TCP can prove `//heat decreases when not firing`, `mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0);`, `if(mount.sound != null){`, and `mount.sound.update(bulletX, bulletY, false);` from `core/src/mindustry/type/Weapon.java`, including idle heat decay, heat clamp, sound false update, and continuous-live no-op branches.

Ninety-first audit found `Weapon.update(Unit unit, WeaponMount mount)` alternating weapon side-flip state was source-backed and statically tested, but not visible as a playable runtime proof package. Runtime now exposes `weapon_update_alternating_side_flip_runtime`, `reset_weapon_update_alternating_side_flip_runtime()`, and `step_weapon_update_alternating_side_flip_runtime(...)` so MCP/TCP can prove `boolean wasFlipped = mount.side;`, `if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f){`, `unit.mounts[otherSide].side = !unit.mounts[otherSide].side;`, `mount.side = !mount.side;`, and the following `(!alternate || wasFlipped == flipSprite) &&` gate from `core/src/mindustry/type/Weapon.java`, including active flip and half-reload guard-false branches.

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
- Added RED test that requires a source-backed unit update healTime runtime proof package.
- Added `unit_update_heal_time_last_state`, `reset_unit_update_heal_time_runtime()`, `step_unit_update_heal_time_runtime(...)`, `unit_update_heal_time_runtime_state()`, and `"unit_update_heal_time_runtime": unit_update_heal_time_runtime_state()` to runtime summary. The wrapper packages `source_unit_update_heal_time_state(...)` and exposes the canonical order from `source_unit_update_heal_time_result.order`.
- Added RED test that requires a source-backed unit update captured-sector death runtime proof package.
- Added `unit_update_captured_sector_death_last_state`, `reset_unit_update_captured_sector_death_runtime()`, `step_unit_update_captured_sector_death_runtime(...)`, `unit_update_captured_sector_death_runtime_state()`, and `"unit_update_captured_sector_death_runtime": unit_update_captured_sector_death_runtime_state()` to runtime summary. The wrapper packages `source_unit_update_captured_sector_death_state(...)` and exposes the canonical guard plus `kill()` call.
- Added RED test that requires a source-backed unit update loop/move sound runtime proof package.
- Added `unit_update_sound_loop_last_state`, `reset_unit_update_sound_loop_runtime()`, `step_unit_update_sound_loop_runtime(...)`, `unit_update_sound_loop_runtime_state()`, and `"unit_update_sound_loop_runtime": unit_update_sound_loop_runtime_state()` to runtime summary. The wrapper packages `source_unit_update_sound_loop_state(...)` and exposes the canonical loop/move sound call records.

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
- TCP unit update healTime proof:
  - `reset_empty=true`
  - `reset_then_decay_healTime=0.95`
  - `reset_then_decay_reset=true`
  - `reset_then_decay_wasHealed=false`
  - `reset_then_decay_order=["updateDrowning","healTime gate","healTime decay","wasHealed reset"]`
  - `healed_no_reset_healTime=0.4`
  - `healed_no_reset_reset=false`
  - `not_healed_healTime=-2.25`
  - `not_healed_reset=false`
  - `summary_has_unit_update_heal_time_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update captured-sector death proof:
  - `reset_empty=true`
  - `all_true_kill=true`
  - `all_true_call="kill()"`
  - `all_true_guard={"state.getSector().isCaptured()":true,"state.isCampaign()":true,"team.isOnlyAI()":true}`
  - `team_false_kill=false`
  - `team_false_call=""`
  - `campaign_false_kill=false`
  - `campaign_false_call=""`
  - `sector_false_kill=false`
  - `sector_false_call=""`
  - `summary_has_unit_update_captured_sector_death_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update sound loop proof:
  - `reset_empty=true`
  - `headless_sound_enabled=false`
  - `headless_loop=null`
  - `headless_move=null`
  - `loop_only_loop_call="control.sound.loop(type.loopSound, this, type.loopSoundVolume)"`
  - `loop_only_move=null`
  - `move_progress=0.5`
  - `move_pitch=1.0`
  - `move_volume=1.0`
  - `zero_speed_progress=1.0`
  - `zero_speed_pitch=1.2`
  - `summary_has_unit_update_sound_loop_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update unsupported-env proof:
  - `reset_empty=true`
  - `supported_alive_envDeath=false`
  - `supported_alive_callOrder=[]`
  - `supported_alive_unitEnvDeath=null`
  - `unsupported_alive_envDeath=true`
  - `unsupported_alive_callOrder=["Call.unitEnvDeath(self())","team.data().updateCount(type, -1)"]`
  - `unsupported_alive_unitEnvDeath="Call.unitEnvDeath(self())"`
  - `unsupported_alive_updateCountAmount=-1`
  - `unsupported_dead_envDeath=false`
  - `unsupported_dead_callOrder=[]`
  - `summary_has_unit_update_unsupported_env_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update abilities-loop proof:
  - `ping_type="pong"`
  - `reset_empty=true`
  - `empty_update_count=0`
  - `empty_updates=[]`
  - `three_update_count=3`
  - `three_update_abilities=["shield","repair","boost"]`
  - `three_update_calls=["a.update(self());","a.update(self());","a.update(self());"]`
  - `three_update_call="a.update(self());"`
  - `three_loop="for(Ability a : abilities){"`
  - `three_ability_update_method="public void update(Unit unit){}"`
  - `summary_has_unit_update_abilities_loop_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update trail-position proof:
  - `reset_empty=true`
  - `null_trail_exists=false`
  - `null_trail_update=null`
  - `null_length_set=null`
  - `active_scale=0.5`
  - `active_offset=4.5`
  - `active_position={"x":5.5,"y":20.0}`
  - `active_trail_update={"call":"trail.update(cx, cy)","x":5.5,"y":20.0}`
  - `active_length_set={"call":"trail.length = type.trailLength","length":7}`
  - `flat_scale=1.0`
  - `flat_offset=8.0`
  - `flat_position={"x":5.0,"y":-2.0}`
  - `summary_has_unit_update_trail_position_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update drag-formula proof:
  - `reset_empty=true`
  - `grounded_drag=0.9`
  - `grounded_floor_factor=0.5`
  - `grounded_formula="type.drag * (isGrounded() ? floorOn().dragMultiplier : 1f) * dragMultiplier * state.rules.dragMultiplier"`
  - `grounded_inputs={"dragMultiplier":2.0,"floorOn().dragMultiplier":0.5,"state.rules.dragMultiplier":3.0,"type.drag":0.3}`
  - `air_drag=1.8`
  - `air_floor_factor=1.0`
  - `defaults_drag=0.3`
  - `defaults_floor_factor=1.0`
  - `summary_has_unit_update_drag_formula_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update spawn-knockback proof:
  - `initial_summary_has_spawn_knockback=true`
  - `reset_empty=true`
  - `active_guard=true`
  - `active_relative_size=10.0`
  - `active_knockback_count=1`
  - `active_first_distance=5.0`
  - `active_first_strength=0.6`
  - `active_first_velocity_x=0.54`
  - `active_first_velocity_y=0.0`
  - `wave_team_guard=false`
  - `wave_team_knockback_count=0`
  - `client_nonlocal_guard=false`
  - `client_nonlocal_knockback_count=0`
  - `summary_has_spawn_knockback=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update falling-drag proof:
  - `initial_summary_has_falling_drag=true`
  - `reset_empty=true`
  - `dead_guard=true`
  - `dead_drag=0.01`
  - `zero_health_guard=true`
  - `zero_health_drag=0.01`
  - `alive_guard=false`
  - `alive_drag=0.7`
  - `summary_has_falling_drag=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update falling-smoke proof:
  - `initial_summary_has_falling_smoke=true`
  - `reset_empty=true`
  - `active_falling_guard=true`
  - `active_effect_x=11.5`
  - `active_effect_y=18.0`
  - `active_tmp_x=1.5`
  - `active_tmp_y=-2.0`
  - `active_range_hit_size=6.0`
  - `no_chance_guard=true`
  - `no_chance_effect=null`
  - `alive_guard=false`
  - `alive_effect=null`
  - `summary_has_falling_smoke=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update falling-engine-trail proof:
  - `initial_summary_has_falling_engine_trail=true`
  - `reset_empty=true`
  - `active_falling_guard=true`
  - `active_angle=180.0`
  - `active_offset=3.75`
  - `active_effect_x=6.5`
  - `active_effect_y=19.25`
  - `active_effect_rotation=0.33`
  - `active_range_value=1.25`
  - `active_range_engine_size=2.5`
  - `active_x_range=0.25`
  - `active_y_range=-0.75`
  - `no_chance_guard=true`
  - `no_chance_effect=null`
  - `alive_guard=false`
  - `alive_effect=null`
  - `summary_has_falling_engine_trail=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update falling-descent proof:
  - `initial_summary_has_falling_descent=true`
  - `reset_empty=true`
  - `falling_guard=true`
  - `falling_elevation_before=1.0`
  - `falling_elevation=-0.0799999999999998`
  - `falling_destroy=null`
  - `falling_threshold=-25.0`
  - `grounded_destroy_id=42`
  - `grounded_elevation=0.82`
  - `wreck_destroy_id=99`
  - `wreck_threshold=-25.0`
  - `alive_guard=false`
  - `alive_elevation=1.0`
  - `alive_destroy=null`
  - `summary_has_falling_descent=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update tile-unitOnAny proof:
  - `initial_summary_has_tile_unit_on_any=true`
  - `reset_empty=true`
  - `active_guard=true`
  - `active_call="tile.build.unitOnAny(self())"`
  - `active_unit=77`
  - `active_tile_exists=true`
  - `active_tile_build_exists=true`
  - `no_tile_guard=false`
  - `no_tile_call=null`
  - `no_build_guard=false`
  - `no_build_call=null`
  - `summary_has_tile_unit_on_any=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update tile-unitOn proof:
  - `initial_summary_has_tile_unit_on=true`
  - `reset_empty=true`
  - `active_guard=true`
  - `active_call="tile.build.unitOn(self())"`
  - `active_unit=88`
  - `active_is_grounded=true`
  - `active_type_hovering=false`
  - `active_tile_build_exists=true`
  - `no_tile_guard=false`
  - `no_tile_call=null`
  - `flying_guard=false`
  - `flying_call=null`
  - `hovering_guard=false`
  - `hovering_call=null`
  - `no_build_guard=true`
  - `no_build_call=null`
  - `summary_has_tile_unit_on=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update floor-damage proof:
  - `reset_empty=true`
  - `active_guard=true`
  - `active_call="damageContinuous(floor.damageTaken)"`
  - `active_floor_damage_taken=3.5`
  - `active_time_delta=2.0`
  - `active_scaled_damage=7.0`
  - `active_with_effect=true`
  - `zero_damage_guard=true`
  - `zero_damage_call=null`
  - `missing_tile_guard=false`
  - `missing_tile_call=null`
  - `flying_guard=false`
  - `flying_call=null`
  - `hovering_guard=false`
  - `hovering_call=null`
  - `summary_has_floor_damage=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update solid-tile response proof:
  - `reset_empty=true`
  - `boost_guard=true`
  - `boost_elevation=1.0`
  - `boost_kill=null`
  - `kill_guard=true`
  - `kill_call="kill()"`
  - `kill_unit=102`
  - `passable_guard=false`
  - `passable_kill=null`
  - `no_tile_guard=false`
  - `no_tile_kill=null`
  - `client_guard=true`
  - `client_kill=null`
  - `remote_gui_guard=true`
  - `remote_gui_kill=null`
  - `summary_has_solid_tile_response=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update AI-controller proof:
  - `reset_empty=true`
  - `active_guard=true`
  - `active_call="controller.updateUnit();"`
  - `active_unit=201`
  - `client_guard=false`
  - `client_update=null`
  - `dead_guard=false`
  - `dead_update=null`
  - `should_update_false_guard=false`
  - `should_update_false_update=null`
  - `summary_has_ai_controller=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update invalid-controller reset proof:
  - `reset_empty=true`
  - `invalid_guard=true`
  - `invalid_call="resetController()"`
  - `invalid_effect="controller(type.createController(self()))"`
  - `invalid_unit=301`
  - `valid_guard=false`
  - `valid_reset=null`
  - `summary_has_invalid_controller_reset=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit update spawned-core despawn proof:
  - `reset_empty=true`
  - `active_guard=true`
  - `active_call="Call.unitDespawn(self())"`
  - `active_effect="Fx.unitDespawn.at(unit.x, unit.y, 0, unit)"`
  - `active_remove="unit.remove()"`
  - `active_unit=401`
  - `not_spawned_guard=false`
  - `not_spawned_despawn=null`
  - `player_guard=false`
  - `player_despawn=null`
  - `dead_guard=false`
  - `dead_despawn=null`
  - `summary_has_spawned_core_despawn=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit icon proof:
  - `reset_empty=true`
  - `call="icon()"`
  - `return="type.uiIcon"`
  - `ui_icon="alpha-ui"`
  - `summary_has_unit_icon=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy initial payload proof:
  - `reset_empty=true`
  - active `return_guard=false`, `is_added=true`, `killable=true`
  - active `explosiveness=11.18`
  - active `flammability=1.68421052631579`
  - active `power=186.357373834953`
  - not-added guard `return_guard=true`, `explosiveness=null`, `flammability=null`, `power=null`
  - not-killable guard `return_guard=true`, `explosiveness=null`, `flammability=null`, `power=null`
  - `source_guard="if(!isAdded() || !killable()) return;"`
  - `summary_has_unit_destroy_initial_payload=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy explosion dispatch proof:
  - `reset_empty=true`
  - dynamic branch `call="Damage.dynamicExplosion"`, `source_call="Damage.dynamicExplosion(x, y, flammability, explosiveness, power, (bounds() + type.legLength/1.7f) / 2f, state.rules.damageExplosions && state.rules.unitCrashDamage(team) > 0, item().flammability > 1, team, type.deathExplosionEffect, 0f);"`
  - dynamic branch `x=12`, `y=34`, `flammability=1.2`, `explosiveness=3.4`, `power=5.6`
  - dynamic branch `radius=10.9411764705882`, `damage=true`, `fire=true`, `team=7`, `explosion_fx="Fx.dynamicExplosion"`, `base_shake=0`
  - blocked dynamic branch `damage=false`, `fire=false`
  - spawned-core branch `call="type.deathExplosionEffect.at"`, `else_branch="}else{"`, `rotation=1`, `effect="Fx.dynamicExplosion"`
  - `summary_has_unit_destroy_explosion_dispatch=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy visual effects proof:
  - `reset_empty=true`
  - fallback branch `method="public void destroy(){"`
  - fallback branch `shake_formula="float shake = type.deathShake < 0 ? 3f + hitSize / 3f : type.deathShake;"`
  - fallback branch `shake=8`, `shake_effect.intensity=8`, `shake_effect.duration=8`, `shake_effect.unit=44`
  - fallback branch `scorch.call="Effect.scorch(x, y, (int)(hitSize / 5));"`, `scorch.size=3`, `scorch.x=10`, `scorch.y=20`
  - explicit branch `shake=2.5`, `shake_effect.intensity=2.5`, `shake_effect.duration=2.5`, `shake_effect.unit=45`
  - explicit branch `scorch=null`
  - `summary_has_unit_destroy_visual_effects=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy sound and event proof:
  - `reset_empty=true`
  - `sound_call.call="type.deathSound.at(this, 1f, type.deathSoundVolume);"`
  - `sound="unitExplode2"`, `pitch=1.0`, `volume=0.65`, `unit=51`
  - `event_call.event="Events.fire(new UnitDestroyEvent(self()));"`
  - `event_class="UnitDestroyEvent"`
  - `summary_has_unit_destroy_sound_and_event_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy suicide bomb trigger proof:
  - `reset_empty=true`
  - active branch `explosiveness=8.5`, `is_local=true`, `was_player=false`, `trigger=true`
  - active branch `event="Events.fire(Trigger.suicideBomb);"`
  - active branch `events_fire="public static <T extends Enum<T>> void fire(Enum<T> type){"`, `events_fire_body="items[i].get(type);"`
  - active branch `trigger_enum="public enum Trigger{"`, `trigger_member="suicideBomb,"`
  - below-threshold branch `explosiveness=7.0`, `is_local=true`, `was_player=true`, `trigger=false`, `event=""`
  - remote-not-player branch `explosiveness=8.5`, `is_local=false`, `was_player=false`, `trigger=false`, `event=""`
  - `summary_has_unit_destroy_suicide_bomb_trigger_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy shoot-on-death mounts proof:
  - `reset_empty=true`
  - mount `0`: `updateMount=true`, `effect.effect="Fx.spawn"`, `effect.x=12.5`, `effect.y=18.25`, `effect.rotation=90.0`
  - mount `0`: `allowShootEffects=false`, `effectCall="mount.weapon.shootOnDeathEffect.at(x, y, rotation);"`
  - mount `1`: `updateMount=false` for `bulletKillShooter=true` and `totalShots=2`
  - mount `2`: `updateMount=true`, `effect=null`, `reload=0.0`, `shoot=true`, `unit=61`
  - active mounts expose `reloadSource="mount.reload = 0f;"`, `shootSource="mount.shoot = true;"`, and `update="mount.weapon.update(self(), mount);"`
  - `summary_has_unit_destroy_shoot_on_death_mounts_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy crash landing damage proof:
  - `reset_empty=true`
  - active branch `should_check_crash=true`, `shield_lookup="var shields = indexer.getEnemy(team, BlockFlag.shield);"`
  - active branch `crash_damage=35.0`, `damage_radius=16.9349062472505`, `team=7`, `x=12.0`, `y=21.0`
  - active branch `damage_call.damageCall="Damage.damage(team, x, y, Mathf.pow(hitSize, 0.94f) * 1.25f, crashDamage, true, false, true);"`
  - active branch `complete=true`, `air=false`, `ground=true`
  - shield-absorbed branch `shield_absorbed=true`, `damage_call=null`
  - guard-false branch `should_check_crash=false`, `crash_damage=null`, `damage_radius=null`, `damage_call=null`
  - `summary_has_unit_destroy_crash_landing_damage_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy wreck decal proof:
  - `reset_empty=true`
  - active branch `should_create_decals=true`, `range=4.0`
  - active branch creates two decals for found regions `dagger-wreck0` and `dagger-wreck2`
  - active branch decal positions `(11.5,18.0)` and `(9.5,23.25)` from source position plus explicit `Tmp.v1` offsets
  - active branch `rotation=90.0` from `source_rotation_degrees - 90.0`
  - active branch exposes `random_call="Tmp.v1.rnd(range);"` and `decal_call="Effect.decal(type.wreckRegions[i], x + Tmp.v1.x, y + Tmp.v1.y, rotation - 90);"`
  - headless guard branch returns `should_create_decals=false`, `range=null`, `decals=[]`
  - no-scorch guard branch returns `should_create_decals=false`, `range=null`, `decals=[]`
  - `summary_has_unit_destroy_wreck_decal_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy ability death proof:
  - `reset_empty=true`
  - empty abilities branch returns `calls=[]`
  - active branch returns three calls in order for abilities `shield`, `repair`, and `boost`
  - each active call exposes `call="a.death(self());"`, `abilityDefault="public void death(Unit unit){}"`, and `unit=77`
  - `loop="for(Ability a : abilities){"`
  - `summary_has_unit_destroy_ability_death_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit destroy type killed/remove proof:
  - `reset_empty=true`
  - active branch `unit=77`
  - order index `0` call is `type.killed(self());` with `unitTypeDefault="public void killed(Unit unit){}"` and `selfMethod="<T extends Entityc> T self(){"`
  - order index `1` call is `remove();` with `unitRemoveOverride="public void remove(){"`
  - top-level fields expose `type_killed_call="type.killed(self());"` and `remove_call="remove();"`
  - `summary_has_unit_destroy_type_killed_remove_runtime=true`
  - `generated_load_failures=0`
  - `generated_instance_failures=0`
- TCP unit killed proof:
  - `reset_empty=true`
  - destroy branch `step_unit_killed_runtime(true, 12.0, false, true, "wreckSound", 0.8, 77)` returns `was_player=true`, `health=0.0`, `dead=true`, `destroy_called=true`, `destroy_call="destroy()"`, and `wreck_sound_call=null`
  - wreck branch `step_unit_killed_runtime(false, -5.0, true, true, "wreckSound", 0.8, 88)` returns `was_player=false`, `health=-5.0`, `dead=true`, `destroy_called=false`, and `wreck_sound_call.call="type.wreckSound.at(this, 1f, type.wreckSoundVolume)"`
  - wreck branch exposes `pitch=1.0`, `volume=0.8`, `sound="wreckSound"`, and `unit=88`
  - `summary_has_unit_killed_runtime=true`
- TCP unit kill sync proof:
  - `reset_empty=true`
  - active branch `step_unit_kill_sync_runtime(false, false, true, 91)` returns `should_return=false`, `dead=false`, `net_client=false`, `killable=true`, and `remote_call.call="Call.unitDeath(id)"`
  - active branch remote bridge exposes `remote="@Remote(called = Loc.server)"`, `serverLookup="Groups.unit.getByID(uid)"`, `serverHandler="unit.killed()"`, `removedEntity="netClient.addRemovedEntity(uid)"`, and `unit=91`
  - dead guard branch `step_unit_kill_sync_runtime(true, false, true, 92)` returns `should_return=true` and `remote_call=null`
  - net-client guard branch `step_unit_kill_sync_runtime(false, true, true, 93)` returns `should_return=true` and `remote_call=null`
  - not-killable guard branch `step_unit_kill_sync_runtime(false, false, false, 94)` returns `should_return=true` and `remote_call=null`
  - `summary_has_unit_kill_sync_runtime=true`
- TCP weapons setup mounts proof:
  - `reset_empty=true`
  - empty branch `step_weapons_setup_mounts_runtime([])` returns `mounts=[]`, `array="mounts = new WeaponMount[def.weapons.size];"`, and `loop="for(int i = 0; i < mounts.length; i++){"`
  - active branch with `cannon`, `left-laser`, and `right-laser` returns three mounts in input order
  - active branch mount records expose `call="mounts[i] = def.weapons.get(i).mountType.get(def.weapons.get(i));"` and `constructor="public WeaponMount(Weapon weapon){"`
  - active branch rotations are `0.0`, `-15.0`, and `15.0` from `Weapon.baseRotation`
  - `summary_has_weapons_setup_mounts_runtime=true`
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
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_heal_time_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_update_heal_time_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_heal_time_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_captured_sector_death_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_update_captured_sector_death_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_captured_sector_death_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.41s`.
- RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_sound_loop_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected on missing `var unit_update_sound_loop_last_state: Dictionary = {}`.
- GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_sound_loop_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 1.32s`.
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
- Focused regression after unit update healTime runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_heal_time_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_heal_time_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_heal_time_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_heal_time_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_heal_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.60s`.
- Focused regression after unit update captured-sector death runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_captured_sector_death_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_captured_sector_death_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_captured_sector_death_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_captured_sector_death_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_heal_time_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.61s`.
- Focused regression after unit update sound loop runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_sound_loop_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_sound_loop_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_sound_loop_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_sound_loop_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_captured_sector_death_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.58s`.
- Focused regression after unit update unsupported-env runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_unsupported_env_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_unsupported_env_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_unsupported_env_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_unsupported_env_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_sound_loop_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.57s`.
- Focused regression after unit update abilities-loop runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_abilities_loop_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_abilities_loop_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_abilities_loop_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_abilities_loop_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_unsupported_env_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.57s`.
- Focused regression after unit update trail-position runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_trail_position_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_trail_position_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_trail_position_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_trail_position_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_abilities_loop_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.62s`.
- Focused regression after unit update drag-formula runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_drag_formula_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_drag_formula_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_drag_formula_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_drag_formula_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_trail_position_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.58s`.
- Focused RED for unit update spawn-knockback runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_spawn_knockback_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_spawn_knockback_last_state: Dictionary = {}`.
- Focused GREEN for unit update spawn-knockback runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_spawn_knockback_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- Focused regression after unit update spawn-knockback runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_spawn_knockback_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_spawn_knockback_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_spawn_knockback_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_spawn_knockback_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_drag_formula_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.61s`.
- Focused RED for unit update falling-drag runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_drag_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_falling_drag_last_state: Dictionary = {}`.
- Focused GREEN for unit update falling-drag runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_drag_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- Focused regression after unit update falling-drag runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_drag_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_falling_drag_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_falling_drag_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_falling_drag_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_spawn_knockback_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.60s`.
- Focused RED for unit update falling-smoke runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_smoke_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_falling_smoke_last_state: Dictionary = {}`.
- Focused GREEN for unit update falling-smoke runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_smoke_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- Focused regression after unit update falling-smoke runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_smoke_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_falling_smoke_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_falling_smoke_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_falling_smoke_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_drag_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.60s`.
- Focused RED for unit update falling-engine-trail runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_engine_trail_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_falling_engine_trail_last_state: Dictionary = {}`.
- Focused GREEN for unit update falling-engine-trail runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_engine_trail_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- Focused regression after unit update falling-engine-trail runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_engine_trail_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_falling_engine_trail_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_falling_engine_trail_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_falling_engine_trail_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_smoke_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.57s`.
- Focused RED for unit update falling-descent runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_descent_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_falling_descent_last_state: Dictionary = {}`.
- Focused GREEN for unit update falling-descent runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_descent_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- Focused regression after unit update falling-descent runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_descent_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_falling_descent_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_falling_descent_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_falling_descent_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_engine_trail_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.61s`.
- Focused RED for unit update tile-unitOnAny runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_tile_unit_on_any_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_tile_unit_on_any_last_state: Dictionary = {}`.
- Focused GREEN for unit update tile-unitOnAny runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_tile_unit_on_any_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- Focused regression after unit update tile-unitOnAny runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_tile_unit_on_any_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_tile_unit_on_any_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_tile_unit_on_any_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_tile_unit_on_any_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_falling_descent_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.57s`.
- Focused RED for unit update tile-unitOn runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_tile_unit_on_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_tile_unit_on_last_state: Dictionary = {}`.
- Focused GREEN for unit update tile-unitOn runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_tile_unit_on_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- Focused regression after unit update tile-unitOn runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_tile_unit_on_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_tile_unit_on_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_tile_unit_on_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_tile_unit_on_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_tile_unit_on_any_runtime_proof -q -p no:cacheprovider`
  - Result: `5 passed in 0.59s`.
- Focused RED for unit update floor-damage runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_floor_damage_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_floor_damage_last_state: Dictionary = {}`.
- Focused GREEN for unit update floor-damage runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_floor_damage_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.44s`.
- Focused regression after unit update floor-damage runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_floor_damage_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_floor_damage_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_floor_damage_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_floor_damage_symbols_are_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `4 passed in 0.58s`.
- Focused RED for unit update solid-tile response runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_solid_tile_response_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_solid_tile_response_last_state: Dictionary = {}`.
- Focused GREEN for unit update solid-tile response runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_solid_tile_response_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- Focused regression after unit update solid-tile response runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_solid_tile_response_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_solid_tile_response_state tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_update_solid_tile_response_matches_upstream_source tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_solid_tile_response_symbols_are_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `4 passed in 0.56s`.
- Focused RED for unit update AI-controller runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_ai_controller_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_ai_controller_last_state: Dictionary = {}`.
- Focused GREEN for unit update AI-controller runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_ai_controller_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- Focused regression after unit update AI-controller runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_ai_controller_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_ai_controller_server_gate_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_ai_controller_server_gate_symbols_are_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `3 passed in 0.55s`.
- Focused RED for unit update invalid-controller reset runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_invalid_controller_reset_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_invalid_controller_reset_last_state: Dictionary = {}`.
- Focused GREEN for unit update invalid-controller reset runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_invalid_controller_reset_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- Focused regression after unit update invalid-controller reset runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_invalid_controller_reset_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_invalid_controller_reset_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_invalid_controller_reset_symbols_are_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `3 passed in 0.47s`.
- Focused RED for unit update spawned-core despawn runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_spawned_core_despawn_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_update_spawned_core_despawn_last_state: Dictionary = {}`.
- Focused GREEN for unit update spawned-core despawn runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_spawned_core_despawn_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- Focused regression after unit update spawned-core despawn runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_update_spawned_core_despawn_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_update_spawned_core_despawn_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_update_spawned_core_despawn_symbols_are_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `3 passed in 0.49s`.
- Focused RED for unit icon runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_icon_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_icon_last_state: Dictionary = {}`.
- Focused GREEN for unit icon runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_icon_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- Focused regression after unit icon runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_icon_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_icon_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_icon_symbols_are_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `3 passed in 0.50s`.
- Focused RED for unit destroy initial payload runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_initial_payload_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_destroy_initial_payload_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy initial payload runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_initial_payload_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.44s`.
- Focused regression after unit destroy initial payload runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_initial_payload_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_initial_payload_runtime_proof tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_initial_payload_symbols_are_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `3 passed in 0.47s`.
- Focused RED for unit destroy explosion dispatch runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_explosion_dispatch_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_destroy_explosion_dispatch_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy explosion dispatch runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_explosion_dispatch_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- Focused regression after unit destroy explosion dispatch runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_explosion_dispatch_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_explosion_dispatch_runtime_proof tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_explosion_dispatch_symbols_are_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `3 passed in 0.54s`.
- Focused RED for unit destroy visual effects runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_visual_effects_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_destroy_visual_effects_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy visual effects runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_visual_effects_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.44s`.
- Focused regression after unit destroy visual effects runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_visual_effects_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_visual_effects_runtime_proof tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_visual_effects_symbols_are_registered_with_source_backing -q -p no:cacheprovider`
  - Result: `3 passed in 0.58s`.
- Focused RED for unit destroy sound and event runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_sound_and_event_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_destroy_sound_and_event_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy sound and event runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_sound_and_event_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.43s`.
- Focused regression after unit destroy sound and event runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_sound_and_event_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_sound_and_event_runtime_proof tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_sound_and_event_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_destroy_sound_and_event_matches_upstream_source -q -p no:cacheprovider`
  - Result: `4 passed in 0.56s`.
- Focused RED for unit destroy suicide bomb trigger runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_suicide_bomb_trigger_runtime_proof -q -p no:cacheprovider`
  - Result: failed as expected with missing `var unit_destroy_suicide_bomb_trigger_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy suicide bomb trigger runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_suicide_bomb_trigger_runtime_proof -q -p no:cacheprovider`
  - Result: `1 passed in 0.42s`.
- Focused regression after unit destroy suicide bomb trigger runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_suicide_bomb_trigger_state tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_suicide_bomb_trigger_runtime_proof tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_suicide_bomb_trigger_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_destroy_suicide_bomb_trigger_matches_upstream_source -q -p no:cacheprovider`
  - Result: `4 passed in 0.58s`.
- Focused RED for unit destroy shoot-on-death mounts runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_shoot_on_death_mounts_runtime_proof -q`
  - Result: failed as expected with missing `var unit_destroy_shoot_on_death_mounts_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy shoot-on-death mounts runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_shoot_on_death_mounts_runtime_proof -q`
  - Result: `1 passed in 0.43s`.
- Focused regression after unit destroy shoot-on-death mounts runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_shoot_on_death_mounts_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_shoot_on_death_mounts_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_shoot_on_death_mounts_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_destroy_shoot_on_death_mounts_matches_upstream_source -q`
  - Result: `4 passed in 0.55s`.
- Focused RED for unit destroy crash landing damage runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_crash_landing_damage_runtime_proof -q`
  - Result: failed as expected with missing `var unit_destroy_crash_landing_damage_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy crash landing damage runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_crash_landing_damage_runtime_proof -q`
  - Result: `1 passed in 0.43s`.
- Focused regression after unit destroy crash landing damage runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_crash_landing_damage_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_crash_landing_damage_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_crash_landing_damage_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_destroy_crash_landing_damage_matches_upstream_source -q`
  - Result: `4 passed in 0.57s`.
- Focused RED for unit destroy wreck decal runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_wreck_decal_runtime_proof -q`
  - Result: failed as expected with missing `var unit_destroy_wreck_decal_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy wreck decal runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_wreck_decal_runtime_proof -q`
  - Result: `1 passed in 0.44s`.
- Focused regression after unit destroy wreck decal runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_wreck_decal_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_wreck_decal_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_wreck_decal_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_destroy_wreck_decal_matches_upstream_source -q`
  - Result: `4 passed in 0.57s`.
- Focused RED for unit destroy ability death runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_ability_death_runtime_proof -q`
  - Result: failed as expected with missing `var unit_destroy_ability_death_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy ability death runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_ability_death_runtime_proof -q`
  - Result: `1 passed in 0.45s`.
- Focused regression after unit destroy ability death runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_ability_death_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_ability_death_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_ability_death_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_destroy_ability_death_matches_upstream_source -q`
  - Result: `4 passed in 0.66s`.
- Focused RED for unit destroy type killed/remove runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_type_killed_remove_runtime_proof -q`
  - Result: failed as expected with missing `var unit_destroy_type_killed_remove_last_state: Dictionary = {}`.
- Focused GREEN for unit destroy type killed/remove runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_type_killed_remove_runtime_proof -q`
  - Result: `1 passed in 0.49s`.
- Focused regression after unit destroy type killed/remove runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_destroy_type_killed_remove_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_destroy_type_killed_remove_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_destroy_type_killed_remove_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_destroy_type_killed_remove_matches_upstream_source -q`
  - Result: `4 passed in 0.69s`.
- Focused RED for unit killed runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_killed_runtime_proof -q`
  - Result: failed as expected with missing `var unit_killed_last_state: Dictionary = {}`.
- Focused GREEN for unit killed runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_killed_runtime_proof -q`
  - Result: `1 passed in 0.50s`.
- Focused regression after unit killed runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_killed_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_killed_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_source_slice_ledger_tracks_registered_source_owners tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_api_contracts_pin_runtime_params_and_return_keys tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_state_schema_pins_dictionary_keys_and_aliases tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_killed_state_matches_upstream_source -q`
  - Result: `6 passed in 0.68s`.
- Focused RED for unit kill sync runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_kill_sync_runtime_proof -q`
  - Result: failed as expected with missing `var unit_kill_sync_last_state: Dictionary = {}`.
- Focused GREEN for unit kill sync runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_kill_sync_runtime_proof -q`
  - Result: `1 passed in 0.47s`.
- Focused regression after unit kill sync runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_unit_kill_sync_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_unit_kill_sync_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_unit_kill_sync_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_source_slice_ledger_tracks_registered_source_owners tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_api_contracts_pin_runtime_params_and_return_keys tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_state_schema_pins_dictionary_keys_and_aliases tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_unit_kill_sync_matches_upstream_source -q`
  - Result: `7 passed in 0.78s`.
- Focused RED for weapons setup mounts runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_weapons_setup_mounts_runtime_proof -q`
  - Result: failed as expected with missing `var weapons_setup_mounts_last_state: Dictionary = {}`.
- Focused GREEN for weapons setup mounts runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_weapons_setup_mounts_runtime_proof -q`
  - Result: `1 passed in 0.45s`.
- Focused regression after weapons setup mounts runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_weapons_setup_mounts_runtime_proof tools/mindustry_godot_transpiler/tests/test_playable.py::PlayableManifestTests::test_port_game_exposes_source_weapons_setup_mounts_state tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_weapons_setup_mounts_symbols_are_registered_with_source_backing tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_source_slice_ledger_tracks_registered_source_owners tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_api_contracts_pin_runtime_params_and_return_keys tools/mindustry_godot_transpiler/tests/test_source_symbols.py::SourceSymbolRegistryTests::test_state_schema_pins_dictionary_keys_and_aliases tools/mindustry_godot_transpiler/tests/test_source_parity.py::SourceParityTests::test_weapons_setup_mounts_matches_upstream_source -q`
  - Result: `7 passed in 0.80s`.
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
- SSOT validator after unit update healTime runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update captured-sector death runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update sound loop runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update unsupported-env runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update abilities-loop runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update trail-position runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update drag-formula runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update spawn-knockback runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update falling-drag runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update falling-smoke runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update falling-engine-trail runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update falling-descent runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update tile-unitOnAny runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update tile-unitOn runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update floor-damage runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update solid-tile response runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update AI-controller runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update invalid-controller reset runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit update spawned-core despawn runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit icon runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy initial payload runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy explosion dispatch runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy visual effects runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy sound and event runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy suicide bomb trigger runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy shoot-on-death mounts runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy crash landing damage runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy wreck decal runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy ability death runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit destroy type killed/remove runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit killed runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after unit kill sync runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- SSOT validator after weapons setup mounts runtime slice:
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
- Full Python suite after unit update healTime runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4054 passed, 39303 subtests passed in 411.60s (0:06:51)`.
- Full Python suite after unit update captured-sector death runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4055 passed, 39303 subtests passed in 403.13s (0:06:43)`.
- Full Python suite after unit update sound loop runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4056 passed, 39303 subtests passed in 382.86s (0:06:22)`.
- Full Python suite after unit update unsupported-env runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4057 passed, 39303 subtests passed in 403.44s (0:06:43)`.
- Full Python suite after unit update abilities-loop runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4058 passed, 39303 subtests passed in 409.09s (0:06:49)`.
- Full Python suite after unit update trail-position runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4059 passed, 39303 subtests passed in 413.75s (0:06:53)`.
- Full Python suite after unit update drag-formula runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4060 passed, 39303 subtests passed in 372.18s (0:06:12)`.
- Full Python suite after unit update spawn-knockback runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4061 passed, 39303 subtests passed in 368.11s (0:06:08)`.
- Full Python suite after unit update falling-drag runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4062 passed, 39303 subtests passed in 408.49s (0:06:48)`.
- Full Python suite after unit update falling-smoke runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4063 passed, 39303 subtests passed in 401.35s (0:06:41)`.
- Full Python suite after unit update falling-engine-trail runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4064 passed, 39303 subtests passed in 394.83s (0:06:34)`.
- Full Python suite after unit update falling-descent runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4065 passed, 39303 subtests passed in 392.31s (0:06:32)`.
- Full Python suite after unit update tile-unitOnAny runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4066 passed, 39303 subtests passed in 360.65s (0:06:00)`.
- Full Python suite after unit update tile-unitOn runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4067 passed, 39303 subtests passed in 355.89s (0:05:55)`.
- Full Python suite after unit update floor-damage runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4068 passed, 39303 subtests passed in 354.88s (0:05:54)`.
- Full Python suite after unit update solid-tile response runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4069 passed, 39303 subtests passed in 391.06s (0:06:31)`.
- Full Python suite after unit update AI-controller runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4070 passed, 39303 subtests passed in 383.17s (0:06:23)`.
- Full Python suite after unit update invalid-controller reset runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4071 passed, 39303 subtests passed in 399.70s (0:06:39)`.
- Full Python suite after unit update spawned-core despawn runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4072 passed, 39303 subtests passed in 394.98s (0:06:34)`.
- Full Python suite after unit icon runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4073 passed, 39303 subtests passed in 360.79s (0:06:00)`.
- Full Python suite after unit destroy initial payload runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4074 passed, 39303 subtests passed in 362.28s (0:06:02)`.
- Full Python suite after unit destroy explosion dispatch runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4075 passed, 39303 subtests passed in 401.75s (0:06:41)`.
- Full Python suite after unit destroy visual effects runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4076 passed, 39303 subtests passed in 397.41s (0:06:37)`.
- Full Python suite after unit destroy sound and event runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4077 passed, 39303 subtests passed in 362.16s (0:06:02)`.
- Full Python suite after unit destroy suicide bomb trigger runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4078 passed, 39303 subtests passed in 396.31s (0:06:36)`.
- Full Python suite after unit destroy shoot-on-death mounts runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4079 passed, 39303 subtests passed in 363.69s (0:06:03)`.
- Full Python suite after unit destroy crash landing damage runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4080 passed, 39303 subtests passed in 358.42s (0:05:58)`.
- Full Python suite after unit destroy wreck decal runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4081 passed, 39303 subtests passed in 391.51s (0:06:31)`.
- Full Python suite after unit destroy ability death runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4082 passed, 39303 subtests passed in 476.33s (0:07:56)`.
- Full Python suite after unit destroy type killed/remove runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4083 passed, 39303 subtests passed in 482.71s (0:08:02)`.
- Full Python suite after unit killed runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4084 passed, 39303 subtests passed in 415.66s (0:06:55)`.
- Full Python suite after unit kill sync runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4085 passed, 39303 subtests passed in 409.52s (0:06:49)`.
- Full Python suite after weapons setup mounts runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4086 passed, 39303 subtests passed in 426.93s (0:07:06)`.
- Full Python suite after weapons set rotation runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4087 passed, 39303 subtests passed in 420.22s (0:07:00)`.
- Full Python suite after weapons control runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4088 passed, 39303 subtests passed in 396.69s (0:06:36)`.
- Full Python suite after weapons aim runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4089 passed, 39303 subtests passed in 395.48s (0:06:35)`.
- Full Python suite after weapons canShoot runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4090 passed, 39303 subtests passed in 398.82s (0:06:38)`.
- Full Python suite after weapons remove continuous bullet cleanup runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4091 passed, 39303 subtests passed in 368.81s (0:06:08)`.
- Full Python suite after weapons remove sound stop runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4092 passed, 39303 subtests passed in 367.73s (0:06:07)`.
- Full Python suite after weapons update dispatch runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4093 passed, 39303 subtests passed in 374.90s (0:06:14)`.
- Full Python suite after weapon update passive timers runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4094 passed, 39303 subtests passed in 374.34s (0:06:14)`.
- Full Python suite after weapon update mount origin runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4095 passed, 39303 subtests passed in 403.82s (0:06:43)`.
- Full Python suite after weapon update auto-target retarget runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4096 passed, 39303 subtests passed in 397.72s (0:06:37)`.
- Full Python suite after weapon update auto-target invalidation runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4097 passed, 39303 subtests passed in 398.59s (0:06:38)`.
- Full Python suite after weapon update auto-target shoot aim runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4098 passed, 39303 subtests passed in 370.90s (0:06:10)`.
- Full Python suite after weapon update rotate-toward runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4099 passed, 39303 subtests passed in 402.19s (0:06:42)`.
- Full Python suite after weapon update bullet origin runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4100 passed, 39303 subtests passed in 369.68s (0:06:09)`.
- SSOT validator after weapon update always-shooting runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite after weapon update always-shooting runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4101 passed, 39303 subtests passed in 397.88s (0:06:37)`.
- SSOT validator after weapon update continuous invalidation runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite after weapon update continuous invalidation runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4102 passed, 39303 subtests passed in 403.73s (0:06:43)`.
- SSOT validator after weapon update continuous live runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite after weapon update continuous live runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4103 passed, 39303 subtests passed in 360.06s (0:06:00)`.
- SSOT validator after weapon update continuous sound runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite after weapon update continuous sound runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4104 passed, 39303 subtests passed in 394.20s (0:06:34)`.
- SSOT validator after weapon update continuous laser aim runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite after weapon update continuous laser aim runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4105 passed, 39303 subtests passed in 393.14s (0:06:33)`.
- SSOT validator after weapon update always-continuous keepalive runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite after weapon update always-continuous keepalive runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4106 passed, 39303 subtests passed in 394.31s (0:06:34)`.
- SSOT validator after weapon update continuous idle heat/sound runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite after weapon update continuous idle heat/sound runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4107 passed, 39303 subtests passed in 362.72s (0:06:02)`.
- SSOT validator after weapon update alternating side flip runtime slice:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count'], 'warning_count': report.get('warning_count', 0)})"`
  - Result: `{'errors': [], 'module_count': 112, 'warning_count': 0}`.
- Full Python suite after weapon update alternating side flip runtime slice:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4108 passed, 39303 subtests passed in 397.40s (0:06:37)`.

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
- [x] Unit update healTime runtime proven: `reset_unit_update_heal_time_runtime()`, `step_unit_update_heal_time_runtime(true, -1.0, 1.0)`, `step_unit_update_heal_time_runtime(true, 0.5, 2.0)`, `step_unit_update_heal_time_runtime(false, -2.0, 5.0)`, reset-then-decay returns `healTime=0.95`, no-reset decay returns `0.4`, not-healed negative decay returns `-2.25`, and `wasHealed=false`.
- [x] Unit update captured-sector death runtime proven: `reset_unit_update_captured_sector_death_runtime()`, `step_unit_update_captured_sector_death_runtime(true, true, true)`, and one-false guard calls for each term; only all-true returns `kill=true` and `call="kill()"`.
- [x] Unit update sound loop runtime proven: `reset_unit_update_sound_loop_runtime()`, headless path returns no calls, loop-only path calls `control.sound.loop(type.loopSound, this, type.loopSoundVolume)`, move path returns `progress=0.5`, `pitch=1.0`, `volume=1.0`, and zero-speed clamp returns `progress=1.0`, `pitch=1.2`.
- [x] Unit update unsupported-env runtime proven: `reset_unit_update_unsupported_env_runtime()`, supported-alive path returns no calls, unsupported-alive path calls `Call.unitEnvDeath(self())` then `team.data().updateCount(type, -1)`, unsupported-dead path skips both calls, and summary exposes `unit_update_unsupported_env_runtime`.
- [x] Unit update abilities-loop runtime proven: `reset_unit_update_abilities_loop_runtime()`, empty abilities returns `update_count=0`, ordered abilities `["shield","repair","boost"]` return three `a.update(self());` records in input order, and summary exposes `unit_update_abilities_loop_runtime`.
- [x] Unit update trail-position runtime proven: `reset_unit_update_trail_position_runtime()`, null trail skips length/update calls, active trail records `trail.length = type.trailLength` and `trail.update(cx, cy)`, elevation scale computes `0.5`, offset `4.5`, position `(5.5,20.0)`, and no-engine-elevation path uses `scale=1.0`.
- [x] Unit update drag-formula runtime proven: `reset_unit_update_drag_formula_runtime()`, grounded path computes `0.3 * 0.5 * 2.0 * 3.0 = 0.9`, non-grounded path uses floor factor `1.0` and computes `1.8`, default multipliers return `0.3`, and summary exposes `unit_update_drag_formula_runtime`.
- [x] Unit update spawn-knockback runtime proven: `reset_unit_update_spawn_knockback_runtime()`, active guard computes `relativeSize=10.0`, one in-range spawn at distance `5.0` yields strength `0.6` and velocity `(0.54,0.0)`, wave-team and client non-local guards skip knockbacks, and summary exposes `unit_update_spawn_knockback_runtime`.
- [x] Unit update falling-drag runtime proven: `reset_unit_update_falling_drag_runtime()`, dead and zero-health paths set drag to `0.01`, alive path keeps current drag `0.7`, and summary exposes `unit_update_falling_drag_runtime`.
- [x] Unit update falling-smoke runtime proven: `reset_unit_update_falling_smoke_runtime()`, falling/chance path emits `type.fallEffect.at` at `(11.5,18.0)` from `(x,y)=(10,20)` plus `Tmp.v1=(1.5,-2.0)`, no-chance and alive paths skip effect, and summary exposes `unit_update_falling_smoke_runtime`.
- [x] Unit update falling-engine-trail runtime proven: `reset_unit_update_falling_engine_trail_runtime()`, falling/chance path emits `type.fallEngineEffect.at` at `(6.5,19.25)` from `(x,y)=(10,20)`, angle `180`, offset `3.75`, engine range `1.25`, position ranges `(0.25,-0.75)`, random rotation `0.33`, no-chance and alive paths skip effect, and summary exposes `unit_update_falling_engine_trail_runtime`.
- [x] Unit update falling-descent runtime proven: `reset_unit_update_falling_descent_runtime()`, falling path descends elevation `1.0 -> -0.0799999999999998` without destroy, grounded path calls `Call.unitDestroy(id)` for id `42`, wreck-health path calls destroy for id `99`, alive path leaves elevation `1.0` and skips destroy, and summary exposes `unit_update_falling_descent_runtime`.
- [x] Unit update tile-unitOnAny runtime proven: `reset_unit_update_tile_unit_on_any_runtime()`, active tile/build path calls `tile.build.unitOnAny(self())` for unit id `77`, missing tile and missing build paths skip callback, and summary exposes `unit_update_tile_unit_on_any_runtime`.
- [x] Unit update tile-unitOn runtime proven: `reset_unit_update_tile_unit_on_runtime()`, grounded non-hovering tile/build path calls `tile.build.unitOn(self())` for unit id `88`, missing tile, flying, and hovering paths skip the outer guard, no-build path keeps outer guard true but skips callback, and summary exposes `unit_update_tile_unit_on_runtime`.
- [x] Unit update floor-damage runtime proven: `reset_unit_update_floor_damage_runtime()`, grounded non-hovering active path calls `damageContinuous(floor.damageTaken)` with `floor.damageTaken=3.5`, `Time.delta=2.0`, `scaledDamage=7.0`, and `withEffect=true`; zero-damage, missing-tile, flying, and hovering paths skip damage; summary exposes `unit_update_floor_damage_runtime`.
- [x] Unit update solid-tile response runtime proven: `reset_unit_update_solid_tile_response_runtime()`, boost path sets elevation `1.0`, kill path records `kill()` for unit id `102`, passable and missing-tile paths skip the guard, client and remote-GUI guards skip kill, and summary exposes `unit_update_solid_tile_response_runtime`.
- [x] Unit update AI-controller runtime proven: `reset_unit_update_ai_controller_runtime()`, server/alive/should-update path calls `controller.updateUnit();` for unit id `201`, client/dead/should-update-false paths skip controller update, and summary exposes `unit_update_ai_controller_runtime`.
- [x] Unit update invalid-controller reset runtime proven: `reset_unit_update_invalid_controller_reset_runtime()`, invalid path calls `resetController()` for unit id `301` with effect `controller(type.createController(self()))`, valid path skips reset, and summary exposes `unit_update_invalid_controller_reset_runtime`.
- [x] Unit update spawned-core despawn runtime proven: `reset_unit_update_spawned_core_despawn_runtime()`, spawned-core non-player alive path calls `Call.unitDespawn(self())` for unit id `401` with effect `Fx.unitDespawn.at(unit.x, unit.y, 0, unit)` and remove `unit.remove()`, not-spawned/player/dead paths skip despawn, and summary exposes `unit_update_spawned_core_despawn_runtime`.
- [x] Unit icon runtime proven: `reset_unit_icon_runtime()`, `step_unit_icon_runtime("alpha-ui")` returns `call="icon()"`, `return="type.uiIcon"`, `ui_icon="alpha-ui"`, and summary exposes `unit_icon_runtime`.
- [x] Unit destroy initial payload runtime proven: `reset_unit_destroy_initial_payload_runtime()`, `step_unit_destroy_initial_payload_runtime(true, true, 1.5, 0.8, 0.25, 4)` returns `return_guard=false`, `explosiveness=11.18`, `flammability=1.68421052631579`, `power=186.357373834953`; not-added and not-killable guards return null payload fields; summary exposes `unit_destroy_initial_payload_runtime`.
- [x] Unit destroy explosion dispatch runtime proven: `reset_unit_destroy_explosion_dispatch_runtime()`, dynamic branch returns `call="Damage.dynamicExplosion"`, `radius=10.9411764705882`, `damage=true`, `fire=true`, `team=7`, `explosion_fx="Fx.dynamicExplosion"`, `base_shake=0`; blocked dynamic branch returns `damage=false` and `fire=false`; spawned-core branch returns `call="type.deathExplosionEffect.at"`, `rotation=1`, `effect="Fx.dynamicExplosion"`; summary exposes `unit_destroy_explosion_dispatch_runtime`.
- [x] Unit destroy visual effects runtime proven: `reset_unit_destroy_visual_effects_runtime()`, fallback branch `step_unit_destroy_visual_effects_runtime(10, 20, 15, -1, true, 44)` returns `shake=8`, `scorch.size=3`, and `shake_effect.intensity=8`; explicit branch `step_unit_destroy_visual_effects_runtime(10, 20, 15, 2.5, false, 45)` returns `shake=2.5` and `scorch=null`; summary exposes `unit_destroy_visual_effects_runtime`.
- [x] Unit destroy sound and event runtime proven: `reset_unit_destroy_sound_and_event_runtime()`, `step_unit_destroy_sound_and_event_runtime("unitExplode2", 0.65, 51)` returns `sound_call.call="type.deathSound.at(this, 1f, type.deathSoundVolume);"`, `sound="unitExplode2"`, `pitch=1.0`, `volume=0.65`, `event_call.event="Events.fire(new UnitDestroyEvent(self()));"`, `event_class="UnitDestroyEvent"`, `unit=51`; summary exposes `unit_destroy_sound_and_event_runtime`.
- [x] Unit destroy suicide bomb trigger runtime proven: `reset_unit_destroy_suicide_bomb_trigger_runtime()`, active branch `step_unit_destroy_suicide_bomb_trigger_runtime(8.5, true, false)` returns `trigger=true`, `event="Events.fire(Trigger.suicideBomb);"`, `trigger_member="suicideBomb,"`; below-threshold branch `step_unit_destroy_suicide_bomb_trigger_runtime(7.0, true, true)` returns `trigger=false`, `event=""`; remote-not-player branch `step_unit_destroy_suicide_bomb_trigger_runtime(8.5, false, false)` returns `trigger=false`, `event=""`; summary exposes `unit_destroy_suicide_bomb_trigger_runtime`.
- [x] Unit destroy shoot-on-death mounts runtime proven: `reset_unit_destroy_shoot_on_death_mounts_runtime()`, `step_unit_destroy_shoot_on_death_mounts_runtime([...], false, 12.5, 18.25, 90.0, 61)` returns mount `0` with `updateMount=true`, effect `Fx.spawn`, `allowShootEffects=false`, position `(12.5,18.25)`, rotation `90.0`; mount `1` blocks repeat kill-shooter fire with `updateMount=false`; mount `2` updates with `effect=null`, `reload=0.0`, `shoot=true`, `unit=61`; summary exposes `unit_destroy_shoot_on_death_mounts_runtime`.
- [x] Unit destroy crash landing damage runtime proven: `reset_unit_destroy_crash_landing_damage_runtime()`, active branch `step_unit_destroy_crash_landing_damage_runtime(true, false, true, 1.4, 16.0, 1.25, true, false, 7, 12.0, 21.0)` returns `should_check_crash=true`, `crash_damage=35.0`, `damage_radius=16.9349062472505`, `damage_call.complete=true`, `air=false`, `ground=true`; shield-absorbed branch returns `damage_call=null`; guard-false branch returns null damage fields; summary exposes `unit_destroy_crash_landing_damage_runtime`.
- [x] Unit destroy wreck decal runtime proven: `reset_unit_destroy_wreck_decal_runtime()`, active branch `step_unit_destroy_wreck_decal_runtime(false, true, [...], [...], 10.0, 20.0, 180.0, 16.0)` returns `should_create_decals=true`, `range=4.0`, two decals for found regions, positions `(11.5,18.0)` and `(9.5,23.25)`, and `rotation=90.0`; headless and no-scorch guards return `decals=[]` and `range=null`; summary exposes `unit_destroy_wreck_decal_runtime`.
- [x] Unit destroy ability death runtime proven: `reset_unit_destroy_ability_death_runtime()`, empty branch `step_unit_destroy_ability_death_runtime([], 77)` returns `calls=[]`; active branch with `shield`, `repair`, and `boost` abilities returns three ordered `a.death(self());` calls with `unit=77` and default `public void death(Unit unit){}`; summary exposes `unit_destroy_ability_death_runtime`.
- [x] Unit destroy type killed/remove runtime proven: `reset_unit_destroy_type_killed_remove_runtime()`, `step_unit_destroy_type_killed_remove_runtime(77)` returns order `[type.killed(self()), remove()]`, top-level `type_killed_call="type.killed(self());"`, `remove_call="remove();"`, default `public void killed(Unit unit){}`, self boundary `<T extends Entityc> T self(){`, and remove boundary `public void remove(){`; summary exposes `unit_destroy_type_killed_remove_runtime`.
- [x] Unit killed runtime proven: `reset_unit_killed_runtime()`, destroy branch `step_unit_killed_runtime(true, 12.0, false, true, "wreckSound", 0.8, 77)` returns `was_player=true`, `health=0.0`, `dead=true`, `destroy_called=true`, `destroy_call="destroy()"`, and `wreck_sound_call=null`; wreck branch `step_unit_killed_runtime(false, -5.0, true, true, "wreckSound", 0.8, 88)` returns `was_player=false`, `health=-5.0`, `dead=true`, `destroy_called=false`, `wreck_sound_call.call="type.wreckSound.at(this, 1f, type.wreckSoundVolume)"`, `pitch=1.0`, `volume=0.8`, and `unit=88`; summary exposes `unit_killed_runtime`.
- [x] Unit kill sync runtime proven: `reset_unit_kill_sync_runtime()`, active branch `step_unit_kill_sync_runtime(false, false, true, 91)` returns `should_return=false`, `remote_call.call="Call.unitDeath(id)"`, remote bridge `@Remote(called = Loc.server)`, `Groups.unit.getByID(uid)`, `netClient.addRemovedEntity(uid)`, and `unit.killed()`; dead, net-client, and not-killable guard branches return `should_return=true` and `remote_call=null`; summary exposes `unit_kill_sync_runtime`.
- [x] Weapons setup mounts runtime proven: `reset_weapons_setup_mounts_runtime()`, empty branch `step_weapons_setup_mounts_runtime([])` returns `mounts=[]`, array allocation and loop source strings; active branch with three weapon states returns three ordered mounts, exact construction call, `WeaponMount` constructor boundary, and rotations `0.0`, `-15.0`, and `15.0` from `Weapon.baseRotation`; summary exposes `weapons_setup_mounts_runtime`.
- [x] Weapons set rotation runtime proven: `reset_weapons_set_rotation_runtime()`, empty branch `step_weapons_set_rotation_runtime([], 45.0)` returns `mounts=[]`; active branch with three mounts returns three ordered `mount.rotation = rotation;` assignments and rotations `135.0` for `cannon`, `left-laser`, and `right-laser`; summary exposes `weapons_set_rotation_runtime`.
- [x] Weapons control runtime proven: `reset_weapons_control_runtime()`, pair branch `step_weapons_control_runtime([...], true, false)` returns `is_rotate=true`, `is_shooting=false`, controllable mounts updated, non-controllable `decoy` preserves prior rotate/shoot; overload branch `step_weapons_control_rotate_shoot_runtime([...], true)` returns `rotateShootMethod="void controlWeapons(boolean rotateShoot){"`, `rotateShootDelegate="controlWeapons(rotateShoot, rotateShoot);"`, and `is_rotate/is_shooting=true`; summary exposes `weapons_control_runtime`.
- [x] Weapons aim runtime proven: `reset_weapons_aim_runtime()`, short-vector branch `step_weapons_aim_runtime([...], 10.0, 20.0, 13.0, 24.0, 10.0)` extends target to `(16.0, 28.0)`, zero-vector branch keeps `(10.0, 20.0)`, non-controllable `decoy` preserves prior aim `(-7.0, 9.0)`, Position overload returns `positionMethod="void aim(Position pos){"` and `positionDelegate="aim(pos.getX(), pos.getY());"`; summary exposes `weapons_aim_runtime`.
- [x] Weapons canShoot runtime proven: `reset_weapons_can_shoot_runtime()`, `step_weapons_can_shoot_runtime(false)` returns `can_shoot=true`, `step_weapons_can_shoot_runtime(true)` returns `can_shoot=false`, both expose `can_shoot_method="boolean canShoot(){"` and `return_expr="return !disarmed;"`; summary exposes `weapons_can_shoot_runtime`.
- [x] Weapons remove continuous bullet cleanup runtime proven: `reset_weapons_remove_continuous_bullet_cleanup_runtime()`, `step_weapons_remove_continuous_bullet_cleanup_runtime([...], 77)` clears continuous same-owner bullet with `bulletTime=30.0` from lifetime `40.0`, preserves non-continuous and owner-mismatch bullets, skips no-bullet mount, and exposes `remove_method="public void remove(){"`; summary exposes `weapons_remove_continuous_bullet_cleanup_runtime`.
- [x] Weapons remove sound stop runtime proven: `reset_weapons_remove_sound_stop_runtime()`, `step_weapons_remove_sound_stop_runtime([{"weapon":"laser","sound":true},{"weapon":"silent","sound":false}])` returns the sound mount with `stopCall.call="mount.sound.stop();"`, `stopCall.method="public void stop(){"`, `stopCall.idGuard="if(id != -1){"`, effects `Core.audio.stop(id);`, `id = -1;`, and `volume = 0f;`, and returns the no-sound mount with `stopCall=null`; summary exposes `weapons_remove_sound_stop_runtime`.
- [x] Weapons update dispatch runtime proven: `reset_weapons_update_dispatch_runtime()`, `step_weapons_update_dispatch_runtime([{"weapon":"duo-left"},{"weapon":"duo-right"}], 77)` returns two ordered dispatches with `call="mount.weapon.update(self(), mount);"`, `unit=77`, `unitArg="self()"`, `mountArg="mount"`, `weaponUpdateMethod="public void update(Unit unit, WeaponMount mount){"`, `loop="for(WeaponMount mount : mounts){"`, and `mounts_field="@SyncLocal WeaponMount[] mounts = {};"`; summary exposes `weapons_update_dispatch_runtime`.
- [x] Weapon update passive timers runtime proven: `reset_weapon_update_passive_timers_runtime()`, `step_weapon_update_passive_timers_runtime({...}, {...}, {...}, 1.0)` with reload `10.0`, reloadMultiplier `1.5`, recoil `0.8`, recoils `[0.5,0.2]`, smoothReload `0.1`, charge `0.25`, warmup `0.3`, linear warmup, and firstShotDelay `5.0` returns `reload=8.5`, `recoil=0.65`, `recoils=[0.35,0.05]`, `smooth_reload=0.14875`, `charge=0.45`, `warmup_target=1.0`, `warmup=0.5`, and `can_shoot_call="boolean can = unit.canShoot();"`; summary exposes `weapon_update_passive_timers_runtime`.
- [x] Weapon update mount origin runtime proven: `reset_weapon_update_mount_origin_runtime()`, `step_weapon_update_mount_origin_runtime({"x":10.0,"y":20.0,"rotation":90.0}, {"x":5.0,"y":0.0})` returns `angle=0.0`, `trnsx=5.0`, `trnsy=0.0`, `mount_x=15.0`, `mount_y=20.0`, source lines `mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),` and `mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);`, and summary exposes `weapon_update_mount_origin_runtime`.
- [x] Weapon update auto-target retarget runtime proven: `reset_weapon_update_auto_target_retarget_runtime()`, `step_weapon_update_auto_target_retarget_runtime({"retarget":0.25,"targetExists":false}, {"controllable":false,"autoTarget":true,"targetInterval":40.0,"targetSwitchInterval":70.0}, {"range":120.0,"collidesAir":true,"collidesGround":false}, 1.0, 15.0, 20.0, true)` returns `gate=true`, `retarget_after_decrement=-0.75`, `find_target_called=true`, `target_exists=true`, `retarget=70.0`, findTarget call `{mountX=15.0,mountY=20.0,range=120.0,air=true,ground=false}`, and summary exposes `weapon_update_auto_target_retarget_runtime`.
- [x] Weapon update auto-target invalidation runtime proven: `reset_weapon_update_auto_target_invalidation_runtime()`, `step_weapon_update_auto_target_invalidation_runtime({"targetExists":true}, {"controllable":false,"autoTarget":true,"shootY":3.0}, {"range":120.0}, 15.0, 20.0, true)` returns `gate=true`, `check_target_called=true`, `check_target_result=true`, `target_exists=false`, `target_cleared=true`, `check_target_call.rangeWithShootY=123.0`, `clear_source="mount.target = null;"`, and summary exposes `weapon_update_auto_target_invalidation_runtime`.
- [x] Weapon update auto-target shoot aim runtime proven: `reset_weapon_update_auto_target_shoot_aim_runtime()`, `step_weapon_update_auto_target_shoot_aim_runtime({"targetExists":true,"aimX":5.0,"aimY":6.0,"targetSized":true,"targetHitSize":8.0}, {"predictTarget":true,"shootY":3.0}, {"range":120.0,"speed":4.0,"keepVelocity":true}, true, 15.0, 20.0, true, {"x":77.0,"y":88.0})` returns `shoot=true`, `rotate=true`, `aim_x=77.0`, `aim_y=88.0`, `target_exists=true`, `target_within=true`, `within_range=127.0`, and summary exposes `weapon_update_auto_target_shoot_aim_runtime`.
- [x] Weapon update rotate-toward runtime proven: `reset_weapon_update_rotate_toward_runtime()`, rotate branch `step_weapon_update_rotate_toward_runtime({"rotate":true,"shoot":false,"rotation":45.0,"targetRotation":0.0,"aimX":15.0,"aimY":30.0}, {"rotate":true,"x":5.0,"y":0.0,"rotateSpeed":20.0,"rotationLimit":360.0,"baseRotation":0.0}, {"x":10.0,"y":20.0,"rotation":90.0}, true, 1.0)` returns `gate=true`, `axis_angle=0.0`, `axis_x=15.0`, `axis_y=20.0`, `target_rotation=0.0`, `rotation=25.0`; non-rotate branch returns `non_rotate_applied=true`, `rotation=12.0`, `target_rotation=90.0`; summary exposes `weapon_update_rotate_toward_runtime`.
- [x] Weapon update bullet origin runtime proven: `reset_weapon_update_bullet_origin_runtime()`, rotate branch `step_weapon_update_bullet_origin_runtime({"rotation":25.0,"aimX":40.0,"aimY":45.0}, {"rotate":true,"baseRotation":12.0,"shootX":2.0,"shootY":3.0}, {"x":10.0,"y":20.0,"rotation":90.0}, 15.0, 20.0)` returns `weapon_rotation=25.0`, `bullet_x=15.5447607888512`, `bullet_y=23.5641598845913`, `shoot_angle=115.0`; non-rotate branch returns `weapon_rotation=12.0`, `shoot_angle=145.600470815284`, `rotate=false`; summary exposes `weapon_update_bullet_origin_runtime`.
- [x] Weapon update always-shooting runtime proven: `reset_weapon_update_always_shooting_runtime()`, enabled branch `step_weapon_update_always_shooting_runtime({"shoot":false}, {"alwaysShooting":true})` returns `shoot=true`, `always_shooting=true`, `always_shooting_source="if(alwaysShooting) mount.shoot = true;"`; disabled branch preserves `shoot=false`, exposes `continuous_reserved_source="if(continuous && mount.bullet != null){"`, and summary exposes `weapon_update_always_shooting_runtime`.
- [x] Weapon update continuous invalidation runtime proven: `reset_weapon_update_continuous_invalidation_runtime()`, invalid branch `step_weapon_update_continuous_invalidation_runtime({"bulletExists":true}, {"continuous":true}, {"isAdded":false,"time":1,"lifetime":10,"typeMatches":true})` clears bullet, expired branch clears bullet at `time=12,lifetime=10`, live branch keeps bullet, no-bullet branch keeps `gate=false`, and summary exposes `weapon_update_continuous_invalidation_runtime`.
- [x] Weapon update continuous live runtime proven: `reset_weapon_update_continuous_live_runtime()`, live branch `step_weapon_update_continuous_live_runtime({"bulletExists":true,"reload":2,"recoil":0.25}, {"continuous":true,"reload":9}, {"velX":1,"velY":-2}, {"isAdded":true,"time":2,"lifetime":10,"typeMatches":true,"recoil":3,"x":0,"y":0}, 0.5, 15, 20, 25)` returns `bullet_rotation=115`, bullet position `(15,20)`, `reload=9`, `recoil=1`, velocity `(1.63392739261105,-3.35946168055497)`, and invalid branch preserves `bullet_rotation=77` and `reload=2`; summary exposes `weapon_update_continuous_live_runtime`.
- [x] Weapon update continuous sound runtime proven: `reset_weapon_update_continuous_sound_runtime()`, live branch `step_weapon_update_continuous_sound_runtime({"bulletExists":true,"hasSound":false}, {"continuous":true,"shootSoundIsNone":false}, {"isAdded":true,"time":2,"lifetime":10,"typeMatches":true}, {"headless":false}, 15, 20)` creates sound and returns `sound_update_call={"call":"mount.sound.update(bulletX, bulletY, true)","play":true,"x":15,"y":20}`, existing-sound branch updates without creation, headless branch keeps `sound_gate=false`, and summary exposes `weapon_update_continuous_sound_runtime`.
- [x] Weapon update continuous laser aim runtime proven: `reset_weapon_update_continuous_laser_aim_runtime()`, live branch `step_weapon_update_continuous_laser_aim_runtime({"bulletExists":true,"aimX":16,"aimY":28,"lastLength":3}, {"continuous":true,"aimChangeSpeed":2}, {"isAdded":true,"time":2,"lifetime":10,"typeMatches":true,"aimX":13,"aimY":24,"range":20}, 1, 10, 20, 0)` returns `shoot_length=10`, `cur_length=5`, `result_length=7`, `last_length=7`, bullet aim `(17,20)`, invalid branch preserves `last_length=3` and bullet aim `(13,24)`, and summary exposes `weapon_update_continuous_laser_aim_runtime`.
- [x] Weapon update always-continuous keepalive runtime proven: `reset_weapon_update_always_continuous_keepalive_runtime()`, active branch `step_weapon_update_always_continuous_keepalive_runtime({"bulletExists":true,"shoot":true,"warmup":0.75}, {"continuous":true,"alwaysContinuous":true,"shootStatus":"burning","shootStatusDuration":120}, {"isAdded":true,"time":2,"lifetime":40,"typeMatches":true,"optimalLifeFract":0.5,"keepAlive":false}, {"statusImmune":false})` returns `bullet_time=15`, `keep_alive=true`, and status application `{"effect":"burning","duration":120}`; immune branch keeps `keepalive_gate=true` but `status_applied=false`; mount-shoot false branch preserves `bullet_time=2` and `keep_alive=false`; summary exposes `weapon_update_always_continuous_keepalive_runtime`.
- [x] Weapon update continuous idle heat/sound runtime proven: `reset_weapon_update_continuous_idle_heat_sound_runtime()`, idle branch `step_weapon_update_continuous_idle_heat_sound_runtime({"bulletExists":false,"heat":0.8,"hasSound":true}, {"continuous":true,"cooldownTime":20}, {"reloadMultiplier":2}, 1, 15, 20)` returns `heat=0.7` and `sound_update_call={"play":false,"x":15,"y":20}`, clamp branch returns `heat=0`, and continuous-live branch preserves `heat=0.8` with no sound update; summary exposes `weapon_update_continuous_idle_heat_sound_runtime`.
- [x] Weapon update alternating side flip runtime proven: `reset_weapon_update_alternating_side_flip_runtime()`, active branch `step_weapon_update_alternating_side_flip_runtime({"side":false,"reload":4,"lastReload":6}, {"flipSprite":false,"alternate":true,"otherSide":1,"reload":10}, [{"side":false},{"side":true}])` returns `was_flipped=false`, `crosses_half_reload=true`, `flip_gate=true`, `mount_side=true`, and paired mount side `false`; guard-false branch with `lastReload=4` returns `crosses_half_reload=false`, `flip_gate=false`, preserves `mount_side=false`, and keeps paired mount side `true`; summary exposes `weapon_update_alternating_side_flip_runtime`.
- [ ] Full playable completion not claimed until broader playthrough audit closes remaining gameplay surfaces.

## Progress

- Source-slice migration: `100.00%`
- Playable checklist: `97/98 = 98.98%` done; open `1/98 = 1.02%`.
- Playable audit: broader runtime still under audit, but playthrough runtime package, turret ammo/fire, placement-cost, builder construction queue, builder deconstruct/removal, builder skip/range, runtime save/load persistence, runtime save slot file, runtime save slot listing, enemy runtime, factory, item dump runtime, put item runtime, payload move/dump runtime, payload default runtime, unit payload targeting runtime, unit killable runtime, unit player-controllable runtime, unit afterSync runtime, unit afterRead runtime, unit afterReadAll runtime, unit add runtime, unit remove runtime, unit landed runtime, unit heal runtime, unit icon runtime, unit killed runtime, unit kill sync runtime, weapons setup mounts runtime, weapons set rotation runtime, weapons control runtime, weapons aim runtime, weapons canShoot runtime, weapons remove continuous bullet cleanup runtime, weapons remove sound stop runtime, weapons update dispatch runtime, weapon update passive timers runtime, weapon update mount origin runtime, weapon update auto-target retarget runtime, weapon update auto-target invalidation runtime, weapon update auto-target shoot aim runtime, weapon update rotate-toward runtime, weapon update bullet origin runtime, weapon update always-shooting runtime, weapon update continuous invalidation runtime, weapon update continuous live runtime, weapon update continuous sound runtime, weapon update continuous laser aim runtime, weapon update always-continuous keepalive runtime, weapon update continuous idle heat/sound runtime, weapon update alternating side flip runtime, unit destroy initial payload runtime, unit destroy explosion dispatch runtime, unit destroy visual effects runtime, unit destroy sound and event runtime, unit destroy suicide bomb trigger runtime, unit destroy shoot-on-death mounts runtime, unit destroy crash landing damage runtime, unit destroy wreck decal runtime, unit destroy ability death runtime, unit destroy type killed/remove runtime, unit update healTime runtime, unit update captured-sector death runtime, unit update sound loop runtime, unit update unsupported-env runtime, unit update abilities-loop runtime, unit update trail-position runtime, unit update drag-formula runtime, unit update spawn-knockback runtime, unit update falling-drag runtime, unit update falling-smoke runtime, unit update falling-engine-trail runtime, unit update falling-descent runtime, unit update tile-unitOnAny runtime, unit update tile-unitOn runtime, unit update floor-damage runtime, unit update solid-tile response runtime, unit update AI-controller runtime, unit update invalid-controller reset runtime, unit update spawned-core despawn runtime, MendProjector heal, bullet-hit, overdrive boost, wave spawn, PowerGraph runtime, PowerGraph battery runtime, PowerGraph distribution runtime, liquid transfer runtime, liquid leak runtime, and game-over runtime paths now proven.
- Current blocker for completion claim: full playable coverage across remaining gameplay surfaces, not playthrough runtime package, bullet-hit, MendProjector heal, placement-cost, builder construction queue, builder deconstruct/removal, builder skip/range, runtime save/load persistence, runtime save slot file, runtime save slot listing, enemy runtime, factory, item dump runtime, payload move/dump runtime, payload default runtime, unit payload targeting runtime, unit killable runtime, unit player-controllable runtime, unit afterSync runtime, unit afterRead runtime, unit afterReadAll runtime, unit add runtime, unit remove runtime, unit landed runtime, unit heal runtime, unit icon runtime, unit killed runtime, unit kill sync runtime, weapons setup mounts runtime, weapons set rotation runtime, weapons control runtime, weapons aim runtime, weapons canShoot runtime, weapons remove continuous bullet cleanup runtime, weapons remove sound stop runtime, weapons update dispatch runtime, weapon update passive timers runtime, weapon update mount origin runtime, weapon update auto-target retarget runtime, weapon update auto-target invalidation runtime, weapon update auto-target shoot aim runtime, weapon update rotate-toward runtime, weapon update bullet origin runtime, weapon update always-shooting runtime, weapon update continuous invalidation runtime, weapon update continuous live runtime, weapon update continuous sound runtime, weapon update continuous laser aim runtime, weapon update always-continuous keepalive runtime, weapon update continuous idle heat/sound runtime, weapon update alternating side flip runtime, unit destroy initial payload runtime, unit destroy explosion dispatch runtime, unit destroy visual effects runtime, unit destroy sound and event runtime, unit destroy suicide bomb trigger runtime, unit destroy shoot-on-death mounts runtime, unit destroy crash landing damage runtime, unit destroy wreck decal runtime, unit destroy ability death runtime, unit destroy type killed/remove runtime, unit update healTime runtime, unit update captured-sector death runtime, unit update sound loop runtime, unit update unsupported-env runtime, unit update abilities-loop runtime, unit update trail-position runtime, unit update drag-formula runtime, unit update spawn-knockback runtime, unit update falling-drag runtime, unit update falling-smoke runtime, unit update falling-engine-trail runtime, unit update falling-descent runtime, unit update tile-unitOnAny runtime, unit update tile-unitOn runtime, unit update floor-damage runtime, unit update solid-tile response runtime, unit update AI-controller runtime, unit update invalid-controller reset runtime, unit update spawned-core despawn runtime, turret ammo/fire, overdrive boost, wave spawn, PowerGraph runtime, PowerGraph battery runtime, PowerGraph distribution runtime, liquid transfer runtime, liquid leak runtime, or game-over runtime.
