# Report N2339 — BeamDrill facing scan / updateFacing count

**Slice:** N2339 — BeamDrill facing scan / updateFacing count (the live
facingAmount computation). **Wave:** advances-15. **Commit:** `54697121`
on `slice/N2339-beam-drill-facing-scan` (base `c89f1d09`). **Files:** 14,
+1962/−21.

## Source

Java: `updateFacing` is **BeamDrill.java:375-411** (NOT :375-410 — the old
driver cite was off by one, the closing brace is :411; NOT :368-411 —
:368-373 is updateLasers), called from updateTile :244 +
onProximityUpdate :365; mineable check :391; `facingAmount` field :228;
shouldConsume :270-271; defs plasma-bore tier/size/range :3043-3045,
large-plasma-bore :3057-3059. Coordinator cite fix at integration
(`1bfe4322`, comment-only): :375-410 → :375-411 in the design-spec N2202
line + `test_c07_beam_drill_should_consume.py` comments (:43/:142/:209);
the N2202 register + historical N2202 report/handoff were left untouched
(register text is ledger content, docs are history).

## Implementation

New pure `source_beam_drill_facing_scan_state(facing_tiles, size,
beam_range, tier, blocked_items)` → `{facing_amount}`: per laser (size),
walk range tiles; the first solid tile breaks the ray (even if
unmineable); count when wallDrop passes the mineable check :391;
null/non-solid tiles don't break the ray. Frame input `facing_tiles`
(default [], one Dict per tile {solid, wall_drop}); missing/short rays →
0; rays past size / tiles past beam_range ignored. Tick stamps
facing_amount each enabled tick BEFORE the N2195 advance and AFTER the
consumption fold (the N2202 gate reads the previous tick's count — Java
order, BuildingComp:2274-2277). size/range/tier from the catalog per def
(2/5/3 plasma-bore, 3/6/5 large-plasma-bore; class defaults 1/5/1).
blockedItems resolved via the shared Drill bind, guarded (neither def
carries the keys in the catalog — verified in content_registry.json +
Blocks.java:3038-3061). **Cycle fix:** preloading SourceDrillRuntimeState
cycles (Factory preloads this driver, DrillRuntime preloads Factory) →
`load()` at call time (BurstDrill precedent,
SourceBurstDrillBuildState.gd:662); test pins assertNotIn on the preload.
Drill `can_mine` NOT reused (it excludes static tiles; updateFacing counts
any solid tile with mineable wallDrop). Param is `beam_range` (GDScript
reserves `range()`). The pure returns the count only; lastItem/facing[]
stay with DEFERRED entry 190.

## Commits

- Slice: `54697121` (14 files, +1962/−21).
- Integration cherry-pick: `7866ebf2` (conflict in the 4 canonical
  generated JSONs — resolved --ours; the register re-run at SSOT merge
  regenerated the entries).

## Tests

Targeted (new module `tests.test_c07_beam_drill_facing_scan`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). Exact-evidence 44/44. Siblings 18/24
PASS (6 proof Godot-absent), 0 other failures.
Full gate (wave advances-15 integration, PID 1755, 08:31–08:52): Ran 6415 tests in 1285.515s, FAILED (failures=280, skipped=5), 0 errors — 280/280 Godot-absent `AssertionError: unexpectedly None` (275 inherited + 5 new proof tests N2338/N2339/N2340/N2342/N2343).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11970/1777/1709/3210 (exactly the SCOPE
estimate): 1 symbol; **44 exact exprs**; 4 production shards changed.
Audit stays 1336.
DEFERRED net 0 (#27 REWRITTEN in place — count live since N2339;
updateLasers geometry + live facing-tile fill still wait; lastItem/facing[]
→ entry 190).

## Godot debt

- NEW proof `C07BeamDrillFacingScanProof` (6 keys:
  `counts_mineable_facing_tiles`, `first_solid_tile_breaks_ray`,
  `blocked_items_excluded`, `missing_tiles_and_bounds`,
  `large_bore_three_lasers`, `live_tick_stamps_facing_amount`) — written
  but NEVER run; debt in GOAL.md §5. The live tick uses plasma-bore (no
  required liquid row, no seeding needed, N2289 precedent); it proves the
  Java-order gate across two ticks.
- Follow-through: old proofs N2155/N2195/N2202/N2256/N2289 verified SAFE,
  no fix slice needed (unlike N2301 — they seed facing_amount before the
  tick and never read it post-tick); only the N2202 proof comment was
  updated (range fix + scan-live note, keys unchanged — NO re-run).
- Known deviation: a disabled drill keeps the previous count (Java
  recomputes it) — waits for the driver-wide disabled-early-return slice.
