# Report N2308 — PayloadDeconstructor intake full-gate wiring

**Slice:** N2308 — Deconstructor intake full-gate wiring (N2297 verdict gates the N2291 push). **Wave:** advances-10.
**Commit:** `2726c503` on `slice/N2308-deconstructor-intake-gate` (base `fa627ace`).
**Files:** 6, +875/−19.

## Source

The pusher checks acceptPayload before handlePayload — `BuildingComp.java:822-824`
(movePayload) and `:844-845` (dumpPayload), `InputHandler.java:668-669` (unit
drop). The N2297 pures (`acceptPayload`, PayloadDeconstructor.java:104-106;
`acceptUnitPayload`, :92-95) expose the verdicts on the frame, but the N2291
intake guard was the frame null check only
(`if frame.get("payload", null) == null:`, driver :831). The handle pure takes
`block_size` as a param at the call site — but that is the DECONSTRUCTOR's own
size (5/3), NOT the payload's.

## Implementation

Tick builds the descriptor `{"requirements_length": len(incoming.requirements),
"block_size": ...}` from the incoming dict and calls the N2297 pure
`source_payload_deconstructor_accept_payload_state`; missing `block_size` → the
pure's default (max+1) → REJECT; non-dict push rejects; a rejected push is still
consumed (`frame["incoming_payload"] = null`). The pure's `payload_empty` /
`deconstructing_empty` terms replace the old null check outright. The offer
verdict still governs `frame["accepts_payload"]` — the intake never overwrites
it (precedence documented in the driver + proof key `live_tick_wires_the_gate`).
Bridge: the incoming dict carries `requirements` as an ARRAY (N2233 contract),
the pure reads `requirements_length` (int) — the intake derives the length from
the array. Only `block_size` is a new incoming-dict contract key.

**Brief self-contradiction (resolved by the worker, kept by the coordinator):**
the brief said "+0/+0/+0/+0" AND instructed "register a ledger entry" — a new
ledger entry necessarily makes slices +1. The worker followed the instruction;
the coordinator kept the entry (the registration test needs it).

**The N2291 test's pushes live in the PROOF file, not the test module** — the
worker updated the `C07PayloadDeconstructorDeconstructingFillProof.gd` fixture
(+`block_size: 2`). Load-bearing: without it, the N2291 proof's
`live_tick_fills_deconstructing` key fails (verdict rejects). → N2291 proof
becomes a RE-RUN.

## Commits

- Slice: `2726c503` (6 files, +875/−19).
- Integration cherry-pick: `634c4a9c` (clean).

## Tests

Targeted (new module `tests.test_c07_payload_deconstructor_intake_gate`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). RED before GREEN: 2 errors + 2 failures, as
expected. Exact-evidence 19/19. Siblings deconstructor (7 modules) Ran 28 = 21
PASS + 7 proof + payload family (8 modules) Ran 32 = 24 PASS + 8 proof, 0 other
failures.
Full gate (wave advances-10 integration, PID 1755, 04:31–04:53, run 2 — run 1 PID 20261 killed by VM restart #8 ~04:30, no footer): Ran 6302 tests in 1216.770s, FAILED (failures=252, skipped=5), 0 errors — 252/252 Godot-absent `AssertionError: unexpectedly None` (248 inherited + 4 new proof tests N2304/N2305/N2306/N2308; N2302/N2303/N2307 add no test).

## SSOT / DEFERRED

SSOT single-slice **+0/+1/+0/+0** → 11922/1750/1685/3162: ledger entry with
`godot_owner` = the N2297 pure, `source_symbols` = its 5 result symbols (shared
ownership — 762 symbols are already claimed by >1 slice; the validator only
requires a non-empty list). No new pure, no new symbol/schema/contract. DEFERRED
324 (325 − 1 intake-gate entry resolved + 0 new — no genuine deviation).

## Godot debt

- NEW proof `C07PayloadDeconstructorIntakeGateProof` (6 keys:
  `intake_accepts_when_verdict_true`, `intake_drops_when_verdict_false`,
  `intake_drops_without_block_size`, `intake_drops_when_deconstructing_busy`,
  `live_tick_wires_the_gate`, `null_push_still_consumed`) — written but NEVER
  run; debt in GOAL.md §5.
- RE-RUN of proof N2291 (`C07PayloadDeconstructorDeconstructingFillProof`) —
  the fixture changed (load-bearing `block_size`); recorded as a re-run note on
  the N2291 §5 entry.
