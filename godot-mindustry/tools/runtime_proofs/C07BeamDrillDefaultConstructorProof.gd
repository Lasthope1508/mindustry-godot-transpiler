extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ctor_case(block_name: String, ambient_sound: Variant, block_flags: Variant) -> Dictionary:
	return state.source_beam_drill_default_constructor_state({}, block_name, ambient_sound, block_flags)


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

	# --- BeamDrill(String name) (N2401):
	# BeamDrill(String name) (BeamDrill.java:63-80) sets
	# the six BeamDrill-only field defaults: the render
	# flags (`drawArrow = false;`, `regionRotated1 = 1;`,
	# `ignoreLineRotation = true;`) and the ambient sound
	# (`ambientSoundVolume = 0.05f;`, `ambientSound =
	# Sounds.loopMineBeam;`) plus the block flag (`flags =
	# EnumSet.of(BlockFlag.drill);`). The proof drives the
	# pure function with synthetic frames (no live tick):
	# plasma-bore (Blocks.java:3038-3051) and
	# large-plasma-bore (Blocks.java:3052-3065) names;
	# the ambient sound and flags params pass through in
	# both shapes. NOT ambient C (N2304 HELD -- the
	# SoundControl updateLoops mixer), NO driver tick
	# line: the ctor is load-time block definition setup.

	# The block name passes through.
	var plasma: Dictionary = _ctor_case("plasma-bore", "loopMineBeam", ["drill"])
	proof["defaults_name_passthrough"] = plasma.get("name", null) == "plasma-bore"

	# The rotation arrow is disabled.
	proof["defaults_draw_arrow_false"] = plasma.get("draw_arrow", true) == false

	# The first rotated region index is 1.
	proof["defaults_region_rotated_1"] = int(plasma.get("region_rotated_1", -1)) == 1

	# The line-drag rotation is ignored.
	proof["defaults_ignore_line_rotation_true"] = plasma.get("ignore_line_rotation", false) == true

	# The ambient sound volume is 0.05 (the same value as
	# the Block base default, Block.java:353).
	proof["defaults_ambient_sound_volume"] = is_equal_approx(float(plasma.get("ambient_sound_volume", -1.0)), 0.05)

	# The ambient sound ref passes through.
	proof["defaults_ambient_sound_passthrough"] = plasma.get("ambient_sound", null) == "loopMineBeam"

	# The block flags pass through in both shapes (array
	# and plain string): a second call with another block
	# name passes its name through too.
	var large: Dictionary = _ctor_case("large-plasma-bore", "loopMineBeam", "drill")
	proof["defaults_flags_passthrough"] = plasma.get("flags", null) == ["drill"] and large.get("flags", null) == "drill" and large.get("name", null) == "large-plasma-bore"

	# Each result carries ONLY its own keys.
	proof["returns_only_expected_keys"] = plasma.size() == 7 and large.size() == 7

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillDefaultConstructorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
