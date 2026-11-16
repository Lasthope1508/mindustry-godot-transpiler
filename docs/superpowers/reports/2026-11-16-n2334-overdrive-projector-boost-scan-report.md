# Report N2334 — OverdriveProjector boost scan

**Slice:** N2334 — OverdriveProjector boost scan (realRange fold + eachBlock
rect filter; application deferred). **Wave:** advances-14.
**Commit:** `0af9b062` on `slice/N2334-overdrive-boost-scan` (base `f3f7af8e`).
**Files:** 5, +1116/−10.

## Source

Java: `if(charge >= reload){ float realRange = range + phaseHeat *
phaseRangeBoost; charge = 0f; indexer.eachBlock(this, realRange, other ->
other.block.canOverdrive, other -> other.applyBoost(realBoost(), reload +
1f));}` (OverdriveProjector.java:106-111 — verified: `if(charge >=
reload){` :106, realRange :107, reset :109, eachBlock :110, close :111; the
brief cite ":107-113" was off by one). The pre-existing N2194 driver comments
cited :110/:113 for the same lines (same shift) — left untouched by the
worker for the coordinator's stale-cite alignment at integration (fixed in
3b2e2055: :110-112 → :106-111, :113 → :110). `canOverdrive` defaults to
`public boolean canOverdrive = true;` (Block.java:309) — only 6 defs opt
out; the brief's tentative "missing can_overdrive → false" was WRONG
(missing → true, admitted; only explicit false excludes — pinned in test +
proof).

## Implementation

New pure `source_overdrive_projector_supplied_boost_targets_state(candidates,
real_range, building_x, building_y)` → `{boost_targets, real_range}`:
eachBlock rect filter (half-side realRange, INCLUSIVE, center-in-rect, N2277
precedent) + canOverdrive predicate. Missing x/y → excluded; non-Dictionary
→ excluded; entries never rewritten. Tick wiring after the N2194 advance
(post-advance phase_heat), gated on `charge_ready`; realRange folded through
the existing `projector_range` accessor (same formula as drawSelect, no
duplicate math); building position from origin cell + block offset (N2306
precedent); result reported as new frame key `frame["last_boost_scan"]`.
When charge is not ready, Java runs no scan → empty targets at the live
realRange.

**Application DEFERRED:** the pure only reports targets;
`applyBoost(realBoost(), reload + 1f)` waits for its own slice (N2325
precedent), documented in docstring + DEFERRED.

**No follow-through needed:** the N2194/N2262 test files were read in full;
all their pins (advance call string, frame keys, consume() removal)
untouched.

## Commits

- Slice: `0af9b062` (5 files, +1116/−10).
- Integration cherry-pick: `c29f4f47` (clean).

## Tests

Targeted (new module `tests.test_c07_overdrive_projector_boost_scan`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 15/15,
all grep-verified verbatim.
Siblings (OverdriveProjector family: power_status, update_tile,
booster_items, source_text): 9/12 PASS, 3 fails all proof tests failing
exactly Godot-absent.
Full gate (wave advances-14 integration, PID 11801, 07:14–07:36): Ran 6394 tests in 1305.500s, FAILED (failures=275, skipped=5), 0 errors — 275/275 Godot-absent `AssertionError: unexpectedly None` (268 inherited + 7 new proof tests N2330–N2336).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11962/1770/1702/3196 (the SCOPE TBD
estimate, confirmed): symbols `..._result.boost_targets` +
`..._result.real_range`; audit stays 1336.
DEFERRED 329→330 (−1+2: resolved #190 range/phase-range — fold live, scan
consumes it; updated #198 boost application in place — scan live, applyBoost
still waits; added live building-index fill for `frame["boost_candidates"]`
+ within/privileged refinement, BlockIndexer.java:346).
**Scope correction:** the DEFERRED numbers in the scope table were wrong —
"#189 + #197" are BeamDrill draw and Radar fogRadius against the advances-13
base. The actual Overdrive entries are **#190** (range/phase-range) and
**#198** (boost application).

## Godot debt

- NEW proof `C07OverdriveProjectorBoostScanProof` (6 keys:
  `scan_admits_in_range_overdrivable`, `scan_excludes_out_of_range`,
  `scan_excludes_non_overdrivable`,
  `scan_uses_real_range_with_phase_heat`, `empty_candidates_empty`,
  `live_tick_scans_when_charge_ready`) — written but NEVER run; debt in
  GOAL.md §5.
