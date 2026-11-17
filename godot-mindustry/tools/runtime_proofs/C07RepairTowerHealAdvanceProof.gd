extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
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

	# --- RepairTower heal advance (N2228):
	# The remainder of RepairTowerBuild.updateTile()
	# (RepairTower.java:69-85): the suppression gate
	# (`if(checkSuppression()){` / `warmup = 0f;` /
	# `return;`, :69-72), the heal loop (`boolean any =
	# false;` / `if(efficiency > 0){` / `for(var target :
	# targets){` / `if(target.damaged()){` /
	# `target.heal(healAmount * edelta());` / `any =
	# true;`, :74-82), the warmup lerp (`warmup =
	# Mathf.lerpDelta(warmup, any ? efficiency : 0f,
	# 0.08f);`, :84) and the totalProgress advance
	# (`totalProgress += Time.delta / circleSpeed;`,
	# :85). damaged() is `health < maxHealth - 0.001f`
	# (HealthComp.java:47-49); the heal adds `healAmount
	# * edelta()` and clamps at maxHealth
	# (HealthComp.java:109-112). edelta() is efficiency
	# * delta() (BuildingComp.java:1927-1928). The proof
	# calls the pure function
	# source_repair_tower_heal_advance_state(frame,
	# targets, heal_amount, delta, circle_speed,
	# suppressed) directly with synthetic frames (the
	# N2213 precedent -- the driver tick line lands with
	# GREEN). Per-def healAmount 1.5f (Blocks.java:6580);
	# circleSpeed 120f (RepairTower.java:23); delta 1/60
	# is one tick, so one healed target gains 1.5 * 1.0
	# * (1/60) = 0.025, warmup lerps by 0.08/60 =
	# 0.0013333 per tick, and totalProgress advances by
	# (1/60)/120 = 0.0001389 per tick.
	var delta: float = 1.0 / 60.0

	# Suppression zeroes warmup: suppressed=true returns
	# early -- warmup 0.0, total_progress unchanged, no
	# heal, any false.
	var frame: Dictionary = {"warmup": 0.5, "total_progress": 2.0, "efficiency": 1.0}
	var targets: Array = [{"id": 1, "health": 50.0, "max_health": 100.0}]
	var result: Dictionary = repair_tower_build_state.source_repair_tower_heal_advance_state(frame, targets, 1.5, delta, 120.0, true)
	proof["suppression_zeroes_warmup"] = bool(result.get("suppressed", false)) and abs(float(result.get("warmup", -1.0)) - 0.0) < 0.0001 and abs(float(result.get("total_progress", -1.0)) - 2.0) < 0.0001 and not bool(result.get("any", true)) and int(result.get("healed_count", -1)) == 0 and abs(float(result.get("heal_amount", -1.0)) - 0.0) < 0.0001 and abs(float((result.get("targets", [{}])[0] as Dictionary).get("health", -1.0)) - 50.0) < 0.001

	# Heals damaged targets: 2 damaged targets, efficiency
	# 1.0 -- each gains 0.025, any true, healed_count 2.
	frame = {"warmup": 0.0, "total_progress": 0.0, "efficiency": 1.0}
	targets = [{"id": 1, "health": 50.0, "max_health": 100.0}, {"id": 2, "health": 80.0, "max_health": 100.0}]
	result = repair_tower_build_state.source_repair_tower_heal_advance_state(frame, targets, 1.5, delta, 120.0, false)
	var healed_targets: Array = result.get("targets", [])
	proof["heal_damaged_targets"] = bool(result.get("any", false)) and int(result.get("healed_count", -1)) == 2 and abs(float(result.get("heal_amount", -1.0)) - 0.025) < 0.001 and abs(float((healed_targets[0] as Dictionary).get("health", -1.0)) - 50.025) < 0.001 and abs(float((healed_targets[1] as Dictionary).get("health", -1.0)) - 80.025) < 0.001 and abs(float(result.get("warmup", -1.0)) - 0.0013333) < 0.0001 and abs(float(result.get("total_progress", -1.0)) - 0.0001389) < 0.0001

	# Clamps at max health: 99.99 + 0.025 stops at 100.0.
	frame = {"warmup": 0.0, "total_progress": 0.0, "efficiency": 1.0}
	targets = [{"id": 3, "health": 99.99, "max_health": 100.0}]
	result = repair_tower_build_state.source_repair_tower_heal_advance_state(frame, targets, 1.5, delta, 120.0, false)
	healed_targets = result.get("targets", [])
	proof["heal_clamps_at_max"] = bool(result.get("any", false)) and abs(float((healed_targets[0] as Dictionary).get("health", -1.0)) - 100.0) < 0.001

	# Undamaged target skipped: health 100.0 is not
	# damaged (`health < maxHealth - 0.001f` fails), so
	# nothing heals, any false, warmup decays toward 0.
	frame = {"warmup": 0.5, "total_progress": 0.0, "efficiency": 1.0}
	targets = [{"id": 4, "health": 100.0, "max_health": 100.0}]
	result = repair_tower_build_state.source_repair_tower_heal_advance_state(frame, targets, 1.5, delta, 120.0, false)
	healed_targets = result.get("targets", [])
	proof["undamaged_target_skipped"] = not bool(result.get("any", true)) and int(result.get("healed_count", -1)) == 0 and abs(float((healed_targets[0] as Dictionary).get("health", -1.0)) - 100.0) < 0.001 and abs(float(result.get("warmup", -1.0)) - 0.4993333) < 0.0001 and abs(float(result.get("total_progress", -1.0)) - 0.0001389) < 0.0001

	# Blocked without power: efficiency 0 heals nothing
	# and reports heal_amount 0.0; warmup still decays.
	frame = {"warmup": 0.5, "total_progress": 0.0, "efficiency": 0.0}
	targets = [{"id": 5, "health": 50.0, "max_health": 100.0}]
	result = repair_tower_build_state.source_repair_tower_heal_advance_state(frame, targets, 1.5, delta, 120.0, false)
	healed_targets = result.get("targets", [])
	proof["efficiency_zero_no_heal"] = not bool(result.get("any", true)) and int(result.get("healed_count", -1)) == 0 and abs(float(result.get("heal_amount", -1.0)) - 0.0) < 0.0001 and abs(float((healed_targets[0] as Dictionary).get("health", -1.0)) - 50.0) < 0.001 and abs(float(result.get("warmup", -1.0)) - 0.4993333) < 0.0001

	# Warmup lerps to efficiency: warmup 0, any true,
	# efficiency 1.0 -- lerpDelta(0, 1, 0.08, delta).
	frame = {"warmup": 0.0, "total_progress": 0.0, "efficiency": 1.0}
	targets = [{"id": 6, "health": 50.0, "max_health": 100.0}]
	result = repair_tower_build_state.source_repair_tower_heal_advance_state(frame, targets, 1.5, delta, 120.0, false)
	proof["warmup_lerps_to_efficiency"] = abs(float(result.get("warmup", -1.0)) - 0.0013333) < 0.0001

	# Warmup decays with no heal: warmup 0.5, no damaged
	# target -- lerpDelta(0.5, 0, 0.08, delta).
	frame = {"warmup": 0.5, "total_progress": 0.0, "efficiency": 1.0}
	targets = []
	result = repair_tower_build_state.source_repair_tower_heal_advance_state(frame, targets, 1.5, delta, 120.0, false)
	proof["warmup_decays_no_heal"] = not bool(result.get("any", true)) and abs(float(result.get("warmup", -1.0)) - 0.4993333) < 0.0001

	# TotalProgress advances by delta / circleSpeed each
	# tick, and stays put when suppressed.
	frame = {"warmup": 0.0, "total_progress": 3.0, "efficiency": 1.0}
	targets = []
	result = repair_tower_build_state.source_repair_tower_heal_advance_state(frame, targets, 1.5, delta, 120.0, false)
	var advanced: bool = abs(float(result.get("total_progress", -1.0)) - 3.0001389) < 0.0001
	frame = {"warmup": 0.0, "total_progress": 3.0, "efficiency": 1.0}
	result = repair_tower_build_state.source_repair_tower_heal_advance_state(frame, targets, 1.5, delta, 120.0, true)
	proof["total_progress_advances"] = advanced and abs(float(result.get("total_progress", -1.0)) - 3.0) < 0.0001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerHealAdvanceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
