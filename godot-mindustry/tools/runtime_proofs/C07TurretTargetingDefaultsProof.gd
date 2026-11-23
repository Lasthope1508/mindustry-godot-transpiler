extends Node

const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Turret targeting/shoot field defaults (Turret.java:42,
	# :44, :82, :89, :91, :93, :99, :101, :109, :111):
	# `public float targetInterval = 20;`
	# `public float newTargetInterval = -1f;`
	# `public boolean reloadWhileCharging = true;`
	# `public boolean targetAir = true;`
	# `public boolean targetGround = true;`
	# `public boolean targetBlocks = true;`
	# `public boolean displayAmmoMultiplier = true;`
	# `public boolean targetUnderBlocks = true;`
	# `public Boolf<Unit> unitFilter = u -> true;`
	# `public Boolf<Building> buildingFilter = b -> targetUnderBlocks || !b.block.underBullets;`
	# No-arg call uses the Java defaults (target_under_blocks
	# true, under_bullets false).

	var defaults: Dictionary = turret_state.source_turret_targeting_defaults_state()

	# Ticks between attempts at finding a target.
	proof["targeting_defaults_target_interval"] = float(defaults.get("target_interval", 0.0)) == 20.0

	# Target interval with a valid target; -1 means
	# targetInterval.
	proof["targeting_defaults_new_target_interval"] = float(defaults.get("new_target_interval", 0.0)) == -1.0

	# The turret can reload while charging.
	proof["targeting_defaults_reload_while_charging"] = bool(defaults.get("reload_while_charging", false)) == true

	# The block targets air units.
	proof["targeting_defaults_target_air"] = bool(defaults.get("target_air", false)) == true

	# The block targets ground units and structures.
	proof["targeting_defaults_target_ground"] = bool(defaults.get("target_ground", false)) == true

	# The block targets blocks.
	proof["targeting_defaults_target_blocks"] = bool(defaults.get("target_blocks", false)) == true

	# The block displays ammo multipliers in its stats.
	proof["targeting_defaults_display_ammo_multiplier"] = bool(defaults.get("display_ammo_multiplier", false)) == true

	# 'Under' blocks like conveyors are targeted.
	proof["targeting_defaults_target_under_blocks"] = bool(defaults.get("target_under_blocks", false)) == true

	# unitFilter is `u -> true`: every unit passes.
	proof["targeting_defaults_unit_filter_always_true"] = bool(defaults.get("unit_filter", false)) == true

	# buildingFilter with targetUnderBlocks true: an
	# under-bullets block still passes.
	var open_under_blocks: Dictionary = turret_state.source_turret_targeting_defaults_state(true, true)
	proof["targeting_defaults_building_filter_open_under_blocks"] = bool(open_under_blocks.get("building_filter", false)) == true

	# buildingFilter with targetUnderBlocks false and the
	# block under bullets: the block is filtered out.
	var closed_blocked: Dictionary = turret_state.source_turret_targeting_defaults_state(false, true)
	proof["targeting_defaults_building_filter_closed_blocked"] = bool(closed_blocked.get("building_filter", true)) == false

	# buildingFilter with targetUnderBlocks false and the
	# block NOT under bullets: the block passes.
	var open_not_under_bullets: Dictionary = turret_state.source_turret_targeting_defaults_state(false, false)
	proof["targeting_defaults_building_filter_open_not_under_bullets"] = bool(open_not_under_bullets.get("building_filter", false)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretTargetingDefaultsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
