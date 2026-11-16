extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
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

	# --- Config / display rows (N2466): display()
	# (LaunchPad.java:164-177), shouldShowConfigure
	# (:180-182) and buildConfiguration (:185-203).
	# display() is `super.display(table);` then the
	# gate `if(!state.isCampaign() || net.client()
	# || team != player.team()) return;` -- the label
	# row renders only in campaign, not a net client,
	# and the pad's team is the player's team. The
	# destination is `Sector dest = state.rules.
	# sector == null ? null : state.rules.sector.info.
	# destination;` and the label is `return Core.
	# bundle.format("launch.destination",` with `dest
	# == null || !dest.hasBase() ? Core.bundle.get(
	# "sectors.nonelaunch") :` else `"[accent]" +
	# dest.name());`. The label is a Dict {key, value}
	# (the N2450 precedent -- the UI composes the
	# rendered string): the key is "launch.
	# destination" (`launch.destination = Destination:
	# {0}`, bundle.properties:875) and the value is
	# the BUNDLE TOKEN "sectors.nonelaunch"
	# (`sectors.nonelaunch = [lightgray]none (sun)`,
	# bundle.properties:921) when the destination is
	# null or has no base, else "[accent]" + name.
	# shouldShowConfigure is `return state.
	# isCampaign();` (campaign only). buildConfiguration
	# is `if(!state.isCampaign() || net.client()){`
	# with the early-return `deselect();`, else
	# `table.button(Icon.upOpen, Styles.cleari, () ->
	# {` opening `ui.planet.showSelect(state.rules.
	# sector, other -> {`; the callback is `if(state.
	# isCampaign() && other.planet == state.rules.
	# sector.planet){` then `var prev = state.rules.
	# sector.info.destination;` + `state.rules.sector.
	# info.destination = other;` + `if(prev != null){`
	# + `prev.info.refreshImportRates(state.getPlanet
	# ());`, and the button is `}).size(40f);`. The
	# button is a CALL record (the N2443 picker
	# precedent -- the UI is NOT ported); the
	# click-time deselect (:201) is part of the
	# button_call record, not a separate key. The
	# refresh fires when prev != null AND the
	# callback applied -- Java's only condition
	# inside the callback is `if(prev != null){`, so
	# a same-sector re-selection still refreshes.

	# --- Display label with a destination: the
	# gate passes (campaign, not a client, player
	# team) and the destination has a base, so the
	# label is {key "launch.destination", value
	# "[accent]" + name}.
	var dest: Dictionary = launch_pad_build_state.source_launch_pad_display_state(true, false, true, {"name": "Frozen Forest", "has_base": true})
	var dest_label: Dictionary = dest.get("destination_label", {})
	proof["display_label_dest"] = str(dest_label.get("key", "")) == "launch.destination" and str(dest_label.get("value", "")) == "[accent]Frozen Forest"

	# --- Display label with no destination: a null
	# destination (no sector, or no destination set)
	# and a destination with no base both read the
	# "sectors.nonelaunch" bundle token -- NOT the
	# localized text.
	var none_dest: Dictionary = launch_pad_build_state.source_launch_pad_display_state(true, false, true, null)
	var no_base: Dictionary = launch_pad_build_state.source_launch_pad_display_state(true, false, true, {"name": "Frozen Forest", "has_base": false})
	var none_label: Dictionary = none_dest.get("destination_label", {})
	var no_base_label: Dictionary = no_base.get("destination_label", {})
	proof["display_label_none"] = str(none_label.get("key", "")) == "launch.destination" and str(none_label.get("value", "")) == "sectors.nonelaunch" and str(no_base_label.get("key", "")) == "launch.destination" and str(no_base_label.get("value", "")) == "sectors.nonelaunch"

	# --- Display gate: not campaign, a net client,
	# or another team's pad all render no label row
	# (destination_label null) -- even with a based
	# destination.
	var gated_dest: Dictionary = {"name": "Frozen Forest", "has_base": true}
	var not_campaign: Dictionary = launch_pad_build_state.source_launch_pad_display_state(false, false, true, gated_dest)
	var client: Dictionary = launch_pad_build_state.source_launch_pad_display_state(true, true, true, gated_dest)
	var other_team: Dictionary = launch_pad_build_state.source_launch_pad_display_state(true, false, false, gated_dest)
	proof["display_gate"] = not_campaign.get("destination_label", {}) == null and client.get("destination_label", {}) == null and other_team.get("destination_label", {}) == null

	# --- Config button: campaign + not a client
	# shows the configure button (show_configure
	# true) as the CALL record {icon "Icon.upOpen",
	# style "Styles.cleari", size 40.0}, with no
	# deselect; with no selection the destination
	# stays prev (null here) and no refresh fires.
	var config: Dictionary = launch_pad_build_state.source_launch_pad_config_state(true, false, null, {"planet": "serpulo"}, null)
	var button: Dictionary = config.get("button_call", {})
	proof["config_button"] = bool(config.get("show_configure", false)) == true and str(button.get("icon", "")) == "Icon.upOpen" and str(button.get("style", "")) == "Styles.cleari" and is_equal_approx(float(button.get("size", -1.0)), 40.0) and bool(config.get("deselect_called", true)) == false and config.get("destination_after", {}) == null and bool(config.get("refresh_import_rates_called", true)) == false

	# --- Config select: a same-planet selection
	# applies (destination_after is the selected
	# sector, and the refresh fires when prev !=
	# null); a cross-planet selection does not apply
	# (destination stays prev, no refresh); with no
	# prev the selection still applies but no refresh
	# fires; a same-sector re-selection still
	# refreshes (Java's only condition is prev !=
	# null); a null selection (dialog dismissed)
	# applies nothing; and a non-campaign callback
	# re-check blocks the selection even on the same
	# planet.
	var prev: Dictionary = {"name": "Ground Zero", "has_base": true, "planet": "serpulo"}
	var selected: Dictionary = {"name": "Frozen Forest", "has_base": true, "planet": "serpulo"}
	var current: Dictionary = {"planet": "serpulo"}
	var applied: Dictionary = launch_pad_build_state.source_launch_pad_config_state(true, false, selected, current, prev)
	var other_planet: Dictionary = launch_pad_build_state.source_launch_pad_config_state(true, false, {"name": "Erekir Sector", "has_base": true, "planet": "erekir"}, current, prev)
	var no_prev: Dictionary = launch_pad_build_state.source_launch_pad_config_state(true, false, selected, current, null)
	var reselect: Dictionary = launch_pad_build_state.source_launch_pad_config_state(true, false, prev, current, prev)
	var no_selection: Dictionary = launch_pad_build_state.source_launch_pad_config_state(true, false, null, current, prev)
	var not_campaign_select: Dictionary = launch_pad_build_state.source_launch_pad_config_state(false, false, selected, current, prev)
	proof["config_select"] = applied.get("destination_after", {}) == selected and bool(applied.get("refresh_import_rates_called", false)) == true and other_planet.get("destination_after", {}) == prev and bool(other_planet.get("refresh_import_rates_called", true)) == false and no_prev.get("destination_after", {}) == selected and bool(no_prev.get("refresh_import_rates_called", true)) == false and reselect.get("destination_after", {}) == prev and bool(reselect.get("refresh_import_rates_called", false)) == true and no_selection.get("destination_after", {}) == prev and bool(no_selection.get("refresh_import_rates_called", true)) == false and not_campaign_select.get("destination_after", {}) == prev and bool(not_campaign_select.get("refresh_import_rates_called", true)) == false

	# --- Config deselect: the gate fail deselects
	# and offers no button -- not campaign
	# (show_configure false) and a net client
	# (show_configure still true: shouldShowConfigure
	# checks campaign only).
	var not_campaign_config: Dictionary = launch_pad_build_state.source_launch_pad_config_state(false, false, null, {"planet": "serpulo"}, null)
	var client_config: Dictionary = launch_pad_build_state.source_launch_pad_config_state(true, true, null, {"planet": "serpulo"}, null)
	proof["config_deselect"] = bool(not_campaign_config.get("show_configure", true)) == false and not_campaign_config.get("button_call", {}) == null and bool(not_campaign_config.get("deselect_called", false)) == true and bool(client_config.get("show_configure", false)) == true and client_config.get("button_call", {}) == null and bool(client_config.get("deselect_called", false)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadConfigDisplayRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
