extends RefCounted
class_name SourceStackConveyorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The StackConveyor implementation (StackConveyor.java:24, `public class StackConveyor extends Block implements Autotiler{`): surge-conveyor (consumePower 1f/60f, Blocks.java:2251, `consumePower(1f / 60f);`; size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1, Blocks.java:2237-2253). StackConveyor extends Block, NOT a factory or crafter or bridge, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_stack_conveyor_building", the radar precedent), and this slice adds the stack-conveyor key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceStackConveyor* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the StackConveyorBuild.updateTile reels items in at a rate that follows the folded efficiency (StackConveyor.java:270, `float eff = enabled ? (efficiency + baseEfficiency) : 1f;` with StackConveyor.java:273, `if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) -- so a surge-conveyor with no power would reel slower and draw no glow, as if power.status were 1.0. The surge def carries `baseEfficiency = 1f;` (Blocks.java:2250), so at efficiency 0 the belt STILL reels at eff 1f -- power raises eff toward 2f and lights the glow (StackConveyor.java:156, `if(glowRegion.found() && power != null && power.status > 0f){` with StackConveyor.java:158, `Draw.color(glowColor, glowAlpha * power.status);`); the glow is the only hard power gate on this family.
const SOURCE_STACK_CONVEYOR_BUILD_IMPLEMENTATIONS := ["StackConveyor"]
const SOURCE_STACK_CONVEYOR_BUILDING_META_KEY := "source_stack_conveyor_building"

