extends RefCounted
class_name SourceBuildingLiquidState

const source_liquid_reaction_state := preload("res://src/game/SourceLiquidReactionState.gd")
const source_building_liquid_dump_state := preload("res://src/game/SourceBuildingLiquidDumpState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

# The conduit frame meta key (SourceConduitRuntimeState.
# SOURCE_CONDUIT_BUILDING_META_KEY, "source_conduit_building"):
# kept as a local const because preloading the conduit
# runtime would cycle (it preloads this file directly, and
# its 59-file transitive preload tree reaches this file).
# The Conduit-class def ids (Blocks.java:2322/2329/2337/2410):
# conduit (liquidCapacity = 20f;) and pulse-conduit are plain
# Conduit; plated-conduit and reinforced-conduit are
# ArmoredConduit (ArmoredConduit.java:8, `public class
# ArmoredConduit extends Conduit{`). A conduit neighbour is
# told from a building neighbour by the frame meta key OR
# the block id (placement never binds the conduit frame --
# only the conduit tick does -- so a fresh conduit carries
# the block id alone).
const SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY := "source_conduit_building"
const SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS := ["conduit", "pulse-conduit", "plated-conduit", "reinforced-conduit"]

static func runtime_method_names(game: Object) -> Dictionary:
	return source_building_liquid_dump_state.runtime_method_names(game)

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return source_building_liquid_dump_state.runtime_method_name(method_names, key, fallback_name)

static func default_callbacks_state(game: Object) -> Dictionary:
	return source_building_liquid_dump_state.default_callbacks_state(game)

static func game_dump_liquid_routing_gate_state(game: Object, liquid: Variant, proximity_size: int, dump_cursor: int, output_dir: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array) -> Dictionary:
	return source_building_liquid_dump_state.game_dump_liquid_routing_gate_state(game, liquid, proximity_size, dump_cursor, output_dir, rotation_value, relative_to_by_index, destination_present_by_index, other_has_liquids_by_index, can_dump_liquid_by_index, other_liquids_present_by_index)

static func handle_liquid_amount(current_amount: float, amount: float) -> float:
	return current_amount + amount

static func accept_liquid_state(has_liquids: bool, consumes_liquid: bool) -> bool:
	return has_liquids and consumes_liquid

static func dump_liquid_default_scaling_state(liquid: Variant, current_liquid_amount: float) -> Dictionary:
	return source_building_liquid_dump_state.dump_liquid_default_scaling_state(liquid, current_liquid_amount)

static func dump_liquid_campaign_unlock_state(liquid: Variant, current_liquid_amount: float, net_client: bool, state_is_campaign: bool, team_is_default_team: bool) -> Dictionary:
	return source_building_liquid_dump_state.dump_liquid_campaign_unlock_state(liquid, current_liquid_amount, net_client, state_is_campaign, team_is_default_team)

static func dump_liquid_routing_gate_state(liquid: Variant, proximity_size: int, dump_cursor: int, output_dir: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array, increment_dump_cursor: Callable) -> Dictionary:
	return source_building_liquid_dump_state.dump_liquid_routing_gate_state(liquid, proximity_size, dump_cursor, output_dir, rotation_value, relative_to_by_index, destination_present_by_index, other_has_liquids_by_index, can_dump_liquid_by_index, other_liquids_present_by_index, increment_dump_cursor)

static func dump_liquid_fraction_transfer_state(liquid: Variant, scaling: float, eligible_indices: Array, current_liquid_amount: float, block_liquid_capacity: float, other_liquid_amount_by_index: Array, other_block_liquid_capacity_by_index: Array) -> Dictionary:
	return source_building_liquid_dump_state.dump_liquid_fraction_transfer_state(liquid, scaling, eligible_indices, current_liquid_amount, block_liquid_capacity, other_liquid_amount_by_index, other_block_liquid_capacity_by_index)

static func dump_liquid_state(liquid: Variant, scaling: float, output_dir: int, current_liquid_amount: float, net_client: bool, state_is_campaign: bool, team_is_default_team: bool, proximity_size: int, dump_cursor: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array, other_liquid_amount_by_index: Array, other_block_liquid_capacity_by_index: Array, other_accepts_liquid_by_index: Array, block_liquid_capacity: float, increment_dump_cursor: Callable) -> Dictionary:
	return source_building_liquid_dump_state.dump_liquid_state(liquid, scaling, output_dir, current_liquid_amount, net_client, state_is_campaign, team_is_default_team, proximity_size, dump_cursor, rotation_value, relative_to_by_index, destination_present_by_index, other_has_liquids_by_index, can_dump_liquid_by_index, other_liquids_present_by_index, other_liquid_amount_by_index, other_block_liquid_capacity_by_index, other_accepts_liquid_by_index, block_liquid_capacity, Callable(SourceBuildingLiquidState, "transfer_liquid_state"), increment_dump_cursor)

static func source_neighbour_liquid_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, liquid: String, amount: float) -> Dictionary:
	# The neighbour liquid write-back (N2371, the N2353 item
	# helper mirror): dumpLiquid (`public void dumpLiquid(Liquid liquid, float scaling, int outputDir){`,
	# BuildingComp.java:886) routes over proximity --
	# `Building other = proximity.get((i + dump) % proximity.size);` (:896) --
	# and transfers to each eligible neighbour --
	# `if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);` (:905) --
	# through transferLiquid (`public void transferLiquid(Building next, float amount, Liquid liquid){`,
	# BuildingComp.java:914) with `float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);` (:915),
	# gated on `if(next.acceptLiquid(self(), liquid)){` (:917), which hands the liquid over for real via
	# `next.handleLiquid(self(), liquid, flow);` (:918) and then `liquids.remove(liquid, flow);` (:919).
	# handleLiquid is `public void handleLiquid(Building source, Liquid liquid, float amount){` with
	# `liquids.add(liquid, amount);` (BuildingComp.java:872-874), no capacity check (acceptLiquid
	# already gated). N2284 routed the Fracker dump but only
	# reported the amounts after; this helper lands the liquid
	# for real. Index i is ring cell i (the
	# source_block_proximity_cells_state ring, angle-sorted),
	# so the live fill must fill the frame neighbour inputs
	# in ring order; the sprite resolves through
	# block_sprite_at_cell. The liquid arrives by name and
	# resolves to its catalog id (the module is id-indexed);
	# an unknown name reports unknown_liquid. A conduit
	# neighbour is told from a building neighbour by the
	# conduit frame meta key OR the Conduit-class block id,
	# checked FIRST -- and a conduit has NO queue (the belt
	# analogy does not hold): Conduit never overrides
	# handleLiquid, so the default liquids.add lands in its
	# LiquidModule, which the port keeps on the sprite
	# source_building_liquids meta (the N2090 pump-dump
	# precedent, which writes the conduit meta store
	# directly). ConduitBuild is `public class ConduitBuild extends LiquidBuild implements ChainedBuilding{`
	# (Conduit.java:156) under `public class Conduit extends LiquidBlock implements Autotiler{`
	# (Conduit.java:26), with its own acceptLiquid
	# `return (liquids.current() == liquid || liquids.currentAmount() < 0.2f)`
	# (Conduit.java:242-244) and `liquidCapacity = 20f;` (Blocks.java:2324). The frame path is
	# the N2142 write-back precedent: the first
	# SOURCE_CONSUMER_FRAME_META_KEYS frame present on the
	# sprite, the liquid lands through the shared liquid
	# module add, and the frame is written back with
	# set_meta. The frame-key list comes from a runtime
	# load (the BeamDrill precedent), NOT a preload: the
	# power-graph state's 104-file transitive preload tree
	# reaches this file through SourceFactoryBuildState, so
	# a preload would cycle (the geometry / liquid-module /
	# placed-block / content-registry preloads above were
	# verified cycle-free by transitive closure). No sprite,
	# no frame, a frame or conduit with no liquids store, or
	# an unknown liquid reports written false with a reason
	# -- the liquid is already routed away, so there is no
	# fallback to the source store (a deviation from Java,
	# where other is always a real Building with a liquids
	# module; a core neighbour carries no frame in the
	# meta-key list, so a routed liquid to one drops with
	# reason no_frame until a core store mapping lands). No
	# accept re-check here: the routing gate already decided
	# acceptance (BuildingComp.java:917).
	var no_cell := Vector2i(-1, -1)
	if amount <= 0.0:
		return {"written": false, "reason": "invalid_amount", "neighbour_cell": no_cell}
	if liquid.is_empty():
		return {"written": false, "reason": "invalid_liquid", "neighbour_cell": no_cell}
	var ring: Array = source_block_geometry.source_block_proximity_cells_state(size, cell.x, cell.y).get("cells", [])
	if neighbour_index < 0 or neighbour_index >= ring.size():
		return {"written": false, "reason": "invalid_index", "neighbour_cell": no_cell}
	var liquid_id := -1
	if game != null:
		var catalog: Variant = game.get("content_catalog")
		if catalog != null:
			liquid_id = int(source_content_registry_runtime_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {}).get(liquid, -1))
	if liquid_id < 0:
		return {"written": false, "reason": "unknown_liquid", "neighbour_cell": no_cell}
	var neighbour_cell: Vector2i = ring[neighbour_index]
	var sprite: Variant = game.call("block_sprite_at_cell", neighbour_cell)
	if sprite == null:
		return {"written": false, "reason": "no_sprite", "neighbour_cell": neighbour_cell}
	var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
	if sprite.has_meta(SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) or SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS.has(block_id):
		var conduit_store: Variant = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
		if not (conduit_store is Dictionary) or not conduit_store.has("liquids") or liquid_id >= int(conduit_store["liquids"].size()):
			return {"written": false, "reason": "no_liquids_store", "neighbour_cell": neighbour_cell}
		var conduit_cache_sums: Array = []
		if conduit_store.get("flow") != null:
			conduit_cache_sums.resize(int(conduit_store["liquids"].size()))
			conduit_cache_sums.fill(0.0)
		sprite.set_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, source_liquid_module_state.source_add_state(conduit_store, liquid_id, amount, conduit_cache_sums))
		return {"written": true, "reason": "conduit", "neighbour_cell": neighbour_cell}
	var power_graph_state = load("res://src/game/SourcePlacedPowerGraphState.gd")
	for meta_key in power_graph_state.SOURCE_CONSUMER_FRAME_META_KEYS:
		if not sprite.has_meta(meta_key):
			continue
		var frame: Variant = sprite.get_meta(meta_key)
		if frame is Dictionary:
			var neighbour_liquids: Variant = frame.get("liquids", null)
			if not (neighbour_liquids is Dictionary) or not neighbour_liquids.has("liquids") or liquid_id >= int(neighbour_liquids["liquids"].size()):
				return {"written": false, "reason": "no_liquids_store", "neighbour_cell": neighbour_cell}
			var frame_cache_sums: Array = []
			if neighbour_liquids.get("flow") != null:
				frame_cache_sums.resize(int(neighbour_liquids["liquids"].size()))
				frame_cache_sums.fill(0.0)
			frame["liquids"] = source_liquid_module_state.source_add_state(neighbour_liquids, liquid_id, amount, frame_cache_sums)
			sprite.set_meta(meta_key, frame)
			return {"written": true, "reason": "live_frame", "neighbour_cell": neighbour_cell}
	return {"written": false, "reason": "no_frame", "neighbour_cell": neighbour_cell}

