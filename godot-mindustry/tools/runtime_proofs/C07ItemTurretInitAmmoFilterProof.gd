extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_turret_build := preload("res://src/game/SourceItemTurretBuildPortBridge.gd")
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

	# --- Anonymous ConsumeItemFilter.build(Building
	# build, Table table) inside ItemTurret.init()
	# (N2431):
	# `content.items().each(i -> filter.get(i) &&
	# i.unlockedNow(),`
	# `item -> image.add(new ReqImage(new Image(
	# item.uiIcon),`
	# `() -> build instanceof ItemTurretBuild it &&
	# !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek())
	# .item == item)));`
	# One ammo-filter UI slice (batch 35 slot 3): the
	# :76-78 statement only. The proof calls the pure
	# function with synthetic inputs (no live tick, no
	# render): keeps an unlocked filtered item with a
	# true Boolp, drops a locked item, drops an
	# unfiltered item, Boolp false when not an
	# ItemTurretBuild / when ammo is empty / when the
	# peeked item differs. Each item entry is a
	# Dictionary {"item", "ui_icon", "filter_pass",
	# "unlocked_now"} -- filter_pass is the
	# `filter.get(i)` call-site and unlocked_now is
	# `i.unlockedNow()`, both explicit bools. The
	# peeked ItemEntry item arrives as an explicit
	# Variant param.

	var copper: Dictionary = {"item": "copper", "ui_icon": "copper-icon", "filter_pass": true, "unlocked_now": true}
	var lead_locked: Dictionary = {"item": "lead", "ui_icon": "lead-icon", "filter_pass": true, "unlocked_now": false}
	var titanium_unfiltered: Dictionary = {"item": "titanium", "ui_icon": "titanium-icon", "filter_pass": false, "unlocked_now": true}

	# Keeps an unlocked filtered item: one ReqImage
	# descriptor with the item icon and a true Boolp.
	var kept: Dictionary = item_turret_build.source_item_turret_init_ammo_filter_state([copper], true, false, "copper")
	var kept_images: Array = kept.get("req_images", [])
	proof["ammo_filter_includes_unlocked_filtered_item"] = kept_images.size() == 1 and kept_images[0].get("ui_icon", "") == "copper-icon" and kept_images[0].get("valid", false) == true

	# Drops a locked item: unlockedNow() false means
	# no ReqImage, even when the filter passes.
	var locked: Dictionary = item_turret_build.source_item_turret_init_ammo_filter_state([lead_locked], true, false, "lead")
	proof["ammo_filter_excludes_locked_item"] = (locked.get("req_images", []) as Array).is_empty()

	# Drops an unfiltered item: filter.get(i) false
	# means no ReqImage, even when unlocked.
	var unfiltered: Dictionary = item_turret_build.source_item_turret_init_ammo_filter_state([titanium_unfiltered], true, false, "titanium")
	proof["ammo_filter_excludes_unfiltered_item"] = (unfiltered.get("req_images", []) as Array).is_empty()

	# Boolp false when the build is not an
	# ItemTurretBuild, even with matching peeked ammo.
	var not_build: Dictionary = item_turret_build.source_item_turret_init_ammo_filter_state([copper], false, false, "copper")
	var not_build_images: Array = not_build.get("req_images", [])
	proof["ammo_filter_invalid_when_not_item_turret_build"] = not_build_images.size() == 1 and not_build_images[0].get("valid", true) == false

	# Boolp false when the ammo seq is empty: the
	# peeked item is never read when there is no ammo.
	var empty_ammo: Dictionary = item_turret_build.source_item_turret_init_ammo_filter_state([copper], true, true, "copper")
	var empty_ammo_images: Array = empty_ammo.get("req_images", [])
	proof["ammo_filter_invalid_when_ammo_empty"] = empty_ammo_images.size() == 1 and empty_ammo_images[0].get("valid", true) == false

	# Boolp false when the peeked ItemEntry item is a
	# different item than the one being displayed.
	var peek_differs: Dictionary = item_turret_build.source_item_turret_init_ammo_filter_state([copper], true, false, "lead")
	var peek_differs_images: Array = peek_differs.get("req_images", [])
	proof["ammo_filter_invalid_when_peek_differs"] = peek_differs_images.size() == 1 and peek_differs_images[0].get("valid", true) == false

	# The result carries only the req_images key.
	proof["ammo_filter_returns_only_req_images_key"] = kept.size() == 1 and locked.size() == 1 and unfiltered.size() == 1 and not_build.size() == 1 and empty_ammo.size() == 1 and peek_differs.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemTurretInitAmmoFilterProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