static func _is_stack_conveyor_build_implementation(implementation: String) -> bool:
	return SOURCE_STACK_CONVEYOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_stack_conveyor_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The stack-conveyor tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (StackConveyor.java:24, `public class StackConveyor extends Block implements Autotiler{`; StackConveyorBuild, StackConveyor.java:114, `public class StackConveyorBuild extends Building{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# stack conveyor skips consumption like Java's updateConsumption
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
	# for this stack conveyor (N2125); the tick preserves a disabled
	# stack conveyor instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_stack_conveyor_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the stack-conveyor frame meta key
	# ("source_stack_conveyor_building"). A StackConveyor sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_stack_conveyor_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_STACK_CONVEYOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_STACK_CONVEYOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_STACK_CONVEYOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_stack_conveyor_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a surge-conveyor does not take the early return. The stack conveyor's power draw is STATIC, not conditional: `consumePower(1f / 60f);` (Blocks.java:2251) registers a plain ConsumePower, so the catalog consumePower 0.0167 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The stack conveyor's updateTile (StackConveyor.java:270, `float eff = enabled ? (efficiency + baseEfficiency) : 1f;` with StackConveyor.java:273, `if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) reels items at a rate that follows the folded efficiency -- and because the surge def sets `baseEfficiency = 1f;` (Blocks.java:2250), the belt still reels at eff 1f with no power; power raises eff toward 2f and lights the glow (StackConveyor.java:156, `if(glowRegion.found() && power != null && power.status > 0f){` with StackConveyor.java:158, `Draw.color(glowColor, glowAlpha * power.status);`). The glow is the only hard power gate on this family.
	# StackConveyorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). There is NO gate to defer here (unlike the ItemBridge / LiquidBridge link gates): the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and edelta (BuildingComp.java:1927-1929, `return efficiency * delta();`) are the surrounding gates. The single def carries `consumePower(1f / 60f);` (Blocks.java:2251) with `baseEfficiency = 1f;` (Blocks.java:2250), `outputRouter = false;` (Blocks.java:2244), `speed = 5f / 60f;` (Blocks.java:2241), `health = 130;` (Blocks.java:2239), `hasPower = true;` (Blocks.java:2245), `consumesPower = true;` (Blocks.java:2246) and `conductivePower = true;` (Blocks.java:2247).
	# The stack conveyor is its own family (StackConveyor.java:24, `public class StackConveyor extends Block implements Autotiler{`; StackConveyorBuild, StackConveyor.java:114, `public class StackConveyorBuild extends Building{`), a distribution block, NOT related to any factory / turret / defense / bridge family. Class fields: `protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;` (StackConveyor.java:25), `public float glowAlpha = 1f;` (StackConveyor.java:34), `public Color glowColor = Pal.redLight;` (StackConveyor.java:35), `public float baseEfficiency = 0f;` (StackConveyor.java:37), `public float speed = 0f;` (StackConveyor.java:38), `public boolean outputRouter = true;` (StackConveyor.java:39), `public float recharge = 2f;` (StackConveyor.java:41), `public Effect loadEffect = Fx.conveyorPoof;` (StackConveyor.java:42), `public Effect unloadEffect = Fx.conveyorPoof;` (StackConveyor.java:43); constructor `rotate = true;` (StackConveyor.java:48), `update = true;` (StackConveyor.java:49), `group = BlockGroup.transportation;` (StackConveyor.java:50), `hasItems = true;` (StackConveyor.java:51), `itemCapacity = 10;` (StackConveyor.java:52), `conveyorPlacement = true;` (StackConveyor.java:53), `underBullets = true;` (StackConveyor.java:54), `priority = TargetPriority.transport;` (StackConveyor.java:55), `drawCached = true;` (StackConveyor.java:56), `buildingCacheLayer = BuildingCacheLayer.under;` (StackConveyor.java:57), `ambientSound = Sounds.loopConveyor;` (StackConveyor.java:59), `ambientSoundVolume = 0.004f;` (StackConveyor.java:60). Build fields: `public int state, blendprox;` (StackConveyor.java:115), `public int link = -1;` (StackConveyor.java:117), `public float cooldown;` (StackConveyor.java:118), `public Item lastItem;` (StackConveyor.java:119), `boolean proxUpdating = false;` (StackConveyor.java:121). The transfer branch (StackConveyor.java:276, `if(link == -1) return;` with StackConveyor.java:287, `if(!enabled) return;`) returns early without a link or when disabled, and the handoff sets `cooldown = recharge;` (StackConveyor.java:311) with `e.cooldown = 1;` (StackConveyor.java:312).
	# Single def -- surge-conveyor only (size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1, Blocks.java:2237-2253). plastanium-conveyor (StackConveyor, no power def, NO hasPower line, Blocks.java:2084) is explicitly OUT of scope. No sense / read / write overrides exist on StackConveyorBuild -- those wait for their own slices only if a later Java line needs them.
	# Documented limits: (1) power-only first pass -- the surge-conveyor's static power consumer (consumePower 1f/60f, Blocks.java:2251) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); surge-conveyor has no second consumer. (2) NO shouldConsume gate to defer -- StackConveyorBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT for this family. (3) No updateTile advance -- eff fold / cooldown reel / link gate / transfer branch (StackConveyor.java:268-315) wait for their own slices; the proof carries no reel / cooldown / transfer / link keys, the eff fold (StackConveyor.java:270) is what the efficiency keys prove. (4) No sense modeling -- sense waits for its own slice. (5) Single def -- surge-conveyor only (size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1); plastanium-conveyor (StackConveyor, no power def) is explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) No draw/config modeling -- draw / drawSelect / config wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_stack_conveyor_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the stack-conveyor tick wiring every
	# tick (StackConveyorBuild.updateTile(), StackConveyor.java:268,
	# reels items in at a rate that follows the folded efficiency
	# (StackConveyor.java:270, `float eff = enabled ? (efficiency + baseEfficiency) : 1f;`, with StackConveyor.java:273, `if(cooldown > 0f) cooldown = Mathf.clamp(cooldown - speed * eff * delta(), 0f, recharge);`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test), so the reel rate follows the folded efficiency; no placed-buildings driver ticks StackConveyor blocks, so this driver is the placed-stack-conveyor tick): each placed StackConveyor build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_stack_conveyor_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_stack_conveyor_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_stack_conveyor_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a stack conveyor with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the reel rate (StackConveyor.java:270-273)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a surge-conveyor does not take the early return. The stack conveyor's power draw is STATIC: `consumePower(1f / 60f);` (Blocks.java:2251) registers a plain ConsumePower, so the catalog consumePower 0.0167 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A stack conveyor with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and StackConveyorBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) -- there is NO gate to defer here, the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_stack_conveyor_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
