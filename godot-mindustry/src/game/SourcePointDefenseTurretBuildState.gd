extends RefCounted
class_name SourcePointDefenseTurretBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The PointDefenseTurret implementation (PointDefenseTurret.java:19,
# `public class PointDefenseTurret extends ReloadTurret{`): segment
# (consumePower 8f, size 2, range 180f, reload 8f, bulletDamage 30f,
# shootLength 5f, hasPower true). The only PointDefenseTurret block
# in the game (Blocks.java:3835-3847). PointDefenseBuild extends
# ReloadTurretBuild, NOT TurretBuild, so the turret driver
# (SourceTurretBuildState.gd) explicitly excludes it and no driver
# ticks it at all: it would rotate and reload as if power.status
# were 1.0. This driver is the point-defense tick. The driver uses
# its own family frame key ("source_point_defense_turret_building",
# the turret precedent); the generic turret frame
# ("source_turret_building") stays untouched, and this slice adds
# the point-defense key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_POINT_DEFENSE_TURRET_BUILD_IMPLEMENTATIONS := ["PointDefenseTurret"]
const SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY := "source_point_defense_turret_building"

static func _is_point_defense_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_POINT_DEFENSE_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_point_defense_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The point-defense tick wires the frame keys the consumption
	# path reads (the N2148 turret pattern): block_implementation
	# is the block's implementation (PointDefenseTurret.java:19,
	# `public class PointDefenseTurret extends ReloadTurret{`),
	# team_id and rules_state are what Java reads as b.team and
	# state.rules, and cheating is the team's live TeamRule value
	# (TeamComp.cheating(), TeamComp.java:17-19 `return team.rules().cheat;`,
	# read through N2099's helper), so a cheating team's segment
	# skips consumption like Java's updateConsumption
	# (BuildingComp.java:1944-1945, "everything is valid when
	# cheating"). A team with no rule keeps the false default
	# (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this segment (N2125); the tick preserves a disabled
	# segment instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"target": null}

static func source_point_defense_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the point-defense frame meta key
	# ("source_point_defense_turret_building"). A PointDefenseTurret
	# sprite gets a frame bound with the target key defaulting to
	# null (the Java field `public @Nullable Bullet target;`,
	# PointDefenseTurret.java:59, defaults to null); the live-loop
	# tick fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_point_defense_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_point_defense_turret_should_consume_state(frame: Dictionary) -> Dictionary:
	# PointDefenseBuild overrides shouldConsume (PointDefenseTurret.java:105, `public boolean shouldConsume(){` with `return super.shouldConsume() && target != null;`, PointDefenseTurret.java:106): the gate reads the enabled flag through super AND the live bullet target. The field is `public @Nullable Bullet target;` (PointDefenseTurret.java:59) -- the target is a BULLET, not a Unit -- on PointDefenseBuild (`public class PointDefenseBuild extends ReloadTurretBuild{`, PointDefenseTurret.java:58); `super` is the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) -- the chain runs PointDefenseBuild -> ReloadTurretBuild (ReloadTurret.java:25) -> BaseTurretBuild (BaseTurret.java:113) -> Building, and neither ReloadTurret.java nor BaseTurret.java overrides shouldConsume, so the default applies. Turret.TurretBuild.shouldConsume() (Turret.java:364-366, `return isShooting || reloadCounter < reload;`) is NOT in this chain -- PointDefenseTurret extends ReloadTurret (PointDefenseTurret.java:19, `public class PointDefenseTurret extends ReloadTurret{`), not Turret. The gate is `enabled && target != null`, so the pure gate reads both frame keys (the RepairTurret N2212 precedent: the super default is read as an internal frame key): target (frame["target"], default null for a frame bound before this slice -- the Java field default) and enabled (frame["enabled"], default true -- BuildingComp.java:77, `transient boolean enabled = true;`); no live fill sets frame["target"] yet -- the live bullet-target retarget (Groups.bullet scan, PointDefenseTurret.java:66, `target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));`, plus the clear when the bullet is pooled, PointDefenseTurret.java:70, `if(target != null && !target.isAdded()){`) is the updateTile advance (PointDefenseTurret.java:62-103) and waits for its own slice. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The rotation advance (PointDefenseTurret.java:81, `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());`) follows the folded efficiency. The only def is segment (Blocks.java:3835-3847): `consumePower(8f);`, `range = 180f;`, `reload = 8f;`, size 2.
	var target: Variant = frame.get("target", null)
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": enabled and target != null, "has_target": target != null}

static func source_point_defense_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a segment does not take the early return. The
	# point-defense rotation and reload follow the folded
	# efficiency through edelta (BuildingComp.java:1928, `return efficiency * delta();`,
	# PointDefenseTurret.java:81, `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());`).
	# Documented limits: (1) power-only first pass -- segment
	# has no other consumers; the folded efficiency is the min
	# over the *modeled* consumers (power only). (2)
	# shouldConsume gate live (N2217) -- PointDefenseBuild.
	# shouldConsume() (PointDefenseTurret.java:105-107, `return
	# super.shouldConsume() && target != null;`); when the gate
	# is false Java forces efficiency to 0 (BuildingComp.java:
	# 1960 + 1992-1994); the pure gate reads the frame target
	# key (default null) plus enabled and feeds should_consume
	# to the machinery; no live fill sets frame["target"] yet
	# (the live bullet-target retarget is the updateTile
	# advance, PointDefenseTurret.java:62-103).
	# (3) No updateTile advance -- retarget / rotation /
	# reloadCounter / beam effects (PointDefenseTurret.java:62-103)
	# waits for its own slice; the proof carries no progress keys,
	# the edelta fold (PointDefenseTurret.java:81-82) is what the
	# efficiency keys prove.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_point_defense_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the point-defense tick wiring every tick
	# (PointDefenseBuild.updateTile(), PointDefenseTurret.java:62,
	# reads the folded efficiency for its rotation and reload; the
	# turret driver never ticks PointDefenseTurret implementations,
	# so this driver is the point-defense tick): each placed
	# PointDefenseTurret build gets its frame keys refreshed from
	# the live rules, so the frame's cheating flag tracks
	# team.rules().cheat and the consumption machinery skips
	# consumption for a cheating team. The frame is bound at
	# placement; a sprite that somehow lacks one gets it bound
	# here instead of crashing the loop.
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
		if not _is_point_defense_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_point_defense_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_point_defense_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2151 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a segment with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the edelta fold (PointDefenseTurret.java:81-82)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a segment does not take the early return. A segment
		# with no power consumer is untouched: the tick models no
		# other consumers yet (the updateTile advance waits for
		# its own slice), and PointDefenseBuild overrides
		# shouldConsume (PointDefenseTurret.java:105, `public
		# boolean shouldConsume(){` with `return super.
		# shouldConsume() && target != null;`,
		# PointDefenseTurret.java:106) -- N2217 feeds the live
		# gate to the machinery (the pure gate is source_point_
		# defense_turret_should_consume_state, fed the frame);
		# the N2151 RED decision is resolved. The gate reads the
		# enabled flag through super (the BuildingComp default,
		# `return enabled;`, BuildingComp.java:755-756), so the
		# pure gate reads frame["enabled"] too (the RepairTurret
		# N2212 precedent); the outer guard below already runs
		# the machinery only when enabled. productionValid is
		# the canonical true default (SourceBuildingAccessState.
		# production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_point_defense_turret_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_point_defense_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
