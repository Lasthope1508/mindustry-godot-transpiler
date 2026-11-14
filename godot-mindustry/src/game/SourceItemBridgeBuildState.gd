extends RefCounted
class_name SourceItemBridgeBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The ItemBridge implementation (ItemBridge.java:24, `public class ItemBridge extends Block{`): phase-conveyor (consumePower 0.30f, Blocks.java:2125, `consumePower(0.30f);`; size 1, range 12, transportTime 2f, phase-fabric 5 / silicon 7 / lead 10 / graphite 10, Blocks.java:2116-2125). ItemBridge extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_item_bridge_building", the radar precedent), and this slice adds the item-bridge key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceItemBridge* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTransport charge (ItemBridge.java:356, `transportCounter += edelta();`) charges its transport counter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a phase-conveyor with no power would never advance its transport counter and never move items across the bridge -- its transport counter would sit frozen as if power.status were 1.0.
const SOURCE_ITEM_BRIDGE_BUILD_IMPLEMENTATIONS := ["ItemBridge"]
const SOURCE_ITEM_BRIDGE_BUILDING_META_KEY := "source_item_bridge_building"

static func _is_item_bridge_build_implementation(implementation: String) -> bool:
	return SOURCE_ITEM_BRIDGE_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_item_bridge_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The item-bridge tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (ItemBridge.java:24, `public class ItemBridge extends Block{`; ItemBridgeBuild, ItemBridge.java:197, `public class ItemBridgeBuild extends Building{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# item bridge skips consumption like Java's updateConsumption
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
	# for this item bridge (N2125); the tick preserves a disabled
	# item bridge instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_item_bridge_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the item-bridge frame meta key
	# ("source_item_bridge_building"). An ItemBridge sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_item_bridge_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_item_bridge_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conveyor does not take the early return. The item bridge's power draw is STATIC, not conditional: `consumePower(0.30f);` (Blocks.java:2125) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTransport charge follows the folded efficiency: the transport charge (ItemBridge.java:356, `transportCounter += edelta();`) charges by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a phase-conveyor with no power would never advance its transport counter and never move items across the bridge. ItemBridgeBuild overrides shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 / ShockwaveTower N2177 precedents): the port tracks no live link on any placed-building frame, so this slice folds power-only and defers the gate with a documented limit; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent) -- when unlinked power.status reads 1.0 while Java efficiency is 0; the observable gap is efficiency 1.0 vs 0.0 when unlinked. The link gate itself is `hadValidLink = linkValid(tile, other);` (ItemBridge.java:333). The item bridge is its own family (ItemBridge.java:24, `public class ItemBridge extends Block{`; ItemBridgeBuild, ItemBridge.java:197, `public class ItemBridgeBuild extends Building{`), a distribution block, NOT related to any factory / turret / defense family. Class fields: `public final int timerCheckMoved = timers ++;` (ItemBridge.java:25), `public int range;` (ItemBridge.java:27), `public float transportTime;` (ItemBridge.java:28), `public boolean fadeIn = true;` (ItemBridge.java:34), `public boolean moveArrows = true;` (ItemBridge.java:35), `public boolean pulse = false;` (ItemBridge.java:36), `public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;` (ItemBridge.java:37), `public float arrowTimeScl = 6.2f;` (ItemBridge.java:38), `public float bridgeWidth = 6.5f;` (ItemBridge.java:39); constructor `update = true;` (ItemBridge.java:45), `solid = true;` (ItemBridge.java:46), `underBullets = true;` (ItemBridge.java:47), `hasPower = true;` (ItemBridge.java:48), `itemCapacity = 10;` (ItemBridge.java:49), `configurable = true;` (ItemBridge.java:50), `hasItems = true;` (ItemBridge.java:51). Build fields: `public int link = -1;` (ItemBridge.java:202), `public IntSeq incoming = new IntSeq(false, 4);` (ItemBridge.java:203), `public float warmup;` (ItemBridge.java:204), `public float time = -8f, timeSpeed;` (ItemBridge.java:205), `public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:206), `public float transportCounter;` (ItemBridge.java:207). The warmup approach (ItemBridge.java:345, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);`) also follows the folded efficiency when a valid link exists; without a link `warmup = 0f` (ItemBridge.java:337). draw() uses `float warmup = hasPower ? this.warmup : 1f;` (ItemBridge.java:387) -- the bridge-conveyor (hasPower false) always draws warmup 1f, another reason the two defs must not share one driver row. BufferedItemBridge extends ItemBridge (BufferedItemBridge.java:9, `public class BufferedItemBridge extends ItemBridge{`) with `hasPower = false;` (BufferedItemBridge.java:18) and `bufferCapacity = 50` class default (def overrides to 14, Blocks.java:2113) and `speed = 74f` (def, Blocks.java:2112). canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. The single def carries `consumePower(0.30f);` (Blocks.java:2125) with `range = 12;` (Blocks.java:2118) and `transportTime = 2f;` (Blocks.java:2119). Single def -- phase-conveyor only (size 1, range 12, transportTime 2f, phase-fabric 5 / silicon 7 / lead 10 / graphite 10, Blocks.java:2116-2125). bridge-conveyor (BufferedItemBridge, no power def) is explicitly OUT of scope.
	# Documented limits: (1) power-only first pass -- the phase-conveyor's static power consumer (consumePower 0.30f, Blocks.java:2125) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); phase-conveyor has no second consumer. (2) shouldConsume gate deferred -- ItemBridgeBuild overrides shouldConsume (`return hadValidLink && enabled;`, ItemBridge.java:495-496); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver runs with should_consume=true when enabled (the MendProjector suppression precedent) -- when unlinked power.status reads 1.0 while Java efficiency is 0. (3) No updateTile transport advance -- link validation / incoming registration / transportCounter charge / item handoff / warmup approach / doDump (ItemBridge.java:319-363) wait for their own slices; the proof carries no transport/warmup/link keys, the transport charge (ItemBridge.java:356) is what the efficiency keys prove. (4) No sense/warmup modeling -- `warmup()` has no override here (draw-only warmup, :387) and sense waits for its own slice. (5) Single def -- phase-conveyor only (size 1, range 12, transportTime 2f, phase-fabric 5 / silicon 7 / lead 10 / graphite 10); bridge-conveyor (BufferedItemBridge, no power def) is explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) No draw/config modeling -- bridge draw / drawSelect / drawConfigure / config link (ItemBridge.java:216-296, 375-394) wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_item_bridge_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the item-bridge tick wiring every
	# tick (ItemBridgeBuild.updateTile(), ItemBridge.java:319,
	# charges the transport counter by the transport charge (ItemBridge.java:356, `transportCounter += edelta();`), so the transport charge follows the folded efficiency; no placed-buildings driver ticks ItemBridge blocks, so this driver is the placed-item-bridge tick): each placed ItemBridge build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_item_bridge_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_item_bridge_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_item_bridge_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# an item bridge with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the transport charge (ItemBridge.java:356, `transportCounter += edelta();`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conveyor does not take the early return. The item bridge's power draw is STATIC: `consumePower(0.30f);` (Blocks.java:2125) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. An item bridge with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and ItemBridgeBuild overrides shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496) -- RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 / ShockwaveTower N2177 precedents): the port tracks no live link on any placed-building frame, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_item_bridge_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
