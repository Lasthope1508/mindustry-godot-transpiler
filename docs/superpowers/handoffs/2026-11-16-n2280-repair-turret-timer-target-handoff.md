# N2280 RepairTurret Timer-Target Cadence — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## What this slice did

RepairTurret timer-target cadence: pure `source_repair_turret_timer_target_state` → {fired, elapsed_after} (frame-local Interval-equivalent, N2266/N2269/N2273 precedent) + driver wiring that passes frame-input `unit_candidates` into the N2226 advance when the timer fires (20f), `[]` otherwise. Selection logic untouched — N2226 already ports the full clear + Units.closest selection pure.

## Key facts for the next agent

- **⚠️ The brief/SCOPE threshold formula was WRONG (pattern-copy error):** Java passes a LITERAL 20 — `if(timer(timerTarget, 20)){` (RepairTurret.java:214), with NO timeScale division, unlike all three precedents (MendProjector/WallCrafter/ImpactReactor all divide by timeScale). The worker implemented the brief's formula (fire at 20f/time_scale) as instructed and documented the deviation everywhere. **Coordinator decision: ACCEPTED as-is** — Java-exact at `time_scale = 1f` (the default); a Java-exact literal-20 threshold is a follow-up slice (DEFERRED entry exists).
- Candidates ride `frame["unit_candidates"]` (N2259 coolant_multiplier precedent) — the N2226 test pins the advance call text with a `[]` literal, so no new parameter was added.
- **First-fire deviation** (documented in docstring + DEFERRED): Java fires nearly immediately after placement; the frame clock delays the first fire by one full interval (20 ticks).
- The timer clock accumulates only while enabled (same pragmatic gate as the advance; Java runs updateTile even when disabled — the driver-wide disabled-early-return slice removes this gate for all families).
- Live unit frames do NOT exist — candidates are a frame input; the live Units scan is its own slice (DEFERRED). Defs: repair-point 60f / repair-turret 145f (Blocks.java:6389/6401), already handled per def by N2226.
- SSOT +2/+1/+1/+2 → 11797/1724/1655/3102 (audit 1336). Exact-evidence 13/13. DEFERRED 292 (2 entries updated in place + 2 new: first-fire deviation, time-scale threshold deviation).

## Godot debt (this slice)

`C07RepairTurretTimerTargetProof` — 6 keys: timer_fires_at_twenty_ticks, timer_no_fire_below_threshold, timer_no_fire_when_time_scale_zero, timer_passes_candidates_on_fire, timer_passes_empty_when_not_fired, timer_resets_elapsed_on_fire (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_repair_turret_timer_target`. Do NOT mark done until it passes there.
