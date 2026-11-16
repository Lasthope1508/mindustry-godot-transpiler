extends RefCounted
class_name SourceShieldWallBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

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

static func source_shield_wall_broken_state(frame: Dictionary) -> Dictionary:
	# broken() (ShieldWall.java:91, `public boolean broken(){` with `return breakTimer > 0 || !canConsume();`, ShieldWall.java:92) over the break timer (ShieldWall.java:45, `public float breakTimer;`, decayed by ShieldWall.java:75-76, `if(breakTimer > 0){` / `breakTimer -= Time.delta;`, and set by ShieldWall.java:110, `breakTimer = breakCooldown;`, when the shield breaks, breakCooldown 60f * 10f, ShieldWall.java:16) and canConsume() (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) over the potential efficiency (BuildingComp.java:89, `transient float potentialEfficiency;`, assigned by BuildingComp.java:1989, `potentialEfficiency = efficiency;`, zeroed when disabled by BuildingComp.java:1955, `potentialEfficiency = efficiency = optionalEfficiency = 0f;`, and set to enabled && productionValid when cheating or without consumers by BuildingComp.java:1946, `potentialEfficiency = enabled && productionValid() ? 1f : 0f;`). The shield regen advance (ShieldWall.java:80, `shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);`) regens by edelta(), and edelta() is efficiency * delta (BuildingComp.java:1927-1929, `return efficiency * delta();`); the shield radius lerp reads broken() (ShieldWall.java:88, `shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);`) and the damage path reads it too (ShieldWall.java:102, `float shieldTaken = broken() ? 0f : Math.min(shield, damage);`). The frame carries the break timer as `break_timer` (float) and the live potential efficiency as `potential_efficiency` (float, stamped by the N2175 machinery); the function reads break_timer with a 0.0 default, so an absent key means "no break in progress", and potential_efficiency with a 1.0 default, so an absent key means "no machinery run yet", not "no power". break_timer>0 breaks the wall (broken true); break_timer=0 with potential_efficiency=0 breaks it (broken true -- the power coupling: no power = broken); break_timer=0 with potential_efficiency>0 leaves it whole (broken false) -- all observed cases run through the one disjunction, `break_timer > 0.0 or not can_consume_state(potential_efficiency)`, where can_consume_state is the canonical BuildingComp.canConsume() model (SourceBuildingEfficiencyState.gd:84-85, `potential_efficiency > 0.0`).
	var break_timer: float = float(frame.get("break_timer", 0.0))
	var potential_efficiency: float = float(frame.get("potential_efficiency", 1.0))
	var broken: bool = break_timer > 0.0 or not source_building_efficiency_state.can_consume_state(potential_efficiency)
	return {"broken": broken}