static func transfer_liquid_state(liquid: Variant, amount: float, next_block_liquid_capacity: float, next_liquid_amount: float, next_accepts_liquid: bool, current_liquid_amount: float) -> Dictionary:
	var flow = minf(next_block_liquid_capacity - next_liquid_amount, amount)
	var next_liquid_amount_after := next_liquid_amount
	var current_liquid_amount_after := current_liquid_amount
	var handle_liquid_called := false
	var remove_liquid_called := false
	if next_accepts_liquid:
		next_liquid_amount_after = next_liquid_amount + flow
		current_liquid_amount_after = current_liquid_amount - flow
		handle_liquid_called = true
		remove_liquid_called = true
	return {
		"method": "public void transferLiquid(Building next, float amount, Liquid liquid){",
		"flow": "float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);",
		"accept_guard": "if(next.acceptLiquid(self(), liquid)){",
		"handle_liquid_call": "next.handleLiquid(self(), liquid, flow);",
		"remove_liquid_call": "liquids.remove(liquid, flow);",
		"liquid": liquid,
		"amount": amount,
		"next_block_liquid_capacity": next_block_liquid_capacity,
		"next_liquid_amount": next_liquid_amount,
		"next_accepts_liquid": next_accepts_liquid,
		"current_liquid_amount": current_liquid_amount,
		"flow_value": flow,
		"accept_guard_passed": next_accepts_liquid,
		"handle_liquid_called": handle_liquid_called,
		"remove_liquid_called": remove_liquid_called,
		"next_liquid_amount_after": next_liquid_amount_after,
		"current_liquid_amount_after": current_liquid_amount_after,
	}

