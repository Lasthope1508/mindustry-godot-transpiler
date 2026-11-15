extends "res://src/game/SourcePortGameCoreStatePortBridge.gd"

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_liquid_reaction_state := preload("res://src/game/SourceLiquidReactionState.gd")
const source_power_defaults := preload("res://src/game/SourcePowerDefaults.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")

var build_palette: Array = []
var selected_build_index := 0
var ore_items_by_cell: Dictionary = {}
var placed_blocks: Dictionary = {}
var placed_block_origins: Dictionary = {}
var mend_projector_charges: Dictionary = {}
var mend_projector_smooth_efficiency: Dictionary = {}
var mend_projector_heat: Dictionary = {}
var mend_projector_phase_heat: Dictionary = {}
var mend_projector_optional_efficiency: Dictionary = {}
var mend_projector_booster_items: Dictionary = {}
var mend_projector_booster_timers: Dictionary = {}
var overdrive_projector_charges: Dictionary = {}
var overdrive_projector_smooth_efficiency: Dictionary = {}
var overdrive_projector_heat: Dictionary = {}
var overdrive_projector_phase_heat: Dictionary = {}
var overdrive_projector_optional_efficiency: Dictionary = {}
var overdrive_projector_booster_items: Dictionary = {}
var overdrive_projector_use_progress: Dictionary = {}
var initial_world_block_count := 0
var initial_occupied_cell_count := 0
var player_placed_block_count := 0
var last_placed_block_id := ""
var last_placed_block_size := 0
var last_placed_block_requirements: Array = []
var last_placed_cell := Vector2i.ZERO
var last_placed_occupied_cell_count := 0
var last_place_blocked := false
# N2199: lastBuild per block def (ItemBridge.java:41-42, `//for autolink` / `public @Nullable ItemBridgeBuild lastBuild;`) -- Java stores the Building reference on the Block; the port stores the origin cell (Vector2i) keyed by block id and resolves the sprite through placed_blocks. One entry per def; never cleared on removal, overwritten by the next placement of the same def.
var source_item_bridge_last_build_by_block: Dictionary = {}
var last_mend_projector_healed_amount := 0.0
var last_mend_projector_healed_block_id := ""
var last_mend_projector_healed_cell := Vector2i.ZERO
var last_mend_projector_target_health := 0.0
var last_mend_projector_target_max_health := 0.0
var last_overdrive_projector_boost_range := 0.0
var last_overdrive_projector_boost := 0.0
var last_overdrive_projector_boost_duration := 0.0
var last_overdrive_projector_boosted_block_id := ""
var last_overdrive_projector_boosted_cell := Vector2i.ZERO
