# Handoff — Solar panel placement binding (N2078)

Date: 2026-11-07. Parent: `dd5f846`. Sequential C01–C12 goal, C03 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-solar-panel-placement-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Placed a solar panel in the bootstrap world, so the live power graph has a producer.

- **N2078 `SourceWorldInitialBuildRuntimeState.source_solar_panel_placement_state(tile_size) -> Dictionary`** — returns the panel's initial-build placement: `{block_id: "solar-panel", role: "solar-panel", cell: (21, 7), x, y, power_production: 0.12}`. `initial_build_plan_state` appends it to the block placements, so `build_world` places it through the same `record_placed_block` path as the drill/core/duo. New layout consts: `SOLAR_PANEL_POS (21, 7)` (SourcePlayableWorldLayoutDefaults), `BLOCK_SOLAR_PANEL "solar-panel"` (SourcePlayableContentDefaults), `INITIAL_BUILD_ROLE_SOLAR_PANEL` (SourcePlayableScenarioDefaults).

SSOT delta: **7 symbols / 2 schemas / 1 contract / 1 slice**. Totals now: **10733 symbols / 1533 slices / 1421 contracts / 2633 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — the audit's discovery only scans PortGame/PortBridge facade functions, so State `source_` functions are not counted there (validated by the catalog validator instead). No `source_modules` shard changed: no module selection matches `content/Blocks.java` for this owner, following the geometry/Teams-owner precedent.

## A bug this slice exposed and fixed

The placed power graph never actually read the real game. `SourcePlacedPowerGraphState._group_state` iterates `placed_block_origins` and calls `block_from_sprite` on each value — but the real game's `placed_block_origins` maps a cell to its **Vector2i origin**, not to a sprite, so `block_from_sprite` returned null for every block and the graph always reported 0 consumers/producers/batteries. (The N2077 proof passed only because it expected those empty counts.) `SourceTextureRuntimeState.block_from_sprite` now resolves a Vector2i cell to its sprite via `block_sprite_at_cell` before the catalog lookup. The two `test_playable` pins that asserted the old `sprite.get_meta` line were updated to the new `resolved.get_meta` line. After the fix the graph sees the real world: 1 producer (the panel) and 21 consumers counted per origin cell (drill 4 + core 9 + conveyors 7 + duo 1), whose usage is 0 so the graph needs no power. The N2077 proof was updated to the new world (producer_count 1, power_produced 0.12/60, consumer_count 21).

## Why it exists

The backlog C03 gate needs power 0/partial/full, battery charge/discharge and multiple consumers, but the bootstrap world had no power producer or consumer — the duo turret and the mechanical drill do not consume power, and the N2077 live-loop update ran on an empty graph. Now the graph is non-empty and produces real power (0.12 per tick at full efficiency). A battery and a power consumer are the follow-up that makes the power flow testable.

## What the Godot proof shows

`SolarPanelPlacementProof` — 5/5 checks true on the real Main scene: the placement returns solar-panel at (21, 7) with power_production 0.12; the real Main scene has the panel sprite at (21, 7); the placed power graph now has 1 producer, 21 consumers (per origin cell), power_produced 0.12/60 and power_needed 0.0.

## Verification

- Full Python suite: **5450 tests OK in 1204.648s** (log `~/workspace/logs/full-suite-n2078.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files changed

- `godot-mindustry/src/game/SourcePlayableContentDefaults.gd` (BLOCK_SOLAR_PANEL)
- `godot-mindustry/src/game/SourcePlayableScenarioDefaults.gd` (BLOCK_SOLAR_PANEL, INITIAL_BUILD_ROLE_SOLAR_PANEL, SOLAR_PANEL_POS re-export)
- `godot-mindustry/src/game/SourcePlayableWorldLayoutDefaults.gd` (SOLAR_PANEL_POS)
- `godot-mindustry/src/game/SourceTextureRuntimeState.gd` (block_from_sprite resolves a Vector2i cell to its sprite)
- `godot-mindustry/src/game/SourceWorldInitialBuildRuntimeState.gd` (N2078 + the initial-build placement)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/PowerGraphLiveUpdateProof.gd` (expectations updated to the new world: producer_count 1, power_produced 0.12/60, consumer_count 21)
- `godot-mindustry/tools/runtime_proofs/SolarPanelPlacementProof.gd`
- `godot-mindustry/tools/runtime_proofs/SolarPanelPlacementProof.tscn`
- `tools/mindustry_godot_transpiler/register_solar_panel_placement_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_solar_panel_placement_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_playable.py` (two block_from_sprite pins updated to the new `resolved` line)
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1532 → 1533, N2078 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-solar-panel-placement-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-solar-panel-placement-binding-handoff.md` (this handoff)

## Open items

- Adding a battery and a power consumer to the bootstrap world so the power flow (charge/discharge, 0/partial/full, multiple consumers) is testable; the C03 gate needs those. C04–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for this slice.
