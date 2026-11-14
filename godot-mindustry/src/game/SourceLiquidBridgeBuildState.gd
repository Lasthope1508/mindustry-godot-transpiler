extends RefCounted
class_name SourceLiquidBridgeBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The LiquidBridge implementation (LiquidBridge.java:7, `public class LiquidBridge extends ItemBridge{`): phase-conduit (consumePower 0.30f, Blocks.java:2396, `consumePower(0.30f);`; size 1, range 12, liquidCapacity 100f, phase-fabric 5 / silicon 7 / metaglass 20 / titanium 10, Blocks.java:2385-2397). LiquidBridge extends ItemBridge, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_liquid_bridge_building", the radar precedent), and this slice adds the liquid-bridge key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceLiquidBridge* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the warmup gate (LiquidBridge.java:23, `if(warmup >= 0.25f){`) blocks ALL liquid movement until warmup reaches 0.25f, and warmup itself follows the folded efficiency through the inherited ItemBridge updateTile (ItemBridge.java:345, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);`) -- so a phase-conduit with no power would never warm up and never move liquid across the bridge, as if power.status were 1.0.
const SOURCE_LIQUID_BRIDGE_BUILD_IMPLEMENTATIONS := ["LiquidBridge"]
const SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY := "source_liquid_bridge_building"

