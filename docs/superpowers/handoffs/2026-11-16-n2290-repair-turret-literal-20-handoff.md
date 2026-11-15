# N2290 RepairTurret Literal-20 Threshold — Fix Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

**This is a FIX slice (N2196 precedent):** no new pure, no new ledger entry, no new proof test, no new test module. SSOT delta **+0/+0/+0/+0**. Its Godot debt is a **RE-RUN of the N2280 proof**.

## What this slice did

Fixed the RepairTurret timer-target threshold to Java-exact literal 20 (was `20f/time_scale`). One code line + docstrings + test + proof scene update.

## Key facts for the next agent

- Java passes a LITERAL 20 — `if(timer(timerTarget, 20)){` (RepairTurret.java:214), NO timeScale division (unlike MendProjector.java:102, WallCrafter.java:207, ImpactReactor.java:91).
- Fix: `var threshold: float = INF if time_scale <= 0.0 else duration` (SourceRepairTurretBuildState.gd:245).
- **Decision — KEEP the `time_scale` param:** still read by the INF guard; signature/contract stable; the guard is unreachable in Java-exact play (timeScale always > 0).
- **The brief was WRONG twice:** (1) `source_delta` is UNSCALED Time.delta (game_source_delta = seconds × TICK_RATE) — the frame clock mirrors global Time.time exactly, making the fix MORE Java-exact; (2) elapsed DOES accumulate at time_scale 0 — no-fire comes from the INF guard, not non-accumulation.
- **Stale-base note (N2277 repeat):** the N2290 register was built on the N2280-era snapshot (291 entries) — the DEFERRED merge REJECTED its 39 removes + 17 re-adds and took only the true delta (deviation entry removal).
- SSOT +0/+0/+0/+0 (totals stayed 11855/1737/1670/3132). N2280 ledger deferred 292→291. Exact-evidence 13/13 (unchanged).

## Godot debt (this slice)

**RE-RUN of `C07RepairTurretTimerTargetProof`** (N2280, 6 keys, updated semantics) — the proof scene changed, so the Godot agent must run the UPDATED scene. Recorded in GOAL.md §5 as a re-run entry (like N2196). Targeted test: `tests.test_c07_repair_turret_timer_target`. Do NOT mark done until it passes on Godot.
