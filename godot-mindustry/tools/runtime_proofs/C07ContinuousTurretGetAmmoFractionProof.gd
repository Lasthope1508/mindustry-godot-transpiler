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

	# --- ContinuousTurretBuild.getAmmoFraction() (N2355):
	# ContinuousTurretBuild.getAmmoFraction()
	# (ContinuousTurret.java:75-84) starts from the block
	# efficiency and caps it by the liquid fraction when a
	# ConsumeLiquid consumer exists:
	# `@Override`
	# `public float getAmmoFraction(){`
	# `//TODO unclean way of calculating ammo fraction to display`
	# `float ammoFract = efficiency;`
	# `if(findConsumer(f -> f instanceof ConsumeLiquidBase) instanceof ConsumeLiquid cons){`
	# `ammoFract = Math.min(ammoFract, liquids.get(cons.liquid) / liquidCapacity);`
	# `}`
	# `return ammoFract;`
	# `}`
	# on `public class ContinuousTurretBuild extends TurretBuild{`
	# (ContinuousTurret.java:38). The findConsumer lookup is
	# NOT ported: its result arrives as the explicit
	# has_liquid_consumer + liquid_amount params (the N2330
	# param precedent). NO driver tick line: a pure accessor
	# the HUD caller reads. The proof calls the pure function
	# with synthetic scalar inputs (no live tick).

	# No liquid consumer: the fraction is the efficiency alone.
	var efficiency_only: Dictionary = bridge.source_continuous_turret_build_get_ammo_fraction_state(0.6, false, 0.0, 10.0)
	proof["ammo_fraction_efficiency_only"] = is_equal_approx(float(efficiency_only.get("ammo_fraction", -1.0)), 0.6)

	# The liquid ratio below efficiency caps the fraction.
	var liquid_caps: Dictionary = bridge.source_continuous_turret_build_get_ammo_fraction_state(0.8, true, 3.0, 10.0)
	proof["ammo_fraction_liquid_caps"] = is_equal_approx(float(liquid_caps.get("ammo_fraction", -1.0)), 0.3)

	# Efficiency below the liquid ratio wins the min.
	var efficiency_caps: Dictionary = bridge.source_continuous_turret_build_get_ammo_fraction_state(0.2, true, 9.0, 10.0)
	proof["ammo_fraction_efficiency_caps"] = is_equal_approx(float(efficiency_caps.get("ammo_fraction", -1.0)), 0.2)

	# Zero efficiency stays zero even with liquid present.
	var zero_efficiency: Dictionary = bridge.source_continuous_turret_build_get_ammo_fraction_state(0.0, true, 5.0, 10.0)
	proof["ammo_fraction_zero_efficiency"] = is_equal_approx(float(zero_efficiency.get("ammo_fraction", -1.0)), 0.0)

	# The result carries ONLY the one ammo_fraction key.
	proof["ammo_fraction_returns_only_one_key"] = efficiency_only.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousTurretGetAmmoFractionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
