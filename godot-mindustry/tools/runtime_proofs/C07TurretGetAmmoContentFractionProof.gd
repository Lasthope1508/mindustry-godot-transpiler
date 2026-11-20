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

	# --- Turret getAmmoContent() + getAmmoFraction() (N2348):
	# TurretBuild.getAmmoContent() (Turret.java:319-321) is the
	# base default null:
	# `@Nullable`
	# `public UnlockableContent getAmmoContent(){`
	# `return null;`
	# `}`
	# and TurretBuild.getAmmoFraction() (Turret.java:324-326)
	# is the base default 1f:
	# `/** @return ammo as a fraction of capacity; used for direct turret control HUD */`
	# `public float getAmmoFraction(){`
	# `return 1f;`
	# `}`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). Both are base-class defaults, not
	# overrides: the subclass overrides (ItemTurretBuild
	# N1180/N1181, LiquidTurretBuild N1197/N1198,
	# ContinuousLiquidTurretBuild N1220/N1221, PowerTurretBuild
	# N1168) own their own bodies. Both are constants: no live
	# input besides the frame, which carries no tracked key.
	# NO driver tick line: both are pure defaults the callers
	# read (updateTile :495, DrawTurret :108-112). The proof
	# calls the pure functions with synthetic frames (no live
	# tick).

	# Content is null for the base default.
	var content: Dictionary = turret_build_state.source_turret_get_ammo_content_state({})
	proof["ammo_content_null"] = content.get("ammo_content", "not-null") == null

	# Content stays null even when the frame carries a content
	# value: the base default ignores the frame.
	var seeded: Dictionary = turret_build_state.source_turret_get_ammo_content_state({"ammo_content": "copper"})
	proof["ammo_content_null_regardless_of_frame"] = seeded.get("ammo_content", "not-null") == null

	# The frame passed in is not mutated by the call.
	var marked: Dictionary = {"marker": 7}
	turret_build_state.source_turret_get_ammo_content_state(marked)
	proof["ammo_content_input_unmutated"] = marked.get("marker", -1) == 7 and marked.size() == 1

	# The content result carries ONLY the one ammo_content key.
	proof["ammo_content_returns_only_one_key"] = content.size() == 1

	# Fraction is one for the base default.
	var fraction: Dictionary = turret_build_state.source_turret_get_ammo_fraction_state({})
	proof["ammo_fraction_one"] = is_equal_approx(float(fraction.get("ammo_fraction", -1.0)), 1.0)

	# Fraction stays one even when the frame carries a
	# different fraction: the base default ignores the frame.
	var seeded_fraction: Dictionary = turret_build_state.source_turret_get_ammo_fraction_state({"ammo_fraction": 0.25})
	proof["ammo_fraction_one_regardless_of_frame"] = is_equal_approx(float(seeded_fraction.get("ammo_fraction", -1.0)), 1.0)

	# The frame passed in is not mutated by the call.
	var marked_fraction: Dictionary = {"marker": 7}
	turret_build_state.source_turret_get_ammo_fraction_state(marked_fraction)
	proof["ammo_fraction_input_unmutated"] = marked_fraction.get("marker", -1) == 7 and marked_fraction.size() == 1

	# The fraction result carries ONLY the one ammo_fraction key.
	proof["ammo_fraction_returns_only_one_key"] = fraction.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretGetAmmoContentFractionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
