extends RefCounted
class_name SourcePayloadUnloaderBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_move_out_payload_state := preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The PayloadUnloader implementation (PayloadUnloader.java:8, `public class PayloadUnloader extends PayloadLoader{`): payload-unloader (hasPower = true;, consumePower(2f);, size 3, offloadSpeed 4, maxPowerUnload 80f, Blocks.java:6691-6698). PayloadUnloader sets outputsPower=true, consumesPower=true, outputsLiquid=true, loadPowerDynamic=false, canOverdrive=false (PayloadUnloader.java:15-19), offloadSpeed 4 (PayloadUnloader.java:9), maxPowerUnload 80f (PayloadUnloader.java:11, `public float maxPowerUnload = 80f;`). PayloadUnloader extends PayloadLoader, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_payload_unloader_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor / payload-loader precedent), and this slice adds the payload-unloader key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourcePayloadUnloader* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the unload gate (PayloadUnloader.java:69, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`) follows the folded efficiency, with the battery unload (PayloadUnloader.java:98, `float total = payload.build.power.status * cap;`).
const SOURCE_PAYLOAD_UNLOADER_BUILD_IMPLEMENTATIONS := ["PayloadUnloader"]
const SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY := "source_payload_unloader_building"
# The load / unload constants (single def -- payload-unloader; the catalog
# carries no load params): `public float loadTime = 2f;` /
# `public int itemsLoaded = 8;` / `public float liquidsLoaded = 40f;`
# (PayloadLoader.java:22-24, inherited), `public int offloadSpeed = 4;` /
# `public float maxPowerUnload = 80f;` (PayloadUnloader.java:9-11),
# `itemCapacity = 100;` / `liquidCapacity = 100f;`
# (PayloadLoader.java:40-41, inherited), `size = 3;`
# (Blocks.java:6696), `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`
# (PayloadBlock.java:18). loadTime and offloadSpeed are the deferred
# cadences (the timer tick and the dump loop); the rest drive the advance.
const SOURCE_PAYLOAD_UNLOADER_LOAD_TIME := 2.0
const SOURCE_PAYLOAD_UNLOADER_ITEMS_LOADED := 8
const SOURCE_PAYLOAD_UNLOADER_LIQUIDS_LOADED := 40.0
const SOURCE_PAYLOAD_UNLOADER_MAX_POWER_UNLOAD := 80.0
const SOURCE_PAYLOAD_UNLOADER_OFFLOAD_SPEED := 4
const SOURCE_PAYLOAD_UNLOADER_ITEM_CAPACITY := 100
const SOURCE_PAYLOAD_UNLOADER_LIQUID_CAPACITY := 100.0
const SOURCE_PAYLOAD_UNLOADER_SIZE := 3
const SOURCE_PAYLOAD_UNLOADER_PAYLOAD_SPEED := 0.7
const SOURCE_PAYLOAD_UNLOADER_PAYLOAD_ROTATE_SPEED := 5.0

static func _is_payload_unloader_build_implementation(implementation: String) -> bool:
	return SOURCE_PAYLOAD_UNLOADER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_payload_unloader_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The payload-unloader tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (PayloadUnloader.java:8, `public class PayloadUnloader extends PayloadLoader{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# payload-unloader skips consumption like Java's updateConsumption
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
	# for this payload-unloader (N2125); the tick preserves a disabled
	# payload-unloader instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# The frame carries the held payload (the
	# PayloadBlockBuild.payload field, PayloadBlock.java:92,
	# `public @Nullable T payload;`, default null); the tick
	# preserves a payload already on the frame instead of
	# resetting it -- no live fill sets it yet (handlePayload /
	# takePayload wait for their own slice; the moveInPayload /
	# moveOutPayload advance is live since N2232), so the
	# shouldConsume gate reads the frame as-is.
	if not frame.has("payload"):
		frame["payload"] = null
	# The updateTile advance keys (N2232): a frame bound before
	# this slice gets the Java field defaults instead of
	# crashing the advance -- payVector (0, 0) / payRotation 0f
	# (PayloadBlock.java:94-95), rotation 0
	# (BuildingComp.java:69 `transient int rotation;`), the
	# Building.items ItemModule (frame["items"], Dictionary
	# keyed by item name, the factory precedent), and
	# lastOutputPower 0f (PayloadUnloader.java:33). Liquids
	# sync from the sprite meta each tick (the N2224 Fracker
	# precedent), not here -- this function has no sprite.
	if not frame.has("pay_vector"):
		frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	if not frame.has("pay_rotation"):
		frame["pay_rotation"] = 0.0
	if not frame.has("rotation"):
		frame["rotation"] = 0
	if not frame.has("items"):
		frame["items"] = {}
	if not frame.has("last_output_power"):
		frame["last_output_power"] = 0.0
	return frame

static func _initial_frame() -> Dictionary:
	# A new PayloadUnloaderBuild starts with no payload (the
	# PayloadBlockBuild.payload field, PayloadBlock.java:92,
	# `public @Nullable T payload;`, default null): the
	# shouldConsume gate (PayloadLoader.java:240-242) reads
	# payload != null, so the frame carries the payload key
	# at its null default. The updateTile advance (N2232)
	# carries the rest of the build fields with their Java
	# defaults: `public Vec2 payVector = new Vec2();`
	# (PayloadBlock.java:94), `public float payRotation;`
	# (PayloadBlock.java:95, default 0f), `transient int
	# rotation;` (BuildingComp.java:69, default 0), the
	# Building.items ItemModule (frame["items"], Dictionary
	# keyed by item name, default {}), and `public float
	# lastOutputPower = 0f;` (PayloadUnloader.java:33).
	# Liquids sync from the sprite meta each tick (the N2224
	# Fracker precedent), not from _initial_frame.
	return {"payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "last_output_power": 0.0}

static func source_payload_unloader_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the payload-unloader frame meta key
	# ("source_payload_unloader_building"). A PayloadUnloader sprite gets a
	# frame bound with the payload key at its null default
	# (frame["payload"] = null, the PayloadBlockBuild.payload
	# field, PayloadBlock.java:92); the live-loop tick fills its
	# other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_payload_unloader_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func _payload_unloader_liquid_current(module_state: Dictionary) -> Variant:
	# `public Liquid current(){` (LiquidModule.java:81-83) with
	# `return current;`: the last received or loaded liquid id,
	# null for a module that never held one (a frame bound
	# before this slice carries no liquids store at all).
	if module_state.is_empty():
		return null
	return module_state.get("current", null)

static func _payload_unloader_liquid_current_amount(module_state: Dictionary) -> float:
	# `public float currentAmount(){` (LiquidModule.java:98-100)
	# with `return liquids[current.id];`: 0.0 when the module
	# has no current liquid or the amounts array does not cover
	# it (a partial fixture).
	var current: Variant = _payload_unloader_liquid_current(module_state)
	if current == null:
		return 0.0
	var amounts: Array = module_state.get("liquids", [])
	var index: int = int(current)
	if index < 0 or index >= amounts.size():
		return 0.0
	return float(amounts[index])

static func _payload_unloader_liquid_add(module_state: Dictionary, liquid_id: int, amount: float) -> Dictionary:
	# LiquidModule.add (LiquidModule.java:110-117):
	# `liquids[liquid.id] += amount;` + `current = liquid;`.
	# Grows the amounts array to cover the id (a partial
	# fixture) and sets current to the added liquid. Mutates
	# the passed dict -- callers pass a duplicate.
	var amounts: Array = (module_state.get("liquids", []) as Array).duplicate()
	while amounts.size() <= liquid_id:
		amounts.append(0.0)
	amounts[liquid_id] = float(amounts[liquid_id]) + amount
	module_state["liquids"] = amounts
	module_state["current"] = liquid_id
	return module_state

static func _payload_unloader_liquid_remove(module_state: Dictionary, liquid_id: int, amount: float) -> Dictionary:
	# LiquidModule.remove (LiquidModule.java:125-128): add with
	# max(-amount, -liquids[liquid.id]) -- capped to prevent
	# negative removal.
	var amounts: Array = module_state.get("liquids", [])
	var held: float = 0.0
	if liquid_id >= 0 and liquid_id < amounts.size():
		held = float(amounts[liquid_id])
	return _payload_unloader_liquid_add(module_state, liquid_id, maxf(-amount, -held))

static func source_payload_unloader_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, load_tick: bool, item_order: Array, front: Dictionary) -> Dictionary:
	# The updateTile advance (PayloadUnloaderBuild.updateTile(),
	# PayloadUnloader.java:50-110), the pure frame advance -- the
	# build fields are `public float lastOutputPower = 0f;`
	# (PayloadUnloader.java:33), `public @Nullable T payload;`
	# (PayloadBlock.java:92), `public Vec2 payVector = new Vec2();`
	# (PayloadBlock.java:94) and `public float payRotation;`
	# (PayloadBlock.java:95), and the advance follows the Java
	# lines in order (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `if(payload != null){`
	# `payload.update(null, this);`
	# `lastOutputPower = 0f;`
	# `if(shouldExport()){`
	# `payload.block().breakEffect.at(this, payload.block().size);`
	# `payload = null;`
	# `moveOutPayload();`
	# `}else if(moveInPayload()){`
	# `if(payload.block().hasItems && !full()){`
	# `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`
	# `for(int j = 0; j < itemsLoaded && !full(); j++){`
	# `for(int i = 0; i < items.length(); i++){`
	# `if(payload.build.items.get(i) > 0){`
	# `Item item = content.item(i);`
	# `payload.build.items.remove(item, 1);`
	# `items.add(item, 1);`
	# `if(payload.block().hasLiquids && payload.build.liquids.currentAmount() >= 0.01f &&`
	# `(liquids.current() == payload.build.liquids.current() || liquids.currentAmount() <= 0.2f)){`
	# `var liq = payload.build.liquids.current();`
	# `float remaining = liquidCapacity - liquids.currentAmount();`
	# `float flow = Math.min(Math.min(liquidsLoaded * edelta(), remaining), payload.build.liquids.currentAmount());`
	# `liquids.add(liq, flow);`
	# `payload.build.liquids.remove(liq, flow);`
	# `if(hasBattery()){`
	# `float cap = payload.block().consPower.capacity;`
	# `float total = payload.build.power.status * cap;`
	# `float unloaded = Math.min(maxPowerUnload * edelta(), total);`
	# `lastOutputPower = unloaded;`
	# `payload.build.power.status -= unloaded / cap;`
	# `dumpLiquid(liquids.current());`
	# `for(int i = 0; i < offloadSpeed; i++){`
	# `dumpAccumulate();`
	# `return items.total() >= itemCapacity;`
	# `return payload != null && (`
	# `(!payload.block().hasItems || payload.build.items.empty()) &&`
	# `(!payload.block().hasLiquids || payload.build.liquids.currentAmount() <= 0.011f) &&`
	# `(!hasBattery() || payload.build.power.status <= 0.0000001f)`
	# `public float getPowerProduction(){`
	# `return lastOutputPower;`
	# `public int offloadSpeed = 4;`
	# `public float maxPowerUnload = 80f;`
	# `public class PayloadUnloader extends PayloadLoader{`
	# `public class PayloadUnloaderBuild extends PayloadLoaderBuild{`
	# `public final int timerLoad = timers++;`
	# `public float loadTime = 2f;`
	# `public int itemsLoaded = 8;`
	# `public float liquidsLoaded = 40f;`
	# `public boolean hasBattery(){`
	# `return payload != null && payload.block().consPower != null && payload.block().consPower.buffered;`
	# `itemCapacity = 100;`
	# `liquidCapacity = 100f;`
	# `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`
	# `if(payload == null) return false;`
	# `payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());`
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`
	# `return hasArrived();`
	# `return payVector.isZero(0.01f);`
	# `Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);`
	# `payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());`
	# `payVector.approach(dest, payloadSpeed * delta());`
	# `boolean canDump = front == null || !front.tile.solid();`
	# `boolean canMove = front != null && (front.block.outputsPayload || front.block.acceptsPayload);`
	# `if(payVector.within(dest, 0.001f)){`
	# `if(movePayload(payload)){`
	# `dumpPayload();`
	# `return Time.delta * timeScale;`
	# `return efficiency * delta();`
	# `return rotation * 90;`
	# `updateConsumption();`
	# `if(enabled || !block.noUpdateDisabled){`
	# `consumePower(2f);`
	# `public Liquid current(){`
	# `public float currentAmount(){`
	# `return liquids[current.id];`
	# `liquids[liquid.id] += amount;`
	# `current = liquid;`
	# `public boolean empty(){`
	# `return total == 0;`
	# `public static final int tilesize = 8;`
	# `return len2() < margin;`
	# delta() is `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924) and edelta() is `return
	# efficiency * delta();` (BuildingComp.java:1927-1929);
	# moveIn/moveOut use delta(), the liquid flow and the
	# battery unload use edelta(). source_delta is Time.delta
	# in ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26), never raw seconds. rotdeg() is `return
	# rotation * 90;` (BuildingComp.java:582-584) from the
	# frame rotation (BuildingComp.java:69 `transient int
	# rotation;`, default 0). hasArrived is the Arc quirk
	# `return payVector.isZero(0.01f);`
	# (PayloadBlock.java:243) with isZero(margin) = len2() <
	# margin (Vec2.java:679-681) -- NOT margin squared.
	# Payload dict contract (this slice; unify is a later
	# slice): payload = {"block": {"has_items": bool,
	# "has_liquids": bool, "instant_deconstruct": bool,
	# "cons_power_capacity": float or null (null = no
	# consPower), "cons_power_buffered": bool}, "build":
	# {"items": {name: int}, "liquids": the
	# SourceLiquidModuleState shape (amounts array by liquid
	# id + current id + flow null), "power_status": float}}.
	# Own frame items are {name: int} (the factory
	# precedent); own frame liquids use the same module
	# shape, synced from the sprite meta each tick (the N2224
	# Fracker precedent). Scoping decisions, all
	# source-backed: (1) payload.update (PayloadUnloader.
	# java:51-53) and updatePayload (PayloadBlock.java:
	# 174-179) are no-ops -- no live payload entity in the
	# port. (2) The timer cadence defers (no timer helper in
	# the port): the pure advance takes load_tick and the
	# driver passes false; the efficiency > 0.01f guard IS
	# modeled. (3) moveIn is ported here (PayloadBlock.java:
	# 186-197); block.rotate is true for PayloadLoader
	# (PayloadLoader.java:45), so the rotation target is
	# rotdeg(). (4) moveOut REUSES the ported helper
	# SourceBlockProducerMoveOutPayloadState
	# .move_out_payload_state through a preload (the N2224
	# precedent): its signature already covers the whole
	# PayloadBlock.java:199-226 body, including the 0.001f
	# arrival epsilon and the pushOutput fraction; the
	# movePayload/dumpPayload APPLICATION defers, so the
	# advance reports payload_moved / payload_dumped and
	# only clears the payload when the helper reports the
	# move succeeded. (5) The item scan runs over item_order
	# -- the catalog item_names_by_id, the content-id order
	# Java iterates (the N2225 precedent); an item name
	# outside the order is never unloaded. (6) The dump
	# defers whole (no dump infra on this path). (7)
	# lastOutputPower is POWER PRODUCTION
	# (getPowerProduction returns it, PayloadUnloader.java:
	# 44-47): the frame carries it, but the power graph
	# builds producers from the static block property
	# powerProduction, so the graph wiring waits for its own
	# distribution-runtime slice. The function does NOT
	# mutate its input frame: the payload, items, and
	# liquids are duplicated before unloading.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var delta: float = source_delta * time_scale
	var edelta: float = efficiency * delta
	var payload_in: Variant = frame.get("payload", null)
	var payload: Variant = null
	if payload_in != null:
		payload = (payload_in as Dictionary).duplicate(true)
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var liquids: Dictionary = (frame.get("liquids", {}) as Dictionary).duplicate(true)
	var pay_vector_in: Dictionary = frame.get("pay_vector", {})
	var pay_vector: Dictionary = {"x": float(pay_vector_in.get("x", 0.0)), "y": float(pay_vector_in.get("y", 0.0))}
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	var rotation: int = int(frame.get("rotation", 0))
	var rotdeg: float = float(rotation) * 90.0
	var last_output_power: float = 0.0
	var moved_in: bool = false
	var payload_moved: bool = false
	var payload_dumped: bool = false
	var deconstructed: bool = false
	var items_unloaded: int = 0
	var liquids_unloaded: float = 0.0
	var should_export: bool = false
	if payload != null:
		var payload_block: Dictionary = (payload as Dictionary).get("block", {})
		var payload_build: Dictionary = (payload as Dictionary).get("build", {})
		var payload_items: Dictionary = payload_build.get("items", {})
		var payload_liquids: Dictionary = payload_build.get("liquids", {})
		var has_battery: bool = payload_block.get("cons_power_capacity", null) != null and bool(payload_block.get("cons_power_buffered", false))
		var payload_power_status: float = float(payload_build.get("power_status", 0.0))
		should_export = (not bool(payload_block.get("has_items", false)) or inventory.items_total(payload_items) == 0) and (not bool(payload_block.get("has_liquids", false)) or _payload_unloader_liquid_current_amount(payload_liquids) <= 0.011) and (not has_battery or payload_power_status <= 0.0000001)
	if should_export:
		var export_block: Dictionary = (payload as Dictionary).get("block", {})
		if bool(export_block.get("instant_deconstruct", false)):
			deconstructed = true
			payload = null
		else:
			var moved_out: Dictionary = source_move_out_payload_state.move_out_payload_state(true, float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0)), pay_rotation, rotdeg, float(SOURCE_PAYLOAD_UNLOADER_SIZE), source_world_defaults.TILESIZE, SOURCE_PAYLOAD_UNLOADER_PAYLOAD_ROTATE_SPEED, SOURCE_PAYLOAD_UNLOADER_PAYLOAD_SPEED, delta, bool(front.get("present", false)), bool(front.get("solid", false)), bool(front.get("outputs_payload", false)), bool(front.get("accepts_payload", false)), bool(front.get("move_payload_result", false)))
			pay_vector = moved_out.get("pay_vector_after", pay_vector)
			pay_rotation = float(moved_out.get("pay_rotation_after", pay_rotation))
			payload_moved = bool(moved_out.get("move_payload_called", false)) and bool(front.get("move_payload_result", false))
			payload_dumped = bool(moved_out.get("dump_payload_called", false))
			if not bool(moved_out.get("payload_after_present", true)):
				payload = null
	elif payload != null:
		pay_rotation = source_math_state.source_angles_move_toward(pay_rotation, rotdeg, SOURCE_PAYLOAD_UNLOADER_PAYLOAD_ROTATE_SPEED * delta)
		pay_vector = source_move_out_payload_state.source_vec2_approach(float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0)), 0.0, 0.0, SOURCE_PAYLOAD_UNLOADER_PAYLOAD_SPEED * delta)
		var pay_x: float = float(pay_vector.get("x", 0.0))
		var pay_y: float = float(pay_vector.get("y", 0.0))
		moved_in = pay_x * pay_x + pay_y * pay_y < 0.01
		if moved_in:
			var unload_block: Dictionary = (payload as Dictionary).get("block", {})
			var unload_build: Dictionary = (payload as Dictionary).get("build", {})
			if bool(unload_block.get("has_items", false)) and inventory.items_total(items) < SOURCE_PAYLOAD_UNLOADER_ITEM_CAPACITY:
				if efficiency > 0.01 and load_tick:
					var held_items: Dictionary = (unload_build.get("items", {}) as Dictionary).duplicate(true)
					for _j in range(SOURCE_PAYLOAD_UNLOADER_ITEMS_LOADED):
						if inventory.items_total(items) >= SOURCE_PAYLOAD_UNLOADER_ITEM_CAPACITY:
							break
						for item_name in item_order:
							var candidate: String = str(item_name)
							if inventory.item_count(held_items, candidate) > 0:
								var removed: Dictionary = inventory.remove_item_state(held_items, candidate, 1)
								held_items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, held_items)
								var added: Dictionary = inventory.add_item_state(items, candidate, 1)
								items = added.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
								items_unloaded += 1
								break
					unload_build["items"] = held_items
			if bool(unload_block.get("has_liquids", false)):
				var held_liquids: Dictionary = (unload_build.get("liquids", {}) as Dictionary).duplicate(true)
				var payload_current: Variant = _payload_unloader_liquid_current(held_liquids)
				var payload_current_amount: float = _payload_unloader_liquid_current_amount(held_liquids)
				if payload_current != null and payload_current_amount >= 0.01:
					var own_current: Variant = _payload_unloader_liquid_current(liquids)
					var own_current_amount: float = _payload_unloader_liquid_current_amount(liquids)
					if own_current == payload_current or own_current_amount <= 0.2:
						var remaining: float = SOURCE_PAYLOAD_UNLOADER_LIQUID_CAPACITY - own_current_amount
						var flow: float = minf(minf(SOURCE_PAYLOAD_UNLOADER_LIQUIDS_LOADED * edelta, remaining), payload_current_amount)
						liquids = _payload_unloader_liquid_add(liquids, int(payload_current), flow)
						held_liquids = _payload_unloader_liquid_remove(held_liquids, int(payload_current), flow)
						unload_build["liquids"] = held_liquids
						liquids_unloaded = flow
			var unload_has_battery: bool = unload_block.get("cons_power_capacity", null) != null and bool(unload_block.get("cons_power_buffered", false))
			if unload_has_battery:
				var cap: float = float(unload_block.get("cons_power_capacity", 0.0))
				var status: float = float(unload_build.get("power_status", 0.0))
				var total: float = status * cap
				var unloaded: float = minf(SOURCE_PAYLOAD_UNLOADER_MAX_POWER_UNLOAD * edelta, total)
				last_output_power = unloaded
				unload_build["power_status"] = status - unloaded / cap
	return {"payload": payload, "pay_vector": pay_vector, "pay_rotation": pay_rotation, "items": items, "liquids": liquids, "last_output_power": last_output_power, "should_export": should_export, "moved_in": moved_in, "payload_moved": payload_moved, "payload_dumped": payload_dumped, "deconstructed": deconstructed, "items_unloaded": items_unloaded, "liquids_unloaded": liquids_unloaded}

