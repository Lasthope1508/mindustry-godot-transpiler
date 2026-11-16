extends RefCounted
class_name SourceLaunchPadBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The LaunchPad implementation (LaunchPad.java:30, `public class LaunchPad extends Block{`): launch-pad (consumePower 4f, Blocks.java:6797, `consumePower(4f);`; size 3, itemCapacity 100, launchTime 60f * 20, Blocks.java:6790-6797) and advanced-launch-pad (consumePower 8f, Blocks.java:6809, `consumePower(8f);`; size 4, itemCapacity 100, launchTime 60f * 30, liquidCapacity 40f, drawLiquid oil, consumeLiquid oil 9f/60f, Blocks.java:6800-6809). LaunchPad extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_launch_pad_building", the wall-crafter precedent), and this slice adds the launch-pad key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceLaunchPad* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`) advances launchCounter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a launch pad with no power would never launch -- its launchCounter would sit frozen as if power.status were 1.0.
const SOURCE_LAUNCH_PAD_BUILD_IMPLEMENTATIONS := ["LaunchPad"]
const SOURCE_LAUNCH_PAD_BUILDING_META_KEY := "source_launch_pad_building"

# The per-def launchTime (N2205): launch-pad 1200f (Blocks.java:6794,
# `launchTime = 60f * 20;`) and advanced-launch-pad 1800f
# (Blocks.java:6804, `launchTime = 60f * 30;`), overriding the class
# default `public float launchTime = 1f;` (LaunchPad.java:32). The
# catalog carries no launchTime property
# (content_registry.json blocks[404]/[405] properties), so the driver
# selects the per-def value by block id here and passes it to the
# shouldConsume gate; an unknown id falls back to the class default.
const SOURCE_LAUNCH_PAD_LAUNCH_TIMES := {"launch-pad": 1200.0, "advanced-launch-pad": 1800.0}