static func can_dump_liquid_default_state(to_state: Variant, liquid: Variant) -> Dictionary:
	return {
		"method": "public boolean canDumpLiquid(Building to, Liquid liquid){",
		"return_true": "return true;",
		"to_state": to_state,
		"liquid": liquid,
		"can_dump_liquid": true,
	}

static func get_liquid_destination_default_state(from_state: Variant, liquid: Variant, self_state: Variant) -> Dictionary:
	return {
		"method": "public Building getLiquidDestination(Building from, Liquid liquid){",
		"return_self": "return self();",
		"from_state": from_state,
		"liquid": liquid,
		"self_state": self_state,
		"destination": self_state,
		"returns_self": true,
	}

static func move_liquid_forward_state(leaks: bool, liquid: Variant, next_tile_present: bool, next_build_present: bool, next_block_solid: bool, next_block_has_liquids: bool, current_liquid_amount: float, move_liquid_return: float) -> Dictionary:
	var move_liquid_called := false
	var leak_guard_passed := false
	var leak_amount := 0.0
	var puddles_deposit_called := false
	var remove_liquid_called := false
	var current_liquid_amount_after := current_liquid_amount
	var return_value := 0.0
	if next_tile_present:
		if next_build_present:
			move_liquid_called = true
			return_value = move_liquid_return
		elif leaks and not next_block_solid and not next_block_has_liquids:
			leak_guard_passed = true
			leak_amount = current_liquid_amount / 1.5
			puddles_deposit_called = true
			remove_liquid_called = true
			current_liquid_amount_after = current_liquid_amount - leak_amount
	return {
		"method": "public float moveLiquidForward(boolean leaks, Liquid liquid){",
		"nearby_lookup": "Tile next = tile.nearby(rotation);",
		"null_return": "if(next == null) return 0;",
		"move_liquid_call": "return moveLiquid(next.build, liquid);",
		"leak_guard": "}else if(leaks && !next.block().solid && !next.block().hasLiquids){",
		"leak_amount": "float leakAmount = liquids.get(liquid) / 1.5f;",
		"puddles_deposit_call": "Puddles.deposit(next, tile, liquid, leakAmount, true, true);",
		"remove_liquid_call": "liquids.remove(liquid, leakAmount);",
		"leaks": leaks,
		"liquid": liquid,
		"next_tile_present": next_tile_present,
		"next_build_present": next_build_present,
		"next_block_solid": next_block_solid,
		"next_block_has_liquids": next_block_has_liquids,
		"current_liquid_amount": current_liquid_amount,
		"move_liquid_return": move_liquid_return,
		"move_liquid_called": move_liquid_called,
		"leak_guard_passed": leak_guard_passed,
		"leak_amount_value": leak_amount,
		"puddles_deposit_called": puddles_deposit_called,
		"remove_liquid_called": remove_liquid_called,
		"current_liquid_amount_after": current_liquid_amount_after,
		"return_value": return_value,
	}

