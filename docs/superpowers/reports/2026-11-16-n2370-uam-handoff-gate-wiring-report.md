# Report N2370 — UnitAssemblerModule handoff-gate moduleFits wiring

**Slice:** N2370 — The UAM tick computes the moduleFits verdict for
the current link and stamps `frame["module_fits"]` before the N2248
advance, so the handoff gate (UnitAssemblerModule.java:138) reads a
live verdict instead of a seeded frame input. **Wave:** advances-19.
**Commit:** `27c627a50` on `slice/N2370-uam-handoff-gate-wiring`
(base `46b1b951b`). **Files:** 5, +965/−7.

## Source

Java: UnitAssemblerModule.java:138 (handoff gate reads moduleFits);
UnitAssembler.java:338-351 (moduleFits geometry — the N2358 fits
pure); UnitAssemblerModule.java:65-69 (getLink / link). 20 exact
exprs, all verified verbatim.

## Implementation

Wiring-only: the tick computes the fits verdict for the CURRENT link
before the N2248 advance and stamps `frame["module_fits"]`. Current
link = the post-discovery link_candidate when the advance will
refresh (`last_change != tile_changes`), else the frame link. The
descriptor lookup runs in `link_candidates` by cell (the N2358
format/defaults).

⚠️ SCOPE CORRECTION: the brief's \"no descriptor → keep module_fits
false\" could NOT mean an unconditional false stamp — the N2248 +
N2314 proofs seed `module_fits=true` with a block-only link and no
candidates and expect handoff. The worker implemented supplied-only
stamping (stamp only when `link_candidates` is supplied; the N2358
discovery precedent); the false default still holds for unseeded live
frames via the advance default. The gate cite is
UnitAssemblerModule.java:138 (not UnitAssembler.java:138).

## Commits

- Slice: `27c627a50` (5 files, +965/−7).
- Integration cherry-pick: `65181efec` (clean).

## Tests

Targeted (new module
`tests.test_c07_unit_assembler_module_handoff_fits_wiring`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 20/20.
Siblings: 8 UAM + 6 C06 modules green except their own proofs, 0
other errors.
Full gate (wave advances-19 integration, PID 7308, 12:44–13:09): Ran 6522 tests in 1485.371s, FAILED (failures=306, skipped=5), 0 errors — 306/306 Godot-absent `AssertionError: unexpectedly None` (299 inherited + 7 new proof tests N2368–N2374; N2375 adds +1 pin test, N2376 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+0/+1/+0/+0** → 12018/1800/1729/3250 (ledger only,
re-listing the 7 N2358 fits symbols — the validator only requires a
non-empty list). Audit stays 1336. DEFERRED **316 → 316** (net 0;
the worker used the MERGED 316 base — correct; the updateTile live
fill entry was rewritten in place: moduleFits LIVE, wasOccupied still
waits).

## Godot debt

- NEW proof `C07UnitAssemblerModuleHandoffFitsWiringProof` (5 keys:
  `handoff_fires_when_link_fits`,
  `handoff_blocked_when_link_does_not_fit`,
  `no_candidates_unseeded_stays_false`,
  `no_candidates_seeded_true_preserved`,
  `candidates_without_matching_descriptor_stays_false`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
