# Handoff — Battery placement binding (N2079)

Date: 2026-11-07. Parent: `40e783f`. Sequential C01–C12 goal, C03 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-battery-placement-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Placed a battery in the bootstrap world, so the live power graph has a battery that the solar panel's surplus charges each frame.

- **N2079 `SourceWorldInitialBuildRuntimeState.source_battery_placement_state(tile_size) -> Dictionary`** — returns the battery's initial-build placement: `{block_id: "battery", role: "battery", cell: (23, 7), x, y, power_capacity: 4000.0}`. `initial_build_plan_state` appends it to the block placements, so `build_world` places it through the same `record_placed_block` path as the drill/core/duo/panel. New layout consts: `BATTERY_POS (23, 7)` (SourcePlayableWorldLayoutDefaults), `BLOCK_BATTERY "battery"` (SourcePlayableContentDefaults), `INITIAL_BUILD_ROLE_BATTERY` (SourcePlayableScenarioDefaults).

SSOT delta: **7 symbols / 2 schemas / 1 contract / 1 slice**. Totals now: **10740 symbols / 1534 slices / 1422 contracts / 2635 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — the audit's discovery only scans PortGame/PortBridge facade functions, so State `source_` functions are not counted there (validated by the catalog validator instead). No `source_modules` shard changed: no module selection matches `content/Blocks.java` for this owner, following the geometry/Teams-owner precedent.

## Why it exists

The backlog C03 gate needs battery charge/discharge and power 0/partial/full, but the bootstrap world had no battery — the N2078 solar panel produced a surplus (0.12 produced, 0 needed) with nowhere to store it. Now the graph has a battery (capacity 4000) and the live update charges it each frame (charged, 0.12/60 per frame, status > 0). A real power consumer is the follow-up that makes the discharge path and the 0/partial/full coverage testable.

## What the Godot proof shows

`BatteryPlacementProof` — 5/5 checks true on the real Main scene: the placement returns battery at (23, 7) with power_capacity 4000.0; the real Main scene has the battery sprite at (23, 7); the placed power graph now has 1 battery, 1 producer, 21 consumers (per origin cell — the panel is a producer, not a consumer), and the update charges the battery (charged true, power_battery_charged 0.12/60, battery power_status 0.0000005 > 0).

The N2077 proof was updated to the new world (battery_count 0 → 1, key renamed `power_graph_live_update_one_producer` → `power_graph_live_update_one_producer_one_battery`).

## Verification

- Full Python suite: **5453 tests OK in 1253.080s** (log `~/workspace/logs/full-suite-n2079.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files changed

- `godot-mindustry/src/game/SourcePlayableContentDefaults.gd` (BLOCK_BATTERY)
- `godot-mindustry/src/game/SourcePlayableScenarioDefaults.gd` (BLOCK_BATTERY, INITIAL_BUILD_ROLE_BATTERY, BATTERY_POS re-export)
- `godot-mindustry/src/game/SourcePlayableWorldLayoutDefaults.gd` (BATTERY_POS)
- `godot-mindustry/src/game/SourceWorldInitialBuildRuntimeState.gd` (N2079 + the initial-build placement)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/PowerGraphLiveUpdateProof.gd` (expectations updated to the new world: battery_count 1, key renamed to `power_graph_live_update_one_producer_one_battery`)
- `godot-mindustry/tools/runtime_proofs/BatteryPlacementProof.gd`
- `godot-mindustry/tools/runtime_proofs/BatteryPlacementProof.tscn`
- `tools/mindustry_godot_transpiler/register_battery_placement_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_battery_placement_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1533 → 1534, N2079 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-battery-placement-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-battery-placement-binding-handoff.md` (this handoff)

## Open items

- Adding a real power consumer (e.g. a lancer turret, powerUsage 6.0) to the bootstrap world so the 0/partial/full coverage and the battery discharge path are testable; the C03 gate needs those. C04–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for this slice.
