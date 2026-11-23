extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourcePayloadAmmoTurretBuildPortBridge.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

var _filter_allowed: Array = []
var _unlocked_allowed: Array = []


func _filter_stub(content: Variant) -> bool:
	return _filter_allowed.has(content)


func _unlocked_now_stub(content: Variant) -> bool:
	return _unlocked_allowed.has(content)


func _ui_icon_stub(content: Variant) -> String:
	return str(content) + "-ui"


func _displayed_names(display_contents: Array) -> Array:
	var names: Array = []
	for entry in display_contents:
		names.append(entry.get("content", ""))
	return names


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

	# --- PayloadAmmoTurret.init() (N2396):
	# PayloadAmmoTurret.init()
	# (PayloadAmmoTurret.java:59-93) registers
	# `consume(new ConsumePayloadFilter(i ->
	# ammoTypes.containsKey(i)){...})`
	# (PayloadAmmoTurret.java:60). Its build() walks
	# content.blocks() then content.units(), calling
	# displayContent() for each; displayContent() adds
	# a ReqImage only when `filter.get(content) &&
	# content.unlockedNow()`, with the per-entry
	# visibility `build instanceof PayloadTurretBuild
	# it && !it.payloads.isEmpty() &&
	# it.currentAmmo() == content`; efficiency() is
	# `build instanceof PayloadTurretBuild it &&
	# it.payloads.any() ? 1f : 0f`. display() is a
	# no-op comment (`//don't display`) and owns no
	# expr. content.blocks/units arrive as explicit
	# Array params, filter/unlockedNow/uiIcon as
	# explicit Callables (the N2330 param precedent);
	# Table/MultiReqImage/ReqImage/Stats are NOT
	# ported -- the proof asserts the frame (the
	# displayed list in blocks-then-units order +
	# efficiency 1f/0f), not rendered UI. The proof
	# calls the pure function with synthetic inputs
	# (no live tick).

	# Blocks passing filter and unlockedNow are listed, with their ui icon.
	_filter_allowed = ["copper-block", "lead-block"]
	_unlocked_allowed = ["copper-block", "lead-block"]
	var blocks_shown: Dictionary = bridge.source_payload_ammo_turret_init_state(["copper-block", "lead-block"], [], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, true, "copper-block")
	proof["init_display_blocks_shown"] = _displayed_names(blocks_shown.get("display_contents", [])) == ["copper-block", "lead-block"] and String(blocks_shown.get("display_contents", [{}])[0].get("ui_icon", "")) == "copper-block-ui"

	# Units passing filter and unlockedNow are listed too.
	_filter_allowed = ["dagger", "mace"]
	_unlocked_allowed = ["dagger", "mace"]
	var units_shown: Dictionary = bridge.source_payload_ammo_turret_init_state([], ["dagger", "mace"], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, true, "dagger")
	proof["init_display_units_shown"] = _displayed_names(units_shown.get("display_contents", [])) == ["dagger", "mace"]

	# Blocks come before units (build() walks blocks first, then units).
	_filter_allowed = ["copper-block", "dagger"]
	_unlocked_allowed = ["copper-block", "dagger"]
	var ordered: Dictionary = bridge.source_payload_ammo_turret_init_state(["copper-block"], ["dagger"], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, true, "copper-block")
	proof["init_display_blocks_before_units"] = _displayed_names(ordered.get("display_contents", [])) == ["copper-block", "dagger"]

	# A content the filter rejects is excluded.
	_filter_allowed = ["copper-block"]
	_unlocked_allowed = ["copper-block", "lead-block"]
	var filtered: Dictionary = bridge.source_payload_ammo_turret_init_state(["copper-block", "lead-block"], [], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, true, "copper-block")
	proof["init_display_filter_rejects"] = _displayed_names(filtered.get("display_contents", [])) == ["copper-block"]

	# A content that is not unlocked yet is excluded.
	_filter_allowed = ["copper-block", "lead-block"]
	_unlocked_allowed = ["copper-block"]
	var locked: Dictionary = bridge.source_payload_ammo_turret_init_state(["copper-block", "lead-block"], [], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, true, "copper-block")
	proof["init_display_locked_excluded"] = _displayed_names(locked.get("display_contents", [])) == ["copper-block"]

	# Empty content lists display nothing.
	var empty: Dictionary = bridge.source_payload_ammo_turret_init_state([], [], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, true, "copper-block")
	proof["init_display_empty"] = (empty.get("display_contents", ["not-empty"]) as Array).is_empty()

	# The entry whose content is the current ammo is visible.
	_filter_allowed = ["copper-block"]
	_unlocked_allowed = ["copper-block"]
	var visible: Dictionary = bridge.source_payload_ammo_turret_init_state(["copper-block"], [], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, true, "copper-block")
	proof["init_display_visible_current_ammo"] = bool(visible.get("display_contents", [{}])[0].get("visible", false))

	# The entry whose content is not the current ammo is hidden.
	var hidden_other: Dictionary = bridge.source_payload_ammo_turret_init_state(["copper-block"], [], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, true, "lead-block")
	proof["init_display_hidden_other_ammo"] = not bool(hidden_other.get("display_contents", [{}])[0].get("visible", true))

	# With no payloads held, no entry is visible.
	var hidden_empty: Dictionary = bridge.source_payload_ammo_turret_init_state(["copper-block"], [], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, false, "copper-block")
	proof["init_display_hidden_no_payloads"] = not bool(hidden_empty.get("display_contents", [{}])[0].get("visible", true))

	# Efficiency is 1.0 for a PayloadTurretBuild with any payload.
	proof["init_efficiency_one_with_ammo"] = is_equal_approx(float(blocks_shown.get("efficiency", -1.0)), 1.0)

	# Efficiency is 0.0 with no payloads held.
	proof["init_efficiency_zero_empty_payloads"] = is_equal_approx(float(hidden_empty.get("efficiency", -1.0)), 0.0)

	# Efficiency is 0.0 for a build that is not a PayloadTurretBuild,
	# and its entries are hidden too.
	var not_payload_build: Dictionary = bridge.source_payload_ammo_turret_init_state(["copper-block"], [], Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), false, true, "copper-block")
	proof["init_efficiency_zero_not_payload_build"] = is_equal_approx(float(not_payload_build.get("efficiency", -1.0)), 0.0) and not bool(not_payload_build.get("display_contents", [{}])[0].get("visible", true))

	# Inputs are read, never written: both arrays are
	# unchanged after the call.
	var content_blocks: Array = ["copper-block", "lead-block"]
	var content_units: Array = ["dagger"]
	var content_blocks_before: Array = content_blocks.duplicate()
	var content_units_before: Array = content_units.duplicate()
	_filter_allowed = ["copper-block", "lead-block", "dagger"]
	_unlocked_allowed = ["copper-block", "lead-block", "dagger"]
	bridge.source_payload_ammo_turret_init_state(content_blocks, content_units, Callable(self, "_filter_stub"), Callable(self, "_unlocked_now_stub"), Callable(self, "_ui_icon_stub"), true, true, "copper-block")
	proof["init_display_input_unmutated"] = content_blocks == content_blocks_before and content_units == content_units_before

	# The result carries ONLY the two init keys.
	proof["init_returns_only_two_keys"] = blocks_shown.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadAmmoTurretInitProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
