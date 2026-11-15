# Report N2301 — WallCrafter getEfficiency live fill

**Slice:** N2301 — WallCrafter getEfficiency live fill. **Wave:** advances-9.
**Commit:** `a78b498b` on `slice/N2301-wall-crafter-get-efficiency` (base `9ca87a72`).
**Files:** 5, +1018/−9.

## Source

`WallCrafter.getEfficiency` (WallCrafter.java:141-180): iterates `size` tiles along
the FACING edge (rotation 0-3 switch), sums `other.block().attributes.get(attribute)`
for SOLID tiles only. **BLOCK attributes, not floor attributes** — different from
SolidPump's floor attributes (N2292); the N2292 pure was NOT reused. `attribute =
Attribute.sand` (**WallCrafter.java:41** — the brief said :43, which is the `output`
field; corrected in driver/register/test). `output = Items.sand` (:43). canPlaceOn:
`return getEfficiency(tile.x, tile.y, rotation, null, null) > 0;`
(WallCrafter.java:137-139). Called from updateTile at :196. Until this slice, a live
cliff-crusher never accumulated time — the N2223 advance takes `efficiency_factor` as
a frame input (default 0.0) with no live fill.

## Implementation

Pure `source_wall_crafter_get_efficiency_state(edge_tiles, rotation, size, attribute)`
→ {efficiency, edge_efficiencies, can_place_on, solid_tile_count, rotation} (5 keys).
Frame input `wall_edge_tiles` = Array of Dicts {solid, attribute_value}, one per edge
tile in edge order (i = 0..size-1); the pure does NOT compute tile coordinates (no
live world) — it takes the edge tiles as given, in order. Missing/short arrays count
missing tiles as non-solid (0). Const `SOURCE_WALL_CRAFTER_ATTRIBUTE := "sand"`.
Tick stamps `frame["efficiency_factor"]` from `frame["wall_edge_tiles"]` (default [])
each enabled tick BEFORE the N2223 advance (rotation live from sprite meta, size from
catalog per def 2/3). N2273 timer-consume, N2283 timerDump, N2264 item-valid wiring
untouched.

**⚠️ Two existing proofs go STALE with this slice (follow-up fix slices needed,
N2300 precedent):** the slice stamps `efficiency_factor` unconditionally each enabled
tick, so proofs that seed `efficiency_factor = 1.0` now read 0.0 with an empty edge:
- N2223 `C07WallCrafterUpdateTileProof` live-tick key (expects eff 1.0 / time 0.5).
- N2273 `C07WallCrafterTimerConsumeProof` `timer_consume_removes_graphite` key
  (consume gate needs eff > 0).
Fix for both: seed `wall_edge_tiles` summing to 1.0 instead of seeding
`efficiency_factor` (e.g. 2 solid tiles × 0.5 for the size-2 crusher; 3 tiles summing
to 1.0 for the large crusher). The worker did NOT touch those proof files (outside
its 5-file scope). Verified unaffected: N2283 (live-tick keys never read eff/time)
and N2264 (never seeds efficiency_factor). This only manifests on Windows Godot runs;
the VM gate is unaffected (those proof tests already fail Godot-absent here).

## Commits

- Slice: `a78b498b` (pushed, ls-remote verified).
- Integration cherry-pick: `4ee264fb`.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 34/34, row-state) +
proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings
(WallCrafter 7 + Drill/BeamDrill/BurstDrill 12 modules): Ran 76 — 57 PASS + 19 proof
fails, 0 other failures. Full gate (wave advances-9 integration, PID 13482, 03:38–03:59): Ran 6286 tests in 1229.839s, FAILED (failures=248, skipped=5), 0 errors — 248/248 Godot-absent `AssertionError: unexpectedly None` (242 inherited + 6 new proof tests N2295/N2296/N2297/N2298/N2299/N2301; N2300 adds no test).

## SSOT / DEFERRED

SSOT single-slice +5/+1/+1/+2 → 11893/1744/1678/3148; audit stays 1336. Shards: the
four production shards (N2223 precedent). DEFERRED 321 (321 − 1 entry 58 resolved +
entry 169 REWRITTEN dropping only the getEfficiency clause + 1 new: live edge-tile
scan — no live tile scan fills `frame["wall_edge_tiles"]` yet).

## Godot debt

Proof `C07WallCrafterGetEfficiencyProof` (6 keys:
`empty_edge_zero_efficiency`, `ignores_non_solid_tiles`,
`live_tick_fills_efficiency_factor`, `placement_gate_efficiency_positive`,
`rotation_carried_through`, `sums_solid_tile_attributes` + registry) — written, NEVER
run on this VM (no Godot binary, user order 2026-11-15). See GOAL.md §5. Plus 2 proof
fixes needed (N2223, N2273 — see above).
