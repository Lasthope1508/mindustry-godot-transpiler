extends "res://src/game/SourcePlacedBlockPortBridge.gd"

const source_turret_cell_registry_state := preload("res://src/game/SourceTurretCellRegistryState.gd")

func register_turret_cell(cell: Vector2i, block) -> void:
	source_turret_cell_registry_state.register_turret_cell(self, cell, block)

func unregister_turret_cell(cell: Vector2i) -> void:
	source_turret_cell_registry_state.unregister_turret_cell(self, cell)
