# Handoff — Two-Drill gate binding (N2073)

Date: 2026-11-07. Parent: `5041e7e`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-two-drill-gate-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Made the live loop dump every drill's output when the dump timer fires (the two-Drill gate):

- **N2073 `SourceFactoryRuntimeState.source_factory_dump_all_drill_outputs_state(game, should_dump) -> Dictionary`** — the live-loop dump step. When `should_dump` is false it returns early with reason `timer_not_fired`. Otherwise it enumerates the drill buildings (via `placed.source_unique_buildings_state`, keeping only sprites with a drill frame meta and an `origin_cell`), resolves each drill's dominant item from its frame, and dumps it through the N2072 per-drill dump. Result keys: `results_by_cell`, `dumped_count`, `reason` (`timer_not_fired` / `no_drills` / `dumped` / `none_dumped`). All drills share the primary's SHOULD_DUMP — they share dumpTime 5 and were placed at bootstrap.
- **`simulate_factory` now calls the dump-all step** instead of the primary-only dump. The old primary-only call is removed from the live loop; the old entry still exists as the N2072 delegate for direct callers and the N2068 proof. The `test_playable` pin that asserted the old primary-only wiring now pins the new dump-all call and asserts the old call is gone.

SSOT delta: **5 symbols / 2 schemas / 1 contract / 1 slice**. Totals now: **10696 symbols / 1528 slices / 1416 contracts / 2623 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — this batch adds one State `source_` function (the dump-all step) and rewires `simulate_factory` to call it (the wiring is folded into this slice, per the N2068 lesson). The new production owner IS mirrored in the `production` module shards.

## Why it exists

The backlog C02 gate requires two drills (multiple conveyors/receivers/cores, capacity, blocked output, multiple items, exact in/out accounting and timers, no double production in one frame). Before this slice the live loop dumped only the primary drill, so a second drill's output accumulated in its frame forever (N2072 fixed the dump step to read the second drill's frame, but the live loop never called it). Now the live loop dumps every drill.

## What the Godot proof shows

`TwoDrillGateProof` — 9/9 checks true on the real Main scene: the step dumps both drills (dumped_count 2, both belts receive their item, both inventories lose one); the timer gate refuses and nothing moves; the live loop itself dumps both drills when the timer fires, with the core inventory unchanged.

## Verification

- Full Python suite: **5438 tests OK in 1139.000s** (log `~/workspace/logs/full-suite-n2073.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files changed

- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (N2073)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_state_schema.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/tools/runtime_proofs/TwoDrillGateProof.gd`
- `godot-mindustry/tools/runtime_proofs/TwoDrillGateProof.tscn`
- `tools/mindustry_godot_transpiler/register_two_drill_gate_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_two_drill_gate_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_playable.py` (the N2068-era primary-only dump pin now pins the dump-all call)
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1527 → 1528, N2073 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-two-drill-gate-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-two-drill-gate-binding-handoff.md` (this handoff)

## Open items

- The queue-to-sprite sync stays open in C02. C01 tail, C03–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for this slice.
