# Report N2313 — PayloadUnloader intake full-gate wiring

**Slice:** N2313 — Unloader intake full-gate wiring (N2296 verdict gates the N2279 push). **Wave:** advances-11.
**Commit:** `c4f76868` on `slice/N2313-unloader-intake-gate` (base `18dcabf2`).
**Files:** 7, +951/−34.

## Source

The pusher checks acceptPayload before handlePayload — `BuildingComp.java:822-824`
(movePayload) and `:844-845` (dumpPayload). The N2296 pure
(`source_payload_unloader_accept_payload_state`, the inherited Loader override,
PayloadLoader.java:90-101) exposes the verdicts on the frame, but the N2279
intake applied the push on the frame null check alone (driver comment :871
explicitly deferred the wiring). The Unloader inherits the Loader's override
(`PayloadUnloaderBuild extends PayloadLoaderBuild`, PayloadUnloader.java:32) —
NOT the bare PayloadBlock base gate.

## Implementation

Tick builds the N2296 descriptor from the incoming dict itself —
`is_build_payload` / `size` on the payload dict, block flags on its `block`
dict; missing keys default to rejecting inside the pure (no `size` = no fits,
`is_build_payload` false) — evaluates
`source_payload_unloader_accept_payload_state(frame payload-null?, descriptor)`,
and applies the push only when it accepts. **Occupancy vs rejection
distinguished (the N2313 difference from N2308):** an input arriving while a
payload is held is KEPT for next tick (N2279 keep-for-retry preserved exactly —
the verdict is only evaluated when the frame is empty); a rejected push is
DROPPED, still consumed (it would retry forever). `frame["accepts_payload"]`
is never overwritten by the intake (offer verdict governs it). The handle pure
is untouched (still one call site).

**The N2279 test's live push lives in the PROOF file, not the test module**
(N2308 precedent) — the worker updated the
`C07PayloadUnloaderLiveFillProof.gd` fixture (+`is_build_payload: true` +
`size: 24.0` on the live payload only; battery branch accepts, pure handle keys
unaffected). Load-bearing: without it, the gate drops the live push. → N2279
proof becomes a RE-RUN.

**Stale pin fix (7th file):** the N2296 test pinned
`count('source_payload_unloader_accept_payload_state(') == 2` with the comment
"called exactly once… intake untouched". The wiring adds the second call site,
so the pin is now 3 with an updated comment — same class as the N2300/N2302/
N2303 fixes. Without it the N2296 sibling test fails.

## Commits

- Slice: `c4f76868` (7 files, +951/−34).
- Integration cherry-pick: `fbce87a1` (clean).

## Tests

Targeted (new module `tests.test_c07_payload_unloader_intake_gate`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). RED before GREEN: 2 errors + 2 failures, as
expected. Exact-evidence 26/26. Siblings (20 modules — 6 Unloader + 6 Loader +
5 PMD + 3 UAM) Ran 80 = 60 PASS + 20 proof, 0 other failures.
Full gate (wave advances-11 integration, PID 7620, 05:08–05:30): Ran 6314 tests in 1275.835s, FAILED (failures=255, skipped=5), 0 errors — 255/255 Godot-absent `AssertionError: unexpectedly None` (252 inherited + 3 new proof tests N2313/N2314/N2315; N2309/N2310/N2311/N2312 add no test).

## SSOT / DEFERRED

SSOT single-slice **+0/+1/+0/+0** → 11933/1754/1688/3168: ledger entry with
`godot_owner` = the N2296 pure, `source_symbols` = its 3 result symbols
(accept_payload / accept_item / accept_liquid — shared ownership; the validator
only requires a non-empty list). No new pure, no new symbol/schema/contract.
DEFERRED 324 (325 − 1 intake-gate entry #313 resolved by text + 0 new).

## Godot debt

- NEW proof `C07PayloadUnloaderIntakeGateProof` (6 keys:
  `intake_accepts_when_verdict_true`, `intake_drops_when_verdict_false`,
  `intake_drops_without_descriptor`, `intake_keeps_when_occupied`,
  `live_tick_wires_the_gate`, `null_push_still_consumed`) — written but NEVER
  run; debt in GOAL.md §5.
- RE-RUN of proof N2279 (`C07PayloadUnloaderLiveFillProof`) — the fixture
  changed (load-bearing descriptor keys); recorded as a re-run note on the
  N2279 §5 entry.
