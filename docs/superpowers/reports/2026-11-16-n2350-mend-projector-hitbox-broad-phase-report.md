# Report N2350 — MendProjector heal scan hitbox broad phase

**Slice:** N2350 — MendProjector heal scan hitbox broad phase (STRICT
Rect.overlaps; N2329 pure delegates). **Wave:** advances-16. **Commit:**
`ed49a44b` on `slice/N2350-mend-hitbox-broad-phase` (base `4f31a099`).
**Files:** 8, +1186/−89.

## Source

Java: MendProjector.java:107/112 call path → eachBlock:324–328 →
`buildings.intersect`:345 → EntityGroup.intersect:195–198 →
QuadTree:190–191 → Rect.overlaps:274–276; hitbox `out.setCentered(...)`
BuildingComp.java:2293, hitSize :2048. 11 exact exprs, all verified
verbatim.

## Implementation

New pure `source_mend_projector_heal_candidates_hitbox_state(candidates,
real_range, building_x, building_y)` → `{candidates}`: STRICT
Rect.overlaps between each candidate's hitbox (a hit_size-sided square
centered on the candidate, BuildingComp.java:2293) and the query rect
(BlockIndexer.java:345). Missing hit_size → 0.0 (the N2335 precedent);
missing x/y or non-Dict excluded; entries never rewritten. The N2329 pure
keeps its signature and `{candidates}` shape and **delegates** to the new
pure instead of the rect center test. The tick is unchanged (broad →
N2335 narrow → N2242 heal scan).

## Commits

- Slice: `ed49a44b` (8 files, +1186/−89).
- Integration cherry-pick: `72aa902a` (clean).

## Tests

Targeted (new module `tests.test_c07_mend_projector_heal_scan_hitbox`):
3/4 PASS (RED 2F+2E) + proof test FAIL exactly AssertionError:
unexpectedly None — NO Godot binary on this VM (user order 2026-11-15).
Exact-evidence 11/11. N2329 + N2335 modules after pin updates: 3/4 PASS
each, proofs Godot-absent (all 3 proof failures confirmed `unexpectedly
None`); siblings (booster_items, booster_timer, heal_scan N2242,
power_status, update_tile): Ran 20, 15 PASS + 5 proof Godot-absent, 0
other errors.
Full gate (wave advances-16 integration, run 2 PID 1743, 09:24–09:46): Ran
6443 tests in 1290.524s, FAILED (failures=287, skipped=5), 0 errors —
287/287 Godot-absent `AssertionError: unexpectedly None` (280 inherited +
7 new proof tests N2344–N2350). Gate run 1 (PID 9349, 09:10–09:24) was
killed by VM restart #11 ~09:24 (javalang wiped, reinstalled 09:24, no
commit/file loss).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11977/1782/1714/3220, exactly as
estimated (1 symbol, java_source arc-core Rect.java, the N2340 precedent;
the register touched 6 generated files incl. defense shards — all
reverted). Audit stays 1336.
DEFERRED **332 → 331 (−1+0)**: resolved the MendProjector rect broad phase
entry, no new entry — the broad phase is now Java-exact over supplied
candidates; only the live building-index fill remains as the scan gap.

## Godot debt

- NEW proof `C07MendProjectorHealScanHitboxProof` (6 keys:
  `hitbox_admits_straddling_hitbox`, `hitbox_admits_edge_hitbox`,
  `hitbox_drops_degenerate_edge_hitbox`, `hitbox_defaults_missing_hit_size`,
  `hitbox_empty_stays_empty`, `live_tick_passes_hitbox_candidates`) —
  written but NEVER run; debt in GOAL.md §5. Live tick seeds the full
  N2329/N2335 frame (power_status 1.0, charge 199.5, heat 1.0, phase_heat
  0.5) + a straddler (dx 52, hit_size 16.0) the old rect would drop. **All
  6 key expectations verified by simulating the pure logic in Python**
  (the N2340 precedent): pure keys 3/3/0/2/0 as expected; live tick 1 heal
  under the new broad phase vs 0 under the old rect, robust across
  phase_heat 0.45–0.5.
- ⚠️ **Scope correction (important):** the brief's conditional — "if proof
  candidates don't carry hit_size → outcome identical → NO re-run" — is
  **wrong for N2329**, and the mandated simulation caught it: with default
  0.0 the edge/corner candidates become degenerate point hitboxes, and
  STRICT overlap drops boundary points. Simulation: **N2329 NEEDS
  RE-RUN** — `scan_admits_in_range` falls **6 → 1** unseeded. Fix applied:
  seeded `"hit_size": 8.0` (size-1 building, BuildingComp.java:2048) on
  the 6 in-range candidates → back to 6. All other N2329 keys unchanged by
  simulation (excludes, phase heat, intact, empty, live tick still 1
  heal). Proof file changed → **N2329 proof needs a Godot re-run** (a
  SECOND re-run note on the N2329 entry, after the N2335 note — the re-run
  COUNT does not increment, N2329 is already a re-run). Note: seeding
  hit_size on the out-of-range near-edge candidates would break
  `scan_excludes_out_of_range` (2 admitted) — deliberately not done.
  **N2335 does NOT need a re-run** (pure keys call the untouched narrow
  pure directly, all outcomes identical; live tick simulates identically —
  1 heal, candidates strictly inside/outside the rect; proof file
  untouched). Test pins N2329/N2335 updated from the old rect test line
  (`if dx > real_range or dy > real_range:`) to the delegation call +
  STRICT overlap lines (FULL call pins preserved).
- Lesson (recorded in STATUS.md): **STRICT-overlap broad phases change
  degenerate-point outcomes** — replacing a rect center test with STRICT
  hitbox overlap changes outcomes for candidates WITHOUT hit_size; a brief
  conditional "no hit_size → identical outcome → no re-run" is WRONG for
  broad-phase slices; the worker MUST simulate proof outcomes in Python
  (the N2340 pattern) before concluding.
