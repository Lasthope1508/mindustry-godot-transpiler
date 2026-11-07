# Handoff — Per-building power graph grouping binding (N2081)

Date: 2026-11-08. Parent: `ad44532`. Sequential C01–C12 goal, C03 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-placed-power-graph-grouping-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Fixed the placed power graph to group each building once, as Java does.

- **N2081 `SourcePlacedPowerGraphState.source_group_buildings_by_origin_state(placed_block_origins) -> Dictionary`** — returns `{origins, count}`: the unique building origins (one per building) from the placed-block origins map. `_group_state` now iterates those unique origins instead of every key of the map, so each building is grouped once. The origins are kept as Variants (Vector2i for the real game, distinct sprites for the module proof's fake game).

SSOT delta: **3 symbols / 2 schemas / 1 contract / 1 slice**. Totals now: **10750 symbols / 1536 slices / 1424 contracts / 2639 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — the audit's discovery only scans PortGame/PortBridge facade functions, so State `source_` functions are not counted there (validated by the catalog validator instead). The power module shards mirror the new owner (`power_api_contracts.json`, `power_slices.json`), as they did for N2077.

## Why it exists

The N2080 batch exposed a divergence: `placed_block_origins` holds one key per footprint cell, so `_group_state` grouped a size-2 building 4 times and a size-3 core 9 times, each cell carrying the block's full usage. The lancer was counted 4x, so the graph needed 0.4 instead of Java's 0.1 and coverage was 0.005 instead of 0.02. Java's `PowerGraph.add(Building)` (PowerGraph.java:277-301) adds each building once, guarded by `build.power.graph != this || !build.power.init`. Now the graph has 11 consumers / 1 producer / 1 battery, needs 0.1, coverage 0.02 — the Java value.

## What the Godot proof shows

`PlacedPowerGraphGroupingProof` — 5/5 checks true on the real Main scene: 13 unique origins (13 buildings) including (7, 8) and (25, 7); the graph has 11 consumers, 1 producer, 1 battery, power_needed 6.0/60, power_produced 0.12/60, coverage 0.02; the live loop runs the grouped step each frame with the same counts.

The N2077, N2078, N2079 and N2080 proofs were updated to the grouped counts (consumer_count 25 → 11, power_needed 0.4 → 6.0/60, coverage 0.005 → 0.02).

## Verification

- Full Python suite: **5459 tests OK in 1236.410s** (log `~/workspace/logs/full-suite-n2081.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files changed

- `godot-mindustry/src/game/SourcePlacedPowerGraphState.gd` (N2081 + the `_group_state` grouping)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/src/generated/source_modules/power_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/power_slices.json`
- `godot-mindustry/tools/runtime_proofs/PowerGraphLiveUpdateProof.gd` (grouped counts; key renamed to `power_graph_live_update_grouped_by_building`)
- `godot-mindustry/tools/runtime_proofs/SolarPanelPlacementProof.gd` (consumer_count 11, power_needed 6.0/60)
- `godot-mindustry/tools/runtime_proofs/BatteryPlacementProof.gd` (consumer_count 11)
- `godot-mindustry/tools/runtime_proofs/LancerPlacementProof.gd` (consumer_count 11, power_needed 6.0/60, coverage 0.02)
- `godot-mindustry/tools/runtime_proofs/PlacedPowerGraphGroupingProof.gd`
- `godot-mindustry/tools/runtime_proofs/PlacedPowerGraphGroupingProof.tscn`
- `tools/mindustry_godot_transpiler/register_placed_power_graph_grouping_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_placed_power_graph_grouping_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1535 → 1536, N2081 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-placed-power-graph-grouping-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-placed-power-graph-grouping-binding-handoff.md` (this handoff)

## Open items

- The battery discharge path (a charged battery covering a deficit) and the full-power case (coverage 1.0); connection removal/split and building disabled/full-output cases. C04–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for this slice.