static func source_payload_unloader_should_consume_state(frame: Dictionary) -> Dictionary:
	# PayloadUnloaderBuild does NOT override shouldConsume (PayloadUnloader.java has no shouldConsume at all; PayloadUnloader extends PayloadLoader, PayloadUnloader.java:8, `public class PayloadUnloader extends PayloadLoader{`, and PayloadUnloaderBuild extends PayloadLoaderBuild, PayloadUnloader.java:32, `public class PayloadUnloaderBuild extends PayloadLoaderBuild{`), so it inherits PayloadLoaderBuild.shouldConsume verbatim (PayloadLoader.java:240, `public boolean shouldConsume(){` with `return payload != null;`, PayloadLoader.java:241): the payload-unloader consumes only while it holds a payload. The default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare payload null check, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The payload is the PayloadBlockBuild field (`public @Nullable T payload;`, PayloadBlock.java:92), default null, set by handlePayload (`this.payload = (T)payload;`, PayloadBlock.java:122) and cleared by takePayload (PayloadBlock.java:145-149); the frame carries it under the `payload` key (default null for a frame bound before this slice), and the gate reads only its null-ness -- a minimal Dictionary fixture suffices in the proof. The def is payload-unloader (`consumePower(2f);`, Blocks.java:6695; `size = 3;`, Blocks.java:6696); there is no large-payload-unloader. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). No live fill sets the frame payload yet -- handlePayload / takePayload wait for their own slice (the moveInPayload / moveOutPayload advance is live since N2232); the gate reads the frame as-is.
	var payload: Variant = frame.get("payload", null)
	var has_payload: bool = payload != null
	return {"should_consume": has_payload, "has_payload": has_payload}

