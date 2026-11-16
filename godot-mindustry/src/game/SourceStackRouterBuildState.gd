extends RefCounted
class_name SourceStackRouterBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

# The StackRouter implementation (StackRouter.java:11, `public class StackRouter extends DuctRouter{`): surge-router (consumePower 3f/60f, Blocks.java:2266, `consumePower(3f / 60f);`; size 1, speed 6f, itemCapacity 10, health 130, surge-alloy 5 / tungsten 1, Blocks.java:2255-2268). StackRouter extends DuctRouter, NOT a factory or crafter or bridge or conveyor, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_stack_router_building", the radar precedent), and this slice adds the stack-router key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceStackRouter* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the StackRouterBuild.updateTile unloads items at a rate that follows the folded efficiency (StackRouter.java:29, `float eff = enabled ? (efficiency + baseEfficiency) : 0f;` with StackRouter.java:35, `progress += eff;`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) -- so a surge-router with no power would unload slower and draw no glow, as if power.status were 1.0. The surge def carries `baseEfficiency = 1f;` (Blocks.java:2265), so at efficiency 0 the router STILL unloads at eff 1f -- power raises eff toward 2f and lights the glow (StackRouter.java:79, `if(glowRegion.found() && power != null && power.status > 0){` with StackRouter.java:81, `Draw.color(glowColor, glowAlpha * power.status);`); the glow is the only hard power gate on this family. Note the disabled branch differs from the conveyor: StackRouter computes `... : 0f;` (StackRouter.java:29) where StackConveyor computes `... : 1f;` (StackConveyor.java:270) -- a disabled surge-router unloads nothing, while a disabled surge-conveyor still reels at eff 1f.
const SOURCE_STACK_ROUTER_BUILD_IMPLEMENTATIONS := ["StackRouter"]
const SOURCE_STACK_ROUTER_BUILDING_META_KEY := "source_stack_router_building"
# The surge-router def constants (single def, Blocks.java:2255-2268):
# `speed = 6f;` (Blocks.java:2259) against the DuctRouter class
# default `public float speed = 5f;` (DuctRouter.java:19),
# `baseEfficiency = 1f;` (Blocks.java:2265) against the
# StackRouter class default `public float baseEfficiency = 0f;`
# (StackRouter.java:12), and `itemCapacity = 10;`
# (StackRouter.java:20, also the Block class default,
# `public int itemCapacity = 10;`, Block.java:75). The catalog
# carries neither speed nor baseEfficiency for this family, so
# the driver reads these constants (the Separator craftTime
# precedent). There is no per-def helper (unlike N2226): the
# surge-router is the only StackRouter def.
const SOURCE_STACK_ROUTER_SPEED := 6.0
const SOURCE_STACK_ROUTER_BASE_EFFICIENCY := 1.0
const SOURCE_STACK_ROUTER_ITEM_CAPACITY := 10
# The glow def constants (StackRouter.java:15-16): `public float glowAlpha = 1f;` and `public Color glowColor = Pal.redLight;` (`redLight = Color.valueOf("feb380"),`, Pal.java:138) -- the single surge-router def sets NEITHER (Blocks.java:2255-2268), so both take the class defaults. The draw pure takes glow_color / glow_alpha as caller-supplied inputs and these constants record the def values (the N2431 elevation precedent).
const SOURCE_STACK_ROUTER_GLOW_ALPHA := 1.0
const SOURCE_STACK_ROUTER_GLOW_COLOR := "Pal.redLight"

static func _is_stack_router_build_implementation(implementation: String) -> bool:
	return SOURCE_STACK_ROUTER_BUILD_IMPLEMENTATIONS.has(implementation)

static func _stack_router_first_item(items: Dictionary, item_order: Array) -> Variant:
	# ItemModule.first() (ItemModule.java:182-189, `public @Nullable Item first(){` with `for(int i = 0; i < items.length; i++){` / `if(items[i] > 0){` / `return content.item(i);`): scans the item slots in content-id order and returns the first with a count above zero, null when none is held. The port's items dict is keyed by item name (the factory precedent), so the scan runs over item_order -- the catalog item_names_by_id, the content-id order Java iterates (the N2225 take() precedent). An item name outside the order is never picked: Java cannot hold a non-content item. An EMPTY order picks nothing: no content order is known, so the port cannot pick faithfully (the driver always passes the catalog order).
	for candidate in item_order:
		if inventory.item_count(items, str(candidate)) > 0:
			return str(candidate)
	return null

static func source_stack_router_target_list_state(neighbours: Array, current: Variant, sort_item: Variant, rotation: int, team: int, cdump: int, handoff_count: int) -> Dictionary:
	# The target() live proximity selection (DuctRouter.target(), DuctRouter.java:139-157), the pure simulation of consecutive target() calls -- the StackRouter while loop (`var target = target();` / `while(target != null && items.get(current) > 0){` / `target = target();`, StackRouter.java:47-52) calls target() once per handoff, so this function simulates up to handoff_count calls (items.get(current) at tick start, `public int get(Item item){` / `return items[item.id];`, ItemModule.java:209-211) and returns the ordered targets plus the cdump value after the simulated calls. Each Java expr on ONE comment line (the N2148 lesson):
	# `public Building target(){`
	# `if(current == null) return null;`
	# `int dump = cdump;`
	# `for(int i = 0; i < proximity.size; i++){`
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# `int rel = relativeTo(other);`
	# `if(!(sortItem != null && (current == sortItem) != (rel == rotation)) && !(rel == (rotation + 2) % 4) && other.team == team && other.acceptItem(this, current)){`
	# `incrementDump(proximity.size);`
	# `public void incrementDump(int prox){`
	# `if(prox != 0){`
	# `cdump = ((cdump + 1) % prox);`
	# `public byte relativeTo(Building build){`
	# `public @Nullable Item sortItem;`
	# `config(Item.class, (DuctRouterBuild tile, Item item) -> tile.sortItem = item);`
	# `transient int cdump;`
	# `transient int rotation;`
	# Each call snapshots `int dump = cdump;` and scans from there; the first match wins. incrementDump runs on EVERY scanned iteration -- before the return on a match (DuctRouter.java:149-150) and at the end of the loop otherwise (DuctRouter.java:153) -- so each call advances cdump by exactly the number of neighbours scanned (1..size), including the match; a call that scans the whole list without a match returns null and stops the sequence (its advance is a full size, i.e. a no-op modulo size). The scan index uses the snapshot dump, NOT the advancing cdump. The neighbour frame contract: each entry is a Dict {id, rel, team, accepts_item} in proximity order -- rel is relativeTo(other) (BuildingComp.java:530) precomputed per neighbour (the N2472 fill computes it live from the ring offsets; a caller-supplied list still carries it precomputed), team is the neighbour team for the `other.team == team` gate, accepts_item is the neighbour acceptItem(this, current) answer. The router team is an explicit parameter: the Java match compares other.team == team, so the pure function needs it as an input. The sort gate compares item names as strings (the N2225 precedent -- Java compares Item references). current == null returns an empty list at once; an empty neighbour list runs no iteration, so cdump is unchanged; handoff_count <= 0 means no call happens. Documented deviation: Java calls target() once more after the last handoff (StackRouter.java:51, `target = target();` before the while condition re-checks items), so cdump advances one extra scan the port does not simulate -- the port stops at handoff_count targets and the trailing result is discarded by Java too, only its cdump side effect is lost.
	var targets: Array = []
	var dump_after: int = cdump
	if current == null or neighbours.is_empty() or handoff_count <= 0:
		return {"targets": targets, "cdump_after": dump_after}
	var size: int = neighbours.size()
	var current_name: String = str(current)
	var sort_name: String = "" if sort_item == null else str(sort_item)
	while targets.size() < handoff_count:
		var dump: int = dump_after
		var matched := false
		for i in range(size):
			var entry: Dictionary = neighbours[(i + dump) % size] as Dictionary
			var rel: int = int(entry.get("rel", -1))
			var sort_gate: bool = sort_item != null and (current_name == sort_name) != (rel == rotation)
			var backwards: bool = rel == (rotation + 2) % 4
			var same_team: bool = int(entry.get("team", -1)) == team
			var accepts: bool = bool(entry.get("accepts_item", false))
			dump_after = (dump_after + 1) % size
			if not sort_gate and not backwards and same_team and accepts:
				targets.append(entry)
				matched = true
				break
		if not matched:
			break
	return {"targets": targets, "cdump_after": dump_after}

