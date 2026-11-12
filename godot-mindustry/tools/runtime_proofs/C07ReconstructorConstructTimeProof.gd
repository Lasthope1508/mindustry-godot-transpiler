extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var additive_block = blocks_by_id["additive-reconstructor"]
	var multiplicative_block = blocks_by_id["multiplicative-reconstructor"]

	# --- Catalog capture (Blocks.java:6310, 6330): the block
	# initializer's own constructTime assignment, else the class
	# default (Reconstructor.java:36, 60 * 2 = 120.0).
	proof["additive_construct_time_600"] = is_equal_approx(float(additive_block.properties.get("constructTime", -1.0)), 600.0)
	proof["multiplicative_construct_time_1800"] = is_equal_approx(float(multiplicative_block.properties.get("constructTime", -1.0)), 1800.0)

	# --- Pure read (N2143): the class default when the catalog
	# carries no override, the per-block value otherwise.
	var default_read: Dictionary = unit_factory_build_state.source_reconstructor_construct_time_state(MindustryBlock.new({}))
	proof["read_default_120"] = is_equal_approx(float(default_read.get("construct_time", -1.0)), 120.0)
	var additive_read: Dictionary = unit_factory_build_state.source_reconstructor_construct_time_state(additive_block)
	proof["read_additive_600"] = is_equal_approx(float(additive_read.get("construct_time", -1.0)), 600.0)

	# --- Tick completes exactly at the catalog time
	# (Reconstructor.java:334 `if(progress >= constructTime){`):
	# progress 599.0 + edelta 1.0 = 600.0 >= 600.0, dagger -> mace.
	var construct_time: float = float(additive_read.get("construct_time", 120.0))
	var completing: Dictionary = unit_factory_build_state.source_reconstructor_production_tick_state({"efficiency": 1.0, "payload": {"unit": "dagger"}, "progress": 599.0, "time": 0.0, "speed_scl": 1.0}, construct_time, true, "mace", true, 1.0, 1.0, 1.0)
	var completed_payload: Variant = completing.get("payload", null)
	proof["tick_completes_at_600"] = bool(completing.get("completed", false)) == true and completed_payload is Dictionary and str(completed_payload.get("unit", "")) == "mace"

	# --- Below the catalog time the tick only advances:
	# progress 100.0 + edelta 1.0 = 101.0 < 600.0, nothing completes.
	var advancing: Dictionary = unit_factory_build_state.source_reconstructor_production_tick_state({"efficiency": 1.0, "payload": {"unit": "dagger"}, "progress": 100.0, "time": 0.0, "speed_scl": 1.0}, construct_time, true, "mace", true, 1.0, 1.0, 1.0)
	proof["tick_incomplete_below_600"] = is_equal_approx(float(advancing.get("progress", -1.0)), 101.0) and bool(advancing.get("completed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ReconstructorConstructTimeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
