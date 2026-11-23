extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceLaserTurretBuildPortBridge.gd")
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

	# --- LaserTurretBuild.updateTile() LEG 1 (N2372):
	# LaserTurretBuild.updateTile()
	# (LaserTurret.java:67-89) is the whole bullets.any()
	# branch: prune dead bullet entries
	# (`bullets.removeAll(b -> !b.bullet.isAdded() ||
	# b.bullet.type == null || b.life <= 0f || b.bullet.owner
	# != this);`), then for each survivor move its bullet
	# to the rotated muzzle offset (`Angles.trnsx/trnsy`,
	# 3-arg overloads, rotation - 90), set its rotation /
	# position, refresh its time (`lifetime *
	# optimalLifeFract`) and keepAlive, decay its life
	# (`Time.delta * timeScale / Math.max(efficiency,
	# 0.00001f)`), then set wasShooting/heat/curRecoil.
	# Leg 2 (the else-if reloadCounter > 0 branch,
	# LaserTurret.java:90-108) is a LATER slice; leg 1
	# returns the branch flag "reload_branch": "bullets"
	# (leg 2 later returns "coolant"|"edelta"). The
	# bullets seq arrives as an explicit Array of entry
	# dicts (the N2330 param precedent); the input array
	# is never mutated. NO driver tick line: a pure
	# function. The proof calls the pure function with
	# synthetic scalar inputs (no live tick).
	# Rotation 0, building at (100, 100), shoot offset
	# (0, 0): the live entry at (1, 2) with rotation 30
	# lands its bullet at (102, 99) -- Vector2(1, 2)
	# rotated by -90 degrees is (2, -1).

	var live_bullet: Dictionary = {"is_added": true, "type_null": false, "owner_is_self": true, "time": 5.0, "lifetime": 100.0, "type_optimal_life_fract": 0.5, "keep_alive": false, "rotation": 0.0, "x": 0.0, "y": 0.0}
	var live_entry: Dictionary = {"x": 1.0, "y": 2.0, "rotation": 30.0, "life": 10.0, "bullet": live_bullet}
	var dead_not_added: Dictionary = {"x": 0.0, "y": 0.0, "rotation": 0.0, "life": 10.0, "bullet": {"is_added": false, "type_null": false, "owner_is_self": true, "time": 5.0, "lifetime": 100.0, "type_optimal_life_fract": 0.5, "keep_alive": false, "rotation": 0.0, "x": 0.0, "y": 0.0}}
	var dead_no_life: Dictionary = {"x": 0.0, "y": 0.0, "rotation": 0.0, "life": 0.0, "bullet": {"is_added": true, "type_null": false, "owner_is_self": true, "time": 5.0, "lifetime": 100.0, "type_optimal_life_fract": 0.5, "keep_alive": false, "rotation": 0.0, "x": 0.0, "y": 0.0}}
	var dead_no_type: Dictionary = {"x": 0.0, "y": 0.0, "rotation": 0.0, "life": 10.0, "bullet": {"is_added": true, "type_null": true, "owner_is_self": true, "time": 5.0, "lifetime": 100.0, "type_optimal_life_fract": 0.5, "keep_alive": false, "rotation": 0.0, "x": 0.0, "y": 0.0}}
	var dead_not_owner: Dictionary = {"x": 0.0, "y": 0.0, "rotation": 0.0, "life": 10.0, "bullet": {"is_added": true, "type_null": false, "owner_is_self": false, "time": 5.0, "lifetime": 100.0, "type_optimal_life_fract": 0.5, "keep_alive": false, "rotation": 0.0, "x": 0.0, "y": 0.0}}
	var entries: Array = [live_entry, dead_not_added, dead_no_life, dead_no_type, dead_not_owner]
	var ticked: Dictionary = bridge.source_laser_turret_build_update_tile_leg1_state(entries, 100.0, 100.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.25, 0.5)
	var kept: Array = ticked.get("bullets", [])

	# All four dead entries are pruned; only the live one survives.
	proof["prunes_dead_bullets"] = kept.size() == 1

	# The survivor keeps its entry fields.
	var survivor: Dictionary = kept[0] if kept.size() == 1 else {}
	proof["keeps_live_bullets"] = is_equal_approx(float(survivor.get("x", -1.0)), 1.0) and is_equal_approx(float(survivor.get("y", -1.0)), 2.0) and is_equal_approx(float(survivor.get("rotation", -1.0)), 30.0)

	# Its bullet moves to the rotated muzzle offset (102, 99) at angle 30.
	var bullet: Dictionary = survivor.get("bullet", {})
	proof["updates_entry_bullet_position"] = is_equal_approx(float(bullet.get("x", -1.0)), 102.0) and is_equal_approx(float(bullet.get("y", -1.0)), 99.0) and is_equal_approx(float(bullet.get("rotation", -1.0)), 30.0)

	# Its bullet time refreshes to lifetime * optimalLifeFract (100 * 0.5 = 50) and keepAlive sets.
	proof["refreshes_bullet_time_and_keep_alive"] = is_equal_approx(float(bullet.get("time", -1.0)), 50.0) and bool(bullet.get("keep_alive", false))

	# Its life decays by delta * timeScale / max(efficiency, 0.00001) = 1 * 1 / 1 = 1: 10 -> 9.
	proof["decays_entry_life"] = is_equal_approx(float(survivor.get("life", -1.0)), 9.0)

	# A bullet around sets wasShooting, heat and curRecoil to 1 and takes the bullets branch.
	proof["sets_was_shooting_heat_recoil_when_bullets"] = bool(ticked.get("was_shooting", false)) and is_equal_approx(float(ticked.get("heat", -1.0)), 1.0) and is_equal_approx(float(ticked.get("cur_recoil", -1.0)), 1.0) and String(ticked.get("reload_branch", "")) == "bullets"

	# No bullets at all: nothing shoots, heat/curRecoil pass through, the reload branch is next.
	var idle: Dictionary = bridge.source_laser_turret_build_update_tile_leg1_state([], 100.0, 100.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.25, 0.5)
	proof["passes_through_when_no_bullets"] = Array(idle.get("bullets", [1])).is_empty() and not bool(idle.get("was_shooting", true)) and is_equal_approx(float(idle.get("heat", -1.0)), 0.25) and is_equal_approx(float(idle.get("cur_recoil", -1.0)), 0.5) and String(idle.get("reload_branch", "")) == "reload"

	# Each result carries ONLY its five keys.
	proof["returns_only_five_keys"] = ticked.size() == 5 and idle.size() == 5

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaserTurretUpdateTileLeg1Proof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