static func source_stack_router_proximity_neighbours_live_fill_state(world_tiles: Dictionary, cell: Vector2i, size: int, team: int, team_map: Dictionary, accepts_map: Dictionary) -> Dictionary:
	# The live proximity query (N2472, DEFERRED #210, QUERY
	# HALF ONLY): the N2324 target-list pure simulates
	# DuctRouter.target() over the frame proximity_neighbours
	# input, but no live query filled that input yet, so a
	# live surge-router with no stamped neighbours passed an
	# empty list and no live handoff happened. This fill
	# scans the Edges proximity ring live and assembles the
	# neighbour Dicts {id, rel, team, accepts_item} in ring
	# order; the tick stamps them on the frame BEFORE the
	# target list reads them. Java builds proximity in
	# updateProximity() (BuildingComp.java:1879-1903) -- NOT
	# onProximityUpdate (:1154-1156, which is just noSleep()).
	# Each Java expr on ONE comment line (the N2148 lesson):
	# `public void updateProximity(){`
	# `Point2[] nearby = Edges.getEdges(block.size);`
	# `Building other = world.build(tile.x + point.x, tile.y + point.y);`
	# `if(other == null || other.team != team) continue;`
	# `other.proximity.addUnique(self());`
	# `//using a set to prevent duplicates`
	# `proximity.add(tile);`
	# `transient Seq<Building> proximity = new Seq<>(true, 6, Building.class);`
	# `static final ObjectSet<Building> tmpTiles = new ObjectSet<>();`
	# `public byte relativeTo(Building build){`
	# `if(Math.abs(x - build.x) > Math.abs(y - build.y)){`
	# `if(x <= build.x - 1) return 0;`
	# `if(x >= build.x + 1) return 2;`
	# `if(y <= build.y - 1) return 1;`
	# `if(y >= build.y + 1) return 3;`
	# `int bot = -(int)(i / 2f) - 1;`
	# `int top = (int)(i / 2f + 0.5f) + 1;`
	# `edges[i][idx++] = new Point2(bot + 1 + j, bot);`
	# `edges[i][idx++] = new Point2(bot + 1 + j, top);`
	# `edges[i][idx++] = new Point2(bot, bot + j + 1);`
	# `edges[i][idx++] = new Point2(top, bot + j + 1);`
	# `Arrays.sort(edges[i], (e1, e2) -> Float.compare(Mathf.angle(e1.x, e1.y), Mathf.angle(e2.x, e2.y)));`
	# `public static Point2[] getEdges(int size){`
	# `public static float angle(float x, float y){`
	# `float result = atan2(x, y) * radDeg;`
	# `if(result < 0) result += 360f;`
	# `public Building target(){`
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# `int rel = relativeTo(other);`
	# `if(!(sortItem != null && (current == sortItem) != (rel == rotation)) && !(rel == (rotation + 2) % 4) && other.team == team && other.acceptItem(this, current)){`
	# `var target = target();`
	# `while(target != null && items.get(current) > 0){`
	# `target.handleItem(this, current);`
	# `public int size = 1;`
	# The ring is the Edges static block (Edges.java:23-40):
	# bot/top from the size, 4*size edge points, sorted by
	# Mathf.angle -- and Mathf.angle NORMALIZES to [0, 360)
	# (arc Mathf.java:98-102), so the size-1 ring is east /
	# north / west / south = rel 0/1/2/3, the Geometry.d4
	# order (arc Geometry.java:9-14). The shared helper
	# source_block_proximity_cells_state sorts UNNORMALIZED
	# atan2 and puts south first, so the fill generates the
	# ring inline, Java-exact (the helper itself is out of
	# scope -- a shared ring-geometry follow-through). rel
	# is relativeTo(Building) (BuildingComp.java:530-540)
	# in tile-offset form: |dx| > |dy| picks east/west
	# (0/2), otherwise the y branch picks north/south
	# (1/3) -- a diagonal ring point takes the y branch
	# (ties go to y). The world-unit thresholds collapse
	# exactly: adjacent tiles differ by 8 world units,
	# above the 1-unit threshold. A ring tile yields an
	# entry only when the tile is known (a world_tiles Dict
	# entry -- a missing key is a null tile, the BeamDrill
	# precedent) AND a building stands there (a team_map
	# key -- its presence IS the building signal, a team
	# only exists on a placed building) AND its team
	# matches the router (the Java same-team filter,
	# BuildingComp.java:1887 -- the fill takes the router
	# team as an input for exactly this: an enemy entry in
	# the list would be scanned and skipped by the N2324
	# pure, advancing cdump past it, which Java never
	# does). The id is the ring tile's "x,y" key (the port
	# cell_key format, SourceWorldGrid.gd); accepts_item is
	# the neighbour acceptItem(this, current) answer for
	# the router's current item, a missing key rejecting
	# (false -- the N2324 pure's default). The fill never
	# reads the solid flag: a neighbour building is not a
	# wall tile. DESIGN DECISIONS (verified, not guessed):
	# world_tiles carries NO team or acceptItem field (the
	# BeamDrill convention is {solid, wall_drop} per tile,
	# SourceBeamDrillBuildState.gd:392), so the team +
	# accepts answers ride the caller-supplied team_map /
	# accepts_map (the N2459 wall_attribute_by_tile
	# precedent) and the live tile producer that stamps
	# frame["world_tiles"] / frame["team_by_tile"] /
	# frame["accepts_item_by_tile"] waits for its own
	# slice -- this slice does NOT invent a tile producer
	# (the N2414 precedent). Documented deviations: (1)
	# Java funnels the proximity list through an ObjectSet
	# (BuildingComp.java:55, tmpTiles), so its final order
	# is hash order while the port uses the deterministic
	# Edges scan order. (2) No dedup: provably unnecessary
	# for size 1 -- no single building can occupy 2
	# orthogonal ring tiles without covering the router's
	# own tile; multiblock dedup for size > 1 waits (the
	# N2394 ring-dedup follow-through). (3) handleItem
	# application (`target.handleItem(this, current);`,
	# StackRouter.java:49) is NOT in scope -- the N2240
	# advance returns handed_off / handed_to as pure
	# results and does not write into another building's
	# frame; it waits for a cross-frame-write design.
	if size < 1:
		return {"proximity_neighbours": []}
	var ring_index: int = size - 1
	var bot: int = -int(float(ring_index) / 2.0) - 1
	var top: int = int(float(ring_index) / 2.0 + 0.5) + 1
	var offsets: Array[Vector2i] = []
	for j in range(ring_index + 1):
		offsets.append(Vector2i(bot + 1 + j, bot))
		offsets.append(Vector2i(bot + 1 + j, top))
		offsets.append(Vector2i(bot, bot + j + 1))
		offsets.append(Vector2i(top, bot + j + 1))
	offsets.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var angle_a: float = rad_to_deg(atan2(float(a.y), float(a.x)))
		if angle_a < 0.0:
			angle_a += 360.0
		var angle_b: float = rad_to_deg(atan2(float(b.y), float(b.x)))
		if angle_b < 0.0:
			angle_b += 360.0
		if angle_a != angle_b:
			return angle_a < angle_b
		if a.x != b.x:
			return a.x < b.x
		return a.y < b.y
	)
	var proximity_neighbours: Array = []
	for offset in offsets:
		var dx: int = int(offset.x)
		var dy: int = int(offset.y)
		var rx: int = cell.x + dx
		var ry: int = cell.y + dy
		var key: String = str(rx) + "," + str(ry)
		var tile: Variant = world_tiles.get(key, null)
		if tile == null or not (tile is Dictionary):
			continue
		if not team_map.has(key):
			continue
		var neighbour_team: int = int(team_map.get(key, -1))
		if neighbour_team != team:
			continue
		var rel: int = -1
		if abs(dx) > abs(dy):
			rel = 0 if dx > 0 else 2
		elif dy > 0:
			rel = 1
		elif dy < 0:
			rel = 3
		proximity_neighbours.append({"id": key, "rel": rel, "team": neighbour_team, "accepts_item": bool(accepts_map.get(key, false))})
	return {"proximity_neighbours": proximity_neighbours}

