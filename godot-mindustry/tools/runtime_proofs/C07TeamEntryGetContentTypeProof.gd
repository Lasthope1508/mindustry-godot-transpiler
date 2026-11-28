extends Node

const registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- TeamEntry.getContentType() (N2493):
	# TeamEntry.getContentType() (TeamEntry.java:27-29):
	#     @Override
	#     public ContentType getContentType(){
	#         return ContentType.team;
	#     }
	# on `public class TeamEntry extends
	# UnlockableContent` (TeamEntry.java:9) -- "only
	# for displaying team lore in the content
	# database". One line, returns the constant enum
	# ContentType.team. The proof calls the pure
	# function with no inputs (no live tick, no game
	# state): the enum is modeled by its qualified
	# Java name string (the N1319 precedent:
	# Block.getContentType() returns
	# "ContentType.block"). ContentType.team is the
	# enum constant with folderName "teams" and
	# contentClass TeamEntry.class
	# (ContentType.java:27).

	# The value is exactly "ContentType.team" --
	# the enum constant name, case-sensitive.
	var result: Dictionary = registry_state.source_team_entry_get_content_type_state()
	proof["content_type_is_team"] = result.get("content_type") == "ContentType.team"

	# The result carries exactly the one envelope key.
	proof["content_type_returns_only_one_key"] = result.size() == 1 and result.has("content_type")

	# The value is a non-empty String, not a null or
	# a number.
	var value: Variant = result.get("content_type")
	proof["content_type_is_string"] = typeof(value) == TYPE_STRING and (value as String).length() > 0

	# TRAP: the generic signature line `public
	# ContentType getContentType(){` is shared with
	# N1319 Block.getContentType() -- a different
	# class returning a different enum value. This
	# slice must return team, not block.
	proof["content_type_not_block"] = result.get("content_type") != "ContentType.block"

	# TRAP: ContentType.item is another sibling enum
	# value in the same enum -- the function must
	# not return a neighbouring constant.
	proof["content_type_not_item"] = result.get("content_type") != "ContentType.item"

	# The value is a qualified enum name: the
	# "ContentType." prefix plus the bare constant
	# name "team".
	var text: String = result.get("content_type", "")
	proof["content_type_qualified_name"] = text.begins_with("ContentType.") and text.trim_prefix("ContentType.") == "team"

	# The function reads no state, so repeated calls
	# agree exactly.
	var again: Dictionary = registry_state.source_team_entry_get_content_type_state()
	proof["content_type_deterministic"] = again == result

	# The value is a bare enum constant name: no
	# spaces, no extra dots, no parentheses.
	var suffix: String = text.trim_prefix("ContentType.")
	proof["content_type_is_enum_constant"] = text.begins_with("ContentType.") and not suffix.contains(" ") and not suffix.contains(".") and not suffix.contains("(")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamEntryGetContentTypeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
