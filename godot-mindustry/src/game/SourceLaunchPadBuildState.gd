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
	# LaunchPadBuild.launchCounter (LaunchPad.java:84, `public float launchCounter;`) is the gate state: shouldConsume() (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) reads it live, and the updateTile launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`) advances it by edelta(); the tick preserves the counter across ticks instead of resetting it, the factory pattern (SourceFactoryBuildState.gd:927), and a fresh frame starts at the Java field default 0f.
	frame["launch_counter"] = float(frame.get("launch_counter", 0.0))
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
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a launch pad does not take the early return. The updateTile advance follows the folded efficiency: the launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`) advances launchCounter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a launch pad with no power would never launch. LaunchPadBuild HAS a shouldConsume override (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) -- N2186 wires the gate: the pure source_launch_pad_should_consume_state gate reads the tracked launchCounter, the driver ANDs enabled (the BuildingComp default, BuildingComp.java:755-757, `return enabled;`, is what the driver uses), and the machinery folds efficiency to 0 when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();`, with BuildingComp.java:1992-1994, `if(!update){` / `efficiency = optionalEfficiency = 0f;`). The launch pad is its own family (LaunchPad.java:30, `public class LaunchPad extends Block{`; LaunchPadBuild, LaunchPad.java:83, `public class LaunchPadBuild extends Building{`). Two defs share the implementation (launch-pad, `consumePower(4f);`, Blocks.java:6797; advanced-launch-pad, `consumePower(8f);`, Blocks.java:6809), so the same driver covers the whole family; the advanced def also consumes liquid oil, which waits for its own slice.
	# Documented limits: (1) power-only first pass -- the launch pad's power consumer is static (consumePower 4f, Blocks.java:6797; consumePower 8f, Blocks.java:6809), so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume gate LIVE (N2186) -- LaunchPadBuild.shouldConsume() (`return launchCounter < launchTime;`, LaunchPad.java:92-95) is the pure source_launch_pad_should_consume_state gate over the tracked launchCounter; the driver ANDs enabled (BuildingComp.java:755-757, `return enabled;`) and the machinery folds efficiency to 0 when the gate is false (BuildingComp.java:1960/:1992-1994). (3) Counter advance only, no launch fire -- the tick advances launchCounter by edelta (the counter half of LaunchPad.java:146); launchSound / LaunchPayload / Fx.launchPod / items.clear / the `launchCounter = 0f;` reset (LaunchPad.java:147-159) wait for their own slice, so a full pad never launches and its counter freezes at launchTime with the gate closed; the proof carries no launch/payload keys. (4) No liquid consumer row -- advanced-launch-pad consumes oil 9f/60f (Blocks.java:6808); see DEFERRED. (5) Two defs, one driver -- launch-pad + advanced-launch-pad share the LaunchPad implementation, so the same driver covers the whole family; the advanced def waits for its own verification slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_launch_pad_should_consume_state(frame: Dictionary) -> Dictionary:
	# LaunchPadBuild.shouldConsume() (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94): the pad consumes only while its launchCounter is below launchTime. The override has NO enabled check -- enabled is handled separately by updateConsumption (BuildingComp.java:1954-1957, the disabled early return) and by the driver gate, the WallCrafter precedent -- so this pure function reads only the counter and the threshold: launchCounter is the build field (LaunchPad.java:84, `public float launchCounter;`, default 0f), launchTime is the block field (LaunchPad.java:32, `public float launchTime = 1f;`, the class default when the driver has not stamped the def value: launch-pad `launchTime = 60f * 20;`, Blocks.java:6794; advanced-launch-pad `launchTime = 60f * 30;`, Blocks.java:6804). A missing counter reads 0.0 (fresh build); a missing threshold reads the class default 1f. When the gate is false, updateConsumption folds efficiency to 0 (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();`, with BuildingComp.java:1992-1994, `if(!update){` / `efficiency = optionalEfficiency = 0f;`), so the pad draws no power while its counter sits full.
	var launch_counter: float = float(frame.get("launch_counter", 0.0))
	var launch_time: float = float(frame.get("launch_time", 1.0))
	return {"should_consume": launch_counter < launch_time, "launch_counter": launch_counter}

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
		# launchTime is a per-def block field the catalog does not carry (the registry entry holds consumePower / itemCapacity / size but no launchTime), so the driver stamps it from the block id every tick: launch-pad `launchTime = 60f * 20;` (Blocks.java:6794), advanced-launch-pad `launchTime = 60f * 30;` (Blocks.java:6804); any other LaunchPad id keeps the class default `public float launchTime = 1f;` (LaunchPad.java:32).
		var launch_time: float = 1.0
		if block_id == "launch-pad":
			launch_time = 60.0 * 20.0
		elif block_id == "advanced-launch-pad":
			launch_time = 60.0 * 30.0
		frame["launch_time"] = launch_time
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a launch pad with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the launch gate (LaunchPad.java:146)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a launch pad does not take the early return. A launch pad with no power consumer is untouched: the tick models no other consumers yet (the launch fire waits for its own slice), and LaunchPadBuild HAS a shouldConsume override (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) -- N2186 wires the gate through the pure source_launch_pad_should_consume_state function, ANDed with enabled (the BuildingComp default, BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756, is what the driver uses). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_launch_pad_should_consume_state(frame)
			var should_consume: bool = bool(frame.get("enabled", true)) and bool(gate.get("should_consume", false))
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
			# The counter half of updateTile (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`): updateConsumption runs first (BuildingComp.java:2274, `updateConsumption();`), then updateTile (BuildingComp.java:2277, `updateTile();`, only `if(enabled || !block.noUpdateDisabled){`, BuildingComp.java:2276; Block.noUpdateDisabled defaults false, Block.java:170), so the counter advances by the freshly folded efficiency times this tick's Time.delta (seconds * 60 via game_source_delta, arc Time.java:26, the N2093/N2189 precedent) -- edelta() is `return efficiency * delta();` (BuildingComp.java:1927-1929) with delta() `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and timeScale default 1f (BuildingComp.java:98), which the frame does not track yet. The launch fire itself (consume() + LaunchPayload + Fx.launchPod + items.clear + `launchCounter = 0f;`, LaunchPad.java:147-159) waits for its own slice, so a counter that reaches launchTime freezes there: the gate closes, efficiency folds to 0, and edelta() is 0. A cheating or disabled pad, or one with no power consumer, never reaches this line (the N2172 guard), so its counter stays frozen too -- the cheating-path advance waits for its own slice.
			frame["launch_counter"] = float(frame.get("launch_counter", 0.0)) + float(frame.get("efficiency", 0.0)) * source_placed_block_state.game_source_delta(game, seconds)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
