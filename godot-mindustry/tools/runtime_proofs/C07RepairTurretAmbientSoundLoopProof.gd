extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- RepairTurret ambient-sound live-loop gate (N2222):
	# BuildingComp.update() loops the ambient sound each tick
	# (BuildingComp.java:2270-2271, inside `public void
	# update(){`, BuildingComp.java:2262):
	# if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){
	# control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());
	# The sound is `Sounds.beamHeal` and its volume scale is
	# `1f` (RepairTurret.java:66-67), the Block defaults they
	# override are `public Sound ambientSound = Sounds.none;`
	# and `public float ambientSoundVolume = 0.05f;`
	# (Block.java:351, :353), and ambientVolume() is the folded
	# efficiency (BuildingComp.java:2015-2017). The gate reuses
	# the N2221 shouldAmbientSound() pure function; headless is
	# an explicit bool param; efficiency absent folds to 1.0.
	# There is no driver tick line: the loop call is a sound
	# side effect with no sink in the port yet.

	# Loop true with a target, full efficiency and a headed game.
	var loop_on: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state({"has_target": true, "efficiency": 1.0}, false)
	proof["loop_true_target_efficiency_headed"] = bool(loop_on.get("should_loop", false)) and str(loop_on.get("sound", "")) == "beamHeal" and is_equal_approx(float(loop_on.get("volume", 0.0)), 1.0)

	# Loop false in a headless game, even with a target and full efficiency.
	var loop_headless: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state({"has_target": true, "efficiency": 1.0}, true)
	proof["loop_false_headless"] = not bool(loop_headless.get("should_loop", true))

	# Loop false with no target, even in a headed game at full efficiency.
	var loop_no_target: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state({"has_target": false, "efficiency": 1.0}, false)
	proof["loop_false_no_target"] = not bool(loop_no_target.get("should_loop", true))

	# Loop false with a target but zero efficiency.
	var loop_no_efficiency: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state({"has_target": true, "efficiency": 0.0}, false)
	proof["loop_false_zero_efficiency"] = not bool(loop_no_efficiency.get("should_loop", true))

	# Loop volume at half efficiency (1f * 0.5).
	var loop_half: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state({"has_target": true, "efficiency": 0.5}, false)
	proof["loop_volume_half_efficiency"] = bool(loop_half.get("should_loop", false)) and is_equal_approx(float(loop_half.get("volume", 0.0)), 0.5)

	# Loop volume with the efficiency key absent (folds to 1.0).
	var loop_default: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state({"has_target": true}, false)
	proof["loop_volume_default_efficiency"] = bool(loop_default.get("should_loop", false)) and is_equal_approx(float(loop_default.get("volume", 0.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretAmbientSoundLoopProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
