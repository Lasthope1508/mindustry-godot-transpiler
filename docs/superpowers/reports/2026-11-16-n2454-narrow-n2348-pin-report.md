# Report N2454 — Narrow N2348 tier_stamp pin (serial pin fix)

**Slice:** N2454 — coordinator-serial pin fix (the N2432/N2424
precedent): the N2447 slice legitimately changed the fact the
N2348 pin asserts, so the pin is narrowed to the remaining true
gap. NO new pure, NO new ledger entry, NO new proof, NO proof
file changed — NO re-run. **Wave:** advances-29. **Commit:**
`45d41d41a` on `integration/wave-advances-29-n2447-n2453`.
**Files:** 1, +10/−2.

## Source

The N2432 pin in `tests.test_c07_unit_assembler_module_tier_stamp`
asserted `'onRemoved / drawSelect still defer'` in the UAM driver
docstring — true when N2432 wrote it (draw rows live N2425, link
rows live N2358/N2381, onRemoved/drawSelect still deferred). N2447
ported drawSelect + onRemoved, so the docstring now says "Select /
remove rows live (N2447)" and the pin fails (verified by
worker-N2447: tier_stamp Ran 4, failures=2 — 1 proof Godot-absent
+ 1 pin break, exactly that assertion).

## Implementation

The pin now asserts:
- `assertIn('Select / remove rows live (N2447)', ...)` — the rows
  are live;
- `assertNotIn('onRemoved / drawSelect still defer', ...)` — the
  stale phrase is gone;
- `assertIn('the wasOccupied predicate evaluation, the
  handoff-to-intake wiring, and the live payload fill wait for
  their own slices', ...)` — the remaining true gap, taken verbatim
  from the driver docstring item (3).
The comment block records the N2454 change (like the N2432
comment). The pin is narrowed, not weakened: it still asserts a
live row + a remaining gap + the absence of the stale phrase.

## Commits

- Serial fix: `45d41d41a` (1 file, +10/−2).

## Tests

Targeted (existing module
`tests.test_c07_unit_assembler_module_tier_stamp`, no new module):
Ran 4, 3/4 PASS (registration, exact-evidence, row-state incl. the
narrowed pin) + proof test FAIL exactly AssertionError:
unexpectedly None — NO Godot binary on this VM (user order
2026-11-15).
Full gate (wave advances-29 integration, PID 5146, from 20:43): Ran 6790 tests in 3014.832s, FAILED (failures=372, skipped=5), 0 errors — 372/372 Godot-absent (365 inherited + 7 new proof tests N2447–N2453; Ran 6790 = 6762 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT **+0/+0/+0/+0** (pin fix only — no register run). DEFERRED
unchanged (no entry resolved or added by this slice).

## Godot debt

- NO new proof. NO re-run (no proof file changed).
