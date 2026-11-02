extends Node

const catalog_script := preload("res://src/mindustry/content/ContentCatalog.gd")
const item_script := preload("res://src/mindustry/content/Item.gd")
const block_script := preload("res://src/mindustry/content/Block.gd")
const content := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const drill := preload("res://src/game/SourceDrillRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

class TypedCatalog extends RefCounted:
	var ordered: Array
	func get_many(kind: String) -> Array:
		assert(kind == "item")
		return ordered
	func get_by_id(_name: String) -> Variant:
		return {"content_type": "liquid"}

func _ready() -> void:
	var catalog := catalog_script.new()
	var view := content.source_item_catalog_state(catalog)
	var fields: Dictionary = view["item_facts_by_field"]
	var names: Dictionary = view["item_facts_by_name"]
	var proof: Dictionary = {}
	proof["source_registration_ids"] = fields["copper"]["id"] == 0 and fields["lead"]["id"] == 1 and fields["sand"]["id"] == 4 and fields["thorium"]["id"] == 7
	proof["effective_source_fields"] = fields["copper"]["hardness"] == 1 and not fields["copper"]["low_priority"] and fields["sand"]["hardness"] == 0 and fields["sand"]["low_priority"] and fields["graphite"]["hardness"] == 0
	proof["field_slug_and_numeric_identity"] = is_same(fields["phaseFabric"], names["phase-fabric"]) and view["item_names_by_id"][11] == "phase-fabric" and names.size() == catalog.get_many("item").size()
	var custom := TypedCatalog.new()
	custom.ordered = [item_script.new({"field": "firstField", "id": "zeta", "properties": {"hardness": 2}}), item_script.new({"field": "secondField", "id": "water", "properties": {"lowPriority": true}})]
	var typed := content.source_item_catalog_state(custom)
	proof["typed_order_without_global_lookup"] = typed["item_facts_by_name"]["zeta"]["id"] == 0 and typed["item_facts_by_name"]["water"]["id"] == 1 and typed["item_facts_by_name"]["water"]["low_priority"]
	proof["null_defaults_preserved"] = drill.source_init_blocked_items_state(null, null)["blocked_items"] == null
	proof["legacy_item_initializes_sequence"] = drill.source_init_blocked_items_state(null, 7)["blocked_items"] == [7]
	var empty: Array = []
	proof["explicit_empty_overrides_legacy"] = is_same(drill.source_init_blocked_items_state(empty, 7)["blocked_items"], empty) and empty.is_empty()
	var existing: Array = [1, 0]
	proof["existing_sequence_identity"] = is_same(drill.source_init_blocked_items_state(existing, 7)["blocked_items"], existing) and existing == [1, 0]
	var blocks: Array = catalog.get_many("block")
	var impact = blocks.filter(func(value): return value.id == "impact-drill")[0]
	var before: Dictionary = impact.properties.duplicate(true)
	var bound := drill.source_bind_ore_items_state(impact, view)
	proof["real_inherited_drill_blocked_item"] = impact.implementation == "BurstDrill" and bound["blocked_items"] == [7] and impact.properties == before
	var mechanical = blocks.filter(func(value): return value.id == "mechanical-drill")[0]
	proof["real_unblocked_drill"] = drill.source_bind_ore_items_state(mechanical, view)["blocked_items"] == null
	var custom_block := block_script.new({"id": "explicit-test-block", "properties": {"blockedItem": "thorium", "blockedItems": []}})
	proof["hydrated_empty_overrides_legacy"] = drill.source_bind_ore_items_state(custom_block, view)["blocked_items"] == []
	custom_block.properties["blockedItems"] = ["lead", "copper"]
	var multiple := drill.source_bind_ore_items_state(custom_block, view)
	proof["field_sequence_order_and_immutability"] = multiple["blocked_items"] == [1, 0] and custom_block.properties["blockedItems"] == ["lead", "copper"]
	var priority := drill.source_count_ore_state([{"is_static": false, "drop": fields["sand"]}, {"is_static": false, "drop": fields["sand"]}, {"is_static": false, "drop": fields["lead"]}], 2, null)
	proof["real_catalog_priority_composes"] = priority["returnItem"]["id"] == 1 and priority["returnCount"] == 1 and is_same(priority["returnItem"], fields["lead"])
	var blocked := drill.source_count_ore_state([{"is_static": false, "drop": fields["thorium"]}, {"is_static": false, "drop": fields["beryllium"]}], impact.properties["tier"], bound["blocked_items"])
	proof["real_blocked_item_composes"] = blocked["returnItem"]["id"] == fields["beryllium"]["id"] and not blocked["oreCount"].has(7)
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("DrillOreBindingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
