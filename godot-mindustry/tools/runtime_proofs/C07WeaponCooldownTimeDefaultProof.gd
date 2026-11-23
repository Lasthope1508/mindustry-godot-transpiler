extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceWeaponsCoreState.gd")
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

	# --- Weapon cooldownTime field default (N2542, trimmed at merge):
	# Weapon cooldownTime (Weapon.java:89, `public float cooldownTime
	# = 20f;`) is the ticks-to-cool-down divisor of the heat-decay
	# leg (Weapon.java:411). The leg itself is owned by N864
	# (SourceWeaponBulletContinuousState.gd:231); this slice keeps
	# the number N2542 with the one genuinely new expr, the field
	# declaration (N2440 field-decl precedent). The same 20.0
	# already lives as SourceWeaponDefaults.COOLDOWN_TIME_DEFAULT.
	var defaults: Dictionary = state.source_weapon_cooldown_time_defaults_state()
	proof["defaults_cooldown_time"] = is_equal_approx(float(defaults.get("cooldown_time", -1.0)), 20.0)

	# The result carries ONLY its own key (1).
	proof["returns_only_expected_keys"] = defaults.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponCooldownTimeDefaultProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
