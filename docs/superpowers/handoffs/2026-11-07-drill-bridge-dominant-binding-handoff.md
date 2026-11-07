# Handoff — Drill bridge dominant-item binding (N2071)

Date: 2026-11-07. Parent: `f28a078`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-drill-bridge-dominant-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Made the drill runtime bridge use the actual dominant item instead of the game-global:

- **N2071 `PortGame.source_drill_runtime_state(seconds) -> Dictionary`** — the drill runtime bridge (in `SourceDrillRuntimePortBridge.gd`; the owner is `PortGame.*` per the PortBridge discovery rule). It resolves the drill sprite at `drill_pos`, reads the actual dominant item from its frame via `source_dominant_item_name_state` (the frame's `dominant_item`, set by the onProximityUpdate ore scan), and passes that item id into `runtime_context` instead of the game-global `drill_output_item_id`. The `drill_ore_cell_count` still comes from the game-global; it matches the frame's `dominant_items` for the primary drill. Result keys: `drill_active, drill_warmup_before, drill_warmup, drill_last_speed_before, drill_last_speed, drill_time_drilled_before, drill_time_drilled_delta, drill_time_drilled, drill_delay, drill_output_delta, production_state, offload_amount, produced_delta, item_progress, source_owner`.

SSOT delta: **16 symbols / 2 schemas / 1 contract / 1 slice**. Totals now: **10677 symbols / 1526 slices / 1414 contracts / 2619 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — this batch adds no PortGame/PortBridge owner (the function already existed; the slice registers it). The new production owner IS mirrored in the `production` module shards.

## Why it exists

The backlog checkpoint C01-C requires production/offload to use the actual dominant item instead of the game-global `drill_output_item_id`. The live factory loop already did (it resolves the dominant item via `source_dominant_item_name_state`); the drill runtime bridge still read the global, which defaults to copper and is only correct while the drill sits on copper ore. Now both paths resolve the dominant item from the drill frame.

## What the Godot proof shows

`DrillBridgeDominantProof` — 9/9 checks true on the real Main scene: with the game-global set to titanium (delay 750), the bridge still reports the copper delay 650 (the actual dominant item); the delay matches the copper delay computed directly and differs from titanium's; the global is left untouched; with the global set back to copper the delay is the same.

## Verification

- Full Python suite: **5432 tests OK in 1126.274s** (log `~/workspace/logs/full-suite-n2071.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files changed

- `godot-mindustry/src/game/SourceDrillRuntimePortBridge.gd` (N2071)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_state_schema.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/tools/runtime_proofs/DrillBridgeDominantProof.gd`
- `godot-mindustry/tools/runtime_proofs/DrillBridgeDominantProof.tscn`
- `tools/mindustry_godot_transpiler/register_drill_bridge_dominant_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_drill_bridge_dominant_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1525 → 1526, N2071 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-drill-bridge-dominant-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-drill-bridge-dominant-binding-handoff.md` (this handoff)

## Open items

- The one-inventory-owner cleanup, the two-Drill gate and the queue-to-sprite sync stay open in C02. C01 tail, C03–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for this slice.
