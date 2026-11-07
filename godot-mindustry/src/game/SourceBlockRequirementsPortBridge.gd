extends "res://src/game/SourceBlockResearchRequirementsPortBridge.gd"

const source_block_requirements_state := preload("res://src/game/SourceBlockRequirementsState.gd")

func can_afford(block) -> bool:
	return source_block_requirements_state.game_can_afford(self, block)

func spend_requirements(block) -> void:
	source_block_requirements_state.game_spend_requirements(self, block)

func requirements_text(block) -> String:
	return source_block_requirements_state.block_requirements_text(block)

func source_block_setup_requirements_simple_state(cat: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.setup_requirements_simple_state(cat, stacks)

func generated_block_setup_requirements_simple_bridge_state(cat: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.generated_block_setup_requirements_simple_bridge_state(cat, stacks)

func source_block_setup_requirements_visible_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.setup_requirements_visible_state(cat, build_visibility, stacks)

func generated_block_setup_requirements_visible_bridge_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.generated_block_setup_requirements_visible_bridge_state(cat, build_visibility, stacks)

func source_block_requirements_unlocked_state(cat: Variant, stacks: Variant, unlocked: bool) -> Dictionary:
	return source_block_requirements_state.requirements_unlocked_state(cat, stacks, unlocked)

func generated_block_requirements_unlocked_bridge_state(cat: Variant, stacks: Variant, unlocked: bool) -> Dictionary:
	return source_block_requirements_state.generated_block_requirements_unlocked_bridge_state(cat, stacks, unlocked)

func source_block_requirements_simple_state(cat: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.requirements_simple_state(cat, stacks)

func generated_block_requirements_simple_bridge_state(cat: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.generated_block_requirements_simple_bridge_state(cat, stacks)

func source_block_requirements_visible_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.requirements_visible_state(cat, build_visibility, stacks)

func generated_block_requirements_visible_bridge_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.generated_block_requirements_visible_bridge_state(cat, build_visibility, stacks)
