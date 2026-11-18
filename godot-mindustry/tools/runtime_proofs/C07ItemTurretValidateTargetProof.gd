extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const item_turret_build_state := preload("res://src/game/SourceItemTurretBuildState.gd")
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

	# --- ItemTurret validateTarget (N2251): the gate at the top
	# of TurretBuild.updateTile() (`if(!validateTarget()) target =
	# null;`, Turret.java:491) and the aim/shoot branch
	# (`if(validateTarget()){`, Turret.java:573). validateTarget is
	# `return !Units.invalidateTarget(target, canHeal() ?
	# Team.derelict : team, x, y) || controlled() ||
	# logicControlled();` (Turret.java:631-633), and it calls the
	# NO-range overload (`return invalidateTarget(target, team, x,
	# y, Float.MAX_VALUE);`, Units.java:160-162), so the range
	# clause is dead here and the pure function takes NO range
	# param. The four live invalidate clauses (Units.java:151-157)
	# are: target null (`return target == null ||`), same effective
	# team (`(target instanceof Teamc t && t.team() == team) ||`),
	# dead Healthc (`(target instanceof Healthc h && !h.isValid())
	# ||`), untargetable Unit (`(target instanceof Unit u &&
	# !u.targetable(team));`). The effective team is Team.derelict
	# (id 0, Team.java:33) when canHeal() (`return targetHealing &&
	# hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();`,
	# Turret.java:635-637) and the turret team otherwise; the
	# resolution happens at the driver/test, NOT in the pure
	# function. targetHealing defaults false (Turret.java:95) and
	# duo never sets it (Blocks.java:3257-3324), so for duo the
	# effective team is always the turret team. controlled() is
	# `unit.isPlayer()` (Turret.java:441-443) and logicControlled()
	# is `logicControlTime > 0` (Turret.java:445-447): either one
	# rescues the verdict even for a null target, exactly as Java's
	# `||` does. The driver runs the verdict at the head of the duo
	# branch, clears frame["target"] / frame["has_target"] when it
	# is invalid, and feeds it into the aim/shoot target_valid arg
	# (N2250). The frame target dict carries only x/y/vx/vy/hit_size,
	# so the team / health / targetable / controlled bools are
	# stamped in from the frame with vacuous defaults (health_valid
	# / unit_targetable true, same team / controlled /
	# logic_controlled false); a frame with has_target false holds
	# no acquired target, so its target dict (if any) counts as null
	# for the verdict. Eight segments, one shared driver tick: a
	# null target is invalid, a same-team target is invalid, a dead
	# Healthc target is invalid, an untargetable Unit is invalid, a
	# controlled build keeps even an invalid target, a
	# logic-controlled build keeps even an invalid target, a healthy
	# enemy target is valid, and the driver clears an invalid target
	# from the frame. The segments sit 48 tiles (384px) apart --
	# wider than twice the 160 range -- so no segment can see
	# another segment's target.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cells: Array[Vector2i] = [Vector2i(28, 21), Vector2i(76, 21), Vector2i(124, 21), Vector2i(172, 21), Vector2i(220, 21), Vector2i(268, 21), Vector2i(316, 21), Vector2i(364, 21)]
	var segments: Array[Sprite2D] = []
	for cell in cells:
		var segment := Sprite2D.new()
		game.add_child(segment)
		game.call("record_placed_block", segment, blocks_by_id["duo"], cell)
		# The raw Sprite2D nodes never pass through the texture
		# path (SourceTextureRuntimeState.configure_block_sprite),
		# which is what assigns a placed block its world position
		# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
		# so without this every segment sits at the origin (0, 0)
		# and the turret-centred query cannot be distinguished
		# from an origin-centred one. Seed the position exactly
		# the way the game does (the N2211 proof lesson).
		segment.position = game.source_block_sprite_base_position(blocks_by_id["duo"], cell)
		turret_build_state.source_turret_bind_frame_state(segment, blocks_by_id["duo"])
		segments.append(segment)
	var frames: Array[Dictionary] = []
	for segment in segments:
		frames.append(segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {}))
	var positions: Array[Vector2] = []
	for segment in segments:
		positions.append(segment.position)

	# One shared tick wires team_id / cheating / enabled onto
	# every frame (and charges each reload by 1/60, which stays
	# far below the 20 reload, so nothing shoots).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(8):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# 0: no target at all -- null is invalid, nothing is aimed.
	# 1: one target due east (+100 x) on the effective team --
	# invalid, the driver must clear it.
	frames[1]["target"] = {"x": positions[1].x + 100.0, "y": positions[1].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[1]["has_target"] = true
	frames[1]["target_same_team_effective"] = true
	# 2: one target due east that is a dead Healthc -- invalid,
	# the driver must clear it.
	frames[2]["target"] = {"x": positions[2].x + 100.0, "y": positions[2].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[2]["has_target"] = true
	frames[2]["target_health_valid"] = false
	# 3: one target due east that is an untargetable Unit --
	# invalid, the driver must clear it.
	frames[3]["target"] = {"x": positions[3].x + 100.0, "y": positions[3].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[3]["has_target"] = true
	frames[3]["target_unit_targetable"] = false
	# 4: one same-team target due east, but the build is
	# player-controlled -- controlled() rescues the verdict, the
	# driver must NOT clear it and the aim must run (dest 90).
	frames[4]["target"] = {"x": positions[4].x + 100.0, "y": positions[4].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[4]["has_target"] = true
	frames[4]["target_same_team_effective"] = true
	frames[4]["controlled"] = true
	# 5: one dead-Healthc target due east, but the build is
	# logic-controlled -- logicControlled() rescues the verdict,
	# the driver must NOT clear it and the aim must run (dest 90).
	frames[5]["target"] = {"x": positions[5].x + 100.0, "y": positions[5].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[5]["has_target"] = true
	frames[5]["target_health_valid"] = false
	frames[5]["logic_controlled"] = true
	# 6: one healthy enemy target due east -- valid, the aim must
	# run (dest 90) and the target must stay.
	frames[6]["target"] = {"x": positions[6].x + 100.0, "y": positions[6].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[6]["has_target"] = true
	# 7: one same-team target due east -- invalid, the driver must
	# clear it from the frame (target null, has_target false).
	frames[7]["target"] = {"x": positions[7].x + 100.0, "y": positions[7].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[7]["has_target"] = true
	frames[7]["target_same_team_effective"] = true

	# The validating tick: invalid targets are cleared and never
	# aimed at; rescued / healthy targets keep the aim running.
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(8):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# The direct pure-function calls pin the predicate truth table
	# behind the driver observables below.
	var direct_null: Dictionary = item_turret_build_state.source_item_turret_validate_target_state(true, false, true, true, false, false)
	var direct_same_team: Dictionary = item_turret_build_state.source_item_turret_validate_target_state(false, true, true, true, false, false)
	var direct_dead: Dictionary = item_turret_build_state.source_item_turret_validate_target_state(false, false, false, true, false, false)
	var direct_untargetable: Dictionary = item_turret_build_state.source_item_turret_validate_target_state(false, false, true, false, false, false)
	var direct_controlled: Dictionary = item_turret_build_state.source_item_turret_validate_target_state(true, false, true, true, true, false)
	var direct_logic: Dictionary = item_turret_build_state.source_item_turret_validate_target_state(true, false, true, true, false, true)
	var direct_healthy: Dictionary = item_turret_build_state.source_item_turret_validate_target_state(false, false, true, true, false, false)

	# 0: null target -- invalid: no aim (dest null), no shot,
	# rotation stays at the 90 default, target stays null.
	proof["validate_null_target_invalid"] = frames[0].get("target", "x") == null and not bool(frames[0].get("has_target", true)) and frames[0].get("dest", null) == null and not bool(frames[0].get("shot", true)) and absf(float(frames[0].get("rotation", -1.0)) - 90.0) < 0.001 and not bool(direct_null.get("valid", true)) and bool(direct_null.get("target_cleared", false))
	# 1: same-team target -- invalid: cleared, no aim, no shot.
	proof["validate_same_team_invalid"] = frames[1].get("target", "x") == null and not bool(frames[1].get("has_target", true)) and frames[1].get("dest", null) == null and not bool(frames[1].get("shot", true)) and absf(float(frames[1].get("rotation", -1.0)) - 90.0) < 0.001 and not bool(direct_same_team.get("valid", true)) and bool(direct_same_team.get("target_cleared", false))
	# 2: dead Healthc target -- invalid: cleared, no aim, no shot.
	proof["validate_dead_target_invalid"] = frames[2].get("target", "x") == null and not bool(frames[2].get("has_target", true)) and frames[2].get("dest", null) == null and not bool(frames[2].get("shot", true)) and absf(float(frames[2].get("rotation", -1.0)) - 90.0) < 0.001 and not bool(direct_dead.get("valid", true)) and bool(direct_dead.get("target_cleared", false))
	# 3: untargetable Unit -- invalid: cleared, no aim, no shot.
	proof["validate_untargetable_unit_invalid"] = frames[3].get("target", "x") == null and not bool(frames[3].get("has_target", true)) and frames[3].get("dest", null) == null and not bool(frames[3].get("shot", true)) and absf(float(frames[3].get("rotation", -1.0)) - 90.0) < 0.001 and not bool(direct_untargetable.get("valid", true)) and bool(direct_untargetable.get("target_cleared", false))
	# 4: controlled build -- the same-team target is rescued:
	# kept (target present, has_target true) and aimed at
	# (dest 90, the due-east target).
	proof["validate_controlled_saves_invalid_target"] = frames[4].get("target", "x") != null and bool(frames[4].get("has_target", false)) and absf(float(frames[4].get("dest", -999.0)) - 90.0) < 0.001 and bool(direct_controlled.get("valid", false)) and not bool(direct_controlled.get("target_cleared", true))
	# 5: logic-controlled build -- the dead target is rescued:
	# kept and aimed at (dest 90).
	proof["validate_logic_controlled_saves_invalid_target"] = frames[5].get("target", "x") != null and bool(frames[5].get("has_target", false)) and absf(float(frames[5].get("dest", -999.0)) - 90.0) < 0.001 and bool(direct_logic.get("valid", false)) and not bool(direct_logic.get("target_cleared", true))
	# 6: healthy enemy target -- valid: kept and aimed at
	# (dest 90), no shot yet (reload far below 20).
	proof["validate_healthy_enemy_valid"] = frames[6].get("target", "x") != null and bool(frames[6].get("has_target", false)) and absf(float(frames[6].get("dest", -999.0)) - 90.0) < 0.001 and not bool(frames[6].get("shot", true)) and bool(direct_healthy.get("valid", false)) and not bool(direct_healthy.get("target_cleared", true))
	# 7: the driver clears an invalid target from the frame --
	# target null and has_target false after the tick, no aim.
	proof["validate_driver_clears_invalid_target"] = frames[7].get("target", "x") == null and not bool(frames[7].get("has_target", true)) and frames[7].get("dest", null) == null and not bool(frames[7].get("shot", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemTurretValidateTargetProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
