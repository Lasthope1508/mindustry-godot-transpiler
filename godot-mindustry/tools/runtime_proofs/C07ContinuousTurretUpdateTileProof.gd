extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceContinuousTurretBuildPortBridge.gd")
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

	# --- ContinuousTurretBuild.updateTile() (N2362):
	# ContinuousTurretBuild.updateTile()
	# (ContinuousTurret.java:86-101) prunes bullets whose
	# bullet is not added, whose type is null, or whose
	# owner is not this turret:
	# `@Override`
	# `public void updateTile(){`
	# `super.updateTile();`
	# `bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.bullet.owner != this);`
	# `if(bullets.any()){`
	# `for(var entry : bullets){`
	# `updateBullet(entry);`
	# `wasShooting = true;`
	# `heat = 1f;`
	# `curRecoil = recoil;`
	# `}`
	# `}`
	# on `public class ContinuousTurretBuild extends TurretBuild{`
	# (ContinuousTurret.java:38). super.updateTile() is the
	# TurretBuild base tick (Turret.java:490): it resets
	# wasShooting to false (Turret.java:517) and decays heat
	# / curRecoil toward 0, so was_shooting is true exactly
	# when pruned bullets remain. updateBullet(entry) is a
	# CALLEE -- NOT ported in this slice (batch 13+). The
	# proof calls the pure function with synthetic bullet
	# entries (no live tick); "mark" is a proof-only order
	# marker carried through untouched.

	# One live entry plus one dead entry per prune reason:
	# not added, null type, other owner.
	var mixed: Array = [
		{"is_added": true, "type_null": false, "owner_is_self": true, "mark": 1},
		{"is_added": false, "type_null": false, "owner_is_self": true, "mark": 2},
		{"is_added": true, "type_null": true, "owner_is_self": true, "mark": 3},
		{"is_added": true, "type_null": false, "owner_is_self": false, "mark": 4},
	]
	var pruned_result: Dictionary = bridge.source_continuous_turret_build_update_tile_state(mixed, 2.5, 0.3, 0.1)
	var pruned: Array = pruned_result.get("bullets", [])
	proof["dead_bullets_pruned"] = pruned.size() == 1 and int(pruned[0].get("mark", -1)) == 1

	# Two live entries stay, in order.
	var live: Array = [
		{"is_added": true, "type_null": false, "owner_is_self": true, "mark": 1},
		{"is_added": true, "type_null": false, "owner_is_self": true, "mark": 2},
	]
	var live_result: Dictionary = bridge.source_continuous_turret_build_update_tile_state(live, 2.5, 0.3, 0.1)
	var kept: Array = live_result.get("bullets", [])
	proof["live_bullets_kept"] = kept.size() == 2 and int(kept[0].get("mark", -1)) == 1 and int(kept[1].get("mark", -1)) == 2

	# A surviving bullet sets wasShooting, heat = 1f,
	# curRecoil = recoil.
	proof["shooting_flags_set"] = bool(live_result.get("was_shooting", false)) and is_equal_approx(float(live_result.get("heat", -1.0)), 1.0) and is_equal_approx(float(live_result.get("cur_recoil", -1.0)), 2.5)

	# No surviving bullet: wasShooting stays false and heat /
	# curRecoil keep their input values -- both for an empty
	# list and for an all-dead list.
	var empty_result: Dictionary = bridge.source_continuous_turret_build_update_tile_state([], 2.5, 0.3, 0.1)
	var all_dead: Array = [
		{"is_added": false, "type_null": false, "owner_is_self": true, "mark": 1},
		{"is_added": true, "type_null": true, "owner_is_self": true, "mark": 2},
	]
	var all_dead_result: Dictionary = bridge.source_continuous_turret_build_update_tile_state(all_dead, 2.5, 0.3, 0.1)
	proof["no_bullets_no_flags"] = (
		Array(empty_result.get("bullets", [1])).is_empty()
		and not bool(empty_result.get("was_shooting", true))
		and is_equal_approx(float(empty_result.get("heat", -1.0)), 0.3)
		and is_equal_approx(float(empty_result.get("cur_recoil", -1.0)), 0.1)
		and Array(all_dead_result.get("bullets", [1])).is_empty()
		and not bool(all_dead_result.get("was_shooting", true))
		and is_equal_approx(float(all_dead_result.get("heat", -1.0)), 0.3)
		and is_equal_approx(float(all_dead_result.get("cur_recoil", -1.0)), 0.1)
	)

	# The input array is not mutated: same size, same entries.
	var before_size: int = mixed.size()
	var before_marks: Array = []
	for entry in mixed:
		before_marks.append(int(entry.get("mark", -1)))
	bridge.source_continuous_turret_build_update_tile_state(mixed, 2.5, 0.3, 0.1)
	var after_marks: Array = []
	for entry in mixed:
		after_marks.append(int(entry.get("mark", -1)))
	proof["input_unmutated"] = mixed.size() == before_size and before_marks == after_marks

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousTurretUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
