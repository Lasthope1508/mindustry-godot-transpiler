extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- BurstDrill per-def shake/effect rows
	# (N2486, the N2304 per-def precedent): the
	# N2469 pure records the CLASS defaults (shake
	# 2f, drillEffect Fx.shockwave, BurstDrill.
	# java:18/:42) -- but BOTH defs override shake =
	# 4f (Blocks.java:3077/:3106) and drillEffect to
	# a MultiEffect. Impact-drill (Blocks.
	# java:3076): `drillEffect = new MultiEffect(Fx.
	# mineImpact, Fx.drillSteam, Fx.mineImpactWave.
	# wrap(Pal.redLight, 40f));`. Eruption-drill
	# (Blocks.java:3100-3105): `drillEffect = new
	# MultiEffect(` with Fx.mineImpact, Fx.drillSteam,
	# Fx.dynamicSpikes.wrap(Liquids.hydrogen.color,
	# 30f) and Fx.mineImpactWave.wrap(Liquids.
	# hydrogen.color, 45f). A MultiEffect fires its
	# children in order at the same x/y/rotation/
	# color (MultiEffect.java:19-20), and the wrap
	# second arg is a ROTATION (Effect.java:101 --
	# WrapEffect.create passes its own rotation +
	# color, not the caller's). The pure returns
	# {shake, drill_effect} for a caller-supplied
	# def id, with the CLASS defaults (shake 2.0,
	# ["Fx.shockwave"]) for an unknown def id (the
	# N2304 fallback precedent). drillSound /
	# drillSoundVolume do NOT differ per def (no
	# override in either def block, Blocks.
	# java:3070-3121), so the pure returns only
	# {shake, drill_effect}. Pure-only: the caller
	# (effects path) reads it; the N2469 pure is
	# unchanged.

	# --- Shake impact: the impact-drill row shakes
	# 4.0, not the class default 2.0 (`shake = 4f;`,
	# Blocks.java:3077).
	var impact: Dictionary = burst_drill_build_state.source_burst_drill_per_def_offload_effects_state("impact-drill")
	proof["shake_impact"] = is_equal_approx(float(impact.get("shake", -1.0)), 4.0)

	# --- Shake eruption: the eruption-drill row
	# shakes 4.0 too (`shake = 4f;`, Blocks.
	# java:3106).
	var eruption: Dictionary = burst_drill_build_state.source_burst_drill_per_def_offload_effects_state("eruption-drill")
	proof["shake_eruption"] = is_equal_approx(float(eruption.get("shake", -1.0)), 4.0)

	# --- Effect impact: the impact-drill
	# MultiEffect children in order -- Fx.mineImpact,
	# Fx.drillSteam, then Fx.mineImpactWave wrapped
	# with Pal.redLight at rotation 40.0 (Blocks.
	# java:3076; the wrap color is the token, not a
	# resolved Color -- Pal.redLight is
	# Color.valueOf("feb380"), Pal.java:138).
	var impact_effect: Array = impact.get("drill_effect", [])
	var impact_wrap: Dictionary = impact_effect[2] if impact_effect.size() == 3 and impact_effect[2] is Dictionary else {}
	proof["effect_impact"] = impact_effect.size() == 3 and str(impact_effect[0]) == "Fx.mineImpact" and str(impact_effect[1]) == "Fx.drillSteam" and str(impact_wrap.get("effect", "")) == "Fx.mineImpactWave" and str(impact_wrap.get("wrap_color", "")) == "Pal.redLight" and is_equal_approx(float(impact_wrap.get("wrap_rotation", -1.0)), 40.0)

	# --- Effect eruption: the eruption-drill
	# MultiEffect children in order -- Fx.mineImpact,
	# Fx.drillSteam, Fx.dynamicSpikes wrapped with
	# Liquids.hydrogen.color at rotation 30.0, then
	# Fx.mineImpactWave wrapped with Liquids.
	# hydrogen.color at rotation 45.0 (Blocks.
	# java:3100-3105; hydrogen is Color.valueOf(
	# "9eabf7"), Liquids.java:83).
	var eruption_effect: Array = eruption.get("drill_effect", [])
	var eruption_wrap_first: Dictionary = eruption_effect[2] if eruption_effect.size() == 4 and eruption_effect[2] is Dictionary else {}
	var eruption_wrap_second: Dictionary = eruption_effect[3] if eruption_effect.size() == 4 and eruption_effect[3] is Dictionary else {}
	proof["effect_eruption"] = eruption_effect.size() == 4 and str(eruption_effect[0]) == "Fx.mineImpact" and str(eruption_effect[1]) == "Fx.drillSteam" and str(eruption_wrap_first.get("effect", "")) == "Fx.dynamicSpikes" and str(eruption_wrap_first.get("wrap_color", "")) == "Liquids.hydrogen.color" and is_equal_approx(float(eruption_wrap_first.get("wrap_rotation", -1.0)), 30.0) and str(eruption_wrap_second.get("effect", "")) == "Fx.mineImpactWave" and str(eruption_wrap_second.get("wrap_color", "")) == "Liquids.hydrogen.color" and is_equal_approx(float(eruption_wrap_second.get("wrap_rotation", -1.0)), 45.0)

	# --- Class fallback: an unknown def id falls
	# back to the CLASS defaults -- shake 2.0
	# (BurstDrill.java:18) and the single Fx.
	# shockwave effect (BurstDrill.java:42) as a
	# one-child list (the N2304 fallback precedent).
	var fallback: Dictionary = burst_drill_build_state.source_burst_drill_per_def_offload_effects_state("unknown-def")
	var fallback_effect: Array = fallback.get("drill_effect", [])
	proof["class_fallback"] = is_equal_approx(float(fallback.get("shake", -1.0)), 2.0) and fallback_effect.size() == 1 and str(fallback_effect[0]) == "Fx.shockwave"

	# --- Per-def live input: the row follows the
	# caller-supplied def id -- the two defs share
	# the first two children but differ after that
	# (3 children vs 4, different wrap colors and
	# rotations), and neither is the class fallback.
	proof["per_def_live_input"] = impact_effect.size() == 3 and eruption_effect.size() == 4 and str(impact_effect[0]) == str(eruption_effect[0]) and str(impact_effect[1]) == str(eruption_effect[1]) and impact_effect != eruption_effect and fallback_effect.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillPerDefShakeEffectRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
