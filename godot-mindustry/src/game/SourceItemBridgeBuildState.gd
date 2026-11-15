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
	# The link frame state (ItemBridge.java:198, `public int link
	# = -1;` and :202, `public boolean wasMoved, moved,
	# hadValidLink;`): the tick preserves a configured link
	# instead of resetting it, the enabled pattern above -- the
	# driver recomputes had_valid_link every tick
	# (ItemBridge.java:332-333).
	frame["link"] = int(frame.get("link", -1))
	frame["had_valid_link"] = bool(frame.get("had_valid_link", false))
	return frame

static func _initial_frame() -> Dictionary:
	# A new ItemBridgeBuild starts unlinked: `public int link = -1;` (ItemBridge.java:198)
	# and `public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:202, hadValidLink
	# defaults false); the driver recomputes had_valid_link every tick (ItemBridge.java:332-333).
	return {"link": -1, "had_valid_link": false}

static func source_item_bridge_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the item-bridge frame meta key
	# ("source_item_bridge_building"). An ItemBridge sprite gets a
	# frame bound with the Java field defaults (link -1,
	# had_valid_link false); the live-loop tick fills its other
	# keys every tick. Any other block, or an already-bound sprite,
	# binds nothing.
	if block == null or not _is_item_bridge_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_item_bridge_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conveyor does not take the early return. The item bridge's power draw is STATIC, not conditional: `consumePower(0.30f);` (Blocks.java:2125) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTransport charge follows the folded efficiency: the transport charge (ItemBridge.java:356, `transportCounter += edelta();`) charges by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a phase-conveyor with no power would never advance its transport counter and never move items across the bridge. ItemBridgeBuild overrides shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 / ShockwaveTower N2177 precedents): the port tracks no live link on any placed-building frame, so this slice folds power-only and defers the gate with a documented limit; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent) -- when unlinked power.status reads 1.0 while Java efficiency is 0; the observable gap is efficiency 1.0 vs 0.0 when unlinked. The link gate itself is `hadValidLink = linkValid(tile, other);` (ItemBridge.java:333). The item bridge is its own family (ItemBridge.java:24, `public class ItemBridge extends Block{`; ItemBridgeBuild, ItemBridge.java:197, `public class ItemBridgeBuild extends Building{`), a distribution block, NOT related to any factory / turret / defense family. Class fields: `public final int timerCheckMoved = timers ++;` (ItemBridge.java:25), `public int range;` (ItemBridge.java:27), `public float transportTime;` (ItemBridge.java:28), `public boolean fadeIn = true;` (ItemBridge.java:34), `public boolean moveArrows = true;` (ItemBridge.java:35), `public boolean pulse = false;` (ItemBridge.java:36), `public float arrowSpacing = 4f, arrowOffset = 2f, arrowPeriod = 0.4f;` (ItemBridge.java:37), `public float arrowTimeScl = 6.2f;` (ItemBridge.java:38), `public float bridgeWidth = 6.5f;` (ItemBridge.java:39); constructor `update = true;` (ItemBridge.java:45), `solid = true;` (ItemBridge.java:46), `underBullets = true;` (ItemBridge.java:47), `hasPower = true;` (ItemBridge.java:48), `itemCapacity = 10;` (ItemBridge.java:49), `configurable = true;` (ItemBridge.java:50), `hasItems = true;` (ItemBridge.java:51). Build fields: `public int link = -1;` (ItemBridge.java:198), `public IntSeq incoming = new IntSeq(false, 4);` (ItemBridge.java:199), `public float warmup;` (ItemBridge.java:200), `public float time = -8f, timeSpeed;` (ItemBridge.java:201), `public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:202), `public float transportCounter;` (ItemBridge.java:203). The warmup approach (ItemBridge.java:345, `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);`) also follows the folded efficiency when a valid link exists; without a link `warmup = 0f` (ItemBridge.java:337). draw() uses `float warmup = hasPower ? this.warmup : 1f;` (ItemBridge.java:387) -- the bridge-conveyor (hasPower false) always draws warmup 1f, another reason the two defs must not share one driver row. BufferedItemBridge extends ItemBridge (BufferedItemBridge.java:9, `public class BufferedItemBridge extends ItemBridge{`) with `hasPower = false;` (BufferedItemBridge.java:18) and `bufferCapacity = 50` class default (def overrides to 14, Blocks.java:2113) and `speed = 74f` (def, Blocks.java:2112). canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. The single def carries `consumePower(0.30f);` (Blocks.java:2125) with `range = 12;` (Blocks.java:2118) and `transportTime = 2f;` (Blocks.java:2119). Single def -- phase-conveyor only (size 1, range 12, transportTime 2f, phase-fabric 5 / silicon 7 / lead 10 / graphite 10, Blocks.java:2116-2125). bridge-conveyor (BufferedItemBridge, no power def) is explicitly OUT of scope.
	# Documented limits: (1) power-only first pass -- the phase-conveyor's static power consumer (consumePower 0.30f, Blocks.java:2125) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); phase-conveyor has no second consumer. (2) shouldConsume gate deferred to N2188 -- ItemBridgeBuild overrides shouldConsume (`return hadValidLink && enabled;`, ItemBridge.java:495-496); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the link frame state exists since N2197 (frame link/had_valid_link + pure configure + pure linkValid), but the driver still runs with should_consume=true when enabled (the MendProjector suppression precedent) until N2188 wires the gate -- when unlinked power.status reads 1.0 while Java efficiency is 0. (3) No updateTile transport advance -- link validation is done (N2197 recomputes had_valid_link every tick), but checkIncoming / incoming registration / transportCounter charge / item handoff / warmup approach / doDump (ItemBridge.java:319-363) wait for their own slices; the power proof carries no transport/warmup keys, the transport charge (ItemBridge.java:356) is what the efficiency keys prove. (4) No sense/warmup modeling -- `warmup()` has no override here (draw-only warmup, :387) and sense waits for its own slice. (5) Single def -- phase-conveyor only (size 1, range 12, transportTime 2f, phase-fabric 5 / silicon 7 / lead 10 / graphite 10); bridge-conveyor (BufferedItemBridge, no power def) is explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) No draw/config-UI modeling -- the pure configure covers the config handlers (ItemBridge.java:64/66), but bridge draw / drawSelect / drawConfigure / drawInput (ItemBridge.java:216-296, 375-394) and placement auto-link (playerPlaced / findLink / lastBuild, ItemBridge.java:41, 167-173, 211-220) wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func _to_short(value: int) -> int:
	# The Java (short) cast: truncate to the low 16 bits, then sign-extend (Point2.pack/unpack cast through short, arc Point2.java:35-42); GDScript ints are 64-bit, so the wrap is explicit.
	var truncated: int = value & 0xFFFF
	if truncated >= 0x8000:
		return truncated - 0x10000
	return truncated

