# Report N2385 — Fix latent cursor_after pins (N2284 + N2371 proofs)

**Slice:** N2385 — SERIAL (coordinator): fix 7 latent
`cursor_after` pins in the N2284 Fracker + N2371 write-back
proofs. **Wave:** advances-20 (serial follow-through). **Commit:**
`9740859b5` on `integration/wave-advances-20-n2377-n2383`.
**Files:** 2, +15/−12.

## Source

Java: BuildingComp.java:894 (the dump loop calls incrementDump
every iteration) + :1116-1121 (`incrementDump(prox)`:
`cdump = ((cdump + 1) % prox);`).

## Implementation

The liquid dump routing runs a FULL proximity scan every tick (N
neighbours = N incrementDump calls), so the cursor wraps back to
its start value — a 1-neighbour scan from cdump 0 ends at
(0+1)%1 = 0, not 1. The N2284 Fracker proof (4 pins: transferred,
scaled, full, refused) and the N2371 write-back proof (3 pins:
transferred, full, refused) pinned 1 for their 1-neighbour cases.
Both proofs never ran on Godot, so the error was latent; flagged
by worker-N2377, verified by the coordinator against the shared
routing (`SourceBuildingLiquidDumpState.gd:83-86` +
`increment_dump_cursor_state` = `(x+1)%prox`) and the N2285/
N2286/N2287 register rules, which all document the full cycle.
The fix also corrects 3 misleading comments ("cursor advances
0 -> 1" / "cursor still advances").

**Repo-wide audit:** every other liquid-dump cursor pin is
correct — N2285, N2286, N2287, N2378, N2379 proofs (early-return
cases keep the start cursor; the N2287 stale-cursor case
normalizes 5 → 2 over 3 neighbours). The item-dump proofs
(Unloader item phase, WallCrafter, the timerDump family) use the
item path, where the cursor moves per neighbour checked until
success — untouched, different invariant.

## Commits

- Serial: `9740859b5` (2 files, +15/−12) — 2 proof files only.

## Tests

Targeted: 2 modules (N2284 + N2371) Ran 8 (6 PASS + 2
Godot-absent proofs), 0 other errors. No Python test pins proof
values (the N2284/N2371 test modules pin driver code only).
Full gate (wave advances-20 integration, PID 14748, 13:27–13:50): Ran 6547 tests in 1364.438s, FAILED (failures=312, skipped=5), 0 errors — 312/312 Godot-absent `AssertionError: unexpectedly None` (306 inherited + 6 new proof tests N2377–N2381 + N2383; N2382 adds +1 pin test, N2384/N2385 add no test).

## SSOT / DEFERRED

SSOT **+0**, DEFERRED 0 — proof-only fix, no register.

## Godot debt

- No new proof. **2 RE-RUNS needed:** the N2284
  `C07FrackerDumpLiquidProof` + N2371
  `C07LiquidNeighbourWriteBackProof` (their pinned values
  changed 1 → 0) — recorded in GOAL.md §5.
