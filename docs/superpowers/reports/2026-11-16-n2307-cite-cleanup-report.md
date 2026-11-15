# Report N2307 — Cite cleanup (CLEANUP slice)

**Slice:** N2307 — Cite cleanup (PayloadBlock fields, Pump dump, UAM header). **Wave:** advances-10.
**Commit:** `2ee51c70` on `slice/N2307-cite-cleanup` (base `fa627ace`).
**Files:** 7, +14/−14, 0 test files.

## Source

Three wrong cites, all grep-verified:
- PayloadBlock fields: pre-existing driver comments cited :94/:95/:96 — actual is
  payload **:92** / payVector **:94** / payRotation **:95** (:93 is a TODO comment,
  :96 is `carried`).
- Pump dump block: cited :180-182 — actual is **:178-180**.
- UAM `acceptsPayload = true`: driver header cited :27 — actual is **:28** (:27 is
  `rotateDraw = false;`).

## Implementation

7 files, +14/−14 (not 4–6: the Pump cite also lived in a proof comment + the
N2088/N2089 registers). No test pinned the old cites (0 hits in tests/). Other
payload drivers already cited :92/:94/:95 correctly. The coordinator re-ran the 3
touched registers at integration (deconstructor update_tile, pump dump liquid
binding, pump update binding), propagating the fixes into the ledger (N2088/N2089
deferred_exprs[0] now cite :178-180) and the state schema, plus a follow-through
fix commit d516af80 (UAM register docstring stale note + spec N2088/N2090/N2291 +
GOAL advances-8 bullet).

**Drift found (pre-existing, NOT this slice's):** re-running the deconstructor
register ADDS `optional_mirror_fields: ["return_type"]` to the manifest + mirrors
`return_type: "Dictionary"` into payload_api_contracts.json (78 lines) — the
register code does this itself, committed generated state lacked it. Recorded in
the SSOT merge commit (479625e9); it does NOT change the 4 SSOT totals.

## Commits

- Slice: `2ee51c70` (7 files, +14/−14).
- Integration cherry-pick: `694bcd36` (clean); follow-through fix: `d516af80`.

## Tests

11 affected modules Ran 42 = 31 PASS + 11 proof, 0 other failures (proof tests
fail exactly AssertionError: unexpectedly None — NO Godot binary on this VM, user
order 2026-11-15).
Full gate (wave advances-10 integration, PID 1755, 04:31–04:53, run 2 — run 1 PID 20261 killed by VM restart #8 ~04:30, no footer): Ran 6302 tests in 1216.770s, FAILED (failures=252, skipped=5), 0 errors — 252/252 Godot-absent `AssertionError: unexpectedly None` (248 inherited + 4 new proof tests N2304/N2305/N2306/N2308; N2302/N2303/N2307 add no test).

## SSOT / DEFERRED

SSOT +0/+0/+0/+0 confirmed at all 3 states (before / after re-running the 3
touched registers / after reverting generated/). DEFERRED unchanged in count
(text changes only).

## Godot debt

None — cleanup slice, no new proof, no re-run.
