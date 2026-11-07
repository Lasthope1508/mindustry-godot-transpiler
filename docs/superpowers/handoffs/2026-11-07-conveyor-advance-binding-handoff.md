# Handoff — Conveyor belt-advance binding (N2069–N2070)

Date: 2026-11-07. Parent: `46cc54f`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-conveyor-advance-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Advanced the belts each frame — the updateTile movement loop plus the handoff to the next belt or the core:

- **N2069 `SourceConveyorRuntimeState.source_conveyor_advance_state(ids, xs, ys, len, speed, delta, time_scale, aligned, next_minitem, blendbits, clog_heat_before) -> Dictionary`** — the updateTile movement loop (no pass; the pass is the wrapper's handoff via N2052). It moves each item from the last index down to 0, clamped by the item ahead and by `nextMax`, drifts x toward 0, scans mid/minitem, computes clogHeat, and reports whether the front item reached the exit. An empty belt at time scale 1 sleeps. Result keys: `ids_after, xs_after, ys_after, len_after, mid, minitem, pass_ready, pass_item_id, clog_heat, no_sleep_called, reason`.
- **N2070 `SourceFactoryRuntimeState.source_factory_advance_conveyors_state(game, conveyor_cells, delta) -> Dictionary`** — the live-loop belt-advance step. It resolves each belt's queue, rotation, team and speed (catalog `properties["speed"]`, default 0.03), advances the belts front-to-back, and hands the ready item to the next belt (N2060/N2061 hooks, `source_block_rotate = true` for the conveyor block) or to the core (the game's core accept/handle methods). It writes back only the queues that actually changed. `simulate_factory` calls it after the dump step, with the conveyor cells reversed to front-to-back. Result keys: `results_by_cell, passed_count, reason`.

SSOT delta: **28 symbols / 4 schemas / 2 contracts / 2 slices**. Totals now: **10661 symbols / 1525 slices / 1413 contracts / 2617 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — no PortGame/PortBridge owner in this batch. The new conveyor owners ARE mirrored in the `conveyor` module shards; the production shards did not change (both slices' Java source is the distribution Conveyor, so both belong to the conveyor module even though N2070 lives in SourceFactoryRuntimeState.gd).

## Why it exists

The drill dump (N2068) put items onto the belt, but they waited there — the belt never moved them and the core never received them via the belt. Now the belt moves its items each frame and hands the front item to the next belt or into the core, so drill → belt → belt → core is a live path.

## What the Godot proof shows

`ConveyorAdvanceProof` — 11/11 checks true on the real Main scene: the advance moves items with the item-ahead clamp and the mid/minitem scan; the front item reaches the exit; an aligned next belt caps the exit; an empty belt sleeps; the wrapper passes belt-to-belt and belt-to-core (core lead count +1); a full next belt caps the exit below 1 (the item stops at 0.83, passed_count 0); the live `simulate_factory` call advances the belts.

## Bugs found and fixed

- `source_conveyor_queue_scan_state` takes an Array of passed flags, not a Dictionary — the wrapper passed `{}` and PortGame failed to compile (fixed to `[]`).
- The wrapper wrote back every resolved queue, so the live loop ticking during the `ConveyorQueueStorageProof` setup frames created a stored (empty) queue on the untouched belts and broke the `queue_storage_read_empty` check — the wrapper now writes back only the queues that actually changed (the same class of bug as N2068's write-back fix).
- The proof's first core assertion read `core_inventory` (the copper alias) instead of the lead count — the core's lead count is read via `game.core_item_count("lead")`.
- The proof's first full-belt assertion expected the item to sit at the exit (y 1.0) — Java's `nextMax` caps it below 1 when the next belt is clogged near its entrance (the item stops at 0.83), so the assertion now checks the cap.

## Verification

- Full Python suite: **5429 tests OK in 1102.908s** (log `~/workspace/logs/full-suite-n2069b.log`; the first full-suite run failed 1 test — the `test_port_game_exposes_playable_scenario_defaults_state` pin against hardcoded block-id literals in the factory runtime, fixed by using the scenario-default constants — and was re-run cleanly). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files changed

- `godot-mindustry/src/game/SourceConveyorRuntimeState.gd` (N2069)
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (N2070, plus the `simulate_factory` wiring)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/src/generated/source_modules/conveyor_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/conveyor_slices.json`
- `godot-mindustry/src/generated/source_modules/conveyor_state_schema.json`
- `godot-mindustry/src/generated/source_modules/conveyor_symbols.json`
- `godot-mindustry/tools/runtime_proofs/ConveyorAdvanceProof.gd`
- `godot-mindustry/tools/runtime_proofs/ConveyorAdvanceProof.tscn`
- `tools/mindustry_godot_transpiler/register_conveyor_advance_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_conveyor_advance_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1523 → 1525, N2069–N2070 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-conveyor-advance-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-conveyor-advance-binding-handoff.md` (this handoff)

## Open items

- The queue-to-sprite sync, the drill bridge global item, one-inventory-owner cleanup and the two-Drill gate stay open in C02. C01 tail, C03–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for this slice.
