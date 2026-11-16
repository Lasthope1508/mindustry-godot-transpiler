# Report N2329 — MendProjector heal scan range query

**Slice:** N2329 — MendProjector heal scan range query (indexer.eachBlock
rect filter over frame heal candidates; realRange = range + phaseHeat ×
phaseRangeBoost from the post-advance frame). **Wave:** advances-13.
**Commit:** `dd624585` on `slice/N2329-mend-projector-heal-scan-range`
(base `4349a660`).
**Files:** 5, +1041/−12.

## Source

Java: `float realRange = range + phaseHeat * phaseRangeBoost;`
(MendProjector.java:107); `indexer.eachBlock(this, realRange, b ->
b.damaged() && !b.isHealSuppressed(), other -> { ... })` (:112). The
eachBlock float-range overload is BlockIndexer.java:324–328 — in
`core/src/mindustry/ai/`, NOT `world/` (brief location corrected by the
worker). The rect is only the BROAD phase (:345); real admission is STRICT
within circle + !privileged (:346) — the worker ported the rect per the
brief and documented the deviation in the driver + DEFERRED. Defs: mender
range 40f / healPercent 4f / phaseBoost 4f / phaseRangeBoost 20f
(Blocks.java:1924–1927); mend-projector range 85f / healPercent 11f /
phaseBoost 15f (:1937–1939), phaseRangeBoost class 50f
(MendProjector.java:30). The N2242 heal_scan pure already filters damaged
+ !heal_suppressed and folds the heal, but takes its candidate list
explicit with NO range filter — the driver passed `[]`.

## Implementation

New pure `source_mend_projector_supplied_heal_candidates_state(candidates,
real_range, building_x, building_y)` → `{candidates}`: filter frame
candidates by rect centered (half-side realRange, INCLUSIVE, center-in-
rect — N2277 precedent). The pure only filters — entry dicts keep their
keys intact (damaged / heal_suppressed / max_health untouched). Missing
x/y → EXCLUDED. NO damaged/suppressed filter here (the heal_scan pure
already does it). Tick wiring runs the scan AFTER the advance (same
position as the current heal_scan call — realRange needs post-advance
phase_heat); the driver computes real_range = range + phase_heat ×
phase_range_boost from the post-advance frame + block props (the SAME
formula the heal_scan pure uses internally) and passes the filtered list
into heal_scan instead of `[]`. Frame input `heal_candidates` (default []
— the live building index still defers).

**No follow-through needed:** the N2242 test only pins the prefix
`source_mend_projector_heal_scan_state(frame` (:135) — the worker verified
the whole file.

## Commits

- Slice: `dd624585` (5 files, +1041/−12).
- Integration cherry-pick: `69843243` (clean).

## Tests

Targeted (new module `tests.test_c07_mend_projector_heal_scan_range`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 13/13.
Siblings Ran 20 = 15 PASS + 5 proof, 0 other failures.
Full gate (wave advances-13 integration, PID 4634, 06:38–07:02): Ran 6366 tests in 1287.324s, FAILED (failures=268, skipped=5), 0 errors — 268/268 Godot-absent `AssertionError: unexpectedly None` (262 inherited + 6 new proof tests N2324–N2329; N2323 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11950/1764/1696/3184 (exactly the SCOPE
estimate): symbol
`source_mend_projector_supplied_heal_candidates_state_result.candidates`;
audit stays 1336. DEFERRED 325→326 (−1+2, NOT −1+1 as scoped: the
within/privileged refinement is a separate entry).

## Godot debt

- NEW proof `C07MendProjectorHealScanRangeProof` (6 keys:
  `scan_admits_in_range`, `scan_excludes_out_of_range`,
  `scan_uses_real_range_with_phase_heat`,
  `scan_keeps_candidate_entries_intact`, `empty_candidates_empty`,
  `live_tick_passes_ranged_candidates`) — written but NEVER run; debt in
  GOAL.md §5.
