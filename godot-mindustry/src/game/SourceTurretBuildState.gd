extends RefCounted
class_name SourceTurretBuildState

const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

const SOURCE_TURRET_BUILD_INNER_CLASS := source_turret_source_text_state.SOURCE_TURRET_BUILD_INNER_CLASS
const SOURCE_TURRET_USE_AMMO_METHOD := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_METHOD
const SOURCE_TURRET_USE_AMMO_CHEATING_GUARD := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_CHEATING_GUARD

# Every block whose build is a TurretBuild: the three classes that
# extend Turret directly (ItemTurret.java:23, LiquidTurret.java:18,
# PowerTurret.java:8) and the two that extend them (LaserTurret
# extends PowerTurret, LaserTurret.java:15; ContinuousTurret extends
# Turret, ContinuousTurret.java:14). None of ItemTurretBuild,
# LiquidTurretBuild or PowerTurretBuild overrides updateTile, and
# LaserTurretBuild/ContinuousTurretBuild call super.updateTile()
# first (LaserTurret.java:67-68, ContinuousTurret.java:86-87), so
# TurretBuild.updateTile() (Turret.java:490) is the tick for all of
# them. ContinuousLiquidTurret is NOT here: it has its own driver
# (N2103). PointDefenseTurret extends ReloadTurret, TractorBeamTurret
# extends BaseTurret, RepairTurret extends Block and BuildTurret
# extends BaseTurret, so none of them is a TurretBuild.
const SOURCE_TURRET_BUILD_IMPLEMENTATIONS := ["ItemTurret", "LiquidTurret", "PowerTurret", "LaserTurret", "ContinuousTurret"]
const SOURCE_CONTINUOUS_LIQUID_TURRET_IMPLEMENTATION := "ContinuousLiquidTurret"
const SOURCE_TURRET_BUILDING_META_KEY := "source_turret_building"

static func _is_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The turret tick wires the frame keys the ammo path reads
	# (the N2102 pattern): block_implementation is the block's
	# implementation (Turret.java:36, `public class Turret extends
	# ReloadTurret{`), team_id and rules_state are what Java reads
	# as b.team and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(), TeamComp.java:17-19
	# `return team.rules().cheat;`, read through N2099's helper), so
	# a cheating team's turret skips ammo consumption like Java's
	# updateConsumption (BuildingComp.java:1944-1945, "everything is
	# valid when cheating"). A team with no rule keeps the false
	# default (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this turret (N2125); the tick preserves a disabled turret
	# instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill and ContinuousLiquidTurret frames).
	# A Turret-family sprite gets an empty frame bound; the live-loop
	# tick fills its keys every tick. Any other block, or an
	# already-bound sprite, binds nothing. A ContinuousLiquidTurret
	# binds nothing here: it has its own frame and driver (N2103).
	if block == null or not _is_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_turret_use_ammo_state(frame: Dictionary, turret_properties: Dictionary, stacks: Array, total_ammo: int) -> Dictionary:
	# TurretBuild.useAmmo() (Turret.java:680-690): a cheating turret
	# returns its peek ammo without consuming anything
	# (`if(cheating()) return peekAmmo();`) — the live-loop tick sets
	# frame["cheating"] from the team's live TeamRule every tick, so
	# a cheating ItemTurret fires without spending ammo. Otherwise
	# the ammo is consumed through the registered stack path
	# (entry.amount -= ammoPerShot, pop when empty, totalAmmo -=
	# ammoPerShot clamped at 0, return entry.type()).
	# ItemTurretBuild does not override useAmmo (ItemTurret.java has
	# no useAmmo; its build inherits TurretBuild.useAmmo), while
	# LiquidTurretBuild and PowerTurretBuild override it with their
	# own cheating branches (N1201, N1170) and never reach this path.
	var cheating := bool(frame.get("cheating", false))
	if cheating:
		var peeked: Dictionary = source_turret_ammo_state.peek_turret_ammo_state(turret_properties, stacks)
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_BUILD_USE_AMMO_STATE,
			"inner_class": SOURCE_TURRET_BUILD_INNER_CLASS,
			"method": SOURCE_TURRET_USE_AMMO_METHOD,
			"cheating_guard_expr": SOURCE_TURRET_USE_AMMO_CHEATING_GUARD,
			"cheating": true,
			"returned_ammo": peeked.get("ammo_data", {}),
			"stacks_after": stacks,
			"total_ammo_after": total_ammo,
			"used": false,
		}
	var used: Dictionary = source_turret_ammo_state.use_turret_ammo_state(turret_properties, stacks, total_ammo)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_BUILD_USE_AMMO_STATE,
		"inner_class": SOURCE_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_TURRET_USE_AMMO_METHOD,
		"cheating_guard_expr": SOURCE_TURRET_USE_AMMO_CHEATING_GUARD,
		"cheating": false,
		"returned_ammo": used.get("ammo_data", {}),
		# The registered stack path names its result
		# "ammo_entries_after" (the ammo stacks after the shot);
		# the useAmmo contract calls them the stacks after.
		"stacks_after": used.get("ammo_entries_after", []),
		"total_ammo_after": int(used.get("total_ammo_after", total_ammo)),
		"used": bool(used.get("used", false)),
	}