static func source_shield_wall_damage_state(frame: Dictionary, damage: float) -> Dictionary:
	# The pure damage() coupling lives on the shield-wall build state: damage() (ShieldWall.java:100, `public void damage(float damage){`) absorbs `float shieldTaken = broken() ? 0f : Math.min(shield, damage);` (ShieldWall.java:102) -- broken() is the N2202 coupling (ShieldWall.java:91, `public boolean broken(){` with `return breakTimer > 0 || !canConsume();`, ShieldWall.java:92) over the break timer (ShieldWall.java:45, `public float breakTimer;`, set by ShieldWall.java:110, `breakTimer = breakCooldown;`, breakCooldown 60f * 10f, ShieldWall.java:16) and canConsume() (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) over the potential efficiency (BuildingComp.java:89, `transient float potentialEfficiency;`). The shield drops by the absorbed amount (`shield -= shieldTaken;`, ShieldWall.java:104) from its field init (`public float shield = shieldHealth, shieldRadius = 0f;`, ShieldWall.java:44, shieldHealth 900f, ShieldWall.java:15); anything absorbed flashes hit (`if(shieldTaken > 0){` / `hit = 1f;`, ShieldWall.java:105-106, hit declared in WallBuild, Wall.java:89, `protected float hit;`); a shield driven to zero breaks the wall (`if(shield <= 0.00001f && shieldTaken > 0){` / `breakTimer = breakCooldown;`, ShieldWall.java:109-110); only the leftover damage reaches the building (`if(damage - shieldTaken > 0){` / `super.damage(damage - shieldTaken);`, ShieldWall.java:113-114), and super.damage is BuildingComp.damage(float) (BuildingComp.java:2059, `public void damage(float damage){` with `if(dead()) return;`, BuildingComp.java:2060, `health -= handleDamage(damage);`, BuildingComp.java:2071, and `if(health <= 0){`, BuildingComp.java:2076). The shield regen advance (ShieldWall.java:80, `shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) is what refills the shield between hits; the radius lerp reads broken() (ShieldWall.java:88, `shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);`). The power row is ConsumePower.efficiency (ConsumePower.java:39, `return build.power.status;`); one def (shielded-wall, `consumePower(3f / 60f);`, Blocks.java:1905; regenSpeed 2f, ShieldWall.java:17; `update = true;`, ShieldWall.java:27). The shield wall is its own family (ShieldWall.java:14, `public class ShieldWall extends Wall{`; ShieldWallBuild, ShieldWall.java:43, `public class ShieldWallBuild extends WallBuild{`). The frame carries the shield as `shield` (float, absent defaults to shieldHealth 900.0 -- absent means "shield never damaged yet", not "shield gone"), the hit flash as `hit` (float, absent defaults to 0.0), the break timer as `break_timer` (float, N2202 default 0.0) and the live potential efficiency as `potential_efficiency` (float, N2202 default 1.0); broken() comes from the N2202 pure function, never re-implemented. shield_taken is 0 when broken, else min(shield, damage); the shield drops by the absorbed amount; hit flashes to 1.0 only when something was absorbed; a shield driven to zero sets break_timer to breakCooldown (60f * 10f); the residual is damage minus shield_taken, returned for the caller -- no live damage call site applies it to building health yet.
	var shield: float = float(frame.get("shield", 900.0))
	var hit: float = float(frame.get("hit", 0.0))
	var break_timer: float = float(frame.get("break_timer", 0.0))
	var broken: bool = bool(source_shield_wall_broken_state(frame).get("broken", false))
	var shield_taken: float = 0.0 if broken else minf(shield, damage)
	shield -= shield_taken
	if shield_taken > 0.0:
		hit = 1.0
	if shield <= 0.00001 and shield_taken > 0.0:
		break_timer = 60.0 * 10.0
	var residual_damage: float = 0.0
	residual_damage = damage - shield_taken
	return {"shield_taken": shield_taken, "shield": shield, "hit": hit, "break_timer": break_timer, "residual_damage": residual_damage}