static func _point2_pack(x: int, y: int) -> int:
	# Point2.pack (arc Point2.java:40-42, `return (((short)x) << 16) | (((short)y) & 0xFFFF);`).
	return (_to_short(x) << 16) | (_to_short(y) & 0xFFFF)

static func _point2_unpack(pos: int) -> Vector2i:
	# Point2.unpack (arc Point2.java:35-37, `return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));`).
	return Vector2i(_to_short(pos >> 16), _to_short(pos & 0xFFFF))

static func source_item_bridge_configure_state(frame: Dictionary, config: Variant, tile_x: int, tile_y: int) -> Dictionary:
	# The ItemBridge config handlers (ItemBridge.java:64, `config(Point2.class, (ItemBridgeBuild tile, Point2 i) -> tile.link = Point2.pack(i.x + tile.tileX(), i.y + tile.tileY()));` and :66, `config(Integer.class, (ItemBridgeBuild tile, Integer i) -> tile.link = i);`): a Point2 config is RELATIVE -- its x/y add the tile position before packing -- while an Integer config is the packed absolute position. Building.configured dispatches by the config's class through block.configurations (BuildingComp.java:1414-1439); a config of any other type matches no handler and leaves the link unchanged. The pack is arc Point2.pack (arc Point2.java:40-42, `return (((short)x) << 16) | (((short)y) & 0xFFFF);`), via the private _point2_pack helper (the N2191 slerpDelta local precedent -- no separate symbol). Returns {"link": ...}; the caller writes it back onto the frame. The config() getter (ItemBridge.java:500-502, `return Point2.unpack(link).sub(tile.x, tile.y);`) and write/read (ItemBridge.java:510-512, `write.i(link);`) wait for their own rebuild slice.
	if config is int:
		return {"link": int(config)}
	if config is Dictionary:
		var dx: int = int(config.get("x", 0))
		var dy: int = int(config.get("y", 0))
		return {"link": _point2_pack(dx + tile_x, dy + tile_y)}
	return {"link": int(frame.get("link", -1))}

