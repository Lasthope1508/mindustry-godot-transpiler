extends RefCounted
class_name SourceShieldWallBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The ShieldWall implementation (ShieldWall.java:14, `public class ShieldWall extends Wall{`; ShieldWallBuild, ShieldWall.java:43, `public class ShieldWallBuild extends WallBuild{`): shielded-wall (consumePower 3f / 60f = 0.05, Blocks.java:1905, `consumePower(3f / 60f);`; size 2, health 260 * wallHealthMultiplier * 4, armor 15f, chanceDeflect 8f, Blocks.java:1903-1916). ShieldWall extends Wall, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_shield_wall_building", the launch-pad precedent), and this slice adds the shield-wall key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceShieldWall* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile regen advance (ShieldWall.java:80, `shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);`) regens by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a shield wall with no power would never regen -- its shield would sit frozen as if power.status were 1.0. And broken() (ShieldWall.java:92, `return breakTimer > 0 || !canConsume();`) with canConsume() (BuildingComp.java:1917-1919, `return potentialEfficiency > 0;`) means a powerless shield wall is broken and absorbs nothing.
const SOURCE_SHIELD_WALL_BUILD_IMPLEMENTATIONS := ["ShieldWall"]
const SOURCE_SHIELD_WALL_BUILDING_META_KEY := "source_shield_wall_building"

static func _is_shield_wall_build_implementation(implementation: String) -> bool:
	return SOURCE_SHIELD_WALL_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_shield_wall_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The shield-wall tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (ShieldWall.java:14, `public class ShieldWall extends Wall{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# shield wall skips consumption like Java's updateConsumption
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
	# for this shield wall (N2125); the tick preserves a disabled
	# shield wall instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_shield_wall_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the shield-wall frame meta key
	# ("source_shield_wall_building"). A ShieldWall sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_shield_wall_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_SHIELD_WALL_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_SHIELD_WALL_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_SHIELD_WALL_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_shield_wall_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shield wall does not take the early return. The updateTile advance follows the folded efficiency: the regen advance (ShieldWall.java:80, `shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);`) regens by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a shield wall with no power would never regen; the broken coupling (ShieldWall.java:92, `return breakTimer > 0 || !canConsume();`) with canConsume() (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) means a powerless shield wall is broken and absorbs nothing. The updateConsumption gate (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`) forces efficiency to zero when the gate is false. ShieldWallBuild has NO shouldConsume override, so the BuildingComp default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). The shield wall is its own family (ShieldWall.java:14, `public class ShieldWall extends Wall{`; ShieldWallBuild, ShieldWall.java:43, `public class ShieldWallBuild extends WallBuild{`). One def (shielded-wall, `consumePower(3f / 60f);`, Blocks.java:1905; shieldHealth 900f, breakCooldown 60f * 10f, regenSpeed 2f, ShieldWall.java:15-17, `public float shieldHealth = 900f;` / `public float breakCooldown = 60f * 10f;` / `public float regenSpeed = 2f;`; `update = true;`, ShieldWall.java:27; `public float shield = shieldHealth, shieldRadius = 0f;`, ShieldWall.java:44).
	# Documented limits: (1) power-only first pass -- the shield wall's only consumer is power (static ConsumePower, `consumePower(3f / 60f);`, Blocks.java:1905; no optional consumer in the def), so the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume override -- ShieldWallBuild has NO shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-757) applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) No updateTile shield regen advance -- shield regen / breakTimer decay / shieldRadius lerp / hit decay (ShieldWall.java:74-89) wait for their own slices; the proof carries no shield/shieldRadius/breakTimer keys, the regen advance (ShieldWall.java:80) is what the efficiency keys prove. (4) broken()/damage coupling NOT modeled -- broken() returns true when `!canConsume()` (ShieldWall.java:92), so a powerless shield wall absorbs no damage (ShieldWall.java:101-117, damage path); the broken/damage path waits for its own slice and must be recorded, not silently skipped. (5) Single def -- shielded-wall only (size 2, health 260 * wallHealthMultiplier * 4, armor 15f, chanceDeflect 8f); per-def stat values wait for their own verification slice. (6) BaseShield is a different class and NOT covered by this driver (its driver covers BaseShield only).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_shield_wall_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the shield-wall tick wiring every
	# tick (ShieldWallBuild.updateTile(), ShieldWall.java:74,
	# advances the shield by the regen advance (ShieldWall.java:80, `shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);`), so the regen advance follows the folded efficiency; no placed-buildings driver ticks ShieldWall blocks, so this driver is the placed-shield-wall tick): each placed ShieldWall build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_shield_wall_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_shield_wall_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_shield_wall_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a shield wall with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the regen advance (ShieldWall.java:80)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shield wall does not take the early return. A shield wall with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and ShieldWallBuild has NO shouldConsume override -- the BuildingComp default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) applies, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_shield_wall_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
