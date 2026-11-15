# Report N2312 — Separator N2222 proof fix (FIX slice)

**Slice:** N2312 — Separator N2222 proof stale slag seed. **Wave:** advances-11.
**Commit:** `3d22b2cf` on `slice/N2312-separator-n2222-proof-fix` (base `18dcabf2`).
**Files:** 1, +33/−14.

## Source

N2252 added the REQUIRED slag liquid row (Separator consumes slag 4f/60f,
separator def). The N2222 proof (`C07SeparatorUpdateTileProof`) seeds no slag,
so the machinery folds the live-tick efficiency to 0 instead of 0.5 and the
`live_tick_advances_progress_and_warmup` key (:140) fails on a Windows Godot
run. Same staleness class as N2300/N2302/N2303 (live-tick keys only). Flagged by
worker-N2281 at 01:58 16/11 (the N2281 slice seeded slag per the N2252
precedent and noticed the N2222 proof did not).

## Implementation

Proof file only (`C07SeparatorUpdateTileProof.gd`): seed slag 1.0 on the sprite
LIQUIDS meta (pattern N2281) + 3 preloads. Slag is a LIQUID (Liquids.slag) —
seeded on the liquids meta, NOT the items dict. Consumption/tick ≈ 0.033, so
1.0 has margin. Expected values unchanged.

## Commits

- Slice: `3d22b2cf` (1 file, +33/−14).
- Integration cherry-pick: `1dd42c4a` (clean).

## Tests

Targeted `tests.test_c07_separator_update_tile`: 3/4 PASS + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Siblings Ran 16 = 12 PASS + 4 proof, 0 other failures. Test file
untouched; the proof .gd change is invisible to the VM gate (the proof test
already fails Godot-absent).
Full gate (wave advances-11 integration, PID 7620, 05:08–05:30): Ran 6314 tests in 1275.835s, FAILED (failures=255, skipped=5), 0 errors — 255/255 Godot-absent `AssertionError: unexpectedly None` (252 inherited + 3 new proof tests N2313/N2314/N2315; N2309/N2310/N2311/N2312 add no test).

## SSOT / DEFERRED

SSOT +0/+0/+0/+0 confirmed (fix slice: no new pure, no new ledger entry, no new
proof test). DEFERRED unchanged.

## Godot debt

RE-RUN of proof N2222 (`C07SeparatorUpdateTileProof`) — the fixture changed, so
the Windows Godot agent must re-run it. Recorded in GOAL.md §5 (re-run note on
the N2222 entry).
