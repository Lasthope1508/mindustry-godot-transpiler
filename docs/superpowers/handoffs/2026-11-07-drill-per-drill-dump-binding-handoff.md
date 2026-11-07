# Handoff — Per-drill dump binding (N2072)

Date: 2026-11-07. Parent: `ff2d8ba`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-drill-per-drill-dump-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Made the drill dump step use each drill's own inventory (one inventory owner per drill):

- **N2072 `SourceFactoryRuntimeState.source_factory_dump_drill_output_for_cell_state(game, drill_cell, drill_output_item_id) -> Dictionary`** — the per-drill dump step. It reads the drill's own inventory: if the drill cell is the primary (`drill_cell == game.drill_pos`) it reads the game-global `drill_items`; otherwise it reads the drill frame's `items`. It writes back the frame's `items` always, and the game-global only for the primary. The rest of the step is unchanged (the ring via N2064, the queues via N2067, the dump composition via N2062/N2063, the receiver-only queue write-back). Result keys: `dumped, item_id, receiver_index, receiver_cell, cdump_before, cdump_after, items_after, queues_after, removed, destination, reason`.
- **The old entry `source_factory_dump_drill_output_state` is now a thin delegate** to the per-drill function, so the N2068 contract and proof keep working unchanged.

SSOT delta: **14 symbols / 2 schemas / 1 contract / 1 slice**. Totals now: **10691 symbols / 1527 slices / 1415 contracts / 2621 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — this batch adds one State `source_` function (the per-drill dump) and keeps the old entry as a delegate. The new production owner IS mirrored in the `production` module shards.

## Why it exists

The backlog rule "Giữ một inventory owner; không vừa frame-local vừa game-global ghi cùng amount" (keep one inventory owner; don't write the same amount to both frame-local and game-global). Before this slice the dump step always read the game-global `drill_items`, so a second drill's output (produced into its own frame by `source_tick_state`) never reached a belt or the core. Now each drill dumps from its own inventory.

## What the Godot proof shows

`DrillPerDrillDumpProof` — 8/8 checks true on the real Main scene: a second drill at (28,20) on lead ore dumps lead from its own frame (the (30,20) belt receives it, cdump 0→3) while the primary's game-global inventory stays untouched; the primary still dumps from the game-global through the old entry.

## Verification

- Full Python suite: **5435 tests OK in 1124.250s** (log `~/workspace/logs/full-suite-n2072.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files changed

- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (N2072)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_state_schema.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/tools/runtime_proofs/DrillPerDrillDumpProof.gd`
- `godot-mindustry/tools/runtime_proofs/DrillPerDrillDumpProof.tscn`
- `tools/mindustry_godot_transpiler/register_drill_per_drill_dump_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_drill_per_drill_dump_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1526 → 1527, N2072 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-drill-per-drill-dump-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-drill-per-drill-dump-binding-handoff.md` (this handoff)

## Open items

- The live loop still dumps only the primary drill; the two-Drill gate (simulate_factory dumping each drill) stays open in C02. The queue-to-sprite sync stays open in C02. C01 tail, C03–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for this slice.