static func move_liquid_state(liquid: Variant, next_present: bool, destination_team_matches: bool, destination_block_has_liquids: bool, current_liquid_amount: float, destination_liquid_amount: float, source_block_liquid_capacity: float, source_block_liquid_pressure: float, destination_block_liquid_capacity: float, destination_accepts_liquid: bool) -> Dictionary:
	var main_guard_passed := false
	var ofract := 0.0
	var fract := 0.0
	var flow_initial := 0.0
	var flow := 0.0
	var transfer_guard_passed := false
	var handle_liquid_called := false
	var remove_liquid_called := false
	var destination_liquid_amount_after := destination_liquid_amount
	var current_liquid_amount_after := current_liquid_amount
	var return_value := 0.0
	if next_present:
		main_guard_passed = destination_team_matches and destination_block_has_liquids and current_liquid_amount > 0.0
		if main_guard_passed:
			ofract = destination_liquid_amount / destination_block_liquid_capacity
			fract = current_liquid_amount / source_block_liquid_capacity * source_block_liquid_pressure
			flow_initial = minf(clampf(fract - ofract, 0.0, 1.0) * source_block_liquid_capacity, current_liquid_amount)
			flow = minf(flow_initial, destination_block_liquid_capacity - destination_liquid_amount)
			transfer_guard_passed = flow > 0.0 and ofract <= fract and destination_accepts_liquid
			if transfer_guard_passed:
				handle_liquid_called = true
				remove_liquid_called = true
				destination_liquid_amount_after = destination_liquid_amount + flow
				current_liquid_amount_after = current_liquid_amount - flow
				return_value = flow
	return {
		"method": "public float moveLiquid(Building next, Liquid liquid){",
		"null_return": "if(next == null) return 0;",
		"get_liquid_destination_call": "next = next.getLiquidDestination(self(), liquid);",
		"main_guard": "if(next.team == team && next.block.hasLiquids && liquids.get(liquid) > 0f){",
		"ofract": "float ofract = next.liquids.get(liquid) / next.block.liquidCapacity;",
		"fract": "float fract = liquids.get(liquid) / block.liquidCapacity * block.liquidPressure;",
		"flow_initial": "float flow = Math.min(Mathf.clamp((fract - ofract)) * (block.liquidCapacity), liquids.get(liquid));",
		"flow_capacity_clamp": "flow = Math.min(flow, next.block.liquidCapacity - next.liquids.get(liquid));",
		"transfer_guard": "if(flow > 0f && ofract <= fract && next.acceptLiquid(self(), liquid)){",
		"handle_liquid_call": "next.handleLiquid(self(), liquid, flow);",
		"remove_liquid_call": "liquids.remove(liquid, flow);",
		"return_flow": "return flow;",
		"liquid": liquid,
		"next_present": next_present,
		"destination_team_matches": destination_team_matches,
		"destination_block_has_liquids": destination_block_has_liquids,
		"current_liquid_amount": current_liquid_amount,
		"destination_liquid_amount": destination_liquid_amount,
		"source_block_liquid_capacity": source_block_liquid_capacity,
		"source_block_liquid_pressure": source_block_liquid_pressure,
		"destination_block_liquid_capacity": destination_block_liquid_capacity,
		"destination_accepts_liquid": destination_accepts_liquid,
		"main_guard_passed": main_guard_passed,
		"ofract_value": ofract,
		"fract_value": fract,
		"flow_initial_value": flow_initial,
		"flow_value": flow,
		"transfer_guard_passed": transfer_guard_passed,
		"handle_liquid_called": handle_liquid_called,
		"remove_liquid_called": remove_liquid_called,
		"destination_liquid_amount_after": destination_liquid_amount_after,
		"current_liquid_amount_after": current_liquid_amount_after,
		"return_value": return_value,
	}

