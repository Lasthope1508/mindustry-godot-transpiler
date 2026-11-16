extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_mass_driver_build_state := preload("res://src/game/SourcePayloadMassDriverBuildState.gd")
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

	# --- updateTile effects / sound / shake rows
	# (N2468): the receive effects + sound + shake
	# (PayloadMassDriver.java:173-181) and the shoot
	# effects + sound + shake (:292-304) reported as
	# pure call records. The STATE is ALREADY LIVE
	# since N2245/N2246 (the effectDelayTimer
	# countdown + reloadCounter = 1f reset, the charge
	# + transfer with partner effectDelayTimer =
	# transferEffect.lifetime 11f), so these pures
	# consume the caller-evaluated gates: receive
	# `receiveEffect.at(x - cx/2f, y - cy/2f,
	# turretRotation);` + `reloadCounter = 1f;` +
	# `Effect.shake(shake, shake, this);` +
	# `receiveSound.at(x, y, 1f + Mathf.range(0.2f),
	# shootSoundVolume);` with cx/cy from the OTHER
	# driver's turretRotation; shoot
	# `shootEffect.at(x + cx, y + cy,
	# turretRotation);` + `smokeEffect.at(x, y,
	# turretRotation);` + `Effect.shake(shake, shake,
	# this);` + `shootSound.at(x, y, Mathf.random(
	# 0.9f, 1.1f), shootSoundVolume);` +
	# `transferEffect.at(x + cx, y + cy,
	# turretRotation, new PayloadMassDriverData(x +
	# cx, y + cy, other.x - cx, other.y - cy,
	# payload));` with cx/cy from the SELF rotation.
	# The fields are Fx.shootBig2 / Fx.shootPayload-
	# Driver / Fx.payloadReceive (Fx.java:1866/2189/
	# 2677), Sounds.massdriver / Sounds.massdriver-
	# Receive (massdriver.ogg + massdriverReceive.ogg
	# -- Sounds is build-generated, the N2444 padLaunch
	# precedent), shootSoundVolume 0.7f, shake 3f,
	# length 89/8f = 11.125, transferEffect lifetime
	# 11f (PayloadMassDriver.java:25/32-40). The pitch
	# rolls are ALREADY-ROLLED caller-supplied inputs
	# (receive: Mathf.range(0.2f) in [-0.2, 0.2];
	# shoot: Mathf.random(0.9f, 1.1f) in [0.9, 1.1])
	# -- NO RNG in the pures (the N2421 precedent).
	# No sound is played, no effect spawned, no camera
	# shaken -- the audio/effect call sites wait for
	# their own slices.

	# --- Receive fires: the crossed timer + a
	# lastOther partner fires all four records. The
	# other driver faces 0 degrees (cx = 11.125,
	# cy = 0), so the receive effect lands at
	# (100 - 11.125/2, 200) = (94.4375, 200) with
	# the SELF rotation 90; the sound is
	# massdriverReceive at pitch 1.0 + 0.1 = 1.1,
	# volume 0.7; the shake is 3.0/3.0; the reload
	# stamp is 1.0. A second case faces the other
	# driver at 90 degrees (cx ~ 0, cy = 11.125),
	# so the effect lands at (100, 200 - 11.125/2)
	# = (100, 194.4375) with the self rotation 0.
	var received: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_receive_effects_state(true, {"turret_rotation": 0.0}, 100.0, 200.0, 90.0, 11.125, 0.1)
	var received_effect: Dictionary = received.get("receive_effect_call", {})
	var received_sound: Dictionary = received.get("receive_sound_call", {})
	var received_shake: Dictionary = received.get("shake_call", {})
	var received_up: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_receive_effects_state(true, {"turret_rotation": 90.0}, 100.0, 200.0, 0.0, 11.125, 0.0)
	var received_up_effect: Dictionary = received_up.get("receive_effect_call", {})
	proof["receive_fires"] = str(received_effect.get("effect", "")) == "Fx.payloadReceive" and is_equal_approx(float(received_effect.get("x", -1.0)), 94.4375) and is_equal_approx(float(received_effect.get("y", -1.0)), 200.0) and is_equal_approx(float(received_effect.get("rotation", -1.0)), 90.0) and str(received_sound.get("sound", "")) == "massdriverReceive" and is_equal_approx(float(received_sound.get("x", -1.0)), 100.0) and is_equal_approx(float(received_sound.get("y", -1.0)), 200.0) and is_equal_approx(float(received_sound.get("pitch", -1.0)), 1.1) and is_equal_approx(float(received_sound.get("volume", -1.0)), 0.7) and is_equal_approx(float(received_shake.get("intensity", -1.0)), 3.0) and is_equal_approx(float(received_shake.get("duration", -1.0)), 3.0) and is_equal_approx(float(received.get("reload_counter_after", -1.0)), 1.0) and is_equal_approx(float(received_up_effect.get("x", -1.0)), 100.0) and is_equal_approx(float(received_up_effect.get("y", -1.0)), 194.4375) and is_equal_approx(float(received_up_effect.get("rotation", -1.0)), 0.0)

	# --- Receive gate: no crossed timer, no
	# records -- even with a partner and a nonzero
	# pitch roll; and no partner, no records --
	# even with a crossed timer and a nonzero roll
	# (the N2397 null-when-absent precedent).
	var idle: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_receive_effects_state(false, {"turret_rotation": 0.0}, 100.0, 200.0, 90.0, 11.125, 0.1)
	var no_partner: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_receive_effects_state(true, null, 100.0, 200.0, 90.0, 11.125, -0.2)
	proof["receive_gate"] = idle.get("receive_effect_call", {}) == null and idle.get("receive_sound_call", {}) == null and idle.get("shake_call", {}) == null and idle.get("reload_counter_after", {}) == null and no_partner.get("receive_effect_call", {}) == null and no_partner.get("receive_sound_call", {}) == null and no_partner.get("shake_call", {}) == null and no_partner.get("reload_counter_after", {}) == null

	# --- Receive pitch: pitch is 1f + pitch_roll --
	# 1.0 at a zero roll, 1.2 at the +0.2 bound, 0.8
	# at the -0.2 bound (Mathf.range(0.2f) spans
	# [-0.2, 0.2], arc Mathf.java:220-222); the sound
	# token is massdriverReceive (Sounds.massdriver-
	# Receive, PayloadMassDriver.java:36) and the
	# volume is shootSoundVolume 0.7f (:37).
	var pitched_high: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_receive_effects_state(true, {"turret_rotation": 0.0}, 100.0, 200.0, 90.0, 11.125, 0.2).get("receive_sound_call", {})
	var pitched_low: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_receive_effects_state(true, {"turret_rotation": 0.0}, 100.0, 200.0, 90.0, 11.125, -0.2).get("receive_sound_call", {})
	var pitched_zero: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_receive_effects_state(true, {"turret_rotation": 0.0}, 100.0, 200.0, 90.0, 11.125, 0.0).get("receive_sound_call", {})
	proof["receive_pitch"] = str(pitched_high.get("sound", "")) == "massdriverReceive" and is_equal_approx(float(pitched_high.get("pitch", -1.0)), 1.2) and is_equal_approx(float(pitched_low.get("pitch", -1.0)), 0.8) and is_equal_approx(float(pitched_zero.get("pitch", -1.0)), 1.0) and is_equal_approx(float(pitched_high.get("volume", -1.0)), 0.7) and is_equal_approx(float(pitched_low.get("volume", -1.0)), 0.7)

	# --- Shoot fires: charge_fired fires all six
	# records. The self rotation is 0 degrees
	# (cx = 11.125, cy = 0), so the shoot effect
	# lands at the muzzle (100 + 11.125, 200) =
	# (111.125, 200) with rotation 0; the smoke is
	# at the self position (100, 200) with rotation
	# 0; the sound is massdriver at pitch 1.0 (the
	# roll IS the pitch -- no 1f + offset, unlike
	# the receive pitch), volume 0.7; the shake is
	# 3.0/3.0; the partner timer stamp is 11.0
	# (transferEffect.lifetime). A second case
	# faces 90 degrees, so the muzzle is (100,
	# 200 + 11.125) = (100, 211.125).
	var fired: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_shoot_effects_state(true, 100.0, 200.0, 0.0, 11.125, 1.0, 300.0, 200.0, {"size": 24.0})
	var fired_shoot: Dictionary = fired.get("shoot_effect_call", {})
	var fired_smoke: Dictionary = fired.get("smoke_effect_call", {})
	var fired_sound: Dictionary = fired.get("shoot_sound_call", {})
	var fired_shake: Dictionary = fired.get("shake_call", {})
	var fired_up: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_shoot_effects_state(true, 100.0, 200.0, 90.0, 11.125, 0.9, 300.0, 200.0, {"size": 24.0})
	var fired_up_shoot: Dictionary = fired_up.get("shoot_effect_call", {})
	var fired_up_sound: Dictionary = fired_up.get("shoot_sound_call", {})
	proof["shoot_fires"] = str(fired_shoot.get("effect", "")) == "Fx.shootBig2" and is_equal_approx(float(fired_shoot.get("x", -1.0)), 111.125) and is_equal_approx(float(fired_shoot.get("y", -1.0)), 200.0) and is_equal_approx(float(fired_shoot.get("rotation", -1.0)), 0.0) and str(fired_smoke.get("effect", "")) == "Fx.shootPayloadDriver" and is_equal_approx(float(fired_smoke.get("x", -1.0)), 100.0) and is_equal_approx(float(fired_smoke.get("y", -1.0)), 200.0) and is_equal_approx(float(fired_smoke.get("rotation", -1.0)), 0.0) and str(fired_sound.get("sound", "")) == "massdriver" and is_equal_approx(float(fired_sound.get("pitch", -1.0)), 1.0) and is_equal_approx(float(fired_sound.get("volume", -1.0)), 0.7) and is_equal_approx(float(fired_shake.get("intensity", -1.0)), 3.0) and is_equal_approx(float(fired_shake.get("duration", -1.0)), 3.0) and is_equal_approx(float(fired.get("effect_delay_timer_after", -1.0)), 11.0) and is_equal_approx(float(fired_up_shoot.get("x", -1.0)), 100.0) and is_equal_approx(float(fired_up_shoot.get("y", -1.0)), 211.125) and is_equal_approx(float(fired_up_sound.get("pitch", -1.0)), 0.9)

	# --- Shoot transfer: the transfer effect call
	# carries the PayloadMassDriverData params
	# (PayloadMassDriver.java:514, `public Payload-
	# MassDriverData(float x, float y, float ox,
	# float oy, Payload payload){`): from the muzzle
	# (111.125, 200), to the partner minus the offset
	# (300 - 11.125, 200) = (288.875, 200), payload
	# passed through untouched. The call itself sits
	# at the muzzle with the self rotation 0. The
	# callee's lerp geometry (the transferEffect body,
	# :40-47) is NOT ported (the N2396 record-the-
	# call precedent). A second case faces 90 degrees:
	# from (100, 211.125), to (300 - 0, 200 - 11.125)
	# = (300, 188.875).
	var fired_transfer: Dictionary = fired.get("transfer_effect_call", {})
	var fired_transfer_data: Dictionary = fired_transfer.get("data", {})
	var fired_transfer_from: Dictionary = fired_transfer_data.get("from", {})
	var fired_transfer_to: Dictionary = fired_transfer_data.get("to", {})
	var fired_up_transfer: Dictionary = fired_up.get("transfer_effect_call", {})
	var fired_up_transfer_data: Dictionary = fired_up_transfer.get("data", {})
	var fired_up_transfer_from: Dictionary = fired_up_transfer_data.get("from", {})
	var fired_up_transfer_to: Dictionary = fired_up_transfer_data.get("to", {})
	proof["shoot_transfer"] = str(fired_transfer.get("effect", "")) == "transferEffect" and is_equal_approx(float(fired_transfer.get("x", -1.0)), 111.125) and is_equal_approx(float(fired_transfer.get("y", -1.0)), 200.0) and is_equal_approx(float(fired_transfer.get("rotation", -1.0)), 0.0) and is_equal_approx(float(fired_transfer_from.get("x", -1.0)), 111.125) and is_equal_approx(float(fired_transfer_from.get("y", -1.0)), 200.0) and is_equal_approx(float(fired_transfer_to.get("x", -1.0)), 288.875) and is_equal_approx(float(fired_transfer_to.get("y", -1.0)), 200.0) and fired_transfer_data.get("payload", {}) == {"size": 24.0} and is_equal_approx(float(fired_up_transfer_from.get("x", -1.0)), 100.0) and is_equal_approx(float(fired_up_transfer_from.get("y", -1.0)), 211.125) and is_equal_approx(float(fired_up_transfer_to.get("x", -1.0)), 300.0) and is_equal_approx(float(fired_up_transfer_to.get("y", -1.0)), 188.875) and fired_up_transfer_data.get("payload", {}) == {"size": 24.0}

	# --- Shoot gate: no charge_fired, no records --
	# even with a nonzero pitch roll and a payload
	# (the N2397 null-when-absent precedent). The
	# timer stamp is null too -- the N2246 branches
	# only stamp the partner timer on a real fire.
	var idle_shoot: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_shoot_effects_state(false, 100.0, 200.0, 0.0, 11.125, 1.05, 300.0, 200.0, {"size": 24.0})
	proof["shoot_gate"] = idle_shoot.get("shoot_effect_call", {}) == null and idle_shoot.get("smoke_effect_call", {}) == null and idle_shoot.get("transfer_effect_call", {}) == null and idle_shoot.get("shoot_sound_call", {}) == null and idle_shoot.get("shake_call", {}) == null and idle_shoot.get("effect_delay_timer_after", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadMassDriverEffectsRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
