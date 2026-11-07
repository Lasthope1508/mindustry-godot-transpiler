# Handoff — Lancer turret placement binding (N2080)

Date: 2026-11-07. Parent: `7a6b29c`. Sequential C01–C12 goal, C03 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-lancer-placement-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Placed a lancer turret in the bootstrap world, so the live power graph has a real power consumer and runs at partial coverage.

- **N2080 `SourceWorldInitialBuildRuntimeState.source_lancer_placement_state(tile_size) -> Dictionary`** — returns the lancer's initial-build placement: `{block_id: "lancer", role: "lancer", cell: (25, 7), x, y, power_usage: 6.0}`. `initial_build_plan_state` appends it to the block placements, so `build_world` places it through the same `record_placed_block` path as the drill/core/duo/panel/battery. New layout consts: `LANCER_POS (25, 7)` (SourcePlayableWorldLayoutDefaults), `BLOCK_LANCER "lancer"` (SourcePlayableContentDefaults), `INITIAL_BUILD_ROLE_LANCER` (SourcePlayableScenarioDefaults).

SSOT delta: **7 symbols / 2 schemas / 1 contract / 1 slice**. Totals now: **10747 symbols / 1535 slices / 1423 contracts / 2637 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — the audit's discovery only scans PortGame/PortBridge facade functions, so State `source_` functions are not counted there (validated by the catalog validator instead). No `source_modules` shard changed: no module selection matches `content/Blocks.java` for this owner, following the geometry/Teams-owner precedent.

## Why it exists

The backlog C03 gate needs power 0/partial/full and battery charge/discharge, but the bootstrap world had no real power consumer — the panel produced a surplus (0.12 produced, 0 needed) and the battery just charged. Now the lancer (powerUsage 6.0) makes the graph run at partial coverage (0.005) and the battery stops charging, which is the deficit case. The discharge path and the full-power case are still open.

## What the Godot proof shows

`LancerPlacementProof` — 5/5 checks true on the real Main scene: the placement returns lancer at (25, 7) with power_usage 6.0; the real Main scene has the lancer sprite at (25, 7); the placed power graph now has 25 consumers (21 + the lancer's 4 footprint cells), 1 producer, 1 battery, power_needed 0.4, power_produced 0.12/60, coverage 0.005, and the battery does not charge.

The N2077, N2078 and N2079 proofs were updated to the new world (consumer_count 21 → 25, power_needed 0.0 → 0.4; the N2079 battery proof now asserts the deficit instead of the charge).

## A divergence this slice exposes (not fixed here)

The placed power graph counts each consumer **per footprint cell**, and each cell carries the block's full usage. The size-2 lancer is counted 4 times with usage 6.0 each, so the graph needs 0.4 per frame; Java counts each building once, so the Java need would be 0.1 and coverage 0.02. Fixing it means grouping by origin building in `_group_state`, which changes every count the proofs pin — a separate slice, deferred.

## Verification

- Full Python suite: **5456 tests OK in 1225.740s** (log `~/workspace/logs/full-suite-n2080.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files changed

- `godot-mindustry/src/game/SourcePlayableContentDefaults.gd` (BLOCK_LANCER)
- `godot-mindustry/src/game/SourcePlayableScenarioDefaults.gd` (BLOCK_LANCER, INITIAL_BUILD_ROLE_LANCER, LANCER_POS re-export)
- `godot-mindustry/src/game/SourcePlayableWorldLayoutDefaults.gd` (LANCER_POS)
- `godot-mindustry/src/game/SourceWorldInitialBuildRuntimeState.gd` (N2080 + the initial-build placement)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/PowerGraphLiveUpdateProof.gd` (expectations updated to the new world: consumer_count 25, power_needed 0.4, key renamed to `power_graph_live_update_one_producer_one_battery_one_consumer`)
- `godot-mindustry/tools/runtime_proofs/SolarPanelPlacementProof.gd` (consumer_count 25, power_needed 0.4)
- `godot-mindustry/tools/runtime_proofs/BatteryPlacementProof.gd` (consumer_count 25, now asserts the deficit instead of the charge)
- `godot-mindustry/tools/runtime_proofs/LancerPlacementProof.gd`
- `godot-mindustry/tools/runtime_proofs/LancerPlacementProof.tscn`
- `tools/mindustry_godot_transpiler/register_lancer_placement_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_lancer_placement_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1534 → 1535, N2080 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-lancer-placement-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-lancer-placement-binding-handoff.md` (this handoff)

## Open items

- The battery discharge path (a charged battery covering a deficit) and the full-power case (coverage 1.0); the per-cell usage divergence in `_group_state`. C04–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for this slice.