static func source_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.
	# nonOptionalConsumers){` / `minEfficiency = Math.min(
	# minEfficiency, result);`). The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a power turret does not take the early return. PowerTurret's
	# own live read is the same value (PowerTurret.java:30,
	# `return power == null ? 0f : power.status;`), and the
	# warmup fold is what the efficiency keys prove (Turret.java:512, `shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`).
	# Documented limits: (1) the tick models no other consumers --
	# foreshadow's item ammo and lustre's liquid nitrogen are not
	# first-pass rows in this driver yet, so the folded efficiency
	# is the min over the *modeled* consumers (power only); those
	# rows wait for their own slices. (2) The shouldConsume gate
	# is wired by N2253 (source_turret_should_consume_state,
	# TurretBuild.shouldConsume(), Turret.java:364-366, `return
	# isShooting || reloadCounter < reload;`): the tick does not
	# track targeting/reload state yet, so the driver reads frame
	# defaults (is_shooting=false, reload_counter=0.0,
	# reload=10f) and the gate preserves should_consume=true
	# when enabled. `!enabled` is handled by the machinery's
	# disabled branch, not here.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_turret_should_consume_state(frame: Dictionary, is_shooting: bool, reload_counter: float, reload: float) -> Dictionary:
	# TurretBuild overrides shouldConsume (Turret.java:364-366):
	# `public boolean shouldConsume(){`
	# `return isShooting || reloadCounter < reload;`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277), over the base default BuildingComp.shouldConsume
	# (BuildingComp.java:755-757): `public boolean shouldConsume(){`
	# `return enabled;`
	# updateConsumption forces efficiency to zero when the gate is false
	# (BuildingComp.java:1960): `boolean update = shouldConsume() && productionValid();`
	# (BuildingComp.java:1993): `efficiency = optionalEfficiency = 0f;`
	# The two inputs are TurretBuild fields: isShooting (Turret.java:292):
	# `public boolean wasShooting, isShooting;`
	# set in updateTile :492; and reloadCounter (ReloadTurret.java:26):
	# `public float reloadCounter;`
	# advanced in updateReload (Turret.java:720-723) and capped at reload
	# (Turret.java:723): `reloadCounter = Math.min(reloadCounter, reload);`
	# against the per-def reload time (ReloadTurret.java:10):
	# `public float reload = 10f;`
	# The same comparison is the canReload gate (ReloadTurret.java:50):
	# `return reloadCounter < reload;`
	# frame is accepted for the family call shape and reads no live frame
	# key: isShooting / reloadCounter / reload arrive as explicit params
	# (the N2188 precedent), because the tick frame tracks only
	# cheating / enabled / power_status / efficiency today. The comparison
	# is strict (< reload): a counter equal to reload is idle, matching
	# Java exactly.
	return {"should_consume": is_shooting or reload_counter < reload}

