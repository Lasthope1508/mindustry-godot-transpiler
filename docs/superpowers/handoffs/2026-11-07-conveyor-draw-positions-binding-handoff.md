# Handoff — Conveyor item draw positions binding (N2076)

Date: 2026-11-07. Parent: `2861c39`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-conveyor-draw-positions-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound the Java conveyor draw formula (Conveyor.java:163-173), the source-backed core of the C02 queue-to-sprite sync, in `SourceConveyorRuntimeState.gd`.

- **N2076 `SourceConveyorRuntimeState.source_conveyor_item_draw_positions_state(queue, center, rotation, tilesize) -> Dictionary`** — for each item in the queue, computes its world position from the Java draw formula: `along = Vector2(tilesize, 0).rotated(angle)`, `lateral = Vector2(-tilesize/2, xs[i]*tilesize/2).rotated(angle)`, `x = center.x + along.x * ys[i] + lateral.x`, `y = center.y + along.y * ys[i] + lateral.y`. Java is y-up and Godot is y-down, so the rotation angle is negated (`angle = deg_to_rad(rotation * -90)`). Result keys: `positions` (one `{item_id, x, y}` per queue item, in queue order), `count`.

SSOT delta: **6 symbols / 2 schemas / 1 contract / 1 slice**. Totals now: **10718 symbols / 1531 slices / 1419 contracts / 2629 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — the audit's discovery only scans PortGame/PortBridge facade functions, so State `source_` functions are not counted there (validated by the catalog validator instead). The conveyor module shards mirror the new owner (all 4 files).

## Why it exists

The backlog C02 tail is the queue-to-sprite sync: the transport runtime is purely visual — a fixed number of item sprites spaced evenly by phase along the path, with no item identity — while the conveyor queues (N2065–N2067) carry item identity (ids, xs, ys). This slice is the formula that converts a queue into the world positions the sprites must occupy, so the sync has a source-backed computation to drive from. The live-loop wiring that actually moves the sprites is a separate design decision and is still open.

## What the Godot proof shows

`ConveyorDrawPositionsProof` — 5/5 checks true on the real Main scene: rotation 0/1/2 place the queue items at the hand-computed Java positions for a known queue and center; an empty queue positions nothing; the real (9,8) belt, with its queue set to the known queue, positions its items at the expected offsets from its real sprite center and rotation.

## Verification

- Full Python suite: **5444 tests OK in 1162.564s** (log `~/workspace/logs/full-suite-n2076.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files changed

- `godot-mindustry/src/game/SourceConveyorRuntimeState.gd` (N2076)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/conveyor_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/conveyor_slices.json`
- `godot-mindustry/src/generated/source_modules/conveyor_state_schema.json`
- `godot-mindustry/src/generated/source_modules/conveyor_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/ConveyorDrawPositionsProof.gd`
- `godot-mindustry/tools/runtime_proofs/ConveyorDrawPositionsProof.tscn`
- `tools/mindustry_godot_transpiler/register_conveyor_draw_positions_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_conveyor_draw_positions_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1530 → 1531, N2076 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-conveyor-draw-positions-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-conveyor-draw-positions-binding-handoff.md` (this handoff)

## Open items

- The live-loop wiring that drives the visual item sprites from these queue-derived positions is still open in C02. Per-belt clogHeat persistence is also still open. C03–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for this slice.
