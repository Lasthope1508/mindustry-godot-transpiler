extends RefCounted
class_name SourceLaunchPadBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

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
	# LaunchPadBuild.launchCounter (LaunchPad.java:84, `public float launchCounter;`) is the updateTile state: the launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`) advances it by edelta() and resets it on launch, and shouldConsume() (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) reads it live; the tick preserves the counter across ticks instead of resetting it, the factory pattern (SourceFactoryBuildState.gd:927), and a fresh frame starts at the Java field default 0f. The frame items (the Building.items ItemModule, a Dictionary keyed by item name, the factory precedent SourceFactoryBuildState.gd:89-101) are preserved the same way -- the launch clears them through the advance, never through the tick wiring.
	frame["launch_counter"] = float(frame.get("launch_counter", 0.0))
	frame["items"] = frame.get("items", {})
	return frame

static func _initial_frame() -> Dictionary:
	# The fresh frame binds the Java build-field defaults:
	# `public float launchCounter;` (LaunchPad.java:84, 0f) and
	# the empty ItemModule (no items held at placement). The
	# frame inputs (launch_time / efficiency) are NOT bound
	# here: launch_time is stamped per-def by the driver (the
	# catalog carries no launchTime) and the advance reads it
	# with the frame.get default 1.0 (the class default,
	# LaunchPad.java:32); efficiency is stamped by the
	# consumption fold and the advance reads it with the
	# frame.get default 0.0 (BuildingComp.java:85 `transient
	# float efficiency;`).
	return {"launch_counter": 0.0, "items": {}}

