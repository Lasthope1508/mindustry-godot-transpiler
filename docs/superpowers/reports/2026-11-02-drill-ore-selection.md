# Drill canMine/countOre canonical state — N2010

Date: 2026-11-02. Parent: `2c713403`. One source capability slice, implemented in the existing `SourceDrillRuntimeState.gd`. No new production module, facade chain, emitter case, Block allowlist or content registry is introduced.

## Acceptance checkpoints

| Gate | Requirement | Status |
| --- | --- | --- |
| DO-A | Exact Java, existing ownership and expected RED | 3 failed / 1 passed in 0.90s; missing two contracts and runtime scene |
| DO-B | Independent state matrix and existing live Drill regression | 5 tests / 6 subtests pass in 23.40s; catalog 0 errors / 113 modules |
| DO-C | Complete full suite, native MCP, explicit stop, editor parse | Accepted: 5366 / 22708 in 1039.04s; native matches=true; editor exit 0 |
| DO-D | Deterministic registration replay, exact staging and commit | Accepted: 12 hashes unchanged; exact index audit retained |

## Source and ownership

- `Drill.java:198–235`: complete `countOre(Tile)` sort/selection and `canMine(Tile)` eligibility.
- `Drill.java:119–120`: base `getDrop(Tile)` returns `tile.drop()`; overridden/subclass drop providers remain explicit caller responsibilities.
- `Item.java:29–39`: hardness and lowPriority source fields. Numeric Item.id is required as explicit input; no string or registration-order guess is embedded here.
- `Tile.java:571` and `Block.java:1100`: tile/drop/static facts are supplied explicitly. This slice does not fabricate world objects from ore-map entries.

`SourceDrillRuntimeState.source_can_mine_state(tile, tier, blocked_items)` returns the source null/static/drop/hardness/blocked predicate. The nullable Tile projection supplies `is_static` and nullable `drop`. Item facts supply numeric `id`, effective `hardness` and `low_priority`. `blocked_items` is null or an Array of canonical numeric Item IDs; membership preserves source Item identity within a valid content domain. Callers must supply source-initialized blockedItems; blockedItem compatibility conversion remains in Drill.init.

`SourceDrillRuntimeState.source_count_ore_state(linked_tiles, tier, blocked_items)` composes that predicate, counts each eligible tile, sorts ascending by `!lowPriority`, count and numeric Item.id, then selects the last item. Output uses the existing Java result names `returnItem`, `returnCount`, plus source `oreCount`/`itemArray`. Empty input returns null/zero and fresh empty containers. Item dictionaries remain shared references; input arrays/items are not mutated. Fresh transient result containers model the state after Java clears its scratch collections.

The existing `ore_count`/`game_ore_count` API remains a bounded counter for an explicitly preselected item in the current flat ore map. It has no second priority-sort formula. Its old proof metadata is not relabeled complete countOre semantics. The new methods live in the same Drill owner so the eventual map/proximity adapter can call the canonical algorithm directly.

## Independent runtime matrix

The native `DrillOreSelectionProof.tscn` calls the public canonical APIs with explicit source facts. It proves state semantics, not live mixed-ore gameplay.

| Check | Independent expected result |
| --- | --- |
| null tile | Not mineable |
| static tile containing otherwise valid ore | Not mineable |
| null drop | Not mineable |
| hardness equals tier / exceeds tier | Eligible / rejected |
| blocked numeric ID / empty blocked array | Rejected / eligible |
| three low-priority tiles versus one normal tile | Normal item wins with count one |
| exposed source itemArray order | Low-priority precedes normal before final peek |
| two normal tiles versus one higher numeric ID | Count wins before ID |
| count/priority tie, IDs 2 and 10, reversed insertion | Numeric 10 wins in both permutations |
| only a low-priority item | Still mineable |
| null/static/too-hard/blocked/valid tiles together | Only valid normal ore counted |
| empty and subsequent all-blocked calls | null/zero, no prior-call state retained |
| reference/input lifecycle | Selected Item reference preserved, inputs unchanged, scratch containers distinct |
| registry | Valid, one headquarter per SSOT |

There are 13 semantic checks plus two registry checks and aggregate `matches`. Proof values are explicit test inputs, not production defaults. It does not call `count_ore_state` twice and treat those outputs as an independent oracle.

## SSOT and test evidence

- Exactly **1 slice, 2 contracts, 6 schemas, 16 symbols** added; ledger **1464 → 1465**.
- All earlier root entries/policies remain unchanged. Existing production mirrors regenerate through the manifest; no new shard/manifest entry, content changes or audit rewrite.
- The first catalog check found two implementation-linkage failures because public method names lacked the source-function discovery prefix. APIs were renamed to `source_can_mine_state`/`source_count_ore_state`, metadata regenerated, and focused/catalog rerun. Validator rules were not changed.
- Final focused gate: **5 passed / 6 subtests in 23.40s**, including the actual automatic liquid-consumption Drill proof from N2007–N2009.
- Pre-full catalog: **0 errors / 113 modules / 0 JSON errors**, all nine counters zero.
- Full suite: **5366 passed / 22708 subtests passed in 1039.04s**; complete log retained.
- Native MCP: **15/15 checks true, matches=true**, explicit stop verified, **0 actual errors / 23 compiler warnings**; debug/stop retained. Editor parse **exit 0**, no actual errors.
- Replay: **12 raw SHA256 hashes unchanged**, including manifest/audit/content. Final catalog **0 errors / 113 modules / 0 JSON errors**. Exact staged allowlist/root-addition audit and whitespace gate pass; see `index-final.log`.

Evidence: `evidence/2026-11-02-drill-ore-selection/`. Raw RED output is compressed; summary and SHA256 retained. Root/shard snapshots and semantic merges stage only this slice. Extensive prior dirty facade/source-text work remains outside the commit. Full/native gates run on this canonical working tree; they do not certify an isolated clean checkout.

## Boundaries and next work

Live gameplay still supports the prior power-free, single-ore subset. N2010 does **not** remove the mixed-ore guard or connect its output to the actual factory game loop.

1. **C01-A:** canonical Item ordinal/effective-field provider, initialized blockedItems and actual Tile.drop/isStatic/getLinkedTilesAs facts. Do not infer IDs from slugs or static flags from occupancy.
2. **C01-B:** source `DrillBuild.onProximityUpdate` assignment/invalidation, pickup/removal lifecycle. Reuse this algorithm rather than putting a sort in the binder.
3. **C01-C:** actual dominant item must drive delay/production/offload and output routing for primary and secondary drills; eliminate the single global output-item assumption before enabling live mixed-ore gameplay.
4. **C02–C12:** per-Building output routing, power, flow/supply, complete consumers/rules/reload, vertical gameplay, unit/campaign domains, generated semantics, ownership debt, serialization/network, performance/presentation and clean reproducibility.

Detailed dependencies and acceptance gates: `../handoffs/2026-11-02-mindustry-completion-backlog.md`. Its inventory distinguishes structural parser coverage, recorded unsupported features and live null-body scan; none is a whole-game completion percentage.

## Reproduction

```powershell
python tools/mindustry_godot_transpiler/register_drill_ore_selection.py
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests/test_drill_ore_selection.py tools/mindustry_godot_transpiler/tests/test_drill_live_consumption.py --tb=short
python -m pytest -q -p no:cacheprovider tools/mindustry_godot_transpiler/tests --tb=short
```

After full success run the proof scene through native Godot MCP against this checkout's `godot-mindustry`, inspect and explicitly stop, then editor parse, deterministic replay and final catalog validation. Preserve all resulting diagnostics, including warnings separately from actual errors.