static func source_stack_router_accept_item_state(unloading: bool, current: Variant, item: Variant, items: Dictionary, item_capacity: int, facing_rel: int, rotation: int) -> Dictionary:
	# The acceptItem intake gate (StackRouterBuild.acceptItem(), StackRouter.java:89-93) -- the StackRouter OVERRIDE, NOT the parent DuctRouter acceptItem (DuctRouter.java:160-164), which is STRICTER: `return current == null && items.total() == 0 &&` (DuctRouter.java:161) takes an item only into an EMPTY router with no current item, while the override takes the current item into a partially filled router. Each Java expr on ONE comment line (the N2148 lesson):
	# `public boolean acceptItem(Building source, Item item){`
	# `return !unloading && (current == null || item == current) && items.total() < itemCapacity &&`
	# `(Edges.getFacingEdge(source.tile, tile).relativeTo(tile) == rotation);`
	# `public boolean unloading = false;`
	# `public @Nullable Item current;`
	# `public int total(){`
	# `public int itemCapacity = 10;`
	# `public static Tile getFacingEdge(Tile tile, Tile other){`
	# `if(!block.isMultiblock()) return world.tile(tilex, tiley);`
	# `public byte relativeTo(Tile tile){`
	# `public static byte relativeTo(int x, int y, int cx, int cy){`
	# `transient int rotation;`
	# The four terms are independent: !unloading (the build field, StackRouter.java:25 -- an unloading router takes nothing); current == null || item == current (current is the nullable build field, DuctRouter.java:80; the port compares item names as strings, the N2225 precedent -- Java compares Item references); items.total() < itemCapacity (total(), ItemModule.java:174-176, via the shared inventory helper; itemCapacity 10, Block.java:75, the surge def value, StackRouter.java:20); and the facing term. The facing chain: Edges.getFacingEdge(Tile, Tile) (Edges.java:57-60) returns the source tile itself when the source block is not a multiblock (`if(!block.isMultiblock()) return world.tile(tilex, tiley);`, Edges.java:63), and relativeTo is Tile.relativeTo (Tile.java:82-84, the adjacency table, Tile.java:95-101: 0-3 for an adjacent tile, -1 otherwise) -- NOT BuildingComp.relativeTo(Building) (BuildingComp.java:530, the float-position one DuctRouter.target() uses for rel). A non-adjacent source yields -1, which never equals rotation, so it rejects. The port takes facing_rel precomputed (the N2324 precedent: rel precomputed per neighbour -- the port has no live tile geometry to run Edges.getFacingEdge / Tile.relativeTo itself) and compares it to rotation (`transient int rotation;`, BuildingComp.java:69). acceptItem is an intake gate called by OTHER buildings' dump/offload (BuildingComp.java:1001-1016, `if(other.acceptItem(self(), item) && canDump(other, item)){` then `other.handleItem(self(), item);`), never by the router's own tick -- so this slice wires no call site: pure + test + proof only. handleItem application (DuctRouter.java:179-184, `current = item;` + `items.add(item, 1);`) still defers: the gate reports the verdict only, it does not add the item.
	var current_match: bool = current == null or str(item) == str(current)
	var accepts: bool = not unloading and current_match and inventory.items_total(items) < item_capacity and facing_rel == rotation
	return {"accepts": accepts}