static func move_liquid_reaction_setup_state(main_guard_passed: bool, transfer_guard_passed: bool, destination_consumes_liquid: bool, destination_current_amount: float, destination_block_liquid_capacity: float, fract_value: float, source_x: float, source_y: float, destination_x: float, destination_y: float, destination_current_liquid: Variant, other_block_reactive: bool, liquid_block_reactive: bool) -> Dictionary:
	var reaction_guard_passed := main_guard_passed and not transfer_guard_passed and not destination_consumes_liquid and (destination_current_amount / destination_block_liquid_capacity) > 0.1 and fract_value > 0.1
	var fx := 0.0
	var fy := 0.0
	var block_reactive_guard_passed := false
	if reaction_guard_passed:
		fx = (source_x + destination_x) / 2.0
		fy = (source_y + destination_y) / 2.0
		block_reactive_guard_passed = other_block_reactive and liquid_block_reactive
	return {
		"reaction_guard": "}else if(!next.block.consumesLiquid(liquid) && next.liquids.currentAmount() / next.block.liquidCapacity > 0.1f && fract > 0.1f){",
		"reaction_guard_passed": reaction_guard_passed,
		"effect_position": "float fx = (x + next.x) / 2f, fy = (y + next.y) / 2f;",
		"fx_expr": "float fx = (x + next.x) / 2f",
		"fy_expr": "float fy = (y + next.y) / 2f",
		"fx": fx,
		"fy": fy,
		"other_expr": "Liquid other = next.liquids.current();",
		"other": destination_current_liquid,
		"block_reactive_guard": "if(other.blockReactive && liquid.blockReactive){",
		"block_reactive_guard_passed": block_reactive_guard_passed,
		"main_guard_passed": main_guard_passed,
		"transfer_guard_passed": transfer_guard_passed,
		"destination_consumes_liquid": destination_consumes_liquid,
		"destination_current_amount": destination_current_amount,
		"destination_block_liquid_capacity": destination_block_liquid_capacity,
		"fract_value": fract_value,
		"source_x": source_x,
		"source_y": source_y,
		"destination_x": destination_x,
		"destination_y": destination_y,
		"destination_current_liquid": destination_current_liquid,
		"other_block_reactive": other_block_reactive,
		"liquid_block_reactive": liquid_block_reactive,
	}

static func move_liquid_fire_reaction_state(block_reactive_guard_passed: bool, other_flammability: float, liquid_temperature: float, liquid_flammability: float, other_temperature: float, fire_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	return source_liquid_reaction_state.fire_reaction_state(block_reactive_guard_passed, other_flammability, liquid_temperature, liquid_flammability, other_temperature, fire_chance_delta_passed, fx, fy)

static func move_liquid_steam_reaction_state(block_reactive_guard_passed: bool, fire_reaction_guard_passed: bool, liquid_temperature: float, other_temperature: float, current_liquid_amount: float, source_delta: float, steam_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	return source_liquid_reaction_state.steam_reaction_state(block_reactive_guard_passed, fire_reaction_guard_passed, liquid_temperature, other_temperature, current_liquid_amount, source_delta, steam_chance_delta_passed, fx, fy)

static func move_liquid_return_zero_state(next_present: bool, transfer_guard_passed: bool) -> Dictionary:
	var fallthrough_return_reached := next_present and not transfer_guard_passed
	var return_value := 0.0
	return {
		"final_return": "return 0;",
		"fallthrough_return_reached": fallthrough_return_reached,
		"return_value": return_value,
		"next_present": next_present,
		"transfer_guard_passed": transfer_guard_passed,
	}