static func _is_launch_pad_build_implementation(implementation: String) -> bool:
	return SOURCE_LAUNCH_PAD_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_launch_pad_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The launch-pad tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (LaunchPad.java:30, `public class LaunchPad extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# launch pad skips consumption like Java's updateConsumption
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
	# for this launch pad (N2125); the tick preserves a disabled
	# launch pad instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_launch_pad_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the launch-pad frame meta key
	# ("source_launch_pad_building"). A LaunchPad sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_launch_pad_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_LAUNCH_PAD_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_LAUNCH_PAD_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_LAUNCH_PAD_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_launch_pad_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a launch pad does not take the early return. The updateTile advance follows the folded efficiency: the launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`) advances launchCounter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a launch pad with no power would never launch. LaunchPadBuild HAS a shouldConsume override (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) -- the gate waits for its own slice; the machinery runs with should_consume=true when enabled (the BuildingComp default, BuildingComp.java:755-757, `return enabled;`, is what the driver uses). The launch pad is its own family (LaunchPad.java:30, `public class LaunchPad extends Block{`; LaunchPadBuild, LaunchPad.java:83, `public class LaunchPadBuild extends Building{`). Two defs share the implementation (launch-pad, `consumePower(4f);`, Blocks.java:6797; advanced-launch-pad, `consumePower(8f);`, Blocks.java:6809), so the same driver covers the whole family; the advanced def also consumes liquid oil, which waits for its own slice.
	# Documented limits: (1) power-only first pass -- the launch pad's power consumer is static (consumePower 4f, Blocks.java:6797; consumePower 8f, Blocks.java:6809), so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume override deferred -- LaunchPadBuild HAS a shouldConsume override (`return launchCounter < launchTime;`, LaunchPad.java:92-95); the gate needs launchCounter state the tick does not track yet, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) No updateTile advance -- launchCounter / launchSound / LaunchPayload / Fx.launchPod / items.clear (LaunchPad.java:143-161) wait for their own slices; the proof carries no launch/counter/payload keys, the launch gate (LaunchPad.java:146) is what the efficiency keys prove. (4) No liquid consumer row -- advanced-launch-pad consumes oil 9f/60f (Blocks.java:6808); see DEFERRED. (5) Two defs, one driver -- launch-pad + advanced-launch-pad share the LaunchPad implementation, so the same driver covers the whole family; the advanced def waits for its own verification slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_launch_pad_should_consume_state(frame: Dictionary, launch_time: float) -> Dictionary:
	# LaunchPadBuild overrides shouldConsume
	# (LaunchPad.java:92, `public boolean shouldConsume(){`
	# with `return launchCounter < launchTime;`,
	# LaunchPad.java:94) over the launch counter
	# (LaunchPad.java:84, `public float launchCounter;`),
	# which the updateTile advance alone writes
	# (LaunchPad.java:146, `if((launchCounter += edelta())
	# >= launchTime && items.total() >= itemCapacity){`).
	# The per-def launchTime is 1200f for launch-pad
	# (Blocks.java:6794, `launchTime = 60f * 20;`, with
	# `size = 3;` and `itemCapacity = 100;` and
	# `consumePower(4f);`) and 1800f for
	# advanced-launch-pad (Blocks.java:6804, `launchTime =
	# 60f * 30;`, with `size = 4;` and `itemCapacity =
	# 100;` and `consumePower(8f);`), overriding the class
	# default `public float launchTime = 1f;`
	# (LaunchPad.java:32). The driver passes the per-def
	# value (SOURCE_LAUNCH_PAD_LAUNCH_TIMES, keyed by block
	# id, defaulting to the class default 1.0): the catalog
	# carries no launchTime property, so the pure function
	# cannot read it from the block. An absent
	# `launch_counter` key means "no observation yet" and
	# preserves the N2172 behavior (`should_consume =
	# enabled`) -- the N2191 `targets_count` precedent --
	# never "fully launched": the future updateTile advance
	# stamps `launch_counter` only after the first launch
	# gate consult each tick, and defaulting absent to
	# false would zero efficiency for every live launch
	# pad before its first advance tick, a live regression
	# against N2172 GREEN. It also matches the Java init:
	# `public float launchCounter;` defaults to 0.0f, which
	# is always < launchTime, so at Java init the gate is
	# true when enabled. updateConsumption forces
	# efficiency to zero when the gate is false
	# (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();`
	# + 1992, `if(!update){` + 1993, `efficiency = optionalEfficiency = 0f;`).
	# A missing power stamp
	# folds to 1.0 before the first graph update, the
	# assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`), and the power consumer counts toward
	# hasConsumers (Block.java:1449, `hasConsumers =
	# consumers.length > 0;`); edelta() is efficiency *
	# delta (BuildingComp.java:1928, `return efficiency *
	# delta();`). The default shouldConsume is `return
	# enabled;` (BuildingComp.java:755-756). sense
	# (LAccess.progress) reads the same counter
	# (LaunchPad.java:98, `if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);`)
	# and waits for its own slice. Two defs share the
	# implementation (LaunchPad.java:30, `public class
	# LaunchPad extends Block{`; LaunchPadBuild,
	# LaunchPad.java:83, `public class LaunchPadBuild
	# extends Building{`).
	var enabled: bool = bool(frame.get("enabled", true))
	var observed: Variant = frame.get("launch_counter", null)
	if observed == null:
		return {"should_consume": enabled}
	return {"should_consume": float(observed) < launch_time and enabled}

