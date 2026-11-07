# Handoff — ConveyorBuild queue primitives binding (N2053–N2055)

Date: 2026-11-07. Parent: `727b8a2`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-conveyor-queue-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound the conveyor item queue — the parallel arrays the intake inserts into:

- **N2053 `SourceConveyorRuntimeState.source_conveyor_queue_add_state(ids, xs, ys, len, index) -> Dictionary`** — add(o): shifts the three parallel arrays right from the insertion index and increments len; the slot at `index` keeps its old value (duplicated) for the caller (handleItem) to overwrite with the inserted item and its x/y. Inserting at the end performs no shift. Result keys: `ids_after, xs_after, ys_after, len_before, len_after, shifted, reason` (shifted, invalid_index).
- **N2054 `SourceConveyorRuntimeState.source_conveyor_queue_remove_state(ids, xs, ys, len, index) -> Dictionary`** — remove(o): shifts the three parallel arrays left from the removal index, drops the stale tail and decrements len. Same result keys.
- **N2055 `SourceConveyorRuntimeState.source_conveyor_queue_scan_state(ys, passed_by_index) -> Dictionary`** — the updateTile mid/minitem scan: `mid = i - 1` for every `i > 0` with `ys[i] > 0.5` (iterating from the last item down, so the final value comes from the smallest such i), and `minitem` is the smallest y among items that did not pass (starting from 1.0). Result keys: `mid, minitem`. The `passed_by_index` input models the `pass(ids[i])` branch of the same loop; per-frame movement stays with the path-progress runtime.

SSOT delta: **28 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10461 symbols / 1510 slices / 1398 contracts / 2587 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — no PortGame/PortBridge owner in this batch. The new owner contracts ARE mirrored in the `conveyor` module shards (`source_modules/conveyor_api_contracts.json`, `conveyor_slices.json`, `conveyor_state_schema.json`, `conveyor_symbols.json`).

## How it was verified

- RED first: registration test failed (failures=1, errors=4) with the proof scene missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Conveyor.java`), `test_tile_slice` 41 OK, binding + liquid + catalog suites 81 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `ConveyorQueueProof` — all 18 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/ConveyorQueueProof.json`. One design note: Java's `add(o)` loop starts at `Math.max(o + 1, len)`, so inserting at the end performs one stale copy beyond the new length; the GDScript version skips the shift there (same visible queue, no out-of-bounds write).
- Full Python suite: **5411 tests OK in 1018.477s** (log `~/workspace/logs/full-suite-n2053.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceConveyorRuntimeState.gd` (N2053 + N2054 + N2055)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_modules/conveyor_api_contracts.json`, `conveyor_slices.json`, `conveyor_state_schema.json`, `conveyor_symbols.json` (conveyor shards mirror the new ConveyorBuild owners; the audit report was regenerated but is byte-identical — `totalSourceFunctions` stays 1335, no new PortGame/PortBridge owner)
- `godot-mindustry/tools/runtime_proofs/ConveyorQueueProof.gd`, `ConveyorQueueProof.tscn`
- `tools/mindustry_godot_transpiler/register_conveyor_queue_binding.py`, `tools/mindustry_godot_transpiler/tests/test_conveyor_queue_binding.py`
- `docs/superpowers/reports/2026-11-07-conveyor-queue-binding.md`, `docs/superpowers/handoffs/2026-11-07-conveyor-queue-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1507 → 1510, N2053–N2055 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `ConveyorQueueProof.gd.uid` and the earlier proof `.uid` files are untracked noise from proof runs; leave them alone.

## What is still open (next batch)

1. C02: `ConveyorBuild.removeStack` (bulk removal over the queue), then the live drill→conveyor→core wiring (the dump composition's hooks to these intake/queue functions for a real chain), the drill runtime bridge's game-global `drill_output_item_id` (make it use the actual dominant item), the one-inventory-owner cleanup, and the backlog's two-Drill gate (multiple conveyors/receivers/cores, capacity and blocked-output cases, exact in/out accounting, no double production in one frame).
2. C01 tail: entity group membership, controller pickup and world transition invalidation (need the unit system and campaign state machine), `Conveyor.unitOn`'s unit-pushing body, remaining Tile/Floor side effects.
3. Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
