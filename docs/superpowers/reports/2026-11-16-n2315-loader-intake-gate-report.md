# Report N2315 — PayloadLoader intake full-gate wiring

**Slice:** N2315 — Loader intake full-gate wiring (N2295 verdict gates the N2278 push). **Wave:** advances-11.
**Commit:** `7addcf20` on `slice/N2315-loader-intake-gate` (base `18dcabf2`).
**Files:** 6, +893/−14.

## Source

The pusher checks acceptPayload before handlePayload — `BuildingComp.java:822-824`
(movePayload) and `:844-845` (dumpPayload), `InputHandler.java:667–669` (unit
drop — the brief said :668–669; the if is :667, the handle call :669; cite
corrected by the worker). The N2295 pure
(`source_payload_loader_accept_payload_state`, PayloadLoader.java:90-101)
exposes the verdicts on the frame, but the N2278 intake applied the push on the
frame null check alone and DROPPED it either way (`frame["incoming_payload"] =
null` at :620, outside the payload-null check). No DEFERRED entry existed for
the Loader intake guard — N2295 oversight (N2295 added only #311 live sources
+ #312 descriptor contract, while N2296 added #313 for the Unloader).

## Implementation

Tick duplicates the incoming dict as the N2295 descriptor and evaluates
`source_payload_loader_accept_payload_state(incoming_descriptor, frame payload
!= null)`; the push applies only when the verdict accepts. **Loader-specific
deviation from N2308:** the N2295 pure defaults a missing `block_size` to 0 —
which FITS — so unlike N2308 (whose pure defaults to rejecting), the intake
must inject the rejecting default itself: a push without `block_size` gets
`SOURCE_PAYLOAD_LOADER_MAX_BLOCK_SIZE + 1`. Non-dict push rejects. The N2278
drop is preserved (`frame["incoming_payload"] = null` runs either way);
`frame["accepts_payload"]` is never overwritten (offer verdict governs the frame
key, intake verdict decides the push alone); the pure's `has_payload` term
subsumes the old frame null check. Handle pure untouched, still passes the
Loader's own size 3 as `block_size`.

**The N2278 test's live push lives in the PROOF file, not the test module**
(N2308 precedent) — the worker updated the
`C07PayloadLoaderLiveFillProof.gd` fixture: the live push was `{"rotation":
45.0, "marker": "first"}` (no descriptor keys → the new gate would reject it),
now carries `is_build_payload: true, block_size: 2, has_items: true,
unloadable: true, item_capacity: 10`. Load-bearing. → N2278 proof becomes a
RE-RUN. The second push (occupied case) was left as-is — it rejects via the
base gate regardless.

**N2295 test pins checked first (N2304 lesson):** only substring `assertIn`s,
no tick-call string pin — no pin update needed. N2278 test pins all preserved.

## Commits

- Slice: `7addcf20` (6 files, +893/−14).
- Integration cherry-pick: `99656324` (clean).

## Tests

Targeted (new module `tests.test_c07_payload_loader_intake_gate`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). RED before GREEN: 2 errors + 2 failures, the
N2308 pattern. Exact-evidence 29/29. Siblings (27 modules: Loader ×6, Unloader
×6, PMD ×5, UAM ×3, Deconstructor ×7) Ran 108 = 81 PASS + 27 proof, 0 other
failures.
Full gate (wave advances-11 integration, PID 7620, 05:08–05:30): Ran 6314 tests in 1275.835s, FAILED (failures=255, skipped=5), 0 errors — 255/255 Godot-absent `AssertionError: unexpectedly None` (252 inherited + 3 new proof tests N2313/N2314/N2315; N2309/N2310/N2311/N2312 add no test).

## SSOT / DEFERRED

SSOT single-slice **+0/+1/+0/+0** → 11933/1754/1688/3168: ledger entry with
`godot_owner` = the N2295 pure, `source_symbols` = its 5 result symbols
(accepts / fits / is_item_container / is_liquid_container / is_battery —
shared ownership; the validator only requires a non-empty list). No new pure,
no new symbol/schema/contract. DEFERRED unchanged 325 (no entry existed —
N2295 oversight; nothing to resolve, none invented). At the wave merge the
coordinator rewrote DEFERRED #311 in place (N2306 entry-167 precedent): its
trailing clause "the N2278 intake keeps its own payload-null guard" is
superseded by N2315 (the intake consults the full gate).

## Godot debt

- NEW proof `C07PayloadLoaderIntakeGateProof` (6 keys:
  `intake_accepts_when_verdict_true`, `intake_drops_when_verdict_false`,
  `intake_drops_without_block_size`, `intake_drops_when_payload_present`,
  `live_tick_wires_the_gate`, `null_push_still_consumed`) — written but NEVER
  run; debt in GOAL.md §5. Live-tick numbers mirror N2278 exactly (pay_vector
  (11.3, 0), pay_rotation 40.0 after one tick from source (100, 0)).
- RE-RUN of proof N2278 (`C07PayloadLoaderLiveFillProof`) — the fixture
  changed (load-bearing descriptor keys); recorded as a re-run note on the
  N2278 §5 entry.
