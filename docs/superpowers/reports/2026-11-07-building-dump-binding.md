# Building.dump(todump) composition binding — N2047–N2049

Date: 2026-11-07. Parent: `407b5d2`. Sequential C01–C12 goal, C02 batch after N2044–N2046. This batch binds `Building.dump(todump)` (BuildingComp.java:1064–1114): the specific-item and any-item branches with the Java guards, the cdump-order proximity scan, and the one-unit transfer to the first accepting neighbor. It does not build conveyor transport, it does not change the drill runtime bridge's game-global item, and it does not accept C02 as a domain or clean-checkout reproducibility.

## Checkpoints and evidence

| Gate | Evidence | Status |
| --- | --- | --- |
| PR-A | Checklist/SSOT/manifest/shards/upstream Java read; RED | Registration test failed first (failures=1, errors=4) with the proof scene missing, before the registration script ran |
| PR-B | Focused and catalog | Registration test OK; exact-evidence test OK; `test_tile_slice` 41 OK; binding + liquid + catalog suites 75 OK; catalog validation 0 errors, JSON modules 0 errors / 113 modules; `git diff --check` clean |
| PR-C | Full suite with frozen inputs; native MCP, inspect and stop | **Python suite done.** Godot proof passes headless on this machine: `BuildingDumpProof` 18/18 checks true, `matches=true`, Godot `4.6.2.stable.official.71f334935`, 0 errors. Full Python suite PASS: **5405 tests OK in 1006.550s** (`~/workspace/logs/full-suite-n2047.log`). Editor parse and deterministic replay were not run on this machine; native MCP runtime proof on Richard's Windows machine (port 7777) is still the remaining step for this gate |
| PR-D | Editor, deterministic replay, exact index | **Pending.** Editor parse and replay not run on this machine; exact staged allowlist below |

Exact-source evidence: all new symbol `java_expr` values and all ledger `exact_exprs` for N2047–N2049 were verified as exact substrings of the pinned upstream tree (`mindustry-upstream/` at `2bdedfe…`). Anchors: `dump()` at `BuildingComp.java:1064` (`return dump(null);`), `dump(Item todump)` at :1072, the guard at :1073 (`if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;`), `int dump = this.cdump;` at :1075, the null branch at :1080, the per-item accept/handle/remove at :1087–1089, the specific accept/handle/remove at :1099–1101, `incrementDump(proximity.size);` at :1090/:1102, `incrementDump` at :1116 (`if(prox != 0){ cdump = ((cdump + 1) % prox); }`), `canDump` at :1125 (`return true;`).

Two corrections during the batch, neither a binding bug: the proof's first draft asserted `cdump_after == 2` for two cases where the second visit wraps the cursor back to 0 (`(1 + 1) % 2 == 0`); the binding was right and the assertions were fixed. And the N2049 owner was first registered as `SourceBuildingItemDumpPortBridge.source_building_dump_state`, which the catalog validator rejected (`facade/module function not discovered`) because discovery forces every `*PortBridge.gd` class name to `PortGame` — the owner is now `PortGame.source_building_dump_state`, matching the N960/N963 precedent, and the catalog is clean.

## Ownership and actual API boundary

`SourceBuildingItemDumpState` gains `source_building_dump_specific_state` (N2047) and `source_building_dump_any_state` (N2048). `PortGame` (via the dump PortBridge) gains `source_building_dump_state` (N2049).

- **N2047 dump specific.** `source_building_dump_specific_state(items, proximity, todump, cdump, has_items, accept_item_hook, handle_item_hook, can_dump_hook) -> Dictionary`. Guards first (no items block, empty items, no proximity, item not held); then the proximity scan in cdump order, one unit to the first neighbor whose accept and canDump hooks pass. Result keys: `dumped, item_id, receiver_index, receiver, cdump_before, cdump_after, items_after, removed, reason`.
- **N2048 dump null.** `source_building_dump_any_state(items, proximity, cdump, has_items, content_item_ids, accept_item_hook, handle_item_hook, can_dump_hook) -> Dictionary`. Same guards and scan, but per neighbor the items are tried in content order, so a neighbor that rejects copper still takes lead. One unit per call. Same result keys.
- **N2049 dump entry.** `PortGame.source_building_dump_state(items, proximity, todump, cdump, has_items, content_item_ids, accept_item_hook, handle_item_hook, can_dump_hook) -> Dictionary`. todump null dispatches to the any-item branch, otherwise to the specific branch, mirroring Java `dump(){ return dump(null); }`. Same result keys.

Hook defaults: a null accept hook is fail-closed (no receiver accepts); a null canDump hook defaults to true (the Java `canDump` default); a missing handle hook means the transfer cannot complete, so that neighbor is skipped. The cdump cursor advances once per neighbor visited, including the receiving one (`increment_dump_cursor_state`, the existing incrementDump binding). The existing array-indexed `dump_item_state` helper in the same file is untouched — it is an unregistered, unwired helper with per-neighbor (not per-item) accept arrays, which would hand the wrong item in the per-item-accept case; the new hook-based functions carry the correct Java semantics.

## SSOT and preservation

Delta: **52 symbols / 6 schemas / 3 contracts / 3 slices** (N2047: 8 inputs + 9 outputs; N2048: 8 inputs + 9 outputs; N2049: 9 inputs + 9 outputs). Working totals: **10398 symbols / 1504 slices / 1392 contracts / 2575 schemas**. Content remains 425 blocks. Extension manifest remains 100 direct modules; expanded validation remains 113. The audit report was regenerated by the registration script after the GDScript existed (the N2035 lesson); `totalSourceFunctions` moves 1334 → 1335 with the new N2049 bridge function. Unlike the N2028 precedent, the new owner contracts ARE mirrored in the `comp` module shards (`source_modules/comp_api_contracts.json` gains the N2049 contract, `source_modules/comp_slices.json` gains N2047–N2049) because the comp module mirrors BuildingComp owners; the registration script's mirror loop regenerated them.

## Remaining C02 work and next batch

Conveyor transport (the dump composition hands items to proximity neighbors; the conveyor-side intake and movement is still the existing transport runtime), the drill runtime bridge's game-global `drill_output_item_id` (make it use the actual dominant item), the one-inventory-owner cleanup, and the two-Drill gate from the backlog (multiple conveyors/receivers/cores, capacity and blocked-output cases, exact in/out accounting, no double production in one frame). Then C03 power, C04 liquid, C05 consumer init, C06 full gameplay loop, C07 units/waves, C08 null-body classification, C09 facade debt, C10 save/load/network, C11 UI/audio/perf, C12 clean-checkout release candidate. No whole-domain acceptance or parity percentage is inferred from ledger counts.

Evidence: `tools/runtime_proofs/BuildingDumpProof.gd` / `.tscn`, `tools/mindustry_godot_transpiler/tests/test_building_dump_binding.py`, `tools/mindustry_godot_transpiler/register_building_dump_binding.py`.