# TurretBuild.progress() (Turret.java:425-427):
# `public float progress(){`
# `return Mathf.clamp(reloadCounter / reload);`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), over the base default BuildingComp.progress
# (BuildingComp.java:617-619): `public float progress(){`
# `return 0f;`
# The two inputs are the same reload pair N2253 wires for
# shouldConsume: reloadCounter (ReloadTurret.java:26):
# `public float reloadCounter;`
# advanced in updateReload (Turret.java:720-723) and capped at reload
# (Turret.java:723): `reloadCounter = Math.min(reloadCounter, reload);`
# against the per-def reload time (ReloadTurret.java:10):
# `public float reload = 10f;`
# arc Mathf.clamp with one argument clamps to [0, 1] (the
# MendProjector precedent, SourceMendProjectorState.gd:41:
# `clamp(charge / reload_value, 0.0, 1.0)`), so a counter past
# reload reads 1 and a negative counter reads 0. The only live
# consumer is sense() case progress (Turret.java:414):
# `case progress -> progress();`
# -- the assigned N2255 slice; setBars (Turret.java:192-202)
# never reads progress(). frame is accepted for the family call
# shape and reads no live frame key: reloadCounter / reload
# arrive as explicit params (the N2188 precedent),
# because the tick frame tracks only cheating / enabled /
# power_status / efficiency today. NO driver line: wiring frame
# defaults would stamp a constant 0.0 progress (0.0 / 10f),
# not a live value -- pure function only, the N2251 / N2252
# precedent; sense() (N2255) calls it with explicit params.
@warning_ignore("unused_parameter")
static func source_turret_progress_state(frame: Dictionary, reload_counter: float, reload: float) -> Dictionary:
	return {"progress": clampf(reload_counter / reload, 0.0, 1.0)}

# TurretBuild.sense() (Turret.java:406-419):
# `public double sense(LAccess sensor){`
# `return switch(sensor){`
# `case ammo -> totalAmmo;`
# `case ammoCapacity -> maxAmmo;`
# `case rotation -> rotation;`
# `case shootX -> World.conv(targetPos.x);`
# `case shootY -> World.conv(targetPos.y);`
# `case shooting -> isShooting ? 1 : 0;`
# `case progress -> progress();`
# `default -> super.sense(sensor);`
# `};`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), over the base default BuildingComp.sense
# (BuildingComp.java:2093): `public double sense(LAccess sensor){`
# whose default is `default -> Float.NaN; //gets converted to null in logic`
# (BuildingComp.java:2123). The sensor spellings are the LAccess
# enum names `ammo,` (LAccess.java:18), `ammoCapacity,` (:19),
# `progress,` (:28), `rotation,` (:30), `shootX,` (:35),
# `shootY,` (:36), `shooting,` (:49). The inputs are TurretBuild
# fields: totalAmmo (Turret.java:283, `public int totalAmmo;`),
# maxAmmo (Turret.java:47, `public int maxAmmo = 30;`), targetPos
# (Turret.java:290, `public Vec2 targetPos = new Vec2();`),
# isShooting (Turret.java:292, `public boolean wasShooting,
# isShooting;`), and rotation, the Building int rotation
# (BuildingComp.java:69, `transient int rotation;`). World.conv
# (World.java:165-166, `public static float conv(float coord){`
# / `return coord / tilesize;`) divides by tilesize (Vars.java:135,
# `public static final int tilesize = 8;`). The progress case calls
# the N2254 pure function (`return Mathf.clamp(reloadCounter /
# reload);`, Turret.java:426) with explicit params (reloadCounter,
# ReloadTurret.java:26, `public float reloadCounter;`; reload,
# ReloadTurret.java:10, `public float reload = 10f;`). All live
# values arrive as explicit params (the N2188 precedent),
# because the tick frame tracks only cheating / enabled /
# power_status / efficiency today. NO driver line: sense is a logic
# read, not a tick write (the N2206 / N2208 / N2223 precedent); the
# logic-processor dispatch hook is its own later slice. The default
# leg falls through to super.sense, so it returns handled=false
# with a null NaN value for the caller to fall through.
@warning_ignore("unused_parameter")
static func source_turret_sense_state(frame: Dictionary, sensor: String, total_ammo: int, max_ammo: int, rotation: int, target_pos: Vector2, is_shooting: bool, reload_counter: float, reload: float, tilesize: float) -> Dictionary:
	match sensor:
		"ammo":
			return {"handled": true, "sense_value": float(total_ammo), "sense_value_is_nan": false}
		"ammoCapacity":
			return {"handled": true, "sense_value": float(max_ammo), "sense_value_is_nan": false}
		"rotation":
			return {"handled": true, "sense_value": float(rotation), "sense_value_is_nan": false}
		"shootX":
			return {"handled": true, "sense_value": target_pos.x / tilesize, "sense_value_is_nan": false}
		"shootY":
			return {"handled": true, "sense_value": target_pos.y / tilesize, "sense_value_is_nan": false}
		"shooting":
			return {"handled": true, "sense_value": 1.0 if is_shooting else 0.0, "sense_value_is_nan": false}
		"progress":
			return {"handled": true, "sense_value": float(source_turret_progress_state(frame, reload_counter, reload).get("progress", 0.0)), "sense_value_is_nan": false}
	return {"handled": false, "sense_value": null, "sense_value_is_nan": true}

