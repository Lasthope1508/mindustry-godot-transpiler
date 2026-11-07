# Handoff — Drill dump step binding (N2062–N2064)

Date: 2026-11-07. Parent: `d60d108`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-drill-dump-step-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound the drill dump step — the dump composition with the conveyor hooks over caller-supplied queues:

- **N2062 `SourceBuildingItemDumpState.source_drill_dump_step_state(items, proximity_cells, todump, cdump, has_items, queues_by_cell, capacity, item_space, conveyor_rotation_by_cell, source_block_rotate, next_is_source, drill_cell, drill_size) -> Dictionary`** — the specific dump step: the N2047 dump-specific composition with hooks built from the N2060/N2061 conveyor functions. The accept hook computes the facing edge per neighbor via N2059 and passes that edge cell as the source cell — passing the drill origin (7,8) directly would fail for the size-2 drill. The handle hook derives the conveyor's items-module count by counting the item in the queue's ids and writes the updated queue back into `queues_after`. Cells without a queue fail closed. Result keys: `dumped, item_id, receiver_index, receiver_cell, cdump_before, cdump_after, items_after, queues_after, removed, destination, reason`.
- **N2063 `SourceBuildingItemDumpState.source_drill_dump_any_step_state(items, proximity_cells, cdump, has_items, content_item_ids, queues_by_cell, capacity, item_space, conveyor_rotation_by_cell, source_block_rotate, next_is_source, drill_cell, drill_size) -> Dictionary`** — the any dump step: the N2048 dump-any composition (`dump(null)`) with the same hooks; items tried in content order per neighbor. Result keys: the same 11 as N2062.
- **N2064 `SourceBlockGeometry.source_block_proximity_cells_state(block_size, tile_x, tile_y) -> Dictionary`** — the proximity ring from `Edges.getEdges`: ring offsets for a block size, built bottom/top/left/right then sorted by atan2 angle ascending, translated to absolute cells. Result keys: `cells, count, reason`. Size 2 at (7,8) gives [(7,7), (8,7), (9,8), (9,9), (8,10), (7,10), (6,9), (6,8)].

SSOT delta: **54 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10601 symbols / 1519 slices / 1407 contracts / 2605 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — no PortGame/PortBridge owner in this batch. The new BuildingComp owner contracts ARE mirrored in the `comp` module shards (`comp_api_contracts.json`, `comp_slices.json`); the geometry owner (N2064) is NOT mirrored, matching the N2029 precedent.

## How it was verified

- RED first: registration test failed (failures=1, errors=4) with the proof scene missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `BuildingComp.java`, `Conveyor.java`, `Edges.java` and `Tile.java`), `test_tile_slice` and binding + liquid + catalog suites 68 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `DrillDumpStepProof` — all 15 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/DrillDumpStepProof.json`. The proof reads the real scene's conveyor rotation meta at (9,8) (0) and the N2064 ring; the dump from cdump 0 visits (7,7) and (8,7) (no queue, fail closed) then lands on the (9,8) belt at receiver index 2 with cdump 0→3.
- Bug found and fixed: the first proof run failed 2 checks (`drill_dump_step_first`, `drill_dump_any_first`) — the dump reported `dumped=true` but the (9,8) queue stayed empty. The handle hook checked `handled.get("accepted", false)`, but N2061's handle-for-cell result has no `accepted` key — it signals refusal with `index == -1`. The hook now writes the queue when `int(handled.get("index", -1)) >= 0`. A debug scene (`DebugDumpStep`, deleted after use) printed the raw step results and confirmed the fix.
- Full Python suite: **5420 tests OK in 1060.005s** (log `~/workspace/logs/full-suite-n2062.log`). The first full-suite run was killed mid-way by a service restart (log ended in progress dots with no summary); the re-run completed cleanly. Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceBuildingItemDumpState.gd` (N2062 + N2063)
- `godot-mindustry/src/game/SourceBlockGeometry.gd` (N2064)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_modules/comp_api_contracts.json`, `comp_slices.json` (comp shards mirror the new BuildingComp owners; the geometry owner is not mirrored; the audit report was regenerated but is byte-identical — `totalSourceFunctions` stays 1335, no new PortGame/PortBridge owner)
- `godot-mindustry/tools/runtime_proofs/DrillDumpStepProof.gd`, `DrillDumpStepProof.tscn`
- `tools/mindustry_godot_transpiler/register_drill_dump_step_binding.py`, `tools/mindustry_godot_transpiler/tests/test_drill_dump_step_binding.py`
- `docs/superpowers/reports/2026-11-07-drill-dump-step-binding.md`, `docs/superpowers/handoffs/2026-11-07-drill-dump-step-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1516 → 1519, N2062–N2064 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `DrillDumpStepProof.gd.uid` and the earlier proof `.uid` files are untracked noise from proof runs; leave them alone.

## What is still open (next batch)

1. C02: runtime queue storage for a conveyor (no storage exists yet — the sprite meta pattern used for the drill frame, or a game dict keyed by cell, is undecided), then the live loop swap (replacing `simulate_factory`'s direct dump-to-core call with the dump step — check `FactoryRuntimeModuleProof` and `DrillLiveConsumptionProof` first, since they assert core inventory increases and a conveyor-mediated path delays core receipt), the drill runtime bridge's game-global `drill_output_item_id` (make it use the actual dominant item), the one-inventory-owner cleanup, and the backlog's two-Drill gate (multiple conveyors/receivers/cores, capacity and blocked-output cases, exact in/out accounting, no double production in one frame).
2. C01 tail: entity group membership, controller pickup and world transition invalidation (need the unit system and campaign state machine), `Conveyor.unitOn`'s unit-pushing body, remaining Tile/Floor side effects.
3. Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
