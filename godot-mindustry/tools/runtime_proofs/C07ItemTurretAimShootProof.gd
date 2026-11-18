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

	# --- ItemTurret aim + reload + shoot (N2250): the duo half
	# of TurretBuild.updateTile() (Turret.java:490-615).
	# ItemTurret does NOT override updateTile
	# (`public class ItemTurret extends Turret{`,
	# ItemTurret.java:23 -- it only overrides ammo), so the whole
	# aim / reload / shoot lives on the plain TurretBuild,
	# following the N2240 PointDefense precedent. The reload
	# charges every tick (`reloadCounter += delta() *
	# ammoReloadMultiplier() * baseReloadSpeed();` /
	# `reloadCounter = Math.min(reloadCounter, reload);`,
	# Turret.java:719-724 -- the cap lives here, on the plain
	# TurretBuild). The aim/shoot half runs only with a valid
	# target (`if(validateTarget()){`, Turret.java:573 -- the
	# findTarget / validateTarget acquisition waits for its own
	# slice, so the driver treats the frame's has_target as the
	# verdict and the proof stamps target + has_target directly).
	# targetPosition (`targetPosition(target);`,
	# Turret.java:581) uses Predict.intercept when
	# `predictTarget && bullet.speed >= 0.01f`
	# (Turret.java:464-465) -- the deterministic quadratic
	# (Predict.java:87-104). `angleTo` is Position.angleTo ->
	# Angles.angle, i.e. `Mathf.atan2(x2 - x, y2 - y) *
	# Mathf.radDeg` normalized to [0, 360)
	# (Angles.java:56-59) -- atan2(dx, dy), 0 degrees is +Y.
	# turnToTarget is `rotation = Angles.moveToward(rotation,
	# targetRot, rotateSpeed * delta() * potentialEfficiency)`
	# (Turret.java:665-667). The shoot gate
	# (`if(!alwaysShooting && Angles.angleDist(rotation,
	# targetRot) < shootCone && canShoot){`, Turret.java:599)
	# is STRICT `<` shootCone, and canShoot is
	# `within(target, range() + hitSize/1.9)`
	# (Turret.java:585 -- Position.within is dst2 <
	# range*range, STRICT <). updateShooting fires only when
	# reloaded, not charging, and warmed up
	# (`if(reloadCounter >= reload && !charging() &&
	# shootWarmup >= minWarmup){`, Turret.java:733) then resets
	# with modulo (`reloadCounter %= reload;`,
	# Turret.java:738 -- NOT `= 0`). The shot consumes ammo
	# once (`if(consumeAmmoOnce){ useAmmo(); }`,
	# Turret.java:771-773 -- `entry.amount -= ammoPerShot;` /
	# `if(entry.amount <= 0) ammo.pop();` / `totalAmmo -=
	# ammoPerShot;` / `totalAmmo = Math.max(totalAmmo, 0);`,
	# Turret.java:680-690) and advances the alternate barrel
	# (`}, () -> barrelCounter++);`, Turret.java:770 --
	# ShootAlternate (Blocks.java:3300, barrels 2). The
	# shoot event carries the bullet origin (`bulletX = x +
	# Angles.trnsx(rotation - 90, shootX, shootY),`,
	# Turret.java:744). `rotation` is the float turret
	# rotation, default 90 (`public float rotation = 90;`,
	# BaseTurret.java:114), and `reloadCounter` is the float
	# on ReloadTurretBuild (`public float reloadCounter;`,
	# ReloadTurret.java:26). The per-def duo overrides are
	# range 160, rotateSpeed 10, reload 20, shootCone 15,
	# shootY 3, inaccuracy 2 (Blocks.java:3257-3324), ammo
	# copper/graphite/silicon with reloadMultiplier 1.0/0.8/1.5
	# and rangeChange 0/16/0, copper bullet speed 2.5.
	# Eight segments, one shared driver tick per phase: A
	# rotates toward a north target, B has no target, C has
	# an out-of-range target that is never acquired, D has
	# its reload pre-charged and shoots in the cone, E shoots
	# and consumes exactly one copper ammo, F shoots and its
	# event carries the bullet origin, G leads a moving target
	# through Predict.intercept, H is charging so it never
	# shoots (plus a direct pure-function call for the
	# warmup-low half, which the driver cannot express --
	# it passes minWarmup 0.0). The segments sit 48 tiles
	# (384px) apart -- wider than twice the 160 range -- so
	# no segment can see another segment's target.
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
	# every frame (and charges each reload by 1/60, which the
	# pre-charge below overwrites where it matters).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(8):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# A: one target due north (+100 y, dest 0 deg) -- rotation
	# starts at the 90 default and must turn toward 0.
	frames[0]["target"] = {"x": positions[0].x, "y": positions[0].y + 100.0, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[0]["has_target"] = true
	# B: no target at all -- no rotation, no shot.
	# C: one target 200px east -- beyond the 160 range, never
	# acquired (has_target false: findTarget / validateTarget
	# waits for its own slice) -- rotation stays 90, no shot.
	frames[2]["target"] = {"x": positions[2].x + 200.0, "y": positions[2].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[2]["has_target"] = false
	# D: one target due east (+100 x, dest 90 deg, the rotation
	# default -- already inside the 15 deg shoot cone) with
	# the reload pre-charged to 19.99 -- one tick must cap the
	# reload at 20, shoot, and reset it with modulo to 0.
	frames[3]["target"] = {"x": positions[3].x + 100.0, "y": positions[3].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[3]["has_target"] = true
	frames[3]["reload_counter"] = 19.99
	# E: same as D, but with 5 copper ammo -- the shot must
	# consume exactly one (total 5 -> 4, stack amount 5 -> 4).
	frames[4]["target"] = {"x": positions[4].x + 100.0, "y": positions[4].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[4]["has_target"] = true
	frames[4]["reload_counter"] = 19.99
	# F: same as D -- the shoot event must carry the bullet
	# origin (rotation 90, shootX 0, shootY 3 -> (x, y + 3))
	# and the barrel must advance 0 -> 1.
	frames[5]["target"] = {"x": positions[5].x + 100.0, "y": positions[5].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[5]["has_target"] = true
	frames[5]["reload_counter"] = 19.99
	# G: one target 20px north moving east at 2 px/s -- with
	# the copper bullet speed 2.5 the Predict.intercept
	# quadratic gives t = 13.333s, so the predicted position
	# is (x + 26.667, y + 20) and dest is atan2(26.667, 20)
	# = 53.13 deg, not the unled 0 deg.
	frames[6]["target"] = {"x": positions[6].x, "y": positions[6].y + 20.0, "vx": 2.0, "vy": 0.0, "hit_size": 0.0}
	frames[6]["has_target"] = true
	# H: one target due east with the reload pre-charged, but
	# charging -- updateShooting must not fire, and the reload
	# stays capped at 20.
	frames[7]["target"] = {"x": positions[7].x + 100.0, "y": positions[7].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[7]["has_target"] = true
	frames[7]["reload_counter"] = 19.99
	frames[7]["charging"] = true

	# Seed copper ammo for E and G (the stacks are the
	# {"item", "amount"} dicts of
	# SourceTurretAmmoState.selected_turret_ammo_entries;
	# copper reloadMultiplier 1.0 / rangeChange 0 / speed 2.5).
	var stacks_map: Dictionary = game.get("turret_ammo_stacks")
	var totals_map: Dictionary = game.get("turret_total_ammo")
	for index in [4, 6]:
		var ammo_key: String = str(game.call("cell_key", cells[index]))
		stacks_map[ammo_key] = [{"item": "copper", "amount": 5}]
		totals_map[ammo_key] = 5

	# The shooting tick: D, E and F shoot (reload 19.99 + 1/60
	# caps at 20, in cone, in range, not charging, warmed up);
	# H does not (charging); A and G only turn a step.
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(8):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# D: reload capped at 20, shot, modulo reset to 0.
	var shot_d: bool = bool(frames[3].get("shot", false))
	var reload_d: float = float(frames[3].get("reload_counter", -1.0))
	proof["reload_caps_and_shoots_in_cone"] = shot_d and absf(reload_d) < 0.001
	# E: one ammo consumed -- total 5 -> 4, stack 5 -> 4.
	var ammo_key_e: String = str(game.call("cell_key", cells[4]))
	var stacks_e: Array = stacks_map.get(ammo_key_e, [])
	var total_e: int = int(totals_map.get(ammo_key_e, -1))
	var amount_e: int = int(stacks_e[stacks_e.size() - 1].get("amount", -1)) if not stacks_e.is_empty() and stacks_e[stacks_e.size() - 1] is Dictionary else -1
	proof["shoot_consumes_one_ammo"] = bool(frames[4].get("shot", false)) and total_e == 4 and amount_e == 4
	# F: the shoot event carries the bullet origin (x, y + 3)
	# at rotation 90 with barrel 0, and the barrel advances.
	var shoot_event_f: Variant = frames[5].get("shoot_event", null)
	var origin_ok: bool = false
	if shoot_event_f is Dictionary:
		# bulletX = x + Angles.trnsx(rotation - 90, shootX,
		# shootY) (Turret.java:744): rotation 90, shootX 0,
		# shootY 3 -> (x + 0, y + 3).
		origin_ok = absf(float(shoot_event_f.get("bullet_x", -999.0)) - positions[5].x) < 0.001 and absf(float(shoot_event_f.get("bullet_y", -999.0)) - (positions[5].y + 3.0)) < 0.001 and absf(float(shoot_event_f.get("rotation", -1.0)) - 90.0) < 0.001 and int(shoot_event_f.get("barrel", -1)) == 0
	proof["shoot_event_carries_bullet_origin"] = bool(frames[5].get("shot", false)) and origin_ok and int(frames[5].get("barrel_counter", -1)) == 1
	# H (charging half): no shot, reload stays capped at 20.
	var reload_h: float = float(frames[7].get("reload_counter", -1.0))
	var charging_no_shot: bool = not bool(frames[7].get("shot", false)) and absf(reload_h - 20.0) < 0.001
	# H (warmup half): the driver passes minWarmup 0.0, so a
	# low warmup can only be shown by calling the pure
	# function directly -- reloaded, in cone, in range, not
	# charging, but shootWarmup 0.0 < minWarmup 0.5: no shot.
	var warmup_frame: Dictionary = {"rotation": 90.0, "reload_counter": 20.0}
	var warmup_target: Dictionary = {"x": positions[7].x + 100.0, "y": positions[7].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	var warmup_result: Dictionary = item_turret_build_state.source_item_turret_aim_shoot_state(warmup_frame, warmup_target, true, 1, positions[7].x, positions[7].y, 1.0 / 60.0, 1.0, 0.0, false, [{"item": "copper", "amount": 5}], 5, 0, 160.0, 10.0, 20.0, 15.0, 0.0, 3.0, 2.0, 1, true, 1.0, 0.0, 2.5, true, 0.5, false, false, 1.0)
	proof["no_shoot_when_charging_or_warmup_low"] = charging_no_shot and not bool(warmup_result.get("shot", true))

	# Phase 2: 29 more 1/60s ticks -- with the shooting tick,
	# A has 30 effective ticks toward the north target: 30
	# ticks * rotateSpeed 10 * delta (1/60 at full efficiency)
	# = 5 deg, so rotation lands at 85. The check is a band
	# (70, 90), not the exact 85, so a small efficiency
	# difference cannot flake it. B and C must still sit at
	# the 90 default; G turns toward the led 53.13 deg dest.
	for tick in range(29):
		turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(8):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var rotation_a: float = float(frames[0].get("rotation", 90.0))
	proof["aim_rotates_toward_target"] = rotation_a < 90.0 and rotation_a > 70.0
	var rotation_b: float = float(frames[1].get("rotation", 90.0))
	proof["aim_no_rotation_without_target"] = absf(rotation_b - 90.0) < 0.001 and not bool(frames[1].get("shot", true))
	var rotation_c: float = float(frames[2].get("rotation", 90.0))
	proof["aim_ignores_out_of_range_target"] = absf(rotation_c - 90.0) < 0.001 and not bool(frames[2].get("shot", true)) and frames[2].get("dest", null) == null
	var dest_g: float = float(frames[6].get("dest", -999.0))
	var target_pos_g: Variant = frames[6].get("target_pos", null)
	var lead_ok: bool = false
	if target_pos_g is Dictionary:
		# The predicted x is 26.667 ahead of the target's
		# current x; the dest is 53.13 deg, not the unled 0.
		lead_ok = float(target_pos_g.get("x", -999.0)) > positions[6].x + 10.0 and absf(float(target_pos_g.get("y", -999.0)) - (positions[6].y + 20.0)) < 0.001
	var rotation_g: float = float(frames[6].get("rotation", 90.0))
	proof["predict_intercept_leads_moving_target"] = lead_ok and absf(dest_g - 53.13) < 0.5 and rotation_g < 90.0 and rotation_g > 70.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemTurretAimShootProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