@warning_ignore("unused_parameter")
static func source_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the turret tick wiring every tick
	# (TurretBuild.updateTile(), Turret.java:490, runs
	# updateConsumption through super.updateTile(); ItemTurretBuild,
	# LiquidTurretBuild and PowerTurretBuild do not override
	# updateTile, and LaserTurretBuild/ContinuousTurretBuild call
	# super.updateTile() first): each placed Turret-family build
	# gets its frame keys refreshed from the live rules, so the
	# frame's cheating flag tracks team.rules().cheat and useAmmo
	# skips consumption for a cheating team. The frame is bound at
	# placement (source_turret_bind_frame_state); a sprite that somehow
	# lacks one gets it bound here instead of crashing the loop. A
	# ContinuousLiquidTurret is skipped: it has its own driver
	# (N2103). The frame delta is not consumed by the wiring itself
	# (it only refreshes keys); a later slice that ticks shooting or
	# consumption reads it.
	var results_by_cell := {}
	var ticked_count := 0
	if game == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var catalog = game.get("content_catalog")
	if catalog == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if str(block.implementation) == SOURCE_CONTINUOUS_LIQUID_TURRET_IMPLEMENTATION:
			continue
		if not _is_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2148 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a turret with a power consumer folds the pure power row
		# into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup fold (Turret.java:512-514)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a power turret does not take the early return. A
		# turret with no power consumer is untouched: the tick
		# models no other consumers yet (foreshadow's item ammo
		# and lustre's liquid nitrogen wait for their own slices),
		# and the shouldConsume gate is wired by N2253
		# (source_turret_should_consume_state, Turret.java:364-366
		# `return isShooting || reloadCounter < reload;`): the
		# tick does not track targeting/reload state yet, so the
		# driver reads frame defaults (is_shooting=false,
		# reload_counter=0.0, reload=10f -- the Java field
		# defaults, boolean false / float 0f /
		# ReloadTurret.java:10) and the gate preserves
		# should_consume=true when enabled. productionValid is
		# the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(source_turret_should_consume_state(frame, bool(frame.get("is_shooting", false)), float(frame.get("reload_counter", 0.0)), float(frame.get("reload", 10.0))).get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
