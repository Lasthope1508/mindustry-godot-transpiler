extends RefCounted
class_name SourceConduitRuntimeState

const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

const SOURCE_CONDUIT_BUILDING_META_KEY := "source_conduit_building"

# Blocks.java:2322-2327: conduit = new Conduit("conduit") with
# liquidCapacity = 20f and health = 45.
# Conduit.java:43: leaks = true. Block.java:79: liquidPressure = 1f.
# Block.java:1407-1418: a block with a liquid consumer and no explicit
# liquidCapacity gets round(10 * max(1, consumer amount * 60)); the
# mechanical drill consumes water 0.05f, so its liquidCapacity is 30.
const CONDUIT_LIQUID_CAPACITY := 20.0
const CONDUIT_LIQUID_PRESSURE := 1.0
const CONDUIT_FLOW_INTERVAL := 1.0
const DRILL_LIQUID_CAPACITY := 30.0


static func _liquid_capacity_for_block_id(block_id: String) -> float:
	# The conduit's forward neighbors in the bootstrap world are
	# conduits (Blocks.java:2324, liquidCapacity = 20f) and the
	# mechanical drill (Block.java:1407-1418, liquidCapacity 30).
	if block_id == "conduit":
		return CONDUIT_LIQUID_CAPACITY
	if block_id == "mechanical-drill":
		return DRILL_LIQUID_CAPACITY
	return 0.0


static func _rotation_offset(rotation: int) -> Vector2i:
	# Java rotation convention: 0 east, 1 north, 2 west, 3 south;
	# in the runtime's y-down coordinates north is (0,-1).
	match rotation % 4:
		0:
			return Vector2i(1, 0)
		1:
			return Vector2i(0, -1)
		2:
			return Vector2i(-1, 0)
		_:
			return Vector2i(0, 1)


static func source_conduit_update_state(game: Object, cell: Vector2i, delta: float) -> Dictionary:
	# Conduit.java:249-255 ConduitBuild.updateTile: smoothLiquid lerps
	# toward liquids.currentAmount() / liquidCapacity (0.05), and when
	# the conduit holds more than 0.0001 liquid and its flow timer
	# (timerFlow, 1s) fires, it calls moveLiquidForward(leaks,
	# liquids.current()). moveLiquidForward (BuildingComp.java:923-937)
	# moves the liquid to tile.nearby(rotation) via the bound
	# moveLiquid (pressure fractions), or leaks a puddle
	# (leakAmount = liquids.get(liquid) / 1.5f) when there is no
	# building ahead. The flow timer and smoothLiquid live on the
	# conduit sprite's meta frame, so they persist across frames.
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"liquid": null, "flowed": 0.0, "smooth_liquid": 0.0, "flow_timer": 0.0}
	var liquids: Variant = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
	if liquids == null:
		return {"liquid": null, "flowed": 0.0, "smooth_liquid": 0.0, "flow_timer": 0.0}
	var frame: Dictionary = sprite.get_meta(SOURCE_CONDUIT_BUILDING_META_KEY, {})
	var smooth_liquid: float = float(frame.get("smooth_liquid", 0.0))
	var flow_timer: float = float(frame.get("flow_timer", 0.0))
	var current_liquid: Variant = liquids.get("current", null)
	var current_amount: float = 0.0
	if current_liquid != null:
		current_amount = float(source_liquid_module_state.source_get_state(liquids, int(current_liquid)).get("amount", 0.0))
	smooth_liquid = source_math_state.source_lerp_delta(smooth_liquid, current_amount / CONDUIT_LIQUID_CAPACITY, 0.05, delta)
	var flowed := 0.0
	flow_timer += delta
	if current_amount > 0.0001 and flow_timer >= CONDUIT_FLOW_INTERVAL:
		flow_timer -= CONDUIT_FLOW_INTERVAL
		var rotation: int = int(sprite.get_meta("rotation", 0))
		var next_cell: Vector2i = cell + _rotation_offset(rotation)
		var next_sprite: Variant = game.call("block_sprite_at_cell", next_cell)
		if next_sprite != null:
			var next_liquids: Variant = next_sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
			if next_liquids != null:
				var next_block_id: String = str(next_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
				var next_capacity: float = _liquid_capacity_for_block_id(next_block_id)
				if next_capacity > 0.0:
					var next_amount: float = float(source_liquid_module_state.source_get_state(next_liquids, int(current_liquid)).get("amount", 0.0))
					var next_current: Variant = next_liquids.get("current", null)
					var next_current_amount := 0.0
					if next_current != null:
						next_current_amount = float(source_liquid_module_state.source_get_state(next_liquids, int(next_current)).get("amount", 0.0))
					var next_rotation: int = int(next_sprite.get_meta("rotation", 0))
					var next_accepts: bool = true
					if next_block_id == "conduit":
						# Conduit.acceptLiquid (Conduit.java:241-244):
						# its current liquid matches, or its current
						# amount is under 0.2, and this conduit is not
						# on the side the next conduit outputs to:
						# source.relativeTo(next tile) is this
						# conduit's rotation, so the check is
						# (rotation + 2) % 4 != next_rotation.
						next_accepts = (next_current == current_liquid or next_current_amount < 0.2) and (rotation + 2) % 4 != next_rotation
					var move: Dictionary = source_building_liquid_state.move_liquid_state(current_liquid, true, true, true, current_amount, next_amount, CONDUIT_LIQUID_CAPACITY, CONDUIT_LIQUID_PRESSURE, next_capacity, next_accepts)
					flowed = float(move.get("return_value", 0.0))
					source_liquid_module_state.source_set_state(next_liquids, int(current_liquid), float(move.get("destination_liquid_amount_after", next_amount)))
					source_liquid_module_state.source_set_state(liquids, int(current_liquid), float(move.get("current_liquid_amount_after", current_amount)))
		else:
			# No building ahead: the conduit leaks (BuildingComp
			# .java:930-935). The puddle deposit is not modeled in
			# this runtime; the leaked amount leaves the conduit.
			var leak_amount: float = current_amount / 1.5
			source_liquid_module_state.source_set_state(liquids, int(current_liquid), current_amount - leak_amount)
			flowed = leak_amount
	frame["smooth_liquid"] = smooth_liquid
	frame["flow_timer"] = flow_timer
	sprite.set_meta(SOURCE_CONDUIT_BUILDING_META_KEY, frame)
	var liquid_after: Variant = liquids.get("current", null)
	return {"liquid": liquid_after, "flowed": flowed, "smooth_liquid": smooth_liquid, "flow_timer": flow_timer}
