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

	# --- ContinuousTurretBuild.estimateDps() + hasAmmo() + shouldActiveSound() (N2389):
	# ContinuousTurretBuild.estimateDps()
	# (ContinuousTurret.java:43-46) returns 0f without
	# ammo, else shootType.damage * 60f over the
	# ContinuousBulletType damageInterval (5f default
	# when the shoot type is not a
	# ContinuousBulletType):
	# `public float estimateDps(){`
	# `if(!hasAmmo()) return 0f;`
	# `return shootType.damage * 60f / (shootType instanceof ContinuousBulletType c ? c.damageInterval : 5f);`
	# `}`
	# ContinuousTurretBuild.hasAmmo()
	# (ContinuousTurret.java:60-62) is canConsume():
	# `public boolean hasAmmo(){`
	# `return canConsume();`
	# `}`
	# ContinuousTurretBuild.shouldActiveSound()
	# (ContinuousTurret.java:166-168) is bullets.any():
	# `public boolean shouldActiveSound(){`
	# `return bullets.any();`
	# `}`
	# on `public class ContinuousTurretBuild extends TurretBuild{`
	# (ContinuousTurret.java:38). hasAmmo is the callee
	# of this very slice and arrives as the explicit
	# has_ammo param; shootType.damage / damageInterval
	# arrive as explicit floats (the N2330 param
	# precedent); the bullets Seq arrives as an explicit
	# Array -- arc Seq.any() is size > 0, so the port
	# reads not bullets.is_empty(). `return bullets.any
	# ();` is registered HERE -- LaserTurretBuild
	# .shouldActiveSound (LaserTurret.java:152-154,
	# byte-identical) is DEAD, never scoped again
	# (main-thread allocation, draft batch 21 §2.2).
	# NO driver tick line: three pure functions the
	# setup/tick reads, not per-tick writes. The proof
	# calls the three pure functions with synthetic
	# inputs (no live tick).

	# estimateDps is 0f without ammo, whatever the
	# shoot type values.
	var no_ammo: Dictionary = bridge.source_continuous_turret_build_estimate_dps_state(false, 10.0, true, 2.0)
	proof["estimate_dps_zero_without_ammo"] = float(no_ammo.get("estimate_dps", -1.0)) == 0.0

	# estimateDps uses the ContinuousBulletType
	# damageInterval: damage 10, interval 2 -> 300.
	var continuous: Dictionary = bridge.source_continuous_turret_build_estimate_dps_state(true, 10.0, true, 2.0)
	proof["estimate_dps_uses_damage_interval"] = float(continuous.get("estimate_dps", -1.0)) == 300.0

	# estimateDps defaults to 5f when the shoot type
	# is not a ContinuousBulletType: damage 10 -> 120,
	# even with a different damage_interval supplied.
	var plain: Dictionary = bridge.source_continuous_turret_build_estimate_dps_state(true, 10.0, false, 2.0)
	proof["estimate_dps_defaults_interval_five"] = float(plain.get("estimate_dps", -1.0)) == 120.0

	# hasAmmo follows canConsume: true when it can
	# consume.
	var ammo_yes: Dictionary = bridge.source_continuous_turret_build_has_ammo_state(true)
	proof["has_ammo_true_when_can_consume"] = bool(ammo_yes.get("has_ammo", false)) == true

	# hasAmmo follows canConsume: false when it cannot
	# consume.
	var ammo_no: Dictionary = bridge.source_continuous_turret_build_has_ammo_state(false)
	proof["has_ammo_false_when_cannot_consume"] = bool(ammo_no.get("has_ammo", true)) == false

	# shouldActiveSound is true while any bullet flies.
	var flying: Array = [{"bullet": "b1"}, {"bullet": "b2"}]
	var sound_on: Dictionary = bridge.source_continuous_turret_build_should_active_sound_state(flying)
	proof["should_active_sound_true_when_bullets"] = bool(sound_on.get("should_active_sound", false)) == true

	# shouldActiveSound is false with no bullets.
	var sound_off: Dictionary = bridge.source_continuous_turret_build_should_active_sound_state([])
	proof["should_active_sound_false_when_empty"] = bool(sound_off.get("should_active_sound", true)) == false

	# Inputs are read, never written: the bullets array
	# is unchanged after the call.
	var flying_before: Array = flying.duplicate(true)
	bridge.source_continuous_turret_build_should_active_sound_state(flying)
	proof["bullets_input_unmutated"] = flying == flying_before

	# Each result carries ONLY its one key.
	proof["returns_only_expected_keys"] = no_ammo.size() == 1 and continuous.size() == 1 and plain.size() == 1 and ammo_yes.size() == 1 and ammo_no.size() == 1 and sound_on.size() == 1 and sound_off.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousTurretEstimateDpsHasAmmoShouldActiveSoundProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
