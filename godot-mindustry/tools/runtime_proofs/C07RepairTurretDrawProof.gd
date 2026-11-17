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

	# --- RepairTurret draw() body (N2225):
	# RepairPointBuild.draw() (`public void draw(){`,
	# RepairTurret.java:164) draws the base rect at (x, y) with
	# no rotation (`Draw.rect(baseRegion, x, y);`,
	# RepairTurret.java:165), sets the z-layer
	# (`Draw.z(Layer.turret);`, RepairTurret.java:167,
	# Layer.turret = 50, Layer.java:48, `turret = 50,`),
	# draws the shadow and the region rect at rotation - 90
	# (`Drawf.shadow(region, x - (size / 2f), y - (size / 2f),
	# rotation - 90);`, RepairTurret.java:168, and
	# `Draw.rect(region, x, y, rotation - 90);`,
	# RepairTurret.java:169), then calls drawBeam
	# (RepairTurret.java:171-173) -- N2219, NOT this slice.
	# The shadow offset quirk stays as Java wrote it: `size /
	# 2f` is subtracted directly on world coords, NOT
	# tilesize-scaled -- size is Block.size in tiles (class
	# default 1, Block.java:215, `public int size = 1;`;
	# repair-point has no override, Blocks.java:6386-6394;
	# repair-turret 2, Blocks.java:6398, `size = 2;`), so
	# repair-point offsets 0.5, repair-turret offsets 1.0.
	# rotation defaults to 90 (the field init `public float
	# strength, rotation = 90;`, RepairTurret.java:156). The
	# proof calls the pure function directly at the sample
	# position x=100, y=200 (the N2224/N2219 pattern); the
	# driver tick line stamps the same four keys live every
	# tick (SourceRepairTurretBuildState.gd driver, after the
	# N2219 beam call).

	# Draw rotation at the class-default rotation 90: 90 - 90
	# = 0.0.
	var rotation_default: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 90.0, 1.0)
	proof["draw_rotation_default"] = is_equal_approx(float(rotation_default.get("draw_rotation", -999.0)), 0.0)

	# Draw rotation at rotation 0: 0 - 90 = -90.0.
	var rotation_zero: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 0.0, 1.0)
	proof["draw_rotation_zero"] = is_equal_approx(float(rotation_zero.get("draw_rotation", -999.0)), -90.0)

	# Draw rotation at a half turn (rotation 180): 180 - 90
	# = 90.0.
	var rotation_half_turn: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 180.0, 1.0)
	proof["draw_rotation_half_turn"] = is_equal_approx(float(rotation_half_turn.get("draw_rotation", -999.0)), 90.0)

	# Shadow at the repair-point def (size 1): (100 - 0.5,
	# 200 - 0.5) = (99.5, 199.5); the base position stays
	# (100, 200) in the same returned dict.
	var shadow_point: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 90.0, 1.0)
	proof["draw_shadow_repair_point"] = (shadow_point.get("shadow_position", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(99.5, 199.5)) and (shadow_point.get("base_position", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(100, 200))

	# Shadow at the repair-turret def (size 2): (100 - 1.0,
	# 200 - 1.0) = (99.0, 199.0).
	var shadow_turret: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 90.0, 2.0)
	proof["draw_shadow_repair_turret"] = (shadow_turret.get("shadow_position", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(99.0, 199.0))

	# Z-layer is Layer.turret = 50 at every def.
	var z_layer: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 90.0, 2.0)
	proof["draw_z_layer_turret"] = is_equal_approx(float(z_layer.get("z_layer", -1.0)), 50.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretDrawProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