static func source_item_bridge_link_valid_state(tile_x: int, tile_y: int, other_x: int, other_y: int, range: int, blocks_match: bool, teams_match: bool, other_link: int, this_pos: int, other_exists: bool, check_double: bool) -> Dictionary:
	# linkValid (ItemBridge.java:145-156, `public boolean linkValid(Tile tile, Tile other){` with `return linkValid(tile, other, true);`, and `public boolean linkValid(Tile tile, Tile other, boolean checkDouble){`): `if(other == null || tile == null || !positionsValid(tile.x, tile.y, other.x, other.y)) return false;` -- a missing other tile is never valid -- then `return ((other.block() == tile.block() && tile.block() == this) || (!(tile.block() instanceof ItemBridge) && other.block() == this))` and `&& (other.team() == tile.team() || tile.block() != this)` and `&& (!checkDouble || ((ItemBridgeBuild)other.build).link != tile.pos());`. The driver ticks ItemBridge builds only, so tile.block() is always this: the block clause reduces to the other block being an ItemBridge (blocks_match, gathered by the driver) and the team clause to the teams matching (teams_match). positionsValid (ItemBridge.java:157-166, `public boolean positionsValid(int x1, int y1, int x2, int y2){`): same column `return Math.abs(y1 - y2) <= range;`, same row `return Math.abs(x1 - x2) <= range;`, else false. updateTile calls the two-arg form, so check_double is true on the live tick (ItemBridge.java:332-333, `Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);`); checkIncoming calls it with false (ItemBridge.java:310), which waits for its own slice.
	if not other_exists:
		return {"had_valid_link": false}
	var positions_valid: bool = false
	if tile_x == other_x:
		positions_valid = abs(tile_y - other_y) <= range
	elif tile_y == other_y:
		positions_valid = abs(tile_x - other_x) <= range
	if not positions_valid:
		return {"had_valid_link": false}
	var double_ok: bool = (not check_double) or (other_link != this_pos)
	return {"had_valid_link": bool(blocks_match and teams_match and double_ok)}

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
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a phase-conveyor does not take the early return. The item bridge's power draw is STATIC: `consumePower(0.30f);` (Blocks.java:2125) registers a plain ConsumePower, so the catalog consumePower 0.3 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. An item bridge with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and ItemBridgeBuild overrides shouldConsume (ItemBridge.java:495, `public boolean shouldConsume(){` with `return hadValidLink && enabled;`, ItemBridge.java:496) -- RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 / ShockwaveTower N2177 precedents): the link frame state exists since N2197 (frame link/had_valid_link + pure configure + pure linkValid), but the gate wiring waits for N2188, so the machinery still runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
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
		# The updateTile link recompute (ItemBridge.java:332-333, `Tile other = world.tile(link);` / `hadValidLink = linkValid(tile, other);`): updateConsumption runs BEFORE updateTile (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), so this recompute runs AFTER the consumption fold above -- and only when enabled (ItemBridge `noUpdateDisabled = true;`, ItemBridge.java:54: a disabled bridge never runs updateTile, so its had_valid_link freezes instead of clearing). The partner sprite is looked up through placed_blocks by the unpacked link cell (Point2.unpack, arc Point2.java:35-37, `return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));`); a missing sprite or a partner that is not an ItemBridge fails the block match, and the partner's team is read the same way as this sprite's (SOURCE_BUILD_TEAM_META_KEY, default derelict). The gate itself does NOT change here -- should_consume stays true when enabled; N2188 wires `should_consume = had_valid_link && enabled` (ItemBridge.java:495-496, `return hadValidLink && enabled;`).
		if bool(frame.get("enabled", true)):
			var link_value: int = int(frame.get("link", -1))
			var other_cell: Vector2i = _point2_unpack(link_value)
			var placed_blocks_value: Variant = game.get("placed_blocks")
			var placed_blocks: Dictionary = placed_blocks_value if placed_blocks_value is Dictionary else {}
			var other_sprite: Variant = placed_blocks.get(game.call("cell_key", other_cell))
			var other_exists: bool = other_sprite != null and is_instance_valid(other_sprite) and other_sprite is Sprite2D
			var other_blocks_match: bool = false
			var other_teams_match: bool = false
			var other_link: int = -1
			if other_exists:
				var other_block_id: String = str(other_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
				if blocks_by_id.has(other_block_id):
					var other_block = blocks_by_id[other_block_id]
					other_blocks_match = _is_item_bridge_build_implementation(str(other_block.implementation))
				var other_team_id: int = int(other_sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
				other_teams_match = other_team_id == team_id
				var other_frame: Variant = other_sprite.get_meta(SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
				if other_frame is Dictionary:
					other_link = int(other_frame.get("link", -1))
			var link_range: int = int(block.properties.get("range", 0))
			var this_pos: int = _point2_pack(cell.x, cell.y)
			frame["had_valid_link"] = bool(source_item_bridge_link_valid_state(cell.x, cell.y, other_cell.x, other_cell.y, link_range, other_blocks_match, other_teams_match, other_link, this_pos, other_exists, true).get("had_valid_link", false))
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
