# Handoff — ConveyorBuild stack API binding (N2056–N2058)

Date: 2026-11-07. Parent: `2efb1cf`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-conveyor-stack-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound the conveyor stack interface — the building-to-building transfer API for the belt:

- **N2056 `SourceConveyorRuntimeState.source_conveyor_remove_stack_state(ids, xs, ys, len, item_id, amount, item_count_before) -> Dictionary`** — removeStack: noSleep runs first, then for each of `amount` iterations the first `ids[i] == item_id` from the front is removed via the N2054 queue removal (one per iteration); the items module loses the same count. Result keys: `ids_after, xs_after, ys_after, len_before, len_after, removed, item_count_after, no_sleep_called`.
- **N2057 `SourceConveyorRuntimeState.source_conveyor_accept_stack_state(minitem, item_space, amount) -> Dictionary`** — acceptStack: `min(int(minitem / itemSpace), amount)` — free slots in item-space units, truncated, capped by the request. Result keys: `accepted, free_slots, reason` (accepted, invalid_item_space).
- **N2058 `SourceConveyorRuntimeState.source_conveyor_handle_stack_state(ids, xs, ys, len, capacity, item_id, amount, item_space, item_count_before) -> Dictionary`** — handleStack: clamps the amount by free capacity, then inserts from `i = amount - 1` down to 0 via the N2053 queue add at index 0, setting `xs[0] = 0`, `ys[0] = i * itemSpace`, `ids[0] = item` and adding one to the items module per insertion, so the finished stack sits spaced itemSpace apart from ys 0; noSleep runs after. Result keys: `ids_after, xs_after, ys_after, len_before, len_after, inserted, item_count_after, no_sleep_called, reason` (inserted, at_capacity, empty_request).

SSOT delta: **39 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10500 symbols / 1513 slices / 1401 contracts / 2593 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — no PortGame/PortBridge owner in this batch. The new owner contracts ARE mirrored in the `conveyor` module shards (`source_modules/conveyor_api_contracts.json`, `conveyor_slices.json`, `conveyor_state_schema.json`, `conveyor_symbols.json`).

## How it was verified

- RED first: registration test failed (failures=1, errors=4) with the proof scene missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Conveyor.java`), `test_tile_slice` 41 OK, binding + liquid + catalog suites 84 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `ConveyorStackProof` — all 17 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/ConveyorStackProof.json`.
- Process note: the first targeted-gates run showed 11 failures, all Godot proof tests, because the shell had no `godot` on `PATH` — an environment artifact of a fresh shell without the `~/workspace/tools` export, not a code regression. Re-running with the export in the same command passed 84/84.
- Full Python suite: **5414 tests OK in 1031.567s** (log `~/workspace/logs/full-suite-n2056.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceConveyorRuntimeState.gd` (N2056 + N2057 + N2058)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_modules/conveyor_api_contracts.json`, `conveyor_slices.json`, `conveyor_state_schema.json`, `conveyor_symbols.json` (conveyor shards mirror the new ConveyorBuild owners; the audit report was regenerated but is byte-identical — `totalSourceFunctions` stays 1335, no new PortGame/PortBridge owner)
- `godot-mindustry/tools/runtime_proofs/ConveyorStackProof.gd`, `ConveyorStackProof.tscn`
- `tools/mindustry_godot_transpiler/register_conveyor_stack_binding.py`, `tools/mindustry_godot_transpiler/tests/test_conveyor_stack_binding.py`
- `docs/superpowers/reports/2026-11-07-conveyor-stack-binding.md`, `docs/superpowers/handoffs/2026-11-07-conveyor-stack-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1510 → 1513, N2056–N2058 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `ConveyorStackProof.gd.uid` and the earlier proof `.uid` files are untracked noise from proof runs; leave them alone.

## What is still open (next batch)

1. C02: the live drill→conveyor→core wiring (the dump composition's hooks to these intake/queue/stack functions for a real chain — the runtime has no per-conveyor item queue, transport is sprite-based, so the wiring needs a queue-to-sprite design decision), the drill runtime bridge's game-global `drill_output_item_id` (make it use the actual dominant item), the one-inventory-owner cleanup, and the backlog's two-Drill gate (multiple conveyors/receivers/cores, capacity and blocked-output cases, exact in/out accounting, no double production in one frame).
2. C01 tail: entity group membership, controller pickup and world transition invalidation (need the unit system and campaign state machine), `Conveyor.unitOn`'s unit-pushing body, remaining Tile/Floor side effects.
3. Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
