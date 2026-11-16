extends Node

const main_scene := preload("res://scenes/Main.tscn")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- PowerBufferRequirement bar rows (N2422):
	# Accelerator.setBars() (Accelerator.java:100-111).
	# super.setBars() + the gate
	# (if(powerBufferRequirement > 0f)) + addBar(
	# "powerBufferRequirement", b -> new Bar(...)) with
	# the label lambda (Core.bundle.format(
	# "bar.powerbuffer", UI.formatAmount((long)b.power.
	# graph.getBatteryStored()), UI.formatAmount((long)
	# powerBufferRequirement))), the color lambda (() ->
	# Pal.powerBar) and the fraction lambda (() -> b.power.
	# graph.getBatteryStored() / powerBufferRequirement).
	# The requirement is the class field (public float
	# powerBufferRequirement;, Accelerator.java:41), set
	# by the single def to 1,000,000f (Blocks.java:6826).
	# The pure returns the bar call as data; it never
	# draws for real (the N2373 draw precedent). The
	# fraction is RAW: Java does not clamp it in the
	# lambda -- the Bar clamps at render (lastValue =
	# value = Mathf.clamp(fraction.get()); in the
	# constructor, float computed = Mathf.clamp(
	# fraction.get()); in draw(), Bar.java; clamp to
	# [0, 1] is return Math.max(Math.min(value, 1f), 0f);,
	# Mathf.java:402-404) -- so a stored battery above
	# the requirement reports a raw fraction above 1.0.
	# The label amounts are raw longs: UI.formatAmount
	# (public static String formatAmount(long number){,
	# UI.java:781) renders the magnitude suffixes +
	# [gray] markup, which is a UI concern the pure does
	# not build.
	var requirement := 1000000.0

	# --- Bar present: at a positive requirement the bar
	# exists -- bar_present true, the bar dict carries
	# the name "powerBufferRequirement", and the top
	# level carries the same name. At half a battery
	# (500,000 stored) the fraction is 0.5.
	var half: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(500000.0, requirement)
	var half_bar: Dictionary = half.get("bar", {})
	proof["bar_present_requirement_positive"] = bool(half.get("bar_present", false)) and not half_bar.is_empty() and half_bar.get("name", "") == "powerBufferRequirement" and half.get("bar_name", "") == "powerBufferRequirement" and half_bar.get("label_key", "") == "bar.powerbuffer" and is_equal_approx(float(half.get("fraction", -1.0)), 0.5) and is_equal_approx(float(half_bar.get("fraction", -1.0)), 0.5)

	# --- Bar absent: at requirement 0 the bar does not
	# exist at all (the gate is strict > 0f) -- bar_present
	# false, the bar dict empty, fraction 0.0 (Java never
	# evaluates the fraction lambda then, so 0.0 is the
	# documented absent default). A negative requirement
	# is absent too.
	var zero: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(500000.0, 0.0)
	var zero_bar: Dictionary = zero.get("bar", {})
	var negative: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(500000.0, -1.0)
	var negative_bar: Dictionary = negative.get("bar", {})
	proof["bar_absent_requirement_zero"] = bool(zero.get("bar_present", true)) == false and zero_bar.is_empty() and is_equal_approx(float(zero.get("fraction", -1.0)), 0.0) and bool(negative.get("bar_present", true)) == false and negative_bar.is_empty() and is_equal_approx(float(negative.get("fraction", -1.0)), 0.0)

	# --- Label amounts: the label key is bar.powerbuffer
	# ("Batteries: {0}/{1}", bundle.properties:1283) and
	# the amounts are the raw longs -- Java casts the
	# floats to long, truncation toward zero, which
	# GDScript int() matches: 500000.7 stored reads
	# 500000, 1000000.9 required reads 1000000. The bar
	# dict carries the same amounts. An empty battery
	# reads stored amount 0.
	var fractional: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(500000.7, 1000000.9)
	var fractional_bar: Dictionary = fractional.get("bar", {})
	var empty: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(0.0, requirement)
	proof["bar_label_amounts"] = fractional.get("label_key", "") == "bar.powerbuffer" and fractional_bar.get("label_key", "") == "bar.powerbuffer" and int(fractional.get("stored_amount", -1)) == 500000 and int(fractional.get("requirement_amount", -1)) == 1000000 and int(fractional_bar.get("stored_amount", -1)) == 500000 and int(fractional_bar.get("requirement_amount", -1)) == 1000000 and int(empty.get("stored_amount", -1)) == 0 and int(empty.get("requirement_amount", -1)) == 1000000

	# --- Color: Pal.powerBar (powerBar =
	# Color.valueOf("ec7b4c"), Pal.java:93), carried as a
	# symbolic token, never resolved to RGB (the N2373
	# color-token precedent) -- on the top level and in
	# the bar dict alike.
	var quarter: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(250000.0, requirement)
	var quarter_bar: Dictionary = quarter.get("bar", {})
	proof["bar_color_power_bar"] = quarter.get("color", "") == "Pal.powerBar" and quarter_bar.get("color", "") == "Pal.powerBar"

	# --- Fraction math: stored / requirement -- 0.0 at
	# an empty battery, 0.5 at half, 1.0 at full. A placed
	# accelerator's frame battery_stored feeds the pure
	# (the N2342 graph stamp fills it live): the frame
	# value 250,000.0 over the 1,000,000 requirement is
	# 0.25.
	var full: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(1000000.0, requirement)
	var accelerator_cell := Vector2i(30, 21)
	var accelerator := Sprite2D.new()
	game.add_child(accelerator)
	game.call("record_placed_block", accelerator, blocks_by_id["interplanetary-accelerator"], accelerator_cell)
	accelerator_build_state.source_accelerator_bind_frame_state(accelerator, blocks_by_id["interplanetary-accelerator"])
	var accelerator_frame: Dictionary = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	accelerator_frame["battery_stored"] = 250000.0
	var live: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(float(accelerator_frame.get("battery_stored", -1.0)), requirement)
	proof["bar_fraction_math"] = is_equal_approx(float(empty.get("fraction", -1.0)), 0.0) and is_equal_approx(float(half.get("fraction", -1.0)), 0.5) and is_equal_approx(float(full.get("fraction", -1.0)), 1.0) and is_equal_approx(float(live.get("fraction", -1.0)), 0.25) and bool(live.get("bar_present", false)) and int(live.get("stored_amount", -1)) == 250000

	# --- Overfull: a stored battery above the requirement
	# reports a RAW fraction above 1.0 -- 1.5 at 1,500,000
	# stored over the 1,000,000 requirement. Java does not
	# clamp the lambda; the Bar clamps at render
	# (Bar.java), so the Bar draws it full.
	var overfull: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(1500000.0, requirement)
	var overfull_bar: Dictionary = overfull.get("bar", {})
	proof["bar_fraction_overfull_raw"] = bool(overfull.get("bar_present", false)) and is_equal_approx(float(overfull.get("fraction", -1.0)), 1.5) and is_equal_approx(float(overfull_bar.get("fraction", -1.0)), 1.5) and float(overfull.get("fraction", 0.0)) > 1.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorPowerBufferBarRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
