# Handoff — Conveyor queue storage binding (N2065–N2067)

Date: 2026-11-07. Parent: `68a2433`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-conveyor-queue-storage-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound conveyor queue storage — a conveyor's item queue lives on its sprite meta, following the drill-frame pattern:

- **N2065 `SourceConveyorRuntimeState.source_conveyor_queue_for_cell_state(game, cell) -> Dictionary`** — the queue read: no sprite → the empty queue with `found=false`, reason `no_sprite`; a sprite with no stored queue → the empty queue with `found=true`, reason `no_queue`; a sprite with a stored queue → its `ids`/`xs`/`ys`/`len` with `found=true`, reason `queue`. Result keys: `ids, xs, ys, len, found, reason`. It does not check the block type: a sprite of another block reads as an empty queue with `found=true`.
- **N2066 `SourceConveyorRuntimeState.source_conveyor_set_queue_for_cell_state(game, cell, queue) -> Dictionary`** — the queue write: the queue dict is stored on the sprite meta `source_conveyor_queue`. No sprite → `stored=false`, reason `no_sprite`. Result keys: `stored, reason`.
- **N2067 `SourceConveyorRuntimeState.source_conveyor_queues_for_cells_state(game, cells) -> Dictionary`** — the resolver: N2065 over each cell, keeping only cells with a sprite. Cells without a conveyor are left out, which is exactly the dump step's fail-closed rule. Result keys: `queues_by_cell, found_count, reason`.

SSOT delta: **18 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10619 symbols / 1522 slices / 1410 contracts / 2611 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — no PortGame/PortBridge owner in this batch. The new conveyor owner contracts ARE mirrored in the `conveyor` module shards.

## How it was verified

- RED first: registration test failed (failures=1, errors=4) with the proof scene missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `Conveyor.java`), `test_tile_slice` and binding + liquid + catalog suites 71 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `ConveyorQueueStorageProof` — all 11 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/ConveyorQueueStorageProof.json`. The proof writes a queue to the (9,8) belt, reads it back, resolves the drill's ring plus a second belt, and runs a resolve → dump step → write-back round trip.
- Proof expectation corrected: the round-trip first wrote the (9,8) belt with an item at `ys [0.0]` and expected the dump step to accept another item, but the Java straight-direction accept arm requires `minitem >= itemSpace` (0.4) — with the front item at y 0.0 the belt correctly refuses. The proof now writes the item at `ys [0.8]`, and the dump inserts the new lead at index 0, giving `ids ["lead", "lead"]`, `len 2`.
- Full Python suite: **5423 tests OK in 1078.684s** (log `~/workspace/logs/full-suite-n2065.log`). Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceConveyorRuntimeState.gd` (N2065 + N2066 + N2067, plus the `SOURCE_CONVEYOR_QUEUE_META_KEY` const)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_modules/conveyor_api_contracts.json`, `conveyor_slices.json`, `conveyor_state_schema.json`, `conveyor_symbols.json` (conveyor shards mirror the new ConveyorBuild owners; the audit report was regenerated but is byte-identical — `totalSourceFunctions` stays 1335, no new PortGame/PortBridge owner)
- `godot-mindustry/tools/runtime_proofs/ConveyorQueueStorageProof.gd`, `ConveyorQueueStorageProof.tscn`
- `tools/mindustry_godot_transpiler/register_conveyor_queue_storage_binding.py`, `tools/mindustry_godot_transpiler/tests/test_conveyor_queue_storage_binding.py`
- `docs/superpowers/reports/2026-11-07-conveyor-queue-storage-binding.md`, `docs/superpowers/handoffs/2026-11-07-conveyor-queue-storage-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1519 → 1522, N2065–N2067 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `ConveyorQueueStorageProof.gd.uid` and the earlier proof `.uid` files are untracked noise from proof runs; leave them alone.

## What is still open (next batch)

1. C02: the live loop swap — replacing `simulate_factory`'s direct dump-to-core call with the dump step over the stored queues (check `FactoryRuntimeModuleProof` and `DrillLiveConsumptionProof` first, since they assert core inventory increases and a conveyor-mediated path delays core receipt), plus the queue-to-sprite sync (the transport runtime is sprite-based with no item identity). Then the drill runtime bridge's game-global `drill_output_item_id` (make it use the actual dominant item), the one-inventory-owner cleanup, and the backlog's two-Drill gate (multiple conveyors/receivers/cores, capacity and blocked-output cases, exact in/out accounting, no double production in one frame).
2. C01 tail: entity group membership, controller pickup and world transition invalidation (need the unit system and campaign state machine), `Conveyor.unitOn`'s unit-pushing body, remaining Tile/Floor side effects.
3. Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
