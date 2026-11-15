# N2290 RepairTurret Literal-20 Threshold — Fix Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

**This is a FIX slice (N2196 precedent):** no new pure, no new ledger entry, no new proof test, no new test module. SSOT delta **+0/+0/+0/+0**. Its Godot debt is a **RE-RUN of the N2280 proof** (`C07RepairTurretTimerTargetProof`, updated semantics) — recorded in GOAL.md §5 alongside the N2196 re-run.

## Source

Java passes a LITERAL 20 — `if(timer(timerTarget, 20)){` (RepairTurret.java:214), with NO timeScale division, unlike all three precedents (MendProjector.java:102, WallCrafter.java:207, ImpactReactor.java:91 all divide by timeScale). So Java re-acquires every 20 global ticks regardless of building timeScale. The N2280 port fired at `20f/time_scale` — Java-exact only at time_scale=1f, wrong under overdrive/slowdown. `delta()` = Time.delta × timeScale (BuildingComp.java:1922-1924). Java timeScale is always positive in practice (default 1f, BuildingComp.java:98; applyBoost/applySlowdown take positive intensities, :461–478; decay resets to 1f, :2265–2266).

## Implementation

`SourceRepairTurretBuildState.gd:245` — one code line: `var threshold: float = INF if time_scale <= 0.0 else duration` (was `duration / time_scale`). Driver header + pure docstring + limits block rewritten to record literal-20 live. Proof scene updated (keys keep names): the overdrive case `timer.call(19.0, 1.0, 2.0)` now fires, and a new no-early-fire case `timer.call(9.0, 1.0, 2.0)` does NOT fire (the N2280 deviation fired there, threshold 10). Test pins the fix (`assertIn 'INF if time_scale <= 0.0 else duration'`, `assertNotIn 'duration / time_scale'`, proof-call pins). Register: DEFERRED deviation entry removed; `time_scale`/`fired` rule texts updated; EXACT_EXPRS untouched (no formula in them).

**Decision — KEEP the `time_scale` param:** (1) it's still read — the non-positive guard (INF threshold) uses it, so it's not dead; (2) signature/contract/call sites/tests stay stable — dropping it would churn all four for zero Java-exactness gain; (3) the guard is a defensive port choice for a corrupt frame input, unreachable in Java-exact play, so the threshold is Java-exact at every reachable time_scale.

**Scope corrections (the brief was WRONG twice, grep-verified):** (1) `source_delta` is UNSCALED Time.delta (`game_source_delta` = seconds × TICK_RATE, SourcePlacedBlockState.gd:74–75; the advance multiplies time_scale separately for edelta) — this makes the fix MORE Java-exact, since the frame clock mirrors global Time.time exactly. (2) Elapsed DOES accumulate at time_scale 0 (the proof's own zero-scale case pins `elapsed_after == 20.0`) — no-fire at time_scale 0 comes from the kept INF guard, not non-accumulation. Docstrings/proof/test now say so. The DEFERRED entry sat at line 298 in DEFERRED-after-advances-7.py, not 294 (merge is by TEXT, no impact).

## Commits

Fix `e65bd685` (worker-N2290, branch `slice/N2290-repair-turret-literal-20`, 4 files, +123/−72, đã push, remote tip verified by ls-remote). Integration cherry-pick `114c7c44` on `integration/wave-advances-8-n2288-n2294` (base 2fcdc554). No coordinator fix needed for this slice. One self-caught fix during the run: the worker's first limits-block edit broke the test's pinned `'timer cadence live (N2280)'` string; reworded to keep the pin intact (N2148 lesson).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 13/13, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (RepairTurret power N2174 + should-consume N2212 + update-tile N2226 + coolant N2259): 12/16 PASS — the 4 fails are all their Godot proof tests, same `unexpectedly None` — 0 other failures. Full gate (wave advances-8 integration, PID 7543, 03:03–03:24): Ran 6262 tests in 1223.176s, FAILED (failures=242, skipped=5), 0 errors — 242/242 Godot-absent `AssertionError: unexpectedly None` (236 inherited + 6 new proof tests N2288/N2289/N2291/N2292/N2293/N2294; N2290 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+0/+0/+0/+0** — totals stayed 11855/1737/1670/3132, audit 1336 (register run verified). The generated diff was exactly the intended 3 files (ledger −1 deferred entry; schema + registry rule texts only). N2280 ledger deferred 292→291 after the register re-run. **Stale-base note (N2277 repeat):** the N2290 register was built on the N2280-era snapshot (291 entries), removing 39 merged entries and re-adding 17 pre-wave entries — the DEFERRED merge REJECTED all of those and took only the true delta (deviation entry removal). The N2280 ledger entry keeps its own 291-entry snapshot, which is correct for that slice. Merged wave DEFERRED: 321 entries (DEFERRED-after-advances-8.py) — 313 − 8 resolved/removed + 16 new, resolved by entry TEXT not number.

## Godot debt

**RE-RUN of `C07RepairTurretTimerTargetProof`** (N2280, 6 keys, updated semantics) — the proof scene changed, so the Godot agent must run the UPDATED scene. Recorded in GOAL.md §5 as a re-run entry (like N2196). Do NOT mark done until it passes on Godot.