static func _is_liquid_bridge_build_implementation(implementation: String) -> bool:
	return SOURCE_LIQUID_BRIDGE_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_liquid_bridge_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The liquid-bridge tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (LiquidBridge.java:7, `public class LiquidBridge extends ItemBridge{`; LiquidBridgeBuild, LiquidBridge.java:19, `public class LiquidBridgeBuild extends ItemBridgeBuild{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# liquid bridge skips consumption like Java's updateConsumption
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
	# for this liquid bridge (N2125); the tick preserves a disabled
	# liquid bridge instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_liquid_bridge_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the liquid-bridge frame meta key
	# ("source_liquid_bridge_building"). A LiquidBridge sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_liquid_bridge_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_liquid_bridge_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conduit does not take the early return. The liquid bridge's power draw is STATIC, not conditional: `consumePower(0.30f);` (Blocks.java:2396) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The liquid bridge's updateTransport (LiquidBridge.java:23-24, `if(warmup >= 0.25f){` with `moved |= moveLiquid(other, liquids.current()) > 0.05f;`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) moves liquid only once warmup reaches 0.25f, and warmup follows the folded efficiency through the inherited ItemBridge updateTile (ItemBridge.java:345, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);`; ItemBridge.java:356, `transportCounter += edelta();`, and edelta() is efficiency * delta (BuildingComp.java:1927-1929, `return efficiency * delta();`)). doDump dumps the current liquid (LiquidBridge.java:30, `dumpLiquid(liquids.current(), 1f);`). draw() uses `float warmup = hasPower ? this.warmup : 1f;` (ItemBridge.java:387) -- the bridge-conduit (hasPower false) always draws warmup 1f, another reason the two defs must not share one driver row.
	# LiquidBridgeBuild inherits ItemBridgeBuild.shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 / ShockwaveTower N2177 / ItemBridge N2178 precedents): the port tracks no live link on any placed-building frame, so this slice folds power-only and defers the gate with a documented limit; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent) -- when unlinked power.status reads 1.0 while Java efficiency is 0; the observable gap is efficiency 1.0 vs 0.0 when unlinked. The link gate itself is `hadValidLink = linkValid(tile, other);` (ItemBridge.java:333).
	# The liquid bridge is its own family (LiquidBridge.java:7, `public class LiquidBridge extends ItemBridge{`; LiquidBridgeBuild, LiquidBridge.java:19, `public class LiquidBridgeBuild extends ItemBridgeBuild{`), a liquid block, NOT related to any factory / turret / defense family. Constructor: `hasItems = false;` (LiquidBridge.java:11), `hasLiquids = true;` (LiquidBridge.java:12), `outputsLiquid = true;` (LiquidBridge.java:13), `canOverdrive = false;` (LiquidBridge.java:14), `group = BlockGroup.liquids;` (LiquidBridge.java:15), `envEnabled = Env.any;` (LiquidBridge.java:16). It inherits the ItemBridge class (ItemBridge.java:24, `public class ItemBridge extends Block{`; ItemBridgeBuild, ItemBridge.java:197, `public class ItemBridgeBuild extends Building{`), a distribution block. Class fields: `public final int timerCheckMoved = timers ++;` (ItemBridge.java:25), `public int range;` (ItemBridge.java:27), `public float transportTime;` (ItemBridge.java:28), `public boolean fadeIn = true;` (ItemBridge.java:34), `public boolean moveArrows = true;` (ItemBridge.java:35), `public boolean pulse = false;` (ItemBridge.java:36), `public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;` (ItemBridge.java:37), `public float arrowTimeScl = 6.2f;` (ItemBridge.java:38), `public float bridgeWidth = 6.5f;` (ItemBridge.java:39); constructor `update = true;` (ItemBridge.java:45), `solid = true;` (ItemBridge.java:46), `underBullets = true;` (ItemBridge.java:47), `hasPower = true;` (ItemBridge.java:48), `itemCapacity = 10;` (ItemBridge.java:49), `configurable = true;` (ItemBridge.java:50), `hasItems = true;` (ItemBridge.java:51). Build fields: `public int link = -1;` (ItemBridge.java:202), `public IntSeq incoming = new IntSeq(false, 4);` (ItemBridge.java:203), `public float warmup;` (ItemBridge.java:204), `public float time = -8f, timeSpeed;` (ItemBridge.java:205), `public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:206), `public float transportCounter;` (ItemBridge.java:207). canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. The single def carries `consumePower(0.30f);` (Blocks.java:2396) with `range = 12;` (Blocks.java:2388) and `liquidCapacity = 100f;` (Blocks.java:2395). No sense / read / write overrides exist on LiquidBridgeBuild -- those wait for their own slices only if a later Java line needs them.
	# Single def -- phase-conduit only (size 1, range 12, liquidCapacity 100f, phase-fabric 5 / silicon 7 / metaglass 20 / titanium 10, Blocks.java:2385-2397). bridge-conduit (LiquidBridge, no power def, `hasPower = false;`, Blocks.java:2380) is explicitly OUT of scope; reinforced-bridge-conduit (DirectionLiquidBridge, Blocks.java:2432, different class, hasPower false) is explicitly OUT of scope.
	# Documented limits: (1) power-only first pass -- the phase-conduit's static power consumer (consumePower 0.30f, Blocks.java:2396) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); phase-conduit has no second consumer. (2) shouldConsume gate deferred -- LiquidBridgeBuild inherits ItemBridgeBuild.shouldConsume (`return hadValidLink && enabled;`, ItemBridge.java:495-496); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver runs with should_consume=true when enabled (the MendProjector suppression precedent) -- when unlinked power.status reads 1.0 while Java efficiency is 0. (3) No updateTransport advance -- warmup gate / moveLiquid / moved flag / doDump (LiquidBridge.java:22-31) wait for their own slices; the proof carries no transport/warmup/move keys, the warmup gate (LiquidBridge.java:23) is what the efficiency keys prove. (4) No sense/warmup modeling -- `warmup()` has no override here (draw-only warmup, ItemBridge.java:387) and sense waits for its own slice. (5) Single def -- phase-conduit only (size 1, range 12, liquidCapacity 100f, phase-fabric 5 / silicon 7 / metaglass 20 / titanium 10); bridge-conduit (LiquidBridge, no power def) and reinforced-bridge-conduit (DirectionLiquidBridge, different class) are explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) No draw/config modeling -- bridge draw / drawSelect / drawConfigure / config link (ItemBridge.java:216-296, 375-394, inherited) wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_liquid_bridge_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the liquid-bridge tick wiring every
	# tick (LiquidBridgeBuild.updateTransport(), LiquidBridge.java:22,
	# moves liquid only once the warmup gate (LiquidBridge.java:23, `if(warmup >= 0.25f){`) passes, and warmup follows the folded efficiency through the inherited ItemBridge updateTile (ItemBridge.java:345, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);`), so the warmup gate follows the folded efficiency; no placed-buildings driver ticks LiquidBridge blocks, so this driver is the placed-liquid-bridge tick): each placed LiquidBridge build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_liquid_bridge_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_liquid_bridge_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_liquid_bridge_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a liquid bridge with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup gate (LiquidBridge.java:23, `if(warmup >= 0.25f){`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conduit does not take the early return. The liquid bridge's power draw is STATIC: `consumePower(0.30f);` (Blocks.java:2396) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A liquid bridge with no power consumer is untouched: the tick models no other consumers yet (the updateTransport advance waits for its own slice), and LiquidBridgeBuild inherits ItemBridgeBuild.shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496) -- RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 / ShockwaveTower N2177 / ItemBridge N2178 precedents): the port tracks no live link on any placed-building frame, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_liquid_bridge_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
