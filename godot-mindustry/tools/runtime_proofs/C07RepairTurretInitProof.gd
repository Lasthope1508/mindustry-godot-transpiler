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

	# --- RepairTurret init() updateClipRadius (N2226):
	# RepairTurret.init() (`public void init(){`,
	# RepairTurret.java:83) pins the clip radius with one
	# call (`updateClipRadius(repairRadius + tilesize);`,
	# RepairTurret.java:90). The coolant leg (:84-86) and
	# the consumePowerCond leg (:89) are NOT this slice;
	# `super.init();` (:91) is deferred Block.init
	# internals (the N1234 TractorBeamTurret.init()
	# precedent). The Block.updateClipRadius side effect
	# (`clipSize = Math.max(clipSize, this.size * tilesize
	# + radiusInWorldUnits * 2f);`, Block.java:1007) is
	# likewise deferred -- only the call argument,
	# repairRadius + tilesize, is pinned. repairRadius
	# defaults to 50f (`public float repairRadius = 50f;`,
	# RepairTurret.java:32); repair-point 60f
	# (Blocks.java:6389, `repairRadius = 60f;`),
	# repair-turret 145f (Blocks.java:6401, `repairRadius =
	# 145f;`); tilesize is 8 (Vars.java:135, `public static
	# final int tilesize = 8;`). There is NO driver tick
	# line: init() runs once at block init, not per tick
	# (the N2217 / N2224 lifecycle precedent). The proof
	# calls the pure function directly with the per-def
	# params (the N2224/N2225 pattern).

	# Class-default repairRadius 50f: 50 + 8 = 58.0.
	var clip_default: Dictionary = repair_turret_build_state.source_repair_turret_init_state(50.0, 8.0)
	proof["clip_radius_default"] = is_equal_approx(float(clip_default.get("clip_radius", -1.0)), 58.0)

	# Repair-point repairRadius 60f: 60 + 8 = 68.0.
	var clip_point: Dictionary = repair_turret_build_state.source_repair_turret_init_state(60.0, 8.0)
	proof["clip_radius_repair_point"] = is_equal_approx(float(clip_point.get("clip_radius", -1.0)), 68.0)

	# Repair-turret repairRadius 145f: 145 + 8 = 153.0.
	var clip_turret: Dictionary = repair_turret_build_state.source_repair_turret_init_state(145.0, 8.0)
	proof["clip_radius_repair_turret"] = is_equal_approx(float(clip_turret.get("clip_radius", -1.0)), 153.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretInitProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
