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

	# --- Turret targetPosition(pos) call (N2266): the control()
	# shootp overload calls it (Turret.java:398,
	# `targetPosition(pos);`) but N2264 deferred it -- the shootp
	# arm only reported target_position_deferred because the call
	# needs hasAmmo / peekAmmo plus Predict.intercept.
	# TurretBuild.targetPosition(Posc pos)
	# (Turret.java:453-471):
	# `public void targetPosition(Posc pos){`
	# `if(!hasAmmo() || pos == null) return;`
	# `BulletType bullet = peekAmmo();`
	# `var offset = Tmp.v1.setZero();`
	# `if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){`
	# `offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta);`
	# `}`
	# `if(predictTarget && bullet.speed >= 0.01f){`
	# `targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));`
	# `}else{`
	# `targetPos.set(pos);`
	# `}`
	# `if(targetPos.isZero()){`
	# `targetPos.set(pos);`
	# `}`
	# The intercept is the Position overload (Predict.java:
	# `public static Vec2 intercept(Position src, Position dst,
	# float offsetx, float offsety, float v){`): the target's
	# per-frame displacement (Hitboxc deltaX/deltaY) is the
	# velocity, the turret building is not a Hitboxc so no
	# shooter velocity is subtracted, and the float overload
	# divides the displacement by Time.delta (`dstvx /=
	# Time.delta;`) before solving the quadratic for the
	# smallest positive root, else the current position
	# (SourcePredictState.source_predict_intercept_state,
	# N2122). Duo pins: `public boolean accurateDelay = true;`
	# (Turret.java:78) but `public boolean moveWhileCharging =
	# true;` (:80), so the offset branch is OFF for duo;
	# `public boolean predictTarget = true;` (:105); duo copper
	# is `new BasicBulletType(2.5f, 9)` (Blocks.java:3260, speed
	# 2.5, damage 9) so the `bullet.speed >= 0.01f` gate is on
	# and the intercept runs; `shoot = new ShootAlternate(3.5f);`
	# (Blocks.java:3299) with `public float firstShotDelay = 0;`
	# (ShootPattern.java:11), so even the accurateDelay offset
	# would be zero for duo. There is NO driver tick: control()
	# is event-driven (the N2264 precedent, N2248) -- the logic
	# executor does not exist in the driver yet, so the pure
	# function is called directly and waits for the executor
	# slice to wire the :398 arm. The direct pure-function
	# calls pin the call behind the driver observables below:
	# no ammo keeps the current targetPos / a null pos keeps
	# it / no prediction uses the pos / a slow bullet uses the
	# pos / the intercept leads a target moving away / a zero
	# intercept falls back to the pos / the accurateDelay
	# offset shifts the intercept when the turret cannot move
	# while charging / the duo offset is zero so the intercept
	# is unchanged / the duo live case aims from the placed
	# duo's world position with copper speed 2.5.

	# The direct pure-function calls pin the call behind the
	# driver observables below. All calls use the turret at the
	# origin (0, 0) unless noted; the target moves at 2/tick
	# away from the turret along +x; the current targetPos is
	# (5, 5) so a kept value is distinguishable from a set one.
	var direct_no_ammo: Dictionary = turret_build_state.source_turret_target_position_control_state(false, {"x": 100.0, "y": 50.0}, true, 2.0, 0.0, true, true, 0.0, 1.0, true, 2.5, 0.0, 0.0, {"x": 5.0, "y": 5.0})
	var direct_null_pos: Dictionary = turret_build_state.source_turret_target_position_control_state(true, {}, true, 2.0, 0.0, true, true, 0.0, 1.0, true, 2.5, 0.0, 0.0, {"x": 5.0, "y": 5.0})
	var direct_no_predict: Dictionary = turret_build_state.source_turret_target_position_control_state(true, {"x": 100.0, "y": 50.0}, true, 2.0, 0.0, true, true, 0.0, 1.0, false, 2.5, 0.0, 0.0, {"x": 5.0, "y": 5.0})
	var direct_slow_bullet: Dictionary = turret_build_state.source_turret_target_position_control_state(true, {"x": 100.0, "y": 50.0}, true, 2.0, 0.0, true, true, 0.0, 1.0, true, 0.005, 0.0, 0.0, {"x": 5.0, "y": 5.0})
	var direct_intercept: Dictionary = turret_build_state.source_turret_target_position_control_state(true, {"x": 100.0, "y": 0.0}, true, 2.0, 0.0, true, false, 0.0, 1.0, true, 2.5, 0.0, 0.0, {"x": 5.0, "y": 5.0})
	var direct_zero: Dictionary = turret_build_state.source_turret_target_position_control_state(true, {"x": 0.0, "y": 0.0}, true, 1.0, 0.0, true, true, 0.0, 1.0, true, 2.5, 0.0, 0.0, {"x": 5.0, "y": 5.0})
	var direct_offset: Dictionary = turret_build_state.source_turret_target_position_control_state(true, {"x": 100.0, "y": 0.0}, true, 2.0, 0.0, true, false, 30.0, 1.0, true, 2.5, 0.0, 0.0, {"x": 5.0, "y": 5.0})
	var direct_duo_offset: Dictionary = turret_build_state.source_turret_target_position_control_state(true, {"x": 100.0, "y": 0.0}, true, 2.0, 0.0, true, true, 30.0, 1.0, true, 2.5, 0.0, 0.0, {"x": 5.0, "y": 5.0})

	# No ammo keeps the current targetPos -- directly (Java
	# returns early at :454, `if(!hasAmmo() || pos == null)
	# return;`, so targetPos is never touched).
	var no_ammo_pos: Dictionary = direct_no_ammo.get("target_pos", {})
	proof["tgt_pos_no_ammo_keeps"] = float(no_ammo_pos.get("x", -1.0)) == 5.0 and float(no_ammo_pos.get("y", -1.0)) == 5.0
	# A null pos keeps the current targetPos -- directly (the
	# same early return at :454; the caller passes an empty
	# dict for a null Posc).
	var null_pos: Dictionary = direct_null_pos.get("target_pos", {})
	proof["tgt_pos_null_pos_keeps"] = float(null_pos.get("x", -1.0)) == 5.0 and float(null_pos.get("y", -1.0)) == 5.0
	# No prediction uses the pos -- directly (predictTarget
	# false takes the else branch at :467-468,
	# `targetPos.set(pos);`).
	var no_predict_pos: Dictionary = direct_no_predict.get("target_pos", {})
	proof["tgt_pos_no_predict_uses_pos"] = float(no_predict_pos.get("x", -1.0)) == 100.0 and float(no_predict_pos.get("y", -1.0)) == 50.0
	# A slow bullet uses the pos -- directly (bullet.speed
	# 0.005 < 0.01f takes the else branch at :467-468; the
	# gate is strict >= at :464).
	var slow_pos: Dictionary = direct_slow_bullet.get("target_pos", {})
	proof["tgt_pos_slow_bullet_uses_pos"] = float(slow_pos.get("x", -1.0)) == 100.0 and float(slow_pos.get("y", -1.0)) == 50.0
	# The intercept leads a target moving away -- directly
	# (turret at (0, 0), target at (100, 0) moving +2/tick,
	# copper speed 2.5: a = 4 - 6.25 = -2.25, b = 400,
	# c = 10000, disc = 250000, smallest positive root
	# t = 200, so the intercept is (100 + 2 * 200, 0) =
	# (500, 0), ahead of the target).
	var intercept_pos: Dictionary = direct_intercept.get("target_pos", {})
	proof["tgt_pos_intercept_leads"] = float(intercept_pos.get("x", -1.0)) == 500.0 and float(intercept_pos.get("y", -1.0)) == 0.0
	# A zero intercept falls back to the pos -- directly
	# (target at (0, 0): the intercept stays (0, 0), so
	# `if(targetPos.isZero()){ targetPos.set(pos); }` at
	# :470-472 fires and the result is the pos).
	var zero_pos: Dictionary = direct_zero.get("target_pos", {})
	proof["tgt_pos_zero_intercept_falls_back"] = float(zero_pos.get("x", -1.0)) == 0.0 and float(zero_pos.get("y", -1.0)) == 0.0
	# The accurateDelay offset shifts the intercept -- directly
	# (accurateDelay true, moveWhileCharging false, Hitboxc
	# delta (2, 0), firstShotDelay 30, time_delta 1.0: the
	# offset is (60, 0), so the intercept runs from (160, 0):
	# a = -2.25, b = 640, c = 25600, disc = 640000,
	# t = 320, intercept (160 + 2 * 320, 0) = (800, 0)).
	var offset_pos: Dictionary = direct_offset.get("target_pos", {})
	proof["tgt_pos_accurate_delay_offset"] = float(offset_pos.get("x", -1.0)) == 800.0 and float(offset_pos.get("y", -1.0)) == 0.0
	# The duo offset is zero -- directly (accurateDelay true
	# but moveWhileCharging true, so the :460 branch is off
	# even with firstShotDelay 30; the intercept is the same
	# (500, 0) as without the offset).
	var duo_offset_pos: Dictionary = direct_duo_offset.get("target_pos", {})
	proof["tgt_pos_duo_offset_zero"] = float(duo_offset_pos.get("x", -1.0)) == 500.0 and float(duo_offset_pos.get("y", -1.0)) == 0.0

	# One duo segment, live on the driver: the aim point is
	# computed from the placed duo's real world position with
	# the duo catalog pins (copper speed 2.5, predictTarget
	# true, accurateDelay true, moveWhileCharging true,
	# firstShotDelay 0).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["duo"], cell)
	# The raw Sprite2D node never passes through the texture
	# path (SourceTextureRuntimeState.configure_block_sprite),
	# which is what assigns a placed block its world position
	# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
	# so without this the segment sits at the origin (0, 0)
	# and the turret-centred query cannot be distinguished
	# from an origin-centred one. Seed the position exactly
	# the way the game does (the N2211 proof lesson).
	segment.position = game.source_block_sprite_base_position(blocks_by_id["duo"], cell)

	var turret_x: float = segment.position.x
	var turret_y: float = segment.position.y
	var live: Dictionary = turret_build_state.source_turret_target_position_control_state(true, {"x": turret_x + 100.0, "y": turret_y}, true, 2.0, 0.0, true, true, 0.0, 1.0, true, 2.5, turret_x, turret_y, {"x": 5.0, "y": 5.0})
	var live_pos: Dictionary = live.get("target_pos", {})
	proof["tgt_pos_duo_live"] = float(live_pos.get("x", -1.0)) == turret_x + 500.0 and float(live_pos.get("y", -1.0)) == turret_y

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretTargetPositionControlProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
