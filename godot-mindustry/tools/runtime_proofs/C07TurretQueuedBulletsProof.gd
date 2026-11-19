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

	# --- Turret queuedBullets counter + charging() gate (N2269):
	# TurretBuild keeps a cross-tick counter of bullets that have
	# been queued to fire but have not fired yet:
	# `public int queuedBullets = 0;` (Turret.java:293). shoot()
	# (Turret.java:741-777) increments it once per bullet the
	# shoot pattern queues: `queuedBullets++;` (:754); when the
	# pattern delay is positive the bullet is deferred:
	# `if(delay > 0f){` `Time.run(delay, () -> {`
	# `bullet(type, xOffset, yOffset, angle, mover);` `});`
	# (:756-764), otherwise it fires at once (`bullet(type,
	# xOffset, yOffset, angle, mover);`, :765). bullet()
	# (Turret.java:772-777) decrements it first thing:
	# `queuedBullets --;` (:773). While any bullet is still
	# queued and the def has a first-shot delay, the turret is
	# charging: `public boolean charging(){`
	# `return queuedBullets > 0 && shoot.firstShotDelay > 0;`
	# `}` (:715-717) -- and updateShooting()
	# (Turret.java:731-740) refuses to shoot while charging:
	# `if(reloadCounter >= reload && !charging() &&
	# shootWarmup >= minWarmup){` `shoot(type);`
	# `reloadCounter %= reload;` `}` (:733-738).
	# updateShooting() runs from updateTile()
	# (`updateShooting();`, :601/:609). The delay branch also
	# plays the charge sound when a shot begins:
	# `if(shoot.firstShotDelay > 0){`
	# `chargeSound.at(bulletX, bulletY,
	# Mathf.random(soundPitchMin, soundPitchMax));` (:747-748) --
	# `/** Sound emitted when shoot.firstShotDelay is >0 and
	# shooting begins. */` (:125). The field default is
	# `public float firstShotDelay = 0;`
	# (ShootPattern.java:11), and the only def that sets it is
	# lancer: `lancer = new PowerTurret("lancer"){{`
	# `range = 165f;` `shoot.firstShotDelay = 40f;`
	# `reload = 80f;` (Blocks.java:3560-3567). Duo never sets it
	# (Blocks.java:3257-3331) so its delay is 0, charging() is
	# always false for duo, and its delay-0 bullets fire at
	# once, leaving the counter at 0. `public float minWarmup =
	# 0f;` (Turret.java:76) is the warmup floor in the gate.
	# There is NO driver tick: the delayed bullets are Time.run
	# callbacks with no driver equivalent, and the gate is
	# evaluated per shoot event, not per tick (the N2248
	# precedent, N2264/N2266/N2267/N2268) -- the logic executor
	# does not exist in the driver yet, so the pure function is
	# called directly. The direct pure-function calls pin the
	# cases behind the driver observables below: queueing
	# increments the counter / firing decrements it / a queued
	# bullet with a first-shot delay is charging / no queued
	# bullet is not charging / a zero first-shot delay never
	# charges / the gate blocks while charging / the gate allows
	# a ready shot and wraps the reload counter / the gate
	# blocks when the reload is not ready / the gate blocks when
	# the warmup is below the floor / a lancer bullet queued on
	# one tick blocks the next tick until it fires / the lancer
	# live case (firstShotDelay 40, reload 80, range 165) / the
	# duo live case (firstShotDelay 0, delay-0 bullets fire at
	# once, counter stays 0).

	# The direct pure-function calls pin the cases behind the
	# driver observables below. The args are (queued_bullets,
	# first_shot_delay, queued_now, fired_now, reload_counter,
	# reload, shoot_warmup, min_warmup).
	var direct_queue: Dictionary = turret_build_state.source_turret_queued_bullets_state(0, 0.0, 3, 0, 0.0, 20.0, 0.0, 0.0)
	var direct_fire: Dictionary = turret_build_state.source_turret_queued_bullets_state(3, 0.0, 0, 1, 0.0, 20.0, 0.0, 0.0)
	var direct_charging_lancer: Dictionary = turret_build_state.source_turret_queued_bullets_state(1, 40.0, 0, 0, 0.0, 80.0, 0.0, 0.0)
	var direct_no_queue: Dictionary = turret_build_state.source_turret_queued_bullets_state(0, 40.0, 0, 0, 0.0, 80.0, 0.0, 0.0)
	var direct_zero_delay: Dictionary = turret_build_state.source_turret_queued_bullets_state(1, 0.0, 0, 0, 0.0, 20.0, 0.0, 0.0)
	var direct_blocked_charging: Dictionary = turret_build_state.source_turret_queued_bullets_state(1, 40.0, 0, 0, 80.0, 80.0, 1.0, 0.0)
	var direct_ready: Dictionary = turret_build_state.source_turret_queued_bullets_state(0, 0.0, 0, 0, 85.0, 80.0, 1.0, 0.0)
	var direct_reload_not_ready: Dictionary = turret_build_state.source_turret_queued_bullets_state(0, 0.0, 0, 0, 79.0, 80.0, 1.0, 0.0)
	var direct_warmup_low: Dictionary = turret_build_state.source_turret_queued_bullets_state(0, 0.0, 0, 0, 80.0, 80.0, 0.25, 0.5)
	# The cross-tick sequence: lancer tick 1 shoots (reload
	# ready, warmup ok, nothing queued) and queues one delayed
	# bullet; tick 2 has the bullet still queued, so charging
	# blocks the next shot; tick 3 the Time.run callback fires
	# the bullet and drains the counter (the gate still reads
	# the pre-update counter that tick, the :733 ordering); tick
	# 4 the queue is empty, charging clears and shooting is
	# allowed again.
	var cross_tick_1: Dictionary = turret_build_state.source_turret_queued_bullets_state(0, 40.0, 1, 0, 85.0, 80.0, 1.0, 0.0)
	var cross_tick_2: Dictionary = turret_build_state.source_turret_queued_bullets_state(1, 40.0, 0, 0, 80.0, 80.0, 1.0, 0.0)
	var cross_tick_3: Dictionary = turret_build_state.source_turret_queued_bullets_state(1, 40.0, 0, 1, 80.0, 80.0, 1.0, 0.0)
	var cross_tick_4: Dictionary = turret_build_state.source_turret_queued_bullets_state(0, 40.0, 0, 0, 80.0, 80.0, 1.0, 0.0)
	var direct_lancer: Dictionary = turret_build_state.source_turret_queued_bullets_state(0, 40.0, 0, 0, 80.0, 80.0, 1.0, 0.0)
	var direct_duo: Dictionary = turret_build_state.source_turret_queued_bullets_state(0, 0.0, 1, 1, 20.0, 20.0, 1.0, 0.0)

	# Queueing increments the counter -- directly (the :754
	# `queuedBullets++;` per bullet the pattern.shoot callback
	# queues: 0 + 3 queued - 0 fired = 3).
	proof["qb_queue_increments"] = direct_queue.get("queued_bullets", -1) == 3
	# Firing decrements the counter -- directly (the :773
	# `queuedBullets --;` at the head of bullet(): 3 + 0 - 1 = 2).
	proof["qb_fire_decrements"] = direct_fire.get("queued_bullets", -1) == 2
	# A queued bullet with a first-shot delay is charging --
	# directly (the :716 gate: 1 queued and lancer delay 40 > 0).
	proof["qb_charging_true_lancer"] = direct_charging_lancer.get("charging", false) == true
	# No queued bullet is not charging -- directly (the :716
	# gate needs queuedBullets > 0; lancer delay 40 with an
	# empty queue is not charging).
	proof["qb_charging_false_no_queue"] = direct_no_queue.get("charging", true) == false
	# A zero first-shot delay never charges -- directly (the
	# :716 gate needs shoot.firstShotDelay > 0; duo delay 0
	# with 1 queued bullet is not charging).
	proof["qb_charging_false_zero_delay"] = direct_zero_delay.get("charging", true) == false
	# The gate blocks while charging -- directly (the :733
	# gate: reload 80 >= 80 and warmup 1 >= 0, but charging is
	# true, so can_shoot is false and the reload counter is
	# left at 80).
	proof["qb_gate_blocks_while_charging"] = direct_blocked_charging.get("can_shoot", true) == false and direct_blocked_charging.get("reload_counter_after", -1.0) == 80.0
	# The gate allows a ready shot and wraps the reload counter
	# -- directly (the :733 gate passes and the :738
	# `reloadCounter %= reload;` wraps 85 % 80 = 5).
	proof["qb_gate_allows_when_ready"] = direct_ready.get("can_shoot", false) == true and direct_ready.get("reload_counter_after", -1.0) == 5.0
	# The gate blocks when the reload is not ready -- directly
	# (the :733 gate: reload 79 < 80, so no shot).
	proof["qb_gate_blocks_reload_not_ready"] = direct_reload_not_ready.get("can_shoot", true) == false
	# The gate blocks when the warmup is below the floor --
	# directly (the :733 gate: warmup 0.25 < minWarmup 0.5, so
	# no shot).
	proof["qb_gate_blocks_warmup_low"] = direct_warmup_low.get("can_shoot", true) == false
	# A lancer bullet queued on one tick blocks the next tick
	# until it fires -- directly (tick 1 shoots and queues 1,
	# wrapping the reload counter 85 % 80 = 5; tick 2 is
	# charging so the gate blocks; tick 3 the bullet fires and
	# drains the counter to 0; tick 4 the queue is empty,
	# charging clears and the gate allows the next shot).
	proof["qb_cross_tick_blocks_next_shot"] = cross_tick_1.get("queued_bullets", -1) == 1 and cross_tick_1.get("can_shoot", false) == true and cross_tick_1.get("reload_counter_after", -1.0) == 5.0 and cross_tick_2.get("charging", false) == true and cross_tick_2.get("can_shoot", true) == false and cross_tick_3.get("queued_bullets", -1) == 0 and cross_tick_4.get("charging", true) == false and cross_tick_4.get("can_shoot", false) == true
	# The lancer live case -- directly (the Blocks.java:3560-3567
	# pins: firstShotDelay 40, reload 80, range 165; reload
	# ready, warmup ok, nothing queued, so the gate allows the
	# shot and the counter wraps 80 % 80 = 0).
	proof["qb_lancer_live"] = direct_lancer.get("charging", true) == false and direct_lancer.get("can_shoot", false) == true and direct_lancer.get("queued_bullets", -1) == 0 and direct_lancer.get("reload_counter_after", -1.0) == 0.0
	# The duo live case -- directly (duo never sets
	# firstShotDelay, Blocks.java:3257-3331, so the delay is the
	# ShootPattern.java:11 default 0; its delay-0 bullet fires
	# at once, so 1 queued - 1 fired leaves the counter at 0,
	# charging is false, the gate allows the shot and the
	# counter wraps 20 % 20 = 0).
	proof["qb_duo_live"] = direct_duo.get("queued_bullets", -1) == 0 and direct_duo.get("charging", true) == false and direct_duo.get("can_shoot", false) == true and direct_duo.get("reload_counter_after", -1.0) == 0.0

	# One duo segment, live on the driver: the placed duo
	# carries the duo pins (firstShotDelay is the 0 default,
	# reload 20, Blocks.java:3257-3331). Any queued bullet is a
	# delay-0 bullet that fires at once, so the counter never
	# stays above 0 and charging() never blocks duo.
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

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretQueuedBulletsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
