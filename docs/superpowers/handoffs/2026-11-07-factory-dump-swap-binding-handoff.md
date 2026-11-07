# Handoff — Live loop dump swap binding (N2068)

Date: 2026-11-07. Parent: `31114de`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-factory-dump-swap-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Swapped the live loop so the drill dumps through the dump composition over the stored conveyor queues instead of straight to the core:

- **N2068 `SourceFactoryRuntimeState.source_factory_dump_drill_output_state(game, drill_cell, drill_output_item_id) -> Dictionary`** — the live-loop dump step. It resolves the drill sprite and its frame (the `cdump` cursor lives on the frame, default 0), the drill size from the catalog block's `properties["size"]` (default 1), the proximity ring via N2064, the queues via N2067, the conveyor rotations from the sprite metas, and the content order from `source_item_catalog["item_names_by_id"]`. It dispatches exactly like `Drill.updateTile`: the specific step (N2062) when the dominant item is held, the any step (N2063) otherwise. It writes back only the receiving belt's queue, the drill inventory (`game.drill_items` and the frame's `items`), and the frame's `cdump`. Result keys: `dumped, item_id, receiver_index, receiver_cell, cdump_before, cdump_after, items_after, queues_after, removed, destination, reason`. `simulate_factory` calls it on the SHOULD_DUMP branch instead of the dump-to-core fallback (the `drill_output_item_id != null` gate is unchanged); the wiring is part of this slice. The legacy `apply_drill_dump` path (only called by `FactoryRuntimeModuleProof` with a fake game) is left untouched.

SSOT delta: **14 symbols / 2 schemas / 1 contract / 1 slice**. Totals now: **10633 symbols / 1523 slices / 1411 contracts / 2613 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — no PortGame/PortBridge owner in this batch. The new factory owner contracts ARE mirrored in the `production` module shards.

## How it was verified

- RED first: registration test failed (failures=1, errors=3) with the proof scene missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Drill.java`, `BuildingComp.java` and `Conveyor.java`), `test_tile_slice` and binding + liquid + catalog suites 74 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `FactoryDumpSwapProof` — all 8 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/FactoryDumpSwapProof.json`. The proof dumps lead to the (9,8) belt via the wrapper, dumps copper via the any branch when lead is not held, refuses a full belt with no core fallback, runs the real `simulate_factory` with a forced dump timer (the item lands on the belt, the core inventory does not change), and refuses a missing sprite.
- Bug found and fixed: the first targeted-gates run failed the `ConveyorQueueStorageProof` check `queue_storage_read_empty` — the (9,8) belt read back a stored (empty) queue instead of `no_queue`. The live loop now ticks during every proof's setup frames, so the dump timer fired, the wrapper ran with an empty drill inventory, and it wrote back every resolved queue — including the untouched empty one — creating the meta. The wrapper now writes back only the receiving belt's queue, and only when something was actually dumped.
- Two full-suite failures found and fixed: (1) `test_port_game_delegates_factory_simulation_apply_state_to_module` pinned the old dump-to-core call in the factory runtime source — the test now asserts the new dump-step call and asserts the old line is gone; (2) a first attempt to register the wiring as its own slice (N2069, owner `simulate_factory`) failed the production shard test and the catalog validator — every module shard test requires each slice owner to have a contract, but the validator only discovers `source_`-prefixed functions, and `simulate_factory` has no `source_` prefix. The wiring was folded into N2068 instead.
- Full Python suite: **5423 tests OK in 1081.583s** (log `~/workspace/logs/full-suite-n2068b.log`; the first full-suite run failed 2 tests — the stale dump-to-core pin and the N2069 contract conflict, both fixed, see the report — and was re-run cleanly). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (N2068, plus the four new preloads, and the `simulate_factory` wiring — the wiring is part of this slice)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_modules/production_api_contracts.json`, `production_slices.json`, `production_state_schema.json`, `production_symbols.json`, `source_ssot_modules.json` (production shards mirror the new factory owners; the audit report was regenerated but is byte-identical — `totalSourceFunctions` stays 1335, no new PortGame/PortBridge owner)
- `godot-mindustry/tools/runtime_proofs/FactoryDumpSwapProof.gd`, `FactoryDumpSwapProof.tscn`
- `tools/mindustry_godot_transpiler/register_factory_dump_swap_binding.py`, `tools/mindustry_godot_transpiler/tests/test_factory_dump_swap_binding.py`
- `docs/superpowers/reports/2026-11-07-factory-dump-swap-binding.md`, `docs/superpowers/handoffs/2026-11-07-factory-dump-swap-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1522 → 1523, N2068 checklist/table/log rows)
- `tools/mindustry_godot_transpiler/tests/test_playable.py` (the `test_port_game_delegates_factory_simulation_apply_state_to_module` pin now asserts the new dump-step call instead of the old dump-to-core call)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `FactoryDumpSwapProof.gd.uid` and the earlier proof `.uid` files are untracked noise from proof runs; leave them alone.

## What is still open (next batch)

1. C02: the belt-advance step — queue items moving along the belt (the updateTile mid/minitem scan + pass, N2055/N2052) and passing to the next building or the core (the core's accept/handle is not bound yet), plus the queue-to-sprite sync (the transport runtime is sprite-based with no item identity). Then the drill runtime bridge's game-global `drill_output_item_id` (make it use the actual dominant item), the one-inventory-owner cleanup, and the backlog's two-Drill gate (multiple conveyors/receivers/cores, capacity and blocked-output cases, exact in/out accounting, no double production in one frame).
2. C01 tail: entity group membership, controller pickup and world transition invalidation (need the unit system and campaign state machine), `Conveyor.unitOn`'s unit-pushing body, remaining Tile/Floor side effects.
3. Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
