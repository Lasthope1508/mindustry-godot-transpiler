extends RefCounted
class_name SourceBeamDrillBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_drill_inventory_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The BeamDrill implementation (BeamDrill.java:25, `public class
# BeamDrill extends Block{`): plasma-bore (consumePower 0.15f,
# drillTime 160f, tier 3, size 2, range 5, hydrogen 0.25f/60f
# booster) and large-plasma-bore (consumePower 0.8f, drillTime
# 100f, tier 5, size 3, range 6, hydrogen 0.5f/60f + nitrogen
# 3f/60f booster). Both havePower=true. BeamDrill extends Block,
# NOT Drill, so it cannot reuse the drill frame key
# ("source_drill_building", bound by the drill proximity path
# for DrillBuild); this driver uses its own family frame key
# ("source_beam_drill_building", the mechanical-pump precedent),
# and this slice adds the beam-drill key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_BEAM_DRILL_BUILD_IMPLEMENTATIONS := ["BeamDrill"]
const SOURCE_BEAM_DRILL_BUILDING_META_KEY := "source_beam_drill_building"
# BeamDrill.java:44, `public float optionalBoostIntensity = 2.5f;`
# -- the class boost intensity; neither def overrides it
# (Blocks.java:3038-3061 only override drillTime, 160f /
# 100f), so both plasma-bore and large-plasma-bore share 2.5.
const SOURCE_BEAM_DRILL_OPTIONAL_BOOST_INTENSITY := 2.5
# BeamDrill.java:242 warmup speed `1f / 60f` and BeamDrill.java:248
# boost-warmup rate `0.1f`, the approachDelta / lerpDelta rates.
const SOURCE_BEAM_DRILL_WARMUP_SPEED := 1.0 / 60.0
const SOURCE_BEAM_DRILL_BOOST_WARMUP_RATE := 0.1

static func _is_beam_drill_build_implementation(implementation: String) -> bool:
	return SOURCE_BEAM_DRILL_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_beam_drill_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The beam-drill tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (BeamDrill.java:25, `public class BeamDrill extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# beam drill skips consumption like Java's updateConsumption
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
	# for this beam drill (N2125); the tick preserves a disabled
	# beam drill instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# The shouldConsume gate inputs (N2202): the item store
	# (frame["items"], the Building.items ItemModule, a
	# Dictionary keyed by item name, the factory precedent
	# SourceFactoryBuildState.gd:89-101) and the facing wall-ore
	# count (frame["facing_amount"], BeamDrill.java:228,
	# `public int facingAmount;`, Java default 0). The tick
	# preserves both instead of resetting them: the production
	# advance fills items and the facing scan fills
	# facing_amount, and both wait for their own slices -- the
	# gate reads the current frame.
	var stored_items: Variant = frame.get("items", {})
	frame["items"] = stored_items if stored_items is Dictionary else {}
	frame["facing_amount"] = int(frame.get("facing_amount", 0))
	return frame

static func _initial_frame() -> Dictionary:
	return {"items": {}, "facing_amount": 0}

static func source_beam_drill_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the beam-drill frame meta key
	# ("source_beam_drill_building"). A BeamDrill sprite gets a
	# frame bound with the Java field defaults (items {},
	# facing_amount 0); the live-loop tick fills its other keys
	# every tick. Any other block, or an already-bound sprite,
	# binds nothing.
	if block == null or not _is_beam_drill_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_BEAM_DRILL_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_BEAM_DRILL_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_BEAM_DRILL_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_beam_drill_should_consume_state(frame: Dictionary, item_capacity: int) -> Dictionary:
	# BeamDrillBuild.shouldConsume (BeamDrill.java:270, `public boolean shouldConsume(){` with `return items.total() < itemCapacity && facingAmount > 0 && enabled;`, BeamDrill.java:271): the beam drill consumes only while its item store is under capacity AND at least one facing tile holds mineable wall ore AND it is enabled. BeamDrill extends Block (BeamDrill.java:25, `public class BeamDrill extends Block{`), NOT Drill, and BeamDrillBuild extends Building (BeamDrill.java:220, `public class BeamDrillBuild extends Building{`), so the gate lives on this family driver, not the drill frame. facingAmount is a plain int field (BeamDrill.java:228, `public int facingAmount;`, Java default 0), recomputed by `updateFacing();` (BeamDrill.java:375-410, called from updateTile :244 and onProximityUpdate :365): `facingAmount = 0;` then `facingAmount ++;` per mineable facing tile, where mineable is `if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){` (BeamDrill.java:391) -- for each of the size facing lasers it walks range tiles along the rotation, takes the first solid tile, and counts it when its wallDrop passes that check. The live facing scan waits for its own slice (the facing/laser binding deferral stays); this gate reads frame["facing_amount"], which the tick preserves at the Java default 0 until the scan lands. The items total reuses the drill inventory helper (SourceDrillInventoryRuntimeState.items_total over frame["items"], the Building.items ItemModule); the production advance that fills the store (BeamDrill.java:253-261) waits for its own slice, so the gate reads the current frame. item_capacity comes from the catalog (block.properties["itemCapacity"]): 10 for plasma-bore (the Block.java:75 field default, `public int itemCapacity = 10;`) and 20 for large-plasma-bore (Blocks.java:3062, `itemCapacity = 20;`). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The gate reads the previous tick's facingAmount -- updateConsumption runs before updateTile (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), so the updateFacing recompute lands after the fold; correct per Java, not a bug.
	var stored_items: Variant = frame.get("items", {})
	var items: Dictionary = stored_items if stored_items is Dictionary else {}
	var items_total: int = source_drill_inventory_runtime_state.items_total(items)
	var facing_amount: int = int(frame.get("facing_amount", 0))
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": items_total < item_capacity and facing_amount > 0 and enabled, "items_total": items_total, "facing_amount": facing_amount}

static func source_beam_drill_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a beam drill does not take the early return. The
	# beam-drill speed follows the folded efficiency
	# (BeamDrill.java:249, `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`), with the warmup gate (BeamDrill.java:242, `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 60f);`) and the boost multiplier (BeamDrill.java:246, `float multiplier = Mathf.lerp(1f, optionalBoostIntensity, optionalEfficiency);`).
	# Documented limits: (1) power-only first pass -- the
	# plasma hydrogen booster and large hydrogen + nitrogen
	# booster liquid rows wait for their own slices, so the
	# folded efficiency is the min over the *modeled*
	# consumers (power only). (2) shouldConsume gate live (N2202)
	# -- BeamDrillBuild.shouldConsume() (BeamDrill.java:270-271,
	# `return items.total() < itemCapacity && facingAmount > 0 && enabled;`) feeds the pure gate to the machinery, so a
	# full store, no facing ore, or a disabled drill folds
	# efficiency to 0; the live facing scan that fills
	# facing_amount and the production advance that fills items
	# wait for their own slices, so the gate reads the current
	# frame. (3) Partial updateTile
	# advance (N2195) -- warmup / boostWarmup / multiplier /
	# time advance each tick (BeamDrill.java:242-251); still
	# deferred: updateLasers / updateFacing / facingAmount,
	# the drop loop + `time %= drillTime;` reset +
	# lastDrillSpeed (BeamDrill.java:249, 253-262, needs
	# lastItem / facing / items state the tick does not
	# track), and the dump timer (BeamDrill.java:264-266).
	# Until the reset slice lands, time grows unbounded.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_beam_drill_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float) -> Dictionary:
	# The updateTile advance, internal part
	# (BeamDrillBuild.updateTile(), BeamDrill.java:237-263):
	# `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 60f);`
	# (BeamDrill.java:242), `float multiplier = Mathf.lerp(1f, optionalBoostIntensity, optionalEfficiency);`
	# (BeamDrill.java:246), `boostWarmup = Mathf.lerpDelta(boostWarmup, optionalEfficiency, 0.1f);`
	# (BeamDrill.java:248), `time += edelta() * multiplier;`
	# (BeamDrill.java:251). The Arc formulas, not guesses:
	# approachDelta(from, to, speed) = approach(from, to,
	# Time.delta * speed) with approach = from + clamp(to -
	# from, -speed, speed), lerpDelta(from, to, progress) =
	# lerp(from, to, clamp(progress * Time.delta)) with lerp
	# = from + (to - from) * progress and clamp(value) =
	# clamp(value, 0, 1), num(b) = b ? 1 : 0
	# (Mathf.java:208-210, 402-404, 415-432). source_delta is
	# Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26); edelta() =
	# efficiency * delta() with delta() = Time.delta *
	# timeScale (BuildingComp.java:1922-1929). efficiency and
	# optionalEfficiency default 0.0, the Java field defaults
	# (BuildingComp.java:85 `transient float efficiency;` /
	# :87 `transient float optionalEfficiency;`); warmup /
	# boostWarmup / time default 0.0, the Java build-field
	# defaults (BeamDrill.java:225-226). optionalEfficiency
	# is folded by the shared machinery before this runs
	# (apply_update_consumption_state stamps
	# frame["optional_efficiency"]; with no optional rows
	# modeled yet it is min(1.0, minEfficiency),
	# BuildingComp.java:1965/1986). Deferred, not done here:
	# updateLasers / updateFacing (BeamDrill.java:240, 244),
	# the drop loop + `time %= drillTime;` reset +
	# lastDrillSpeed (BeamDrill.java:249, 253-262, needs
	# lastItem, which updateFacing sets), and the dump timer
	# (BeamDrill.java:264-266); until the reset slice lands,
	# time grows unbounded.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var boost_warmup: float = float(frame.get("boost_warmup", 0.0))
	var time: float = float(frame.get("time", 0.0))
	var target: float = 1.0 if efficiency > 0.0 else 0.0
	var step: float = source_delta * SOURCE_BEAM_DRILL_WARMUP_SPEED
	var next_warmup: float = warmup + clampf(target - warmup, -step, step)
	var multiplier: float = lerpf(1.0, SOURCE_BEAM_DRILL_OPTIONAL_BOOST_INTENSITY, optional_efficiency)
	var next_boost_warmup: float = lerpf(boost_warmup, optional_efficiency, clampf(SOURCE_BEAM_DRILL_BOOST_WARMUP_RATE * source_delta, 0.0, 1.0))
	var next_time: float = time + efficiency * source_delta * time_scale * multiplier
	return {"warmup": next_warmup, "boost_warmup": next_boost_warmup, "multiplier": multiplier, "time": next_time}

static func source_beam_drill_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the beam-drill tick wiring every
	# tick (BeamDrillBuild.updateTile(), BeamDrill.java:237,
	# gates on the warmup gate (BeamDrill.java:242,
	# `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 60f);`) and folds the
	# lastDrillSpeed (BeamDrill.java:249,
	# `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`), so the
	# lastDrillSpeed fold follows the folded efficiency; no
	# placed-buildings driver ticks BeamDrill blocks, so this
	# driver is the placed-beam-drill tick): each placed
	# BeamDrill build gets its frame keys refreshed from the
	# live rules, so the frame's cheating flag tracks
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
		if not _is_beam_drill_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_beam_drill_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_beam_drill_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a beam drill with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the lastDrillSpeed fold (BeamDrill.java:249)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a beam
		# drill does not take the early return. A beam drill with
		# no power consumer is untouched: the tick models no other
		# consumers yet (the plasma hydrogen booster and large
		# hydrogen + nitrogen booster liquid rows wait for their
		# own slices). BeamDrillBuild.shouldConsume
		# (BeamDrill.java:270-271) is live since N2202: the pure
		# gate (source_beam_drill_should_consume_state, fed the
		# frame's items/facing_amount/enabled and the catalog
		# itemCapacity) feeds should_consume to the machinery, so
		# a full store, no facing ore, or a disabled drill folds
		# efficiency to 0 like Java.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_beam_drill_should_consume_state(frame, int(block.properties.get("itemCapacity", 10)))
			var should_consume: bool = bool(frame.get("enabled", true)) and bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_beam_drill_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2195: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2275
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2277-2279; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled beam drill's
		# warmup DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and time freezes (edelta() is 0). The port keeps the
		# enabled gate below as a pragmatic choice: the driver
		# skips the consumption fold when disabled, so the
		# frame efficiency goes stale and running the advance
		# on it would charge warmup/time from a stale
		# efficiency. The driver-wide disabled-early-return
		# slice (deferred in the N2195 register) removes this
		# gate for all families. super.updateTile() is an
		# empty no-op (BuildingComp.java:2010-2012), so the
		# driver owes it nothing. The source delta is
		# Time.delta in ticks: game_source_delta(game, seconds)
		# is seconds * 60 (arc Time.java:26), never raw seconds.
		# timeScale reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`).
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advanced: Dictionary = source_beam_drill_update_tile_advance_state(frame, source_delta, time_scale)
			frame["warmup"] = advanced["warmup"]
			frame["boost_warmup"] = advanced["boost_warmup"]
			frame["multiplier"] = advanced["multiplier"]
			frame["time"] = advanced["time"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