static func source_shield_wall_update_tile_state(frame: Dictionary, delta: float) -> Dictionary:
	# The pure updateTile() advance lives on the shield-wall build state: updateTile() (ShieldWall.java:74, `public void updateTile(){`) decays the break timer by the raw delta while broken (`if(breakTimer > 0){` / `breakTimer -= Time.delta;`, ShieldWall.java:75-76, no clamp -- the timer may go slightly negative and broken() reads `breakTimer > 0`), regens the shield while whole (`shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);`, ShieldWall.java:80, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) with edelta() = efficiency * delta() (BuildingComp.java:1927-1928, `public float edelta(){` with `return efficiency * delta();`, and `public float delta(){` with `return Time.delta * timeScale;`, BuildingComp.java:1922-1923 -- timeScale is 1 by default and the port passes the raw tick seconds, the N2190 driver convention), decays the hit flash (`if(hit > 0){` / `hit -= Time.delta / 10f;` / `hit = Math.max(hit, 0f);`, ShieldWall.java:83-86, hit declared in WallBuild, Wall.java:89, `protected float hit;`), and lerps the shield radius toward broken() ? 0f : 1f (`shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);`, ShieldWall.java:88) through the port's canonical lerpDelta (SourceMathState.source_lerp_delta). broken() is the N2202 coupling (ShieldWall.java:91, `public boolean broken(){` with `return breakTimer > 0 || !canConsume();`, ShieldWall.java:92) over the break timer (ShieldWall.java:45, `public float breakTimer;`, set by ShieldWall.java:110, `breakTimer = breakCooldown;`, breakCooldown 60f * 10f, ShieldWall.java:16) and canConsume() (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) over the potential efficiency (BuildingComp.java:89, `transient float potentialEfficiency;`); the folded efficiency is the transient field (BuildingComp.java:85, `transient float efficiency;`), default 0.0 before the first machinery run. A disabled wall is broken and never regens: updateConsumption zeroes the efficiencies first (`if(!enabled){` with `potentialEfficiency = efficiency = optionalEfficiency = 0f;`, BuildingComp.java:1954-1955), so the driver zeroes them before the call. The power row is ConsumePower.efficiency (ConsumePower.java:39, `return build.power.status;`); one def (shielded-wall, `consumePower(3f / 60f);`, Blocks.java:1905; shieldHealth 900f, breakCooldown 60f * 10f, regenSpeed 2f, ShieldWall.java:15-17; `update = true;`, ShieldWall.java:27). The shield wall is its own family (ShieldWall.java:14, `public class ShieldWall extends Wall{`; ShieldWallBuild, ShieldWall.java:43, `public class ShieldWallBuild extends WallBuild{`). The frame carries the shield as `shield` (float, absent defaults to shieldHealth 900.0 -- the field init, ShieldWall.java:44, `public float shield = shieldHealth, shieldRadius = 0f;`), the break timer as `break_timer` (float, N2202 default 0.0), the hit flash as `hit` (float, N2203 default 0.0), the shield radius as `shield_radius` (float, absent defaults to 0.0 -- the Java field init, ShieldWall.java:44), the folded efficiency as `efficiency` (float, absent defaults to 0.0 -- the transient field default, the N2192 charge precedent) and the live potential efficiency as `potential_efficiency` (float, N2202 default 1.0); broken() comes from the N2202 pure function evaluated on the UPDATED break timer, never re-implemented and never read off the stale frame. The regen branch is decided on the PRE-update timer (the if/else, ShieldWall.java:75-81), so a timer that crosses zero this tick does NOT regen yet; broken() for the radius lerp is read AFTER the decay, so the pure function evaluates it on the updated timer (via a duplicated frame), never on the stale one.
	var shield: float = float(frame.get("shield", 900.0))
	var break_timer: float = float(frame.get("break_timer", 0.0))
	var hit: float = float(frame.get("hit", 0.0))
	var shield_radius: float = float(frame.get("shield_radius", 0.0))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var potential_efficiency: float = float(frame.get("potential_efficiency", 1.0))
	if break_timer > 0.0:
		break_timer -= delta
	else:
		shield = clampf(shield + 2.0 * efficiency * delta, 0.0, 900.0)
	if hit > 0.0:
		hit -= delta / 10.0
		hit = maxf(hit, 0.0)
	var advanced_frame: Dictionary = {}
	advanced_frame["break_timer"] = break_timer
	advanced_frame["potential_efficiency"] = potential_efficiency
	var broken: bool = bool(source_shield_wall_broken_state(advanced_frame).get("broken", false))
	shield_radius = source_math_state.source_lerp_delta(shield_radius, 0.0 if broken else 1.0, 0.12, delta)
	return {"shield": shield, "break_timer": break_timer, "hit": hit, "shield_radius": shield_radius, "broken": broken}

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
			# The broken coupling reads the fresh potential_efficiency the machinery just stamped: broken() (ShieldWall.java:92, `return breakTimer > 0 || !canConsume();`) with canConsume() (BuildingComp.java:1918, `return potentialEfficiency > 0;`) means a powerless shield wall is broken the same tick the power drops, so the flag is stamped here, after the machinery, inside the consumption block (the N2201 precedent). A disabled or cheating shield wall keeps its last stamped broken value from this block -- the driver skips the whole consumption block there (the N2188/N2201 precedent); the updateTile advance below re-stamps broken outside the consumption gate.
			frame["broken"] = bool(source_shield_wall_broken_state(frame).get("broken", false))
		# The updateTile advance runs for every ticked shield wall, after the consumption block (updateConsumption runs BEFORE updateTile in Java, ShieldWall.java:74, `public void updateTile(){`, so the advance reads this tick's freshly stamped efficiency): a disabled wall is broken and never regens, so its efficiencies are zeroed first (`if(!enabled){` with `potentialEfficiency = efficiency = optionalEfficiency = 0f;`, BuildingComp.java:1954-1955), and broken is re-stamped outside the consumption gate (the N2203 handoff note).
		if not bool(frame.get("enabled", true)):
			frame["potential_efficiency"] = 0.0
			frame["efficiency"] = 0.0
		var advanced: Dictionary = source_shield_wall_update_tile_state(frame, seconds)
		frame["shield"] = advanced.get("shield", 900.0)
		frame["break_timer"] = advanced.get("break_timer", 0.0)
		frame["hit"] = advanced.get("hit", 0.0)
		frame["shield_radius"] = advanced.get("shield_radius", 0.0)
		frame["broken"] = advanced.get("broken", false)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
