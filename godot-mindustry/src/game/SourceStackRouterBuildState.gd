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

static func _is_stack_router_build_implementation(implementation: String) -> bool:
	return SOURCE_STACK_ROUTER_BUILD_IMPLEMENTATIONS.has(implementation)

static func _stack_router_first_item(items: Dictionary, item_order: Array) -> Variant:
	# ItemModule.first() (ItemModule.java:182-189, `public @Nullable Item first(){` with `for(int i = 0; i < items.length; i++){` / `if(items[i] > 0){` / `return content.item(i);`): scans the item slots in content-id order and returns the first with a count above zero, null when none is held. The port's items dict is keyed by item name (the factory precedent), so the scan runs over item_order -- the catalog item_names_by_id, the content-id order Java iterates (the N2225 take() precedent). An item name outside the order is never picked: Java cannot hold a non-content item. An EMPTY order picks nothing: no content order is known, so the port cannot pick faithfully (the driver always passes the catalog order).
	for candidate in item_order:
		if inventory.item_count(items, str(candidate)) > 0:
			return str(candidate)
	return null

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
	# A new StackRouterBuild starts idle: `public boolean unloading = false;` (StackRouter.java:25), `public float progress;` (DuctRouter.java:79, default 0f) and `public @Nullable Item current;` (DuctRouter.java:80, default null); the Building.items ItemModule starts empty (frame["items"], Dictionary keyed by item name, the factory precedent -- the N2225 ItemBridge advance carries the same key).
	return {"unloading": false, "current": null, "progress": 0.0, "items": {}}

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
	# Documented limits: (1) power-only first pass -- the surge-router's static power consumer (consumePower 3f/60f, Blocks.java:2266) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); surge-router has no second consumer. (2) NO shouldConsume gate to defer -- StackRouterBuild has no shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) applies; the power-only fold is EXACT for this family. (3) updateTile advance live (N2240) -- eff fold / progress advance / unload branch / target handoff / current-pick branch (StackRouter.java:28-70) run every enabled tick after the consumption fold through the pure source_stack_router_update_tile_advance_state function; the target() live proximity selection (DuctRouter.java:139-156) and handleItem application defer (the driver passes an empty targets list, so no live handoff happens; the pure advance pops the explicit list in order, cdump rotation simulated by list order). The power proof carries no progress / unloading / target / acceptItem keys; the eff fold (StackRouter.java:29) is what the efficiency keys prove, and the N2240 proof carries the advance keys. (4) No sense modeling -- sense waits for its own slice. (5) Single def -- surge-router only (size 1, speed 6f, itemCapacity 10, health 130, surge-alloy 5 / tungsten 1); duct-router (DuctRouter, no power def) and router (Router, no power def) are explicitly OUT of scope; per-def stat values wait for their own verification slice. (6) No draw/config modeling -- draw / drawSelect / config wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

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
		# The updateTile advance (N2240, StackRouter.java:28-70): runs after the consumption fold -- updateConsumption runs before updateTile (BuildingComp.java:2274-2277, `updateConsumption();` then `if(enabled || !block.noUpdateDisabled){` / `updateTile();`) -- and only when enabled. For this family the enabled gate is EXACT, not the N2195 pragmatic choice: DuctRouter sets `noUpdateDisabled = true;` (DuctRouter.java:32) against the Block default `public boolean noUpdateDisabled = false;` (Block.java:170), so Java never runs updateTile for a disabled stack router. The driver passes an EMPTY targets list: no live proximity query exists in the port, so no live handoff happens (the StackRouter updateTile live fill entry stays deferred); only the charge / current-pick / empty-reset lines run live. The item order is the catalog item_names_by_id, the content-id order ItemModule.first() scans (ItemModule.java:182-189). The pure advance returns the advanced values, which the driver writes back onto the frame.
		if bool(frame.get("enabled", true)):
			var item_order: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
			var advanced: Dictionary = source_stack_router_update_tile_advance_state(frame, SOURCE_STACK_ROUTER_SPEED, SOURCE_STACK_ROUTER_BASE_EFFICIENCY, SOURCE_STACK_ROUTER_ITEM_CAPACITY, [], item_order)
			frame["unloading"] = advanced["unloading"]
			frame["current"] = advanced["current"]
			frame["progress"] = advanced["progress"]
			frame["items"] = advanced["items"]
			frame["handed_off"] = advanced["handed_off"]
			frame["handed_to"] = advanced["handed_to"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