static func source_launch_pad_sense_state(frame: Dictionary, sensor: String, launch_time: float) -> Dictionary:
	# LaunchPadBuild overrides sense
	# (LaunchPad.java:98, `public double sense(LAccess sensor){`
	# with `if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);`,
	# LaunchPad.java:99) over the launch counter
	# (LaunchPad.java:84, `public float launchCounter;`),
	# which the updateTile advance alone writes
	# (LaunchPad.java:146, `if((launchCounter += edelta())
	# >= launchTime && items.total() >= itemCapacity){`).
	# Non-progress sensors fall through to super.sense
	# (LaunchPad.java:100, `return super.sense(sensor);`),
	# and the BuildingComp super switch has NO progress case
	# (BuildingComp.java:2093, `public double sense(LAccess sensor){`
	# + 2123, `default -> Float.NaN; //gets converted to null in logic`),
	# so a logic read of `progress` on a launch pad currently
	# returns NaN/null while Java returns the clamped fraction. Do NOT confuse sense with progress():
	# `public float progress(){` + `return 0f;`
	# (BuildingComp.java:617-619) is a DIFFERENT method the
	# sense switch never calls. The sensor enum value is
	# `progress,` (LAccess.java:28). The same expression
	# drives the progress bar (LaunchPad.java:70,
	# `Mathf.clamp(build.launchCounter / launchTime)`).
	# Mathf.clamp one-arg clamps to [0, 1]; the GDScript
	# spelling is clampf(value, 0.0, 1.0) -- the
	# SourceShockwaveTowerBuildState.gd:306 precedent. The
	# per-def launchTime is 1200f for launch-pad
	# (Blocks.java:6794, `launchTime = 60f * 20;`, with
	# `size = 3;` and `itemCapacity = 100;`) and 1800f for
	# advanced-launch-pad (Blocks.java:6804, `launchTime =
	# 60f * 30;`, with `size = 4;` and `itemCapacity =
	# 100;`), overriding the class default `public float
	# launchTime = 1f;` (LaunchPad.java:32). Sense is a
	# logic read, not a tick write: NO driver tick line
	# belongs here (the N2203 damage() precedent -- the
	# proof calls the pure function
	# source_launch_pad_sense_state(frame, sensor, launch_time)
	# directly with synthetic frames); the logic-processor
	# integration -- how a logic `sense progress` read on a
	# placed launch pad reaches this family function -- is
	# its own later slice. An absent `launch_counter` key
	# reads 0.0 -- the Java init default (`public float
	# launchCounter;` defaults to 0.0f), so a freshly built
	# pad senses 0.0, NOT NaN. Two defs share the
	# implementation (LaunchPad.java:30, `public class
	# LaunchPad extends Block{`; LaunchPadBuild,
	# LaunchPad.java:83, `public class LaunchPadBuild
	# extends Building{`).
	if sensor == "progress":
		var observed: Variant = frame.get("launch_counter", null)
		var counter: float = 0.0 if observed == null else float(observed)
		var fraction: float = clampf(counter / launch_time, 0.0, 1.0)
		return {"handled": true, "sense_value": fraction, "sense_value_is_nan": false}
	return {"handled": false, "sense_value": null, "sense_value_is_nan": true}

@warning_ignore("unused_parameter")
static func source_launch_pad_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the launch-pad tick wiring every
	# tick (LaunchPadBuild.updateTile(), LaunchPad.java:143,
	# gates on the launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`), so the launchCounter advance follows the folded efficiency; no placed-buildings driver ticks LaunchPad blocks, so this driver is the placed-launch-pad tick): each placed LaunchPad build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_launch_pad_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_launch_pad_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_launch_pad_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a launch pad with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the launch gate (LaunchPad.java:146)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a launch pad does not take the early return. A launch pad with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and LaunchPadBuild HAS a shouldConsume override (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) -- N2205 wires the gate through source_launch_pad_should_consume_state(frame, launch_time) (the BuildingComp default, BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756, is what an absent launch_counter key preserves). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			# N2205 wires the shouldConsume gate through source_launch_pad_should_consume_state(frame, launch_time): float(launch_counter) < launch_time and enabled when a counter observation is present, enabled when the frame carries no launch_counter key (the N2172 behavior preserved; the future updateTile advance stamps launch_counter). The per-def launchTime comes from SOURCE_LAUNCH_PAD_LAUNCH_TIMES by block id (launch-pad 1200.0, advanced-launch-pad 1800.0, class default 1.0) because the catalog carries no launchTime property.
			var launch_time: float = float(SOURCE_LAUNCH_PAD_LAUNCH_TIMES.get(block_id, 1.0))
			var should_consume: bool = bool(source_launch_pad_should_consume_state(frame, launch_time).get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_launch_pad_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
