extends Node

const source_block_placement := preload("res://src/game/SourceBlockPlacement.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")

class FakeBlock extends RefCounted:
	var id := "proof_block"
	var properties := {
		"size": 2,
		"requirements": [{"item": "copper", "amount": 1}],
	}


class FakeContentCatalog extends RefCounted:
	var block

	func _init(block_input) -> void:
		block = block_input

	func get_by_id(block_id: String):
		if block_id == "proof_block":
			return block
		return null


class FakePlacementGame extends Node:
	var build_palette: Array = []
	var selected_build_index := 0
	var content_catalog
	var placed_blocks: Dictionary = {}
	var placed_block_origins: Dictionary = {}
	var player_placed_block_count := 0
	var last_placed_block_id := ""
	var last_placed_block_size := 0
	var last_placed_block_requirements: Array = []
	var last_placed_cell := Vector2i.ZERO
	var last_placed_occupied_cell_count := 0
	var last_place_blocked := false
	var spent_count := 0
	var recorded_count := 0
	var registered_count := 0

	func setup_nodes() -> void:
		var world := Node2D.new()
		world.name = "World"
		add_child(world)
		var block_layer := Node2D.new()
		block_layer.name = "BlockLayer"
		world.add_child(block_layer)

	func world_to_grid(world_pos: Vector2) -> Vector2i:
		return Vector2i(int(world_pos.x / 8.0), int(world_pos.y / 8.0))

	func can_afford(_block) -> bool:
		return true

	func spend_requirements(_block) -> void:
		spent_count += 1

	func configure_block_sprite(sprite: Sprite2D, _block, cell: Vector2i) -> void:
		sprite.position = Vector2(float(cell.x * 8), float(cell.y * 8))

	func record_placed_block(sprite: Sprite2D, _block, cell: Vector2i) -> void:
		var key := source_world_grid.cell_key(cell)
		placed_block_origins[key] = cell
		placed_blocks[key] = sprite
		recorded_count += 1

	func register_turret_cell(_cell: Vector2i, _block) -> void:
		registered_count += 1


func _ready() -> void:
	var block := {"id": "proof_block", "properties": {"size": 2}}
	var open_state := source_block_placement.selected_block_placement_state(block, Vector2i(2, 2), {}, Vector2i(8, 8), true)
	var occupied_blocks: Dictionary = {source_world_grid.cell_key(Vector2i(2, 2)): true}
	var blocked_state := source_block_placement.selected_block_placement_state(block, Vector2i(2, 2), occupied_blocks, Vector2i(8, 8), true)
	var fake_game := FakePlacementGame.new()
	add_child(fake_game)
	fake_game.setup_nodes()
	fake_game.build_palette = [FakeBlock.new()]
	var placement_execution_result := source_block_placement.place_selected_block_at_world(fake_game, Vector2(16.0, 16.0), Vector2i(8, 8))
	var add_block_game := FakePlacementGame.new()
	add_child(add_block_game)
	add_block_game.setup_nodes()
	add_block_game.content_catalog = FakeContentCatalog.new(FakeBlock.new())
	var add_source_parent: Node = add_block_game.get_node("World/BlockLayer")
	source_block_placement.add_source_block(add_block_game, add_source_parent, "proof_block", Vector2i(3, 3))
	var lookup_state := source_ssot_catalog.canonical_headquarter_lookup_state("block placement")
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_PLACEMENT_MODULE_PROOF",
		"open_can_place": bool(open_state.get("can_place", false)),
		"open_can_afford": bool(open_state.get("can_afford", false)),
		"open_occupied_cell_count": int(open_state.get("occupied_cell_count", 0)),
		"blocked_can_place": bool(blocked_state.get("can_place", true)) == false,
		"placement_execution_matches": placement_execution_result
			and fake_game.player_placed_block_count == 1
			and fake_game.last_place_blocked == false
			and fake_game.last_placed_block_id == "proof_block"
			and fake_game.last_placed_occupied_cell_count == 4
			and fake_game.spent_count == 1
			and fake_game.recorded_count == 1
			and fake_game.registered_count == 1
			and fake_game.get_node("World/BlockLayer").get_child_count() == 1,
		"add_source_block_matches": add_source_parent.get_child_count() == 1
			and add_block_game.recorded_count == 1
			and add_block_game.registered_count == 1
			and add_block_game.placed_blocks.size() == 1,
		"headquarter": str(lookup_state.get("headquarter", "")),
		"canonical_key": str(lookup_state.get("canonical_key", "")),
		"registry_errors": registry_state.get("errors", []).duplicate(),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("BLOCK_PLACEMENT_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(20.0).timeout
	get_tree().quit(0)
