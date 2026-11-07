# Handoff — Drill→conveyor dump wiring hooks binding (N2059–N2061)

Date: 2026-11-07. Parent: `a7e27df`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-drill-conveyor-dump-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound the wiring layer between the drill and the conveyor:

- **N2059 `SourceBlockGeometry.source_block_facing_edge_state(block_size, tile_x, tile_y, other_x, other_y) -> Dictionary`** — Edges.getFacingEdge: size 1 returns the tile itself; a multiblock clamps the offset to the neighbor (`-(size - 1) / 2 .. size / 2`, integer division, negation after the division to match Java's truncation). Result keys: `edge_x, edge_y, is_multiblock, reason` (tile, facing_edge). The size-2 drill at (7,8) facing the conveyor at (9,8) gives the edge (8,8).
- **N2060 `SourceConveyorRuntimeState.source_conveyor_accept_for_cell_state(queue_ids, queue_xs, queue_ys, queue_len, capacity, item_space, source_cell, conveyor_cell, conveyor_rotation, source_block_rotate, next_is_source) -> Dictionary`** — the accept hook for a real neighbor cell: the facing direction from the source edge cell via the existing `tile_relative_cardinal_state`, minitem from the N2055 queue scan, then the N2050 accept arms. Result keys: `accepted, direction, facing_direction, minitem, reason`.
- **N2061 `SourceConveyorRuntimeState.source_conveyor_handle_for_cell_state(queue_ids, queue_xs, queue_ys, queue_len, capacity, item_space, source_cell, conveyor_cell, conveyor_rotation, item_id, item_count_before) -> Dictionary`** — the handle hook for a real neighbor cell: the facing direction and mid from the queue scan, then the N2051 intake applied via the N2053 queue add. Result keys: `ids_after, xs_after, ys_after, len_before, len_after, index, x, y, item_count_after, no_sleep_called, reason`.

SSOT delta: **47 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10547 symbols / 1516 slices / 1404 contracts / 2599 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — no PortGame/PortBridge owner in this batch. The new conveyor owner contracts ARE mirrored in the `conveyor` module shards; the geometry owner (N2059) is NOT mirrored, matching the N2029 precedent.

## How it was verified

- RED first: registration test failed (failures=1, errors=4) with the proof scene missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Edges.java`, `Tile.java`, `Conveyor.java` and `Block.java`), `test_tile_slice` 41 OK, binding + liquid + catalog suites 87 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `DrillConveyorDumpProof` — all 19 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/DrillConveyorDumpProof.json`. The proof reads the real scene's conveyor rotation meta at (9,8) (0) and the drill's facing edge (8,8).
- Design correction: the first registration bound the dump step before the facing edge existed, but the size-2 drill's origin (7,8) is not near the conveyor (9,8), so the accept would fail closed. The batch was reverted cleanly (`git checkout` of both GDScript files and all touched SSOT JSONs, back to 1513 slices) and re-registered as edge + accept-for-cell + handle-for-cell; the dump step moves to the next batch (N2062). The reverted files were never committed.
- Label correction: the direction numbering is 0 east / 1 north / 2 west / 3 south (Mindustry rotations), not 0 west / 2 east as the N2050 summary said; the arms only use the absolute difference and parity, so N2050–N2058 behavior is unaffected.
- Full Python suite: **5417 tests OK in 1048.743s** (log `~/workspace/logs/full-suite-n2059.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceBlockGeometry.gd` (N2059)
- `godot-mindustry/src/game/SourceConveyorRuntimeState.gd` (N2060 + N2061)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_modules/conveyor_api_contracts.json`, `conveyor_slices.json`, `conveyor_state_schema.json`, `conveyor_symbols.json` (conveyor shards mirror the new ConveyorBuild owners; the geometry owner is not mirrored; the audit report was regenerated but is byte-identical — `totalSourceFunctions` stays 1335, no new PortGame/PortBridge owner)
- `godot-mindustry/tools/runtime_proofs/DrillConveyorDumpProof.gd`, `DrillConveyorDumpProof.tscn`
- `tools/mindustry_godot_transpiler/register_drill_conveyor_dump_binding.py`, `tools/mindustry_godot_transpiler/tests/test_drill_conveyor_dump_binding.py`
- `docs/superpowers/reports/2026-11-07-drill-conveyor-dump-binding.md`, `docs/superpowers/handoffs/2026-11-07-drill-conveyor-dump-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1513 → 1516, N2059–N2061 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `DrillConveyorDumpProof.gd.uid` and the earlier proof `.uid` files are untracked noise from proof runs; leave them alone.

## What is still open (next batch)

1. C02: the drill dump step (N2062) — the dump composition (N2049) with the N2060/N2061 hooks over caller-supplied conveyor queues keyed by cell, cells without a queue failing closed, proven on the real Main scene with the drill's proximity ring and the conveyor at (9,8). Then runtime queue storage for a conveyor, the live loop swap (replacing the direct-to-core dump), the drill runtime bridge's game-global `drill_output_item_id` (make it use the actual dominant item), the one-inventory-owner cleanup, and the backlog's two-Drill gate (multiple conveyors/receivers/cores, capacity and blocked-output cases, exact in/out accounting, no double production in one frame).
2. C01 tail: entity group membership, controller pickup and world transition invalidation (need the unit system and campaign state machine), `Conveyor.unitOn`'s unit-pushing body, remaining Tile/Floor side effects.
3. Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