static func source_payload_unloader_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-unloader does not take the early return. The unload gate follows the folded efficiency (PayloadUnloader.java:69, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`), with the battery unload (PayloadUnloader.java:98, `float total = payload.build.power.status * cap;`) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){`) and the shouldConsume override inherited from PayloadLoaderBuild (PayloadLoader.java:241, `return payload != null;`); the gate is live since N2209 (the pure gate source_payload_unloader_should_consume_state feeds payload != null to the machinery; when the gate is false updateConsumption forces efficiency to 0, BuildingComp.java:1960 + 1992).
	# Documented limits: (1) power-only first pass -- PayloadUnloader has NO dynamic power consumer: `loadPowerDynamic = false` (PayloadUnloader.java:18), so `init()` never registers the ConsumePowerDynamic lambda (PayloadLoader.java:77-84, guarded by `if(loadPowerDynamic){` at :78); the static consumePower(2f) def (Blocks.java:6695) is the only power consumer, so the folded efficiency is the min over the *modeled* consumers (power only) and the power-only fold is EXACT. (An earlier docstring + DEFERRED entry claimed an inherited dynamic consumer -- WRONG, corrected at wave power-launch-build integration, 2026-11-16.) (2) shouldConsume gate live (N2209) -- PayloadUnloaderBuild inherits shouldConsume() to return payload != null (PayloadLoader.java:240-242); the pure gate (source_payload_unloader_should_consume_state) feeds should_consume to the machinery from the frame payload key (default null). No live payload fill yet -- handlePayload / takePayload wait for their own slice (the moveInPayload / moveOutPayload advance is live since N2232); the gate reads the frame as-is, so a live payload-unloader with no fill reads payload null and does not consume. (3) shouldExport gate live (N2232) -- shouldExport() (PayloadUnloader.java:116-122) runs in the pure advance over the frame payload (items empty / liquids <= 0.011f / battery status <= 0.0000001f). (4) updateTile advance live (N2232) -- moveInPayload / moveOutPayload (reused helper) / unload items+liquids / battery unload / lastOutputPower (PayloadUnloader.java:50-110) run on the frame; the timer cadence (the driver passes load_tick false), the dump, the movePayload/dumpPayload application, and the live front query wait for their own slices. (5) No accept/handle payload rows -- acceptPayload fits maxBlockSize (PayloadLoader.java:102-115, inherited) is payload acceptance, not tick state; PayloadUnloaderBuild overrides acceptItem/acceptLiquid to return false (PayloadUnloader.java:35-44). (6) Battery unload live (N2232), power-production graph wiring deferred -- getPowerProduction returns lastOutputPower (PayloadUnloader.java:46-48; lastOutputPower 0f, PayloadUnloader.java:33) and the battery unload (PayloadUnloader.java:94-102) fills frame last_output_power each tick, but the power graph builds producers from the static block property powerProduction, so the dynamic value waits for a distribution-runtime slice; dump cadence waits for its own slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_payload_unloader_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the payload-unloader tick wiring every
	# tick (PayloadUnloaderBuild.updateTile(), PayloadUnloader.java:50,
	# gates on the unload gate (PayloadUnloader.java:69, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`) and the battery unload (PayloadUnloader.java:98, `float total = payload.build.power.status * cap;`), so the unload gate follows the folded efficiency; no placed-buildings driver ticks PayloadUnloader blocks, so this driver is the placed-payload-unloader tick): each placed PayloadUnloader build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
	var item_order: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_payload_unloader_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_payload_unloader_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_payload_unloader_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.rotation (BuildingComp.
		# java:69 `transient int rotation;`, default 0) for the
		# moveIn/moveOut rotdeg() (BuildingComp.java:582-584
		# `return rotation * 90;`): the runtime stores it on
		# the sprite meta at placement (the factory precedent),
		# and sprites placed before the meta existed read as
		# rotation 0. The frame carries the Building.liquids
		# LiquidModule (frame["liquids"]): the live store lives
		# on the sprite meta (source_building_liquids,
		# initialized at placement), so the driver syncs the
		# reference into the frame each tick (the N2224
		# Fracker precedent) and the advance reads the result
		# amount from it.
		frame["rotation"] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a payload-unloader with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the unload gate (PayloadUnloader.java:69)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-unloader does not take the early return. A payload-unloader with no power consumer is untouched: the tick models no other consumers yet (there is NO dynamic power consumer row -- loadPowerDynamic is false, PayloadUnloader.java:18), and PayloadUnloaderBuild inherits shouldConsume() to return payload != null (PayloadLoader.java:240-242) -- N2209 feeds the live gate to the machinery (the pure gate is source_payload_unloader_should_consume_state, fed the frame payload key); the N2163 RED decision is resolved. The gate has no enabled term (Java returns the bare payload null check); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_payload_unloader_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_payload_unloader_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2232: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# `updateConsumption();`, then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- the port keeps the enabled gate
		# below as a pragmatic choice (the N2195
		# coordinator-fix precedent): the driver skips the
		# consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would unload from a stale efficiency. The driver-wide
		# disabled-early-return slice removes this gate for all
		# families. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The timer
		# cadence defers (no timer helper in the port), so the
		# driver passes load_tick false and unload items never
		# fire live until a timer-infra slice lands; the item
		# order is the catalog item_names_by_id (the N2225
		# content-id order). The front flags arrive as explicit
		# params (no live neighbor query), so the driver passes
		# front-absent: a live payload-unloader never moves its
		# payload into a front building until a live-front slice
		# lands. The advanced liquids store is written back to
		# the sprite meta (the pure advance returns a duplicate,
		# it does not mutate the synced store in place).
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var front: Dictionary = {"present": false, "solid": false, "outputs_payload": false, "accepts_payload": false, "move_payload_result": false}
			var advanced: Dictionary = source_payload_unloader_update_tile_advance_state(frame, source_delta, time_scale, false, item_order, front)
			frame["payload"] = advanced["payload"]
			frame["pay_vector"] = advanced["pay_vector"]
			frame["pay_rotation"] = advanced["pay_rotation"]
			frame["items"] = advanced["items"]
			frame["liquids"] = advanced["liquids"]
			sprite.set_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, advanced["liquids"])
			frame["last_output_power"] = advanced["last_output_power"]
			frame["should_export"] = advanced["should_export"]
			frame["moved_in"] = advanced["moved_in"]
			frame["payload_moved"] = advanced["payload_moved"]
			frame["payload_dumped"] = advanced["payload_dumped"]
			frame["deconstructed"] = advanced["deconstructed"]
			frame["items_unloaded"] = advanced["items_unloaded"]
			frame["liquids_unloaded"] = advanced["liquids_unloaded"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
