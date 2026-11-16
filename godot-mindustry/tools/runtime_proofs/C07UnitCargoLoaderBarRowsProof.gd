extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_cargo_loader_build_state := preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")
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

	# --- Bar rows (N2417): UnitCargoLoader.setBars()
	# (UnitCargoLoader.java:48-63) registers the "units"
	# bar -- the bar.unitcap label (the unicode icon of
	# unitType.name + the live countType + the cap string
	# or "∞", formatted by `bar.unitcap = {0} {1}/{2}`),
	# the Pal.power color, and the count/cap fraction
	# (1f when the type ignores the unit cap).
	# getStringCap (Units.java:128-132) substitutes "∞"
	# when the cap is Integer.MAX_VALUE - 1 or more, and
	# getCap (Units.java:119-126) clamps at 0 -- so cap 0
	# is reachable in Java and Java divides anyway: the
	# fraction is UNGUARDED (count 0 / cap 0 is NaN,
	# count > 0 / cap 0 is Infinity), and the pure
	# matches it with no guard. The unicode icon is the
	# Fonts lookup over the runtime font atlas, so it
	# arrives caller-supplied (here the "M" fixture)
	# like the live countType / cap. Pure-only: the tick
	# never calls setBars -- the bar is presentation,
	# read by the UI, so this proof has no live-tick key.

	# --- Label parts: the capped case formats the icon,
	# the count, and the cap string as "M 3/10", with
	# the bar named "units" for unit type manifold.
	var capped: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_bar_rows_state("manifold", "M", 3, true, 10)
	var capped_label: Dictionary = capped.get("bar_label", {})
	proof["bar_label_parts"] = str(capped.get("bar_name", "")) == "units" and str(capped.get("unit_type_name", "")) == "manifold" and str(capped_label.get("icon", "")) == "M" and int(capped_label.get("count", -1)) == 3 and str(capped_label.get("cap_text", "")) == "10" and str(capped_label.get("text", "")) == "M 3/10" and str(capped.get("cap_text", "")) == "10"

	# --- Cap branch: an uncapped team (cap
	# Integer.MAX_VALUE, or MAX_VALUE - 1 at the
	# getStringCap boundary) reads "∞" even in the
	# capped branch, and the fraction is the tiny
	# count/MAX_VALUE ratio, not 1f.
	var uncapped: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_bar_rows_state("manifold", "M", 7, true, 2147483647)
	var uncapped_label: Dictionary = uncapped.get("bar_label", {})
	var boundary: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_bar_rows_state("manifold", "M", 7, true, 2147483646)
	var boundary_label: Dictionary = boundary.get("bar_label", {})
	proof["bar_cap_branch"] = str(uncapped_label.get("cap_text", "")) == "∞" and str(uncapped_label.get("text", "")) == "M 7/∞" and str(boundary_label.get("cap_text", "")) == "∞" and float(uncapped.get("bar_fraction", -1.0)) > 0.0 and float(uncapped.get("bar_fraction", -1.0)) < 0.000001

	# --- No-cap branch: a type that ignores the unit
	# cap reads "∞" with fraction 1f -- even when the
	# supplied cap is 0, because the division never
	# runs.
	var no_cap: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_bar_rows_state("manifold", "M", 5, false, 10)
	var no_cap_label: Dictionary = no_cap.get("bar_label", {})
	var no_cap_zero: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_bar_rows_state("manifold", "M", 5, false, 0)
	proof["bar_no_cap_branch"] = str(no_cap_label.get("cap_text", "")) == "∞" and str(no_cap_label.get("text", "")) == "M 5/∞" and is_equal_approx(float(no_cap.get("bar_fraction", -1.0)), 1.0) and is_equal_approx(float(no_cap_zero.get("bar_fraction", -1.0)), 1.0)

	# --- Color: the bar is Pal.power in every branch --
	# capped, no-cap, and zero-cap alike.
	var zero_cap: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_bar_rows_state("manifold", "M", 0, true, 0)
	proof["bar_color"] = str(capped.get("bar_color", "")) == "Pal.power" and str(no_cap.get("bar_color", "")) == "Pal.power" and str(zero_cap.get("bar_color", "")) == "Pal.power"

	# --- Fraction math: the fraction is count/cap --
	# 0.3 at 3/10, 1.0 at a full cap, 0.0 at count 0
	# with a nonzero cap.
	var full: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_bar_rows_state("manifold", "M", 10, true, 10)
	var empty: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_bar_rows_state("manifold", "M", 0, true, 10)
	proof["bar_fraction_math"] = is_equal_approx(float(capped.get("bar_fraction", -1.0)), 0.3) and is_equal_approx(float(full.get("bar_fraction", -1.0)), 1.0) and is_equal_approx(float(empty.get("bar_fraction", -1.0)), 0.0)

	# --- Zero-cap edge: Java does NOT guard the
	# division (getCap clamps at 0, never below, so cap
	# 0 is reachable) -- count 0 / cap 0 is NaN and
	# count 5 / cap 0 is positive Infinity, exactly
	# like Java float division. The label still formats
	# the cap string as "0".
	var zero_cap_five: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_bar_rows_state("manifold", "M", 5, true, 0)
	var zero_cap_label: Dictionary = zero_cap.get("bar_label", {})
	proof["bar_zero_cap_edge"] = is_nan(float(zero_cap.get("bar_fraction", 0.0))) and is_inf(float(zero_cap_five.get("bar_fraction", 0.0))) and float(zero_cap_five.get("bar_fraction", 0.0)) > 0.0 and str(zero_cap_label.get("cap_text", "")) == "0" and str(zero_cap_label.get("text", "")) == "M 0/0"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitCargoLoaderBarRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