static func source_stack_router_update_tile_advance_state(frame: Dictionary, speed: float, base_efficiency: float, item_capacity: int, targets: Array, item_order: Array) -> Dictionary:
	# The updateTile advance (StackRouterBuild.updateTile(), StackRouter.java:28-70), the pure frame advance -- the build fields are `public boolean unloading = false;` (StackRouter.java:25), `public float progress;` (DuctRouter.java:79) and `public @Nullable Item current;` (DuctRouter.java:80), and the advance follows the Java lines in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public class StackRouter extends DuctRouter{`
	# `public class StackRouterBuild extends DuctRouterBuild{`
	# `public float baseEfficiency = 0f;`
	# `itemCapacity = 10;`
	# `public void updateTile(){`
	# `float eff = enabled ? (efficiency + baseEfficiency) : 0f;`
	# `float cap = speed;`
	# `if(!unloading && current != null && items.total() >= itemCapacity){`
	# `if(progress < cap){`
	# `progress += eff;`
	# `if(progress >= cap){`
	# `unloading = true;`
	# `progress %= cap;`
	# `if(unloading && current != null){`
	# `var target = target();`
	# `while(target != null && items.get(current) > 0){`
	# `target.handleItem(this, current);`
	# `items.remove(current, 1);`
	# `target = target();`
	# `if(items.get(current) == 0){`
	# `current = null;`
	# `unloading = false;`
	# `if((current == null || items.get(current) == 0) && items.total() > 0){`
	# `current = items.first();`
	# `if(items.empty()){`
	# The two charge ifs are SEQUENTIAL, not elif -- a charge that crosses the cap in the same tick sets unloading = true + progress %= cap immediately (StackRouter.java:38-40) -- and the unload branch runs in the SAME tick (a separate if, :45), so a router that reaches the cap starts unloading at once. The eff fold is 0f when disabled (NOT the conveyor's 1f, StackConveyor.java:270), and the charge carries NO delta multiply -- this advance takes no source_delta at all. The %= cap guards cap > 0 (Java would produce NaN on a 0 speed; the def const is 6f -- the N2225 transport_time guard precedent).
	# The parent DuctRouter (DuctRouter.java:18, `public class DuctRouter extends Block{`; DuctRouterBuild, DuctRouter.java:76, `public class DuctRouterBuild extends Building{`) supplies the speed (`public float speed = 5f;`, DuctRouter.java:19) and the target() query (`public Building target(){`, DuctRouter.java:139, with `if(current == null) return null;`, `int dump = cdump;`, `for(int i = 0; i < proximity.size; i++){`, `Building other = proximity.get((i + dump) % proximity.size);`, `int rel = relativeTo(other);`, `if(!(sortItem != null && (current == sortItem) != (rel == rotation)) && !(rel == (rotation + 2) % 4) && other.team == team && other.acceptItem(this, current)){` and `incrementDump(proximity.size);`, DuctRouter.java:140-153) -- a live proximity scan with cdump rotation, so the pure advance takes the explicit ordered targets list instead: each entry models one target() call result, popped in order per handoff (cdump rotation simulated by list order -- to model N items to the same target, repeat its entry N times). handleItem application defers -- the advance returns handed_off / handed_to as pure results. The zero-count-current edge is faithful: when unloading is true but items.get(current) is already 0, the while loop never runs and the `if(items.get(current) == 0){` clear (StackRouter.java:56-58) fires, so the router still clears current/unloading and re-picks.
	# DuctRouter sets `noUpdateDisabled = true;` (DuctRouter.java:32) against the Block default `public boolean noUpdateDisabled = false;` (Block.java:170), so Java's `if(enabled || !block.noUpdateDisabled){` (BuildingComp.java:2276) never runs updateTile for a disabled stack router -- the driver gate is EXACT, not the N2195 pragmatic choice. updateConsumption runs before updateTile (`updateConsumption();`, BuildingComp.java:2274), so the advance reads the freshly folded efficiency. The frame inputs are `transient float efficiency;` (BuildingComp.java:85, default 0.0) and `transient boolean enabled = true;` (BuildingComp.java:77, default true).
	# The ItemModule lines: `public @Nullable Item first(){` (ItemModule.java:182-189, `for(int i = 0; i < items.length; i++){` / `if(items[i] > 0){` / `return content.item(i);` -- content-id order, via _stack_router_first_item), `public boolean empty(){` (ItemModule.java:170-172, `return total == 0;`), `public int get(Item item){` (ItemModule.java:209-211, `return items[item.id];`), and the remove clamp (ItemModule.java:258-262, `amount = Math.min(amount, items[item.id]);` / `items[item.id] -= amount;` / `total -= amount;`) -- the shared inventory helpers do the same (item_count / items_total / remove_item_state, the N2225 precedent). The def values come from the driver constants: `speed = 6f;` (Blocks.java:2259), `baseEfficiency = 1f;` (Blocks.java:2265), `consumePower(3f / 60f);` (Blocks.java:2266).
	var enabled: bool = bool(frame.get("enabled", true))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var unloading: bool = bool(frame.get("unloading", false))
	var current: Variant = frame.get("current", null)
	var progress: float = float(frame.get("progress", 0.0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var handed_off: int = 0
	var handed_to: Array = []
	var eff: float = efficiency + base_efficiency if enabled else 0.0
	var cap: float = speed
	if not unloading and current != null and inventory.items_total(items) >= item_capacity:
		if progress < cap:
			progress += eff
		if progress >= cap:
			unloading = true
			if cap > 0.0:
				progress = fmod(progress, cap)
	if unloading and current != null:
		var current_name: String = str(current)
		var target_index: int = 0
		while target_index < targets.size() and inventory.item_count(items, current_name) > 0:
			var entry: Variant = targets[target_index]
			target_index += 1
			var removed: Dictionary = inventory.remove_item_state(items, current_name, 1)
			items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
			handed_off += 1
			if entry is Dictionary:
				handed_to.append(str(entry.get("id", "")))
			else:
				handed_to.append(str(entry))
		if inventory.item_count(items, current_name) == 0:
			current = null
			unloading = false
	var current_count: int = 0 if current == null else inventory.item_count(items, str(current))
	if (current == null or current_count == 0) and inventory.items_total(items) > 0:
		current = _stack_router_first_item(items, item_order)
	if inventory.items_total(items) == 0:
		unloading = false
		current = null
	return {"unloading": unloading, "current": current, "progress": progress, "items": items, "handed_off": handed_off, "handed_to": handed_to}

static func source_stack_router_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The stack-router tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (StackRouter.java:11, `public class StackRouter extends DuctRouter{`; StackRouterBuild, StackRouter.java:24, `public class StackRouterBuild extends DuctRouterBuild{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# stack router skips consumption like Java's updateConsumption
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
	# for this stack router (N2125); the tick preserves a disabled
	# stack router instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# A new StackRouterBuild starts idle: `public boolean unloading = false;` (StackRouter.java:25), `public float progress;` (DuctRouter.java:79, default 0f) and `public @Nullable Item current;` (DuctRouter.java:80, default null); the Building.items ItemModule starts empty (frame["items"], Dictionary keyed by item name, the factory precedent -- the N2225 ItemBridge advance carries the same key). The target() selection (N2324) adds the dump cursor `transient int cdump;` (BuildingComp.java:68, default 0) and the sort item `public @Nullable Item sortItem;` (DuctRouter.java:77, default null).
	return {"unloading": false, "current": null, "progress": 0.0, "items": {}, "cdump": 0, "sort_item": null}

static func source_stack_router_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the stack-router frame meta key
	# ("source_stack_router_building"). A StackRouter sprite gets a
	# frame bound with the Java field defaults (unloading false,
	# current null, progress 0, items empty); the live-loop tick
	# fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_stack_router_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_STACK_ROUTER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_STACK_ROUTER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_STACK_ROUTER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_stack_router_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a surge-router does not take the early return. The stack router's power draw is STATIC, not conditional: `consumePower(3f / 60f);` (Blocks.java:2266) registers a plain ConsumePower, so the catalog consumePower 0.05 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The stack router's updateTile (StackRouter.java:29, `float eff = enabled ? (efficiency + baseEfficiency) : 0f;` with StackRouter.java:35, `progress += eff;`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) unloads items at a rate that follows the folded efficiency -- and because the surge def sets `baseEfficiency = 1f;` (Blocks.java:2265), the router still unloads at eff 1f with no power; power raises eff toward 2f and lights the glow (StackRouter.java:79, `if(glowRegion.found() && power != null && power.status > 0){` with StackRouter.java:81, `Draw.color(glowColor, glowAlpha * power.status);`). The glow is the only hard power gate on this family.
	# StackRouterBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). There is NO gate to defer here (unlike the ItemBridge / LiquidBridge link gates): the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and edelta (BuildingComp.java:1927-1929, `return efficiency * delta();`) are the surrounding gates. The single def carries `consumePower(3f / 60f);` (Blocks.java:2266) with `baseEfficiency = 1f;` (Blocks.java:2265), `speed = 6f;` (Blocks.java:2259), `health = 130;` (Blocks.java:2257), `hasPower = true;` (Blocks.java:2260), `consumesPower = true;` (Blocks.java:2261) and `conductivePower = true;` (Blocks.java:2262).
	# The stack router is its own family (StackRouter.java:11, `public class StackRouter extends DuctRouter{`; StackRouterBuild, StackRouter.java:24, `public class StackRouterBuild extends DuctRouterBuild{`), a distribution block, NOT related to any factory / turret / defense / bridge / conveyor family. Class fields: `public float baseEfficiency = 0f;` (StackRouter.java:12), `public @Load(value = "@-glow", fallback = "arrow-glow") TextureRegion glowRegion;` (StackRouter.java:14), `public float glowAlpha = 1f;` (StackRouter.java:15), `public Color glowColor = Pal.redLight;` (StackRouter.java:16); constructor `public StackRouter(String name){` (StackRouter.java:18), `itemCapacity = 10;` (StackRouter.java:20), `drawDynamic = true;` (StackRouter.java:21). Build fields: `public boolean unloading = false;` (StackRouter.java:25). The updateTile advance (StackRouter.java:29, `float eff = enabled ? (efficiency + baseEfficiency) : 0f;` with StackRouter.java:30, `float cap = speed;` and StackRouter.java:35, `progress += eff;`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test) fills toward the cap: `if(!unloading && current != null && items.total() >= itemCapacity){` (StackRouter.java:32) with `if(progress < cap){` (StackRouter.java:33), then `if(progress >= cap){` (StackRouter.java:37) sets `unloading = true;` (StackRouter.java:38) and `progress %= cap;` (StackRouter.java:39). The unload branch `if(unloading && current != null){` (StackRouter.java:46) hands items to the target: `var target = target();` (StackRouter.java:47), `while(target != null && items.get(current) > 0){` (StackRouter.java:48), `target.handleItem(this, current);` (StackRouter.java:49), `items.remove(current, 1);` (StackRouter.java:50), `if(items.get(current) == 0){` (StackRouter.java:52) sets `current = null;` (StackRouter.java:53) and `unloading = false;` (StackRouter.java:54). The current-pick branch `if((current == null || items.get(current) == 0) && items.total() > 0){` (StackRouter.java:62) with `current = items.first();` (StackRouter.java:63) picks the next item, and `if(items.empty()){` (StackRouter.java:68) clears it. The draw branch `public void drawCached(){` (StackRouter.java:75) calls `super.draw();` (StackRouter.java:76), then `if(glowRegion.found() && power != null && power.status > 0){` (StackRouter.java:79) with `Draw.z(Layer.blockAdditive);` (StackRouter.java:80), `Draw.color(glowColor, glowAlpha * power.status);` (StackRouter.java:81), `Draw.blend(Blending.additive);` (StackRouter.java:82), `Draw.rect(glowRegion, x, y, rotation * 90);` (StackRouter.java:83), `Draw.blend();` (StackRouter.java:84) and `Draw.color();` (StackRouter.java:85). The accept branch `public boolean acceptItem(Building source, Item item){` (StackRouter.java:89) checks `(Edges.getFacingEdge(source.tile, tile).relativeTo(tile) == rotation);` (StackRouter.java:90).
	# The parent DuctRouter (DuctRouter.java:18, `public class DuctRouter extends Block{`; DuctRouterBuild, DuctRouter.java:76, `public class DuctRouterBuild extends Building{`) supplies the sortItem / progress / current build fields and the base updateTile (`progress += edelta() / speed * 2f;`, DuctRouter.java:102, with `if(progress >= (1f - 1f/speed)){`, DuctRouter.java:103, and `progress %= (1f - 1f/speed);`, DuctRouter.java:104) -- but StackRouterBuild OVERRIDES updateTile (StackRouter.java:28), so the parent's edelta-based advance never runs for a surge-router. Parent class fields: `public float speed = 5f;` (DuctRouter.java:19), `public @Load(value = "@-top") TextureRegion topRegion;` (DuctRouter.java:21); constructor `public DuctRouter(String name){` (DuctRouter.java:25), `group = BlockGroup.transportation;` (DuctRouter.java:26), `update = true;` (DuctRouter.java:27), `solid = false;` (DuctRouter.java:28), `hasItems = true;` (DuctRouter.java:29), `unloadable = false;` (DuctRouter.java:30), `itemCapacity = 1;` (DuctRouter.java:31), `noUpdateDisabled = true;` (DuctRouter.java:32), `configurable = true;` (DuctRouter.java:33), `saveConfig = true;` (DuctRouter.java:34), `rotate = true;` (DuctRouter.java:35), `clearOnDoubleTap = true;` (DuctRouter.java:36), `underBullets = true;` (DuctRouter.java:37), `priority = TargetPriority.transport;` (DuctRouter.java:38), `envEnabled = Env.space | Env.terrestrial | Env.underwater;` (DuctRouter.java:39), `drawCached = true;` (DuctRouter.java:40), `drawDynamic = false;` (DuctRouter.java:41). Parent build fields: `public @Nullable Item sortItem;` (DuctRouter.java:77), `public float progress;` (DuctRouter.java:79), `public @Nullable Item current;` (DuctRouter.java:80).
	# Single def -- surge-router only (size 1, speed 6f, itemCapacity 10, health 130, surge-alloy 5 / tungsten 1, Blocks.java:2255-2268). duct-router (DuctRouter, no power def, NO hasPower line, Blocks.java:2193) and router (Router, no power def, NO hasPower line, Blocks.java:2139) are explicitly OUT of scope. No sense / read / write overrides exist on StackRouterBuild -- those wait for their own slices only if a later Java line needs them.
	# Documented limits: (1) power-only first pass -- the surge-router's static power consumer (consumePower 3f/60f, Blocks.java:2266) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); surge-router has no second consumer. (2) NO shouldConsume gate to defer -- StackRouterBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT for this family. (3) updateTile advance live (N2240) -- eff fold / progress advance / unload branch / target handoff / current-pick branch (StackRouter.java:28-70) run every enabled tick after the consumption fold through the pure source_stack_router_update_tile_advance_state function; target() selection live (N2324) -- the tick simulates consecutive DuctRouter.target() calls (DuctRouter.java:139-157) over the frame proximity_neighbours input and passes the ordered list into the advance, stamping cdump only when a handoff happened; handleItem application still defers (the advance returns handed_off / handed_to as pure results) and the live proximity query is live since N2472 (the tick scans the Edges ring live from frame["world_tiles"] + the caller-supplied team/accepts maps and stamps frame["proximity_neighbours"] before the N2240 advance, supplied lists win); acceptItem gate live (N2332) -- the pure source_stack_router_accept_item_state ports the 4-term StackRouter acceptItem override (StackRouter.java:89-93), NOT the stricter parent DuctRouter acceptItem (DuctRouter.java:160-164); no live caller evaluates it yet (acceptItem is called by other buildings' dump/offload, BuildingComp.java:1001-1016, and no live proximity/facing query fills facing_rel) and handleItem application still defers (the gate reports the verdict only). The power proof carries no progress / unloading / target / acceptItem keys; the eff fold (StackRouter.java:29) is what the efficiency keys prove, and the N2240 proof carries the advance keys. (4) No sense modeling -- sense waits for its own slice. (5) Single def -- surge-router only (size 1, speed 6f, itemCapacity 10, health 130, surge-alloy 5 / tungsten 1); duct-router (DuctRouter, no power def) and router (Router, no power def) are explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) Draw rows live (N2433) -- the draw pure (source_stack_router_draw_state) models drawCached() (:73-75: super.draw() = the parent DuctRouter draw, base rect + sort center when sortItem != null else the top rect at rotdeg()) + draw() (:78-87: the additive glow at Layer.blockAdditive with alpha glowAlpha * power.status when the glow region is found AND power != null AND power.status > 0) + drawSelect() (DuctRouter.java:93-99: super.drawSelect() + drawItemSelection(sortItem), recorded as calls) + icons() (DuctRouter.java:55-57: {region, topRegion}). Pure-only: the tick never calls draw -- drawCached/draw are called by the renderer, drawSelect by the UI, and the renderer/UI call sites wait for their own slices. Config rows live (N2449) -- see (8). (7) Stats/plan rows live (N2442) -- the stats pure (source_stack_router_stats_state) models setStats() (DuctRouter.java:48-52: stats.add(Stat.itemsMoved, 60f / speed * itemCapacity, StatUnit.itemsSecond), 60/5*10 = 120 at the class defaults) and the plan pure (source_stack_router_draw_plan_state) models drawPlanRegion() (DuctRouter.java:60-63: base rect + top rect at plan.rotation * 90) + minimapColor() (DuctRouter.java:66-69: 0 when the build or sort item is null, else sortItem.color.rgba(), the rgba8888 int) + rotatedOutput() (DuctRouter.java:72-74: false). Pure-only: the tick never calls setStats / drawPlanRegion / minimapColor / rotatedOutput -- the stats UI / placement renderer / minimap call sites wait for their own slices. (8) Config rows live (N2449) -- the config pure (source_stack_router_config_state) models config(Item) (DuctRouter.java:44: sortItem = item) + configClear (:45: sortItem = null) + buildConfiguration (:124-127: the ItemSelection.buildTable CALL record) + configured() (:128-135: super + recache() + renderer.minimap.update(tile) when !headless) as a pure-only fold over the discriminated action (set / clear / none, the N2443 precedent); the item is caller-supplied as null or a Dict {name, color} (the N2433 precedent) and the pure takes the current sort item as an input so the none action returns it unchanged. Pure-only: the tick never calls config / configured / buildConfiguration -- the configure-UI / input-handler call sites wait for their own slices; read/write rows still wait for their own slice. (9) HandleStack / removeStack rows live (N2458) -- the handle-stack pure (source_duct_router_handle_stack_state) models handleStack (DuctRouter.java:173-177: super adds the stack then current = item) + removeStack (:166-171: super removes the clamped amount min(amount, items.get(item)), BuildingComp.java:786-792, then current = null iff item == current, the clear unconditional on the removed amount) as a pure-only fold over the discriminated action (handle_stack / remove_stack, the N2443/N2449 precedent); the item is caller-supplied as null or a Dict {name} (the N2433/N2449 precedent), current is the same build field the N2324 target pure reads (DuctRouter.java:80) compared by name, and items_count is items.get(item) before the call (ItemModule.java:209-211). handleItem (DuctRouter.java:179-184, progress = -1f) is NOT ported here -- it stays tracked under the N2324/N2332 entries. Pure-only: the tick never calls handleStack / removeStack -- the stack-intake call sites wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_stack_router_draw_state(x_value: float, y_value: float, rotation: int, sort_item: Variant, power_status: float, glow_found: bool, glow_color: String, glow_alpha: float) -> Dictionary:
	# The draw rows (StackRouterBuild.drawCached(), StackRouter.java:73-75, + draw(), :78-87, + the parent DuctRouterBuild.draw(), DuctRouter.java:83-92, + drawSelect(), :93-99), the pure draw-call dict -- the port never draws for real (the N2431 precedent: the pure returns the draw calls as data). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void drawCached(){`
	# `super.draw();`
	# `public void draw(){`
	# `Draw.rect(region, x, y);`
	# `if(sortItem != null){`
	# `Draw.color(sortItem.color);`
	# `Draw.rect("center", x, y);`
	# `Draw.color();`
	# `Draw.rect(topRegion, x, y, rotdeg());`
	# `if(glowRegion.found() && power != null && power.status > 0){`
	# `Draw.z(Layer.blockAdditive);`
	# `Draw.color(glowColor, glowAlpha * power.status);`
	# `Draw.blend(Blending.additive);`
	# `Draw.rect(glowRegion, x, y, rotation * 90);`
	# `Draw.blend();`
	# `Draw.color();`
	# `public void drawSelect(){`
	# `super.drawSelect();`
	# `drawItemSelection(sortItem);`
	# `public TextureRegion[] icons(){`
	# `return new TextureRegion[]{region, topRegion};`
	# drawCached() calls super.draw() -- the DuctRouter draw -- and DuctRouter sets `drawCached = true;` (DuctRouter.java:40) while StackRouter sets `drawDynamic = true;` (StackRouter.java:21), so the cached layer is the parent draw and the dynamic layer is the glow. The glow region is the `@-glow` region with the arrow-glow fallback (`public @Load(value = "@-glow", fallback = "arrow-glow") TextureRegion glowRegion;`, StackRouter.java:14) and the top region is the `@-top` region (`public @Load(value = "@-top") TextureRegion topRegion;`, DuctRouter.java:21). glowAlpha is `public float glowAlpha = 1f;` (StackRouter.java:15) and glowColor is `public Color glowColor = Pal.redLight;` (StackRouter.java:16, `redLight = Color.valueOf("feb380"),`, Pal.java:138) -- the single surge-router def (`surgeRouter = new StackRouter("surge-router"){{`, Blocks.java:2255, `consumePower(3f / 60f);`, Blocks.java:2266) sets NEITHER, so both take the class defaults (the driver constants SOURCE_STACK_ROUTER_GLOW_ALPHA / SOURCE_STACK_ROUTER_GLOW_COLOR). The sort item is the frame state the N2324 target pure reads (`public @Nullable Item sortItem;`, DuctRouter.java:77) -- the pure takes it caller-supplied as null or a Dict {name, color} and never reads the frame; the color token is caller-supplied (the port has no live Item objects, the N2415 token precedent), and a non-Dict non-null value is read as a bare name with an empty color token. rotdeg() is rotation * 90 (`public float rotdeg(){` with `return rotation * 90;`, BuildingComp.java:582-584) and rotation is the transient int (`transient int rotation;`, BuildingComp.java:69). The power gate is a STRICT > 0 -- power.status exactly 0 draws no glow -- and power_status -1 is the power-null sentinel (the `power != null` gate, StackRouter.java:79): the gate is glow_found && power_status > 0.0, so -1 fails it exactly like a null power. drawItemSelection draws the icon only when the selection is non-null (`public void drawItemSelection(@Nullable UnlockableContent selection){` with `if(selection != null){`, BuildingComp.java:1249-1250), so the select call carries draws_icon true iff sort_item is set; the super call is always recorded. StackRouter does NOT override icons() -- the override is the parent's, inherited by the surge-router. Pure-only: the tick never calls draw -- drawCached/draw are called by the renderer, drawSelect by the UI, and the renderer/UI call sites wait for their own slices.
	var rotdeg_value: float = float(rotation * 90)
	var sort_name: String = ""
	var sort_color: String = ""
	if sort_item != null:
		if sort_item is Dictionary:
			sort_name = str(sort_item.get("name", ""))
			sort_color = str(sort_item.get("color", ""))
		else:
			sort_name = str(sort_item)
	var cached_base_call: Dictionary = {
		"call": "Draw.rect(region, x, y);",
		"region": "region",
		"x": x_value,
		"y": y_value,
	}
	var cached_sort_call: Variant = null
	if sort_item != null:
		cached_sort_call = {
			"call": "Draw.rect(\"center\", x, y);",
			"region": "center",
			"color": sort_color,
			"sort_item": sort_name,
			"x": x_value,
			"y": y_value,
		}
	var cached_top_call: Variant = null
	if sort_item == null:
		cached_top_call = {
			"call": "Draw.rect(topRegion, x, y, rotdeg());",
			"region": "topRegion",
			"x": x_value,
			"y": y_value,
			"rotation": rotdeg_value,
		}
	var glow_alpha_value: float = glow_alpha * power_status
	var glow_call: Variant = null
	if glow_found and power_status > 0.0:
		glow_call = {
			"call": "Draw.rect(glowRegion, x, y, rotation * 90);",
			"region": "glowRegion",
			"color": glow_color,
			"alpha": glow_alpha_value,
			"x": x_value,
			"y": y_value,
			"rotation": rotdeg_value,
			"z": "Layer.blockAdditive",
			"blend": "additive",
		}
	var select_call: Dictionary = {
		"super_call": "super.drawSelect();",
		"item_selection_call": "drawItemSelection(sortItem);",
		"sort_item": sort_name if sort_item != null else null,
		"draws_icon": sort_item != null,
	}
	var icon_regions: Array = ["region", "topRegion"]
	return {
		"cached_expr": "super.draw();",
		"base_expr": "Draw.rect(region, x, y);",
		"sort_gate_expr": "if(sortItem != null){",
		"sort_color_expr": "Draw.color(sortItem.color);",
		"sort_expr": "Draw.rect(\"center\", x, y);",
		"top_expr": "Draw.rect(topRegion, x, y, rotdeg());",
		"glow_gate_expr": "if(glowRegion.found() && power != null && power.status > 0){",
		"glow_z_expr": "Draw.z(Layer.blockAdditive);",
		"glow_color_expr": "Draw.color(glowColor, glowAlpha * power.status);",
		"glow_blend_expr": "Draw.blend(Blending.additive);",
		"glow_expr": "Draw.rect(glowRegion, x, y, rotation * 90);",
		"select_super_expr": "super.drawSelect();",
		"select_expr": "drawItemSelection(sortItem);",
		"icons_expr": "return new TextureRegion[]{region, topRegion};",
		"x": x_value,
		"y": y_value,
		"rotation": rotation,
		"sort_item": sort_item,
		"power_status": power_status,
		"glow_found": glow_found,
		"glow_color": glow_color,
		"glow_alpha": glow_alpha,
		"rotdeg": rotdeg_value,
		"glow_alpha_value": glow_alpha_value,
		"cached_base_call": cached_base_call,
		"cached_sort_call": cached_sort_call,
		"cached_top_call": cached_top_call,
		"glow_call": glow_call,
		"select_call": select_call,
		"icon_regions": icon_regions,
	}

static func source_stack_router_stats_state(speed: float, item_capacity: int) -> Dictionary:
	# The setStats rows (DuctRouter.setStats(), DuctRouter.java:48-52), the pure stats dict -- StackRouter inherits setStats() from DuctRouter (StackRouter.java:11, `public class StackRouter extends DuctRouter{`) and overrides NOTHING here. Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void setStats(){`
	# `super.setStats();`
	# `stats.add(Stat.itemsMoved, 60f / speed * itemCapacity, StatUnit.itemsSecond);`
	# `itemsMoved = new Stat("itemsMoved", StatCat.items),`
	# `itemsSecond = new StatUnit("itemsSecond"),`
	# The float math is Java-exact: 60f / speed FIRST, then times itemCapacity (left-assoc) -- 60 / 5 * 10 = 120 at the class defaults (`public float speed = 5f;`, DuctRouter.java:19; `itemCapacity = 10;`, StackRouter.java:20). The single surge-router def (`surgeRouter = new StackRouter("surge-router"){{`, Blocks.java:2255) sets `speed = 6f;` (Blocks.java:2259) and NO itemCapacity override, so its rate is 60 / 6 * 10 = 100; the duct-router def (`ductRouter = new DuctRouter("duct-router"){{`, Blocks.java:2193) sets `speed = 4f;` (Blocks.java:2196) with the DuctRouter class `itemCapacity = 1;` (DuctRouter.java:31), so its rate is 60 / 4 * 1 = 15. There is NO "stack-router" def in Blocks.java -- surge-router is the only StackRouter def. The tokens are exact: itemsMoved (Stat.java:52) and itemsSecond (StatUnit.java:20). Pure-only: the tick never calls setStats -- the stats UI calls it, and the call site waits for its own slice.
	var items_moved_per_second: float = 60.0 / speed * item_capacity
	return {
		"set_stats_expr": "stats.add(Stat.itemsMoved, 60f / speed * itemCapacity, StatUnit.itemsSecond);",
		"speed": speed,
		"item_capacity": item_capacity,
		"items_moved_per_second": items_moved_per_second,
		"stat_key": "itemsMoved",
		"stat_unit": "itemsSecond",
	}

static func source_stack_router_draw_plan_state(plan_x: float, plan_y: float, rotation: int, sort_item: Variant) -> Dictionary:
	# The drawPlanRegion rows (DuctRouter.drawPlanRegion(), DuctRouter.java:60-63, + minimapColor(), :66-69, + rotatedOutput(), :72-74), the pure plan draw-call dict -- the port never draws for real (the N2419 precedent: the pure returns the plan calls as data). StackRouter inherits all three from DuctRouter (StackRouter.java:11, `public class StackRouter extends DuctRouter{`) and overrides NOTHING here. Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){`
	# `Draw.rect(region, plan.drawx(), plan.drawy());`
	# `Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);`
	# `public int minimapColor(Tile tile){`
	# `var build = (DuctRouterBuild)tile.build;`
	# `return build == null || build.sortItem == null ? 0 : build.sortItem.color.rgba();`
	# `public boolean rotatedOutput(int x, int y){`
	# `return false;`
	# The base rect draws region unrotated at the plan position; the top rect draws topRegion (`public @Load(value = "@-top") TextureRegion topRegion;`, DuctRouter.java:21) at the plan position rotated plan.rotation * 90 (DuctRouter sets `rotate = true;`, DuctRouter.java:35). The plan position is plan.drawx() / drawy() caller-supplied (the N2419 precedent). minimapColor returns 0 when the build or the sort item is null, else sortItem.color.rgba() -- rgba() is the rgba8888 INT (`public int rgba(){` with `return rgba8888();`, arc Color.java:365-367), NOT a string token, so the sort_item dict carries `color` as the caller-supplied rgba8888 int (the sort item is the frame state the N2324 target pure reads, `public @Nullable Item sortItem;`, DuctRouter.java:77 -- the pure takes it caller-supplied as null or a Dict {name, color} and never reads the frame, the N2433 precedent). A null sort_item covers BOTH null branches (no build means no sortItem); a non-Dict sort_item carries no color, so the minimap reads 0 (the input contract is null-or-Dict). Surge-alloy is 0xf3e979ff, the Java signed int -202802689 (`surgeAlloy = new Item("surge-alloy", Color.valueOf("f3e979")){{`, Items.java:83). rotatedOutput is always false. Pure-only: the tick never calls drawPlanRegion / minimapColor / rotatedOutput -- the placement renderer / minimap call sites wait for their own slices.
	var rotdeg_value: float = float(rotation * 90)
	var minimap_color: int = 0
	if sort_item != null and sort_item is Dictionary:
		minimap_color = int(sort_item.get("color", 0))
	var base_call: Dictionary = {
		"call": "Draw.rect(region, plan.drawx(), plan.drawy());",
		"region": "region",
		"x": plan_x,
		"y": plan_y,
	}
	var top_call: Dictionary = {
		"call": "Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);",
		"region": "topRegion",
		"x": plan_x,
		"y": plan_y,
		"rotation": rotdeg_value,
	}
	return {
		"plan_base_expr": "Draw.rect(region, plan.drawx(), plan.drawy());",
		"plan_top_expr": "Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);",
		"minimap_expr": "return build == null || build.sortItem == null ? 0 : build.sortItem.color.rgba();",
		"rotated_output_expr": "return false;",
		"plan_x": plan_x,
		"plan_y": plan_y,
		"rotation": rotation,
		"sort_item": sort_item,
		"rotdeg": rotdeg_value,
		"base_call": base_call,
		"top_call": top_call,
		"minimap_color": minimap_color,
		"rotated_output": false,
	}

static func source_stack_router_config_state(action: String, item: Variant, headless: bool, current_sort_item: Variant) -> Dictionary:
	# The config rows (DuctRouter config(Item), DuctRouter.java:44; configClear, :45; buildConfiguration, :124-127; configured(), :128-135), the pure config fold -- StackRouter inherits all four from DuctRouter (StackRouter.java:11, `public class StackRouter extends DuctRouter{`) and overrides NONE of them. Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `config(Item.class, (DuctRouterBuild tile, Item item) -> tile.sortItem = item);`
	# `configClear((DuctRouterBuild tile) -> tile.sortItem = null);`
	# `public void buildConfiguration(Table table){`
	# `ItemSelection.buildTable(DuctRouter.this, table, content.items(), () -> sortItem, this::configure);`
	# `public void configured(Unit player, Object value){`
	# `super.configured(player, value);`
	# `if(!headless){`
	# `recache();`
	# `renderer.minimap.update(tile);`
	# `public @Nullable Item sortItem;`
	# `configurable = true;`
	# `saveConfig = true;`
	# `public void recache(){`
	# `if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);`
	# `public Item config(){`
	# `return sortItem;`
	# `public class StackRouter extends DuctRouter{`
	# `public class DuctRouterBuild extends Building{`
	# `configurations.put(void.class, (tile, value) -> cons.get((E)tile));`
	# `Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();`
	# `if(value instanceof Item) type = Item.class;`
	# `block.configurations.get(type).get(this, value);`
	# `build.configured(player == null || player.dead() ? null : player.unit(), value);`
	# The action is a discriminated input (the N2443 precedent): "set" applies the config(Item) handler (sortItem = item), "clear" applies configClear (sortItem = null), "none" leaves sortItem untouched (the pure returns the current_sort_item input). The dispatch: configClear registers under void.class (Block.java:922-924) and BuildingComp.configured dispatches null values to void.class (BuildingComp.java:1414-1416), so a null configure clears; a non-null Item dispatches to Item.class (BuildingComp.java:1418). The super configured() runs the handler (BuildingComp.java:1429) with NO equality check anywhere in the chain (InputHandler.tileConfig, InputHandler.java:728, calls build.configured unconditionally), so a configure with the SAME item still recaches + updates the minimap when !headless: recache_called = minimap_updated = (action ran) && !headless (the N2443 lesson). recache(), verified first, is BuildingComp.recache() (BuildingComp.java:1285-1287) -- a renderer-side cache invalidation (it redraws the cached building layer) with its own !headless guard and NO pure state of its own, so it is a CALL flag, not a state key of its own (Tile.recache(), Tile.java:358, is a DIFFERENT method -- the tile-level recache; the one configured() calls on the Building is BuildingComp.recache()). buildConfiguration is recorded as a CALL {method: "ItemSelection.buildTable", current_sort_item} -- the supplier `() -> sortItem` reads the pre-action sort item and `this::configure` is the callback the UI would invoke; the UI itself is NOT ported (the N2396 CALL precedent). config() returns sortItem (DuctRouter.java:187-189), so the pure's sort_item IS the post-action config() value. The block is `configurable = true;` + `saveConfig = true;` (DuctRouter.java:33-34): the block is configurable and the config persists (write/read serialize the sortItem id, DuctRouter.java:197-209 -- the read/write rows wait for their own slice). The item is caller-supplied as null or a Dict {name, color} (the N2433 precedent -- the port has no live Item objects, the color token is caller-supplied); the pure passes the item through untouched, so a set stores the caller's dict as-is. Pure-only: the tick never calls config / configured / buildConfiguration -- config/configured run from the configure UI and the input handler, buildConfiguration from the configure UI, and the call sites wait for their own slices. Config rows live (N2449).
	var is_action: bool = action == "set" or action == "clear"
	var new_sort_item: Variant = current_sort_item
	if action == "set":
		new_sort_item = item
	elif action == "clear":
		new_sort_item = null
	var recache_called: bool = is_action and not headless
	var minimap_updated: bool = is_action and not headless
	var configure_call: Dictionary = {"method": "ItemSelection.buildTable", "current_sort_item": current_sort_item}
	return {
		"config_expr": "config(Item.class, (DuctRouterBuild tile, Item item) -> tile.sortItem = item);",
		"config_clear_expr": "configClear((DuctRouterBuild tile) -> tile.sortItem = null);",
		"build_configuration_expr": "ItemSelection.buildTable(DuctRouter.this, table, content.items(), () -> sortItem, this::configure);",
		"configured_expr": "if(!headless){",
		"recache_expr": "recache();",
		"minimap_expr": "renderer.minimap.update(tile);",
		"config_getter_expr": "return sortItem;",
		"action": action,
		"item": item,
		"headless": headless,
		"current_sort_item": current_sort_item,
		"sort_item": new_sort_item,
		"recache_called": recache_called,
		"minimap_updated": minimap_updated,
		"configure_call": configure_call,
	}

static func source_duct_router_handle_stack_state(action: String, item: Variant, amount: int, current: Variant, items_count: int) -> Dictionary:
	# The handleStack / removeStack rows (DuctRouterBuild.removeStack, DuctRouter.java:166-171; handleStack, :173-177), the pure stack-transfer fold -- StackRouter inherits both from DuctRouter (StackRouter.java:11, `public class StackRouter extends DuctRouter{`) and overrides NEITHER of them. Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public int removeStack(Item item, int amount){`
	# `int removed = super.removeStack(item, amount);`
	# `if(item == current) current = null;`
	# `return removed;`
	# `public void handleStack(Item item, int amount, Teamc source){`
	# `super.handleStack(item, amount, source);`
	# `current = item;`
	# `public @Nullable Item current;`
	# `public class StackRouter extends DuctRouter{`
	# `public class DuctRouterBuild extends Building{`
	# `if(items == null) return 0;`
	# `amount = Math.min(amount, items.get(item));`
	# `noSleep();`
	# `items.remove(item, amount);`
	# `return amount;`
	# `public void handleStack(Item item, int amount, @Nullable Teamc source){`
	# `items.add(item, amount);`
	# `public int get(Item item){`
	# `return items[item.id];`
	# `public void add(Item item, int amount){`
	# `items[item] += amount;`
	# `public void remove(Item item, int amount){`
	# `amount = Math.min(amount, items[item.id]);`
	# The action is a discriminated input (the N2443/N2449 precedent): "handle_stack" runs the handleStack override (super adds the stack to the store, then current = item), "remove_stack" runs the removeStack override (super removes the clamped amount, then clears current iff item == current). The super calls are BuildingComp.removeStack (BuildingComp.java:786-792: `if(items == null) return 0;` then `amount = Math.min(amount, items.get(item));` then `items.remove(item, amount);` then `return amount;`) and BuildingComp.handleStack (BuildingComp.java:795-798: `noSleep();` then `items.add(item, amount);`) -- verified first, so the removed count is the CLAMPED amount min(amount, items.get(item)) and the handle count is the UNCLAMPED add (ItemModule.add just +=, ItemModule.java:234-242, no capacity clamp; ItemModule.remove re-clamps, ItemModule.java:258-263, but the super already clamped). The clear is UNCONDITIONAL on the removed amount: DuctRouter.removeStack clears current whenever item == current (DuctRouter.java:168), even when the removed amount is 0 (an empty store or a zero amount) -- there is no removed > 0 guard. The item is caller-supplied as null or a Dict {name} (the N2433/N2449 precedent -- the port has no live Item objects); current is the same build field the N2324 target pure reads (`public @Nullable Item current;`, DuctRouter.java:80, the frame key "current"), null or a Dict {name}; the port compares item NAMES (Java `==` on Item is identity, the N2449 precedent). items_count is items.get(item) before the call (ItemModule.java:209-211) -- the pure takes the count, not the store, so it models the non-null store path: the null-store branch (`if(items == null) return 0;`, BuildingComp.java:787) never applies to a placed router (the driver frame always carries an items dict, the factory precedent) and noSleep() is not modeled (no sleep state in the driver). handleItem (DuctRouter.java:179-184, current = item + progress = -1f + items.add(item, 1)) is NOT ported here -- progress = -1f belongs to handleItem, NOT handleStack, and handleItem application stays tracked under the N2324/N2332 entries. Pure-only: the tick never calls handleStack / removeStack -- no intake wiring calls them yet (the stack-intake call sites wait for their own slices). HandleStack / removeStack rows live (N2458).
	var item_name: String = str(item.get("name", "")) if item is Dictionary else str(item)
	var current_name: String = str(current.get("name", "")) if current is Dictionary else str(current)
	var same_item: bool = item != null and current != null and item_name == current_name
	var removed_count: int = 0
	var items_count_after: int = items_count
	var current_after: Variant = current
	if action == "handle_stack":
		items_count_after = items_count + amount
		current_after = item
	elif action == "remove_stack":
		removed_count = mini(amount, items_count)
		items_count_after = items_count - removed_count
		if same_item:
			current_after = null
	return {
		"remove_stack_expr": "int removed = super.removeStack(item, amount);",
		"handle_stack_expr": "super.handleStack(item, amount, source);",
		"clear_expr": "if(item == current) current = null;",
		"clamp_expr": "amount = Math.min(amount, items.get(item));",
		"add_expr": "items.add(item, amount);",
		"action": action,
		"item": item,
		"amount": amount,
		"current": current,
		"items_count": items_count,
		"current_after": current_after,
		"removed_count": removed_count,
		"items_count_after": items_count_after,
	}

@warning_ignore("unused_parameter")
static func source_stack_router_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the stack-router tick wiring every
	# tick (StackRouterBuild.updateTile(), StackRouter.java:28,
	# unloads items at a rate that follows the folded efficiency
	# (StackRouter.java:29, `float eff = enabled ? (efficiency + baseEfficiency) : 0f;`, with StackRouter.java:35, `progress += eff;`, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails this test), so the unload rate follows the folded efficiency; no placed-buildings driver ticks StackRouter blocks, so this driver is the placed-stack-router tick): each placed StackRouter build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_stack_router_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_stack_router_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		# Building.rotation (`transient int rotation;`, BuildingComp.java:69) is set from the placement rotation at creation and stored on the sprite meta (SourceBlockGeometry.gd:162-167, the UnitAssemblerModule precedent): the target() selection (N2324) reads it live for the sort gate and the backwards exclusion.
		var rotation: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
		frame["rotation"] = rotation
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_stack_router_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a stack router with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the unload rate (StackRouter.java:29-35)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a surge-router does not take the early return. The stack router's power draw is STATIC: `consumePower(3f / 60f);` (Blocks.java:2266) registers a plain ConsumePower, so the catalog consumePower 0.05 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A stack router with no power consumer gets no consumption fold: the tick models no other consumers yet (the updateTile advance still runs below, N2240, on whatever efficiency the frame carries), and StackRouterBuild has NO shouldConsume override, so the BuildingComp default applies (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) -- there is NO gate to defer here, the power-only fold is EXACT, because the only gate is `enabled`, which the driver already checks. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_stack_router_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# The updateTile advance (N2240, StackRouter.java:28-70): runs after the consumption fold -- updateConsumption runs before updateTile (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`) -- and only when enabled. For this family the enabled gate is EXACT, not the N2195 pragmatic choice: DuctRouter sets `noUpdateDisabled = true;` (DuctRouter.java:32) against the Block default `public boolean noUpdateDisabled = false;` (Block.java:170), so Java never runs updateTile for a disabled stack router. The target list (N2324) is computed BEFORE the advance call: the pure source_stack_router_target_list_state simulates consecutive DuctRouter.target() calls (DuctRouter.java:139-157) over the frame proximity_neighbours input (the N2472 live query below stamps it before the target list reads it; default [] -- a router with no ring neighbours still passes an empty list and no live handoff happens), with handoff_count = items.get(current) at tick start through the shared drill inventory helper, and the ordered list goes into the advance instead of []. The item order is the catalog item_names_by_id, the content-id order ItemModule.first() scans (ItemModule.java:182-189). The pure advance returns the advanced values, which the driver writes back onto the frame -- and frame["cdump"] is stamped with cdump_after ONLY when a handoff actually happened: Java calls target() only inside the unload branch, so a charging tick must not rotate cdump (a full-scan null call advances cdump by the whole size, a no-op modulo size, so skipping the stamp when nothing matched changes nothing).
		if bool(frame.get("enabled", true)):
			var item_order: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
			var target_current: Variant = frame.get("current", null)
			var tick_items: Dictionary = frame.get("items", {}) as Dictionary
			var handoff_count: int = 0 if target_current == null else inventory.item_count(tick_items, str(target_current))
			# N2472: the live proximity query
			# (BuildingComp.updateProximity(),
			# BuildingComp.java:1879-1903) fills
			# frame["proximity_neighbours"] BEFORE the
			# N2324 target list reads it below: Java scans
			# Edges.getEdges(block.size) (:1883), looks up
			# world.build(tile.x + point.x, tile.y +
			# point.y) (:1885) and keeps same-team
			# buildings only (:1887). The tick scans
			# frame["world_tiles"] (the BeamDrill N2339
			# convention, Dict keyed "x,y" to {solid,
			# wall_drop}) over the Edges ring, with the
			# neighbour teams from the caller-supplied
			# frame["team_by_tile"] (Dict "x,y" -> team --
			# world_tiles carries NO team field) and the
			# acceptItem answers from the caller-supplied
			# frame["accepts_item_by_tile"] (Dict "x,y" ->
			# bool -- the per-neighbour-type acceptItem
			# evaluation waits for its own slice).
			# Supplied lists WIN (the N2381 precedent):
			# the fill runs only when the frame carries no
			# proximity_neighbours key -- the N2324 proof
			# seeds the list by hand, so a fill there would
			# overwrite the seed. A frame the fill already
			# stamped (proximity_neighbours_live -- port
			# bookkeeping, not Java state, the N2394
			# precedent) refreshes every tick, so a
			# later-placed neighbour joins the list and a
			# removed one leaves it. The tick reads the
			# origin_cell meta inline as fill_cell (cell is
			# bound after the enabled block, the N2363
			# note) and the catalog size + the live team_id
			# the target list already binds; the existing
			# neighbours read below picks up the filled
			# array. The local is neighbours_filled, NOT
			# `filled` (the N2416 duplicate-var lesson).
			var has_supplied_proximity_neighbours: bool = frame.has("proximity_neighbours")
			if not has_supplied_proximity_neighbours or bool(frame.get("proximity_neighbours_live", false)):
				var fill_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
				var fill_world_tiles: Dictionary = frame.get("world_tiles", {})
				var fill_team_map: Dictionary = frame.get("team_by_tile", {})
				var fill_accepts_map: Dictionary = frame.get("accepts_item_by_tile", {})
				var neighbours_filled: Dictionary = source_stack_router_proximity_neighbours_live_fill_state(fill_world_tiles, fill_cell, int(block.properties.get("size", 1)), team_id, fill_team_map, fill_accepts_map)
				frame["proximity_neighbours"] = neighbours_filled.get("proximity_neighbours", [])
				frame["proximity_neighbours_live"] = true
			var neighbours: Array = frame.get("proximity_neighbours", []) as Array
			var target_list: Dictionary = source_stack_router_target_list_state(neighbours, target_current, frame.get("sort_item", null), rotation, team_id, int(frame.get("cdump", 0)), handoff_count)
			var targets: Array = target_list.get("targets", [])
			var advanced: Dictionary = source_stack_router_update_tile_advance_state(frame, SOURCE_STACK_ROUTER_SPEED, SOURCE_STACK_ROUTER_BASE_EFFICIENCY, SOURCE_STACK_ROUTER_ITEM_CAPACITY, targets, item_order)
			frame["unloading"] = advanced["unloading"]
			frame["current"] = advanced["current"]
			frame["progress"] = advanced["progress"]
			frame["items"] = advanced["items"]
			frame["handed_off"] = advanced["handed_off"]
			frame["handed_to"] = advanced["handed_to"]
			if int(advanced.get("handed_off", 0)) > 0:
				frame["cdump"] = int(target_list.get("cdump_after", int(frame.get("cdump", 0))))
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
