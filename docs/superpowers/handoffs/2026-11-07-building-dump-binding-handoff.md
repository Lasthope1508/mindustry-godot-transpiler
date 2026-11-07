# Handoff — Building.dump(todump) composition binding (N2047–N2049)

Date: 2026-11-07. Parent: `407b5d2`. Sequential C01–C12 goal, C02 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-building-dump-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What this slice did

Bound `Building.dump(todump)` (BuildingComp.java:1064–1114), the output composition C02 needs before conveyor transport can be wired:

- **N2047 `SourceBuildingItemDumpState.source_building_dump_specific_state(items, proximity, todump, cdump, has_items, accept_item_hook, handle_item_hook, can_dump_hook) -> Dictionary`** — dump a specific item: guards (no items block, empty items, no proximity, item not held), then the proximity scan in cdump order, one unit to the first neighbor whose accept and canDump hooks pass. Result keys: `dumped, item_id, receiver_index, receiver, cdump_before, cdump_after, items_after, removed, reason`.
- **N2048 `SourceBuildingItemDumpState.source_building_dump_any_state(items, proximity, cdump, has_items, content_item_ids, accept_item_hook, handle_item_hook, can_dump_hook) -> Dictionary`** — dump(null): same guards and scan, but per neighbor the items are tried in content order, so a neighbor that rejects copper still takes lead. One unit per call. Same result keys.
- **N2049 `PortGame.source_building_dump_state(items, proximity, todump, cdump, has_items, content_item_ids, accept_item_hook, handle_item_hook, can_dump_hook) -> Dictionary`** — the dump() entry: todump null dispatches to the any-item branch, otherwise to the specific branch (mirroring Java `dump(){ return dump(null); }`). Same result keys.

Hook defaults: a null accept hook is fail-closed; a null canDump hook defaults to true (the Java default); a missing handle hook means that neighbor is skipped (the transfer cannot complete). The cdump cursor advances once per neighbor visited, including the receiving one. The existing array-indexed `dump_item_state` helper in the same file is untouched — it is unregistered and unwired, and its per-neighbor accept arrays would hand the wrong item when accept is per-item.

SSOT delta: **52 symbols / 6 schemas / 3 contracts / 3 slices**. Totals now: **10398 symbols / 1504 slices / 1392 contracts / 2575 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` moves 1334 → 1335 with the new N2049 bridge function. Unlike the N2028 precedent, the new owner contracts ARE mirrored in the `comp` module shards (`source_modules/comp_api_contracts.json` gains the N2049 contract, `source_modules/comp_slices.json` gains N2047–N2049).

## How it was verified

- RED first: registration test failed (failures=1, errors=4) with the proof scene missing before the registration script ran.
- Targeted: registration test OK, exact-evidence test OK (all binding symbol exprs + ledger exprs exact against pinned `BuildingComp.java`), `test_tile_slice` 41 OK, binding + liquid + catalog suites 75 OK.
- Catalog: 0 errors, JSON modules 0 errors / 113 modules. `git diff --check` clean.
- Godot proof: `BuildingDumpProof` — all 18 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935` headless. Proof JSON at `godot-mindustry/tools/runtime_proofs/BuildingDumpProof.json`. Two fixes worth remembering: the proof first asserted `cdump_after == 2` where the second visit wraps the cursor to 0 — the binding was right; and the N2049 owner must be `PortGame.*`, not `SourceBuildingItemDumpPortBridge.*`, because discovery forces every `*PortBridge.gd` class name to `PortGame`.
- Full Python suite PASS: 5405 tests OK in 1006.550s. Editor parse, deterministic replay and native MCP proof are still open for this slice.

## Files in this slice (stage/commit exactly these)

- `godot-mindustry/src/game/SourceBuildingItemDumpState.gd` (N2047 + N2048)
- `godot-mindustry/src/game/SourceBuildingItemDumpPortBridge.gd` (N2049)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`, `source_symbol_audit_report.json` (audit report regenerated; `totalSourceFunctions` 1334 → 1335), `source_modules/comp_api_contracts.json`, `source_modules/comp_slices.json` (comp shards mirror the new BuildingComp owners)
- `godot-mindustry/tools/runtime_proofs/BuildingDumpProof.gd`, `BuildingDumpProof.tscn`
- `tools/mindustry_godot_transpiler/register_building_dump_binding.py`, `tools/mindustry_godot_transpiler/tests/test_building_dump_binding.py`
- `docs/superpowers/reports/2026-11-07-building-dump-binding.md`, `docs/superpowers/handoffs/2026-11-07-building-dump-binding-handoff.md`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1501 → 1504, N2047–N2049 checklist/table/log rows)

Do NOT stage `mindustry-upstream/`, `arc-upstream/`, `.godot/`, `godot-mindustry/project.godot`, or `*.gd.uid` (gitignored / known workspace noise). `BuildingDumpProof.gd.uid` and the earlier proof `.uid` files are untracked noise from proof runs; leave them alone.

## What is still open (next batch)

1. C02: conveyor transport (the dump composition hands items to proximity neighbors; the conveyor-side intake and movement is still the existing transport runtime), the drill runtime bridge's game-global `drill_output_item_id` (make it use the actual dominant item), the one-inventory-owner cleanup, and the backlog's two-Drill gate (multiple conveyors/receivers/cores, capacity and blocked-output cases, exact in/out accounting, no double production in one frame).
2. C01 tail: entity group membership, controller pickup and world transition invalidation (need the unit system and campaign state machine), `Conveyor.unitOn`'s unit-pushing body, remaining Tile/Floor side effects.
3. Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate.

No whole-domain acceptance or parity percentage is inferred from ledger counts.
