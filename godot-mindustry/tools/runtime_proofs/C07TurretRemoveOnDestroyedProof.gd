extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret remove() + onDestroyed() (N2350):
	# TurretBuild.remove() (Turret.java:303-308) is the
	# lifecycle stop:
	# `@Override`
	# `public void remove(){`
	# `super.remove();`
	# `if(soundLoop != null){`
	# `soundLoop.stop();`
	# `}`
	# `}`
	# and TurretBuild.onDestroyed() (Turret.java:311-317)
	# is the same stop on destruction:
	# `@Override`
	# `public void onDestroyed(){`
	# `super.onDestroyed();`
	# `if(soundLoop != null){`
	# `soundLoop.stop();`
	# `}`
	# `}`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). Both stop the sound loop when it is
	# non-null and do nothing when it is null; the two bodies
	# differ only in the super call. soundLoop is the
	# TurretBuild field (Turret.java:298) and arrives as the
	# explicit bool has_sound_loop (the minRange has_ammo
	# precedent -- a null check carried as an explicit bool;
	# GDScript has no SoundLoop object here).
	# super.remove()/super.onDestroyed() are the Building
	# base -- deferred, not ported. NO driver tick line:
	# both are pure lifecycle functions the engine calls,
	# not per-tick writes. NO SoundLoop playback: both
	# functions only return the stopped flag, never real
	# audio. The proof calls the pure functions with
	# synthetic frames (no live tick).

	# Remove stops a live loop.
	var removed: Dictionary = turret_build_state.source_turret_remove_state({}, true)
	proof["remove_stops_loop"] = removed.get("sound_loop_stopped", false) == true

	# Remove is a no-op when the loop is null.
	var removed_null: Dictionary = turret_build_state.source_turret_remove_state({}, false)
	proof["remove_null_loop_noop"] = removed_null.get("sound_loop_stopped", true) == false

	# The remove result carries ONLY the one sound_loop_stopped key.
	proof["remove_returns_only_one_key"] = removed.size() == 1

	# The frame passed in is not mutated by the call.
	var marked: Dictionary = {"marker": 7}
	turret_build_state.source_turret_remove_state(marked, true)
	proof["remove_input_unmutated"] = marked.get("marker", -1) == 7 and marked.size() == 1

	# onDestroyed stops a live loop.
	var destroyed: Dictionary = turret_build_state.source_turret_on_destroyed_state({}, true)
	proof["on_destroyed_stops_loop"] = destroyed.get("sound_loop_stopped", false) == true

	# onDestroyed is a no-op when the loop is null.
	var destroyed_null: Dictionary = turret_build_state.source_turret_on_destroyed_state({}, false)
	proof["on_destroyed_null_loop_noop"] = destroyed_null.get("sound_loop_stopped", true) == false

	# The onDestroyed result carries ONLY the one sound_loop_stopped key.
	proof["on_destroyed_returns_only_one_key"] = destroyed.size() == 1

	# The frame passed in is not mutated by the call.
	var marked_destroyed: Dictionary = {"marker": 7}
	turret_build_state.source_turret_on_destroyed_state(marked_destroyed, true)
	proof["on_destroyed_input_unmutated"] = marked_destroyed.get("marker", -1) == 7 and marked_destroyed.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretRemoveOnDestroyedProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