static func source_launch_pad_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the launch-pad frame meta key
	# ("source_launch_pad_building"). A LaunchPad sprite gets a
	# frame bound with the updateTile state keys
	# (launch_counter 0.0 / items {}, the Java build-field
	# defaults, LaunchPad.java:84 -- N2238); the live-loop tick
	# fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_launch_pad_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_LAUNCH_PAD_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_LAUNCH_PAD_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_LAUNCH_PAD_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_launch_pad_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a launch pad does not take the early return. The updateTile advance follows the folded efficiency: the launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`) advances launchCounter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a launch pad with no power would never launch. LaunchPadBuild HAS a shouldConsume override (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) -- the gate waits for its own slice; the machinery runs with should_consume=true when enabled (the BuildingComp default, BuildingComp.java:755-757, `return enabled;`, is what the driver uses). The launch pad is its own family (LaunchPad.java:30, `public class LaunchPad extends Block{`; LaunchPadBuild, LaunchPad.java:83, `public class LaunchPadBuild extends Building{`). Two defs share the implementation (launch-pad, `consumePower(4f);`, Blocks.java:6797; advanced-launch-pad, `consumePower(8f);`, Blocks.java:6809), so the same driver covers the whole family; the advanced def also consumes liquid oil, which waits for its own slice.
	# Documented limits: (1) power-only first pass -- the launch pad's power consumer is static (consumePower 4f, Blocks.java:6797; consumePower 8f, Blocks.java:6809), so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume override deferred -- LaunchPadBuild HAS a shouldConsume override (`return launchCounter < launchTime;`, LaunchPad.java:92-95); the counter state it reads is now tracked (N2238), but the gate itself waits for its own slice (N2186 lives on an unmerged branch in this line), so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) updateTile advance live (N2238) -- the launchCounter advance, the full-and-timed launch gate, the stacks copy, items.clear and the launchCounter = 0f reset (LaunchPad.java:143-161) advance in the pure function (source_launch_pad_update_tile_advance_state); the LaunchPayload entity creation/application (LaunchPad.java:150-155) and the launch sound / effects (launchSound / Fx.launchPod / Effect.shake, LaunchPad.java:149/156/158) still defer. (4) No liquid consumer row -- advanced-launch-pad consumes oil 9f/60f (Blocks.java:6808); see DEFERRED. (5) Two defs, one driver -- launch-pad + advanced-launch-pad share the LaunchPad implementation, so the same driver covers the whole family; the advanced def waits for its own verification slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_launch_pad_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, item_capacity: int) -> Dictionary:
	# The updateTile advance (LaunchPadBuild.updateTile(),
	# LaunchPad.java:143-161), the pure frame advance -- the
	# build class is `public class LaunchPadBuild extends Building{`
	# (LaunchPad.java:83) on `public class LaunchPad extends Block{`
	# (LaunchPad.java:30), the counter field is `public float launchCounter;`
	# (LaunchPad.java:84, 0f) and the threshold field is
	# `public float launchTime = 1f;` (LaunchPad.java:32, the
	# class default; the defs override it -- launch-pad
	# `launchTime = 60f * 20;`, Blocks.java:6794, advanced-
	# launch-pad `launchTime = 60f * 30;`, Blocks.java:6804).
	# The advance follows the Java lines in order (each exact
	# expr on ONE comment line, the N2148 lesson):
	# `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`
	# `consume();`
	# `launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand));`
	# `LaunchPayload entity = LaunchPayload.create();`
	# `items.each((item, amount) -> entity.stacks.add(new ItemStack(item, amount)));`
	# `entity.set(this);`
	# `entity.lifetime(120f);`
	# `entity.team(team);`
	# `entity.add();`
	# `Fx.launchPod.at(this);`
	# `items.clear();`
	# `Effect.shake(3f, 3f, this);`
	# `launchCounter = 0f;`
	# edelta() is `return efficiency * delta();`
	# (BuildingComp.java:1927-1929) with delta()
	# `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924); source_delta is
	# Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26), never raw
	# seconds. efficiency defaults 0.0, the Java field
	# default (BuildingComp.java:85 `transient float efficiency;`);
	# timeScale reads live from the sprite meta, default 1.0
	# (BuildingComp.java:98 `private transient float timeScale = 1f, timeScaleDuration;`).
	# items.total() is `public int total(){` with
	# `return total;` (ItemModule.java:174-176) over the
	# ItemModule; the port's items dict is keyed by item name
	# (the factory precedent, SourceFactoryBuildState.gd:
	# 89-101) and its total is the drill inventory total
	# (inventory.items_total, the Separator precedent).
	# itemCapacity is the catalog value (both defs
	# `itemCapacity = 100;`, Blocks.java:6793/6803); the
	# Block class default is `public int itemCapacity = 10;`
	# (Block.java:75). Scoping decisions, all source-backed:
	# (1) consume() triggers every consumer
	# (`for(Consume cons : block.consumers){` /
	# `cons.trigger(self());`, BuildingComp.java:1911-1915),
	# but only ConsumeItems / ConsumeItemDynamic remove
	# anything -- the launch-pad def has NO item consumer
	# (only `consumePower(4f);`, Blocks.java:6797),
	# ConsumePower has no trigger override, and the Consume
	# default trigger is empty (`public void trigger(Building build){}`,
	# Consume.java:50), so consume() is a no-op for items
	# here; the advanced def's `consumeLiquid(Liquids.oil, 9f/60f);`
	# (Blocks.java:6808) has no trigger override either, so
	# consume() is a no-op for liquids too -- the pure
	# advance owes consume() nothing. (2) the LaunchPayload
	# entity creation/application (LaunchPayload.create() +
	# entity.set(this) + lifetime(120f) + team + add()) has no
	# live entity in the port, so the launch is reported as
	# the pure result launched_stacks (the N2234 spawned_unit
	# precedent): the items.each stacks copy
	# (`Seq<ItemStack> stacks = new Seq<>();`,
	# LaunchPad.java:230) plus the launched bool; the live
	# entity creation/application defers. The stacks copy
	# skips zero amounts, like ItemModule.each
	# (`public void each(ItemConsumer cons){` with
	# `if(items[i] != 0){`, ItemModule.java:100-106). (3) the
	# launch sound and effects (launchSound.at + Fx.launchPod
	# + Effect.shake(3f, 3f, this)) are sound/presentation and
	# defer; this slice launches silently. (4) the launch
	# clears the items (`public void clear(){`,
	# ItemModule.java:281-284) and resets the counter to 0f;
	# the reset reopens the shouldConsume gate
	# (`public boolean shouldConsume(){` with
	# `return launchCounter < launchTime;`, LaunchPad.java:
	# 92-95) the NEXT tick -- consumption runs first, so the
	# gate reads the pre-advance counter. The defs share the
	# implementation: launch-pad (size 3, itemCapacity 100,
	# launchTime 60f * 20, `acceptMultipleItems = true;`,
	# `consumePower(4f);`, Blocks.java:6790-6797) and
	# advanced-launch-pad (size 4, itemCapacity 100,
	# launchTime 60f * 30, liquidCapacity 40f, consumeLiquid
	# oil 9f/60f, `consumePower(8f);`, Blocks.java:6800-6809).
	# The function does NOT mutate its input frame.
	var launch_counter: float = float(frame.get("launch_counter", 0.0))
	var launch_time: float = float(frame.get("launch_time", 1.0))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var edelta: float = efficiency * source_delta * time_scale
	launch_counter += edelta
	var launched: bool = false
	var launched_stacks: Dictionary = {}
	if launch_counter >= launch_time and inventory.items_total(items) >= item_capacity:
		launched = true
		for item_name in items:
			if int(items[item_name]) != 0:
				launched_stacks[item_name] = int(items[item_name])
		items = {}
		launch_counter = 0.0
	return {"launched": launched, "launched_stacks": launched_stacks, "launch_counter": launch_counter, "items": items}

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
		# launchTime is a per-def block field the catalog does not carry (the registry entry holds consumePower / itemCapacity / size but no launchTime), so the driver stamps it from the block id every tick: launch-pad `launchTime = 60f * 20;` (Blocks.java:6794), advanced-launch-pad `launchTime = 60f * 30;` (Blocks.java:6804); any other LaunchPad id keeps the class default `public float launchTime = 1f;` (LaunchPad.java:32). (The N2186 stamp, mirrored here because N2186 is not in this base.)
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
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a launch pad does not take the early return. A launch pad with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance is live since N2238 -- it runs after this fold, below), and LaunchPadBuild HAS a shouldConsume override (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) -- the gate waits for its own slice, so the machinery runs with should_consume=true when enabled (the BuildingComp default, BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756, is what the driver uses). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
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
		# N2238: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# `updateConsumption();`, then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277 with `updateTile();`;
		# noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled launch pad's
		# counter freezes (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and edelta() is 0. The port keeps the enabled gate
		# below as a pragmatic choice (the N2195 coordinator-fix
		# precedent): the driver skips the consumption fold when
		# disabled, so the frame efficiency goes stale and
		# running the advance on it would charge the counter
		# from a stale efficiency. The driver-wide
		# disabled-early-return slice (deferred in the N2238
		# register) removes this gate for all families.
		# super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default the game
		# default 1.0 (BuildingComp.java:98 `private transient
		# float timeScale = 1f, timeScaleDuration;`).
		# itemCapacity comes from the catalog (both defs 100);
		# the Block class default 10 (Block.java:75) applies
		# when the catalog is silent. A pad with no power
		# consumer or a cheating team never folds efficiency,
		# so the advance reads the stale/absent frame
		# efficiency (0.0 default) and its counter freezes --
		# the disabled / cheating / no-power advance waits for
		# its own slice (deferred in the N2238 register). The
		# gate reads the pre-advance counter (consumption runs
		# first), so a launch reopens the shouldConsume gate
		# the NEXT tick -- and a launch needs the counter at
		# launchTime (1200f / 1800f) with a full pad, so a
		# single tick never launches from a fresh frame.
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var item_capacity: int = int(block.properties.get("itemCapacity", 10))
			var advanced: Dictionary = source_launch_pad_update_tile_advance_state(frame, source_delta, time_scale, item_capacity)
			frame["launch_counter"] = float(advanced.get("launch_counter", 0.0))
			frame["items"] = advanced.get("items", {})
			frame["launched"] = bool(advanced.get("launched", false))
			frame["launched_stacks"] = advanced.get("launched_stacks", {})
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
