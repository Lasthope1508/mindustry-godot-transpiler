# Handoff N2489 — RepairTurret per-def stat rows

## What this slice did

One pure-only per-def stats pure (VERIFICATION slice, N2304 /
N2442 precedent — values were driver-header constants):
`source_repair_turret_per_def_stats_state` returns
{repair_speed, repair_radius, length, beam_width,
pulse_radius}; unknown def → CLASS defaults. 5 files, +906/−1,
commit `d7b3d5369` on
`slice/N2489-repair-turret-per-def-stat-rows`.

## Key facts for the next agent

- repair-point: 0.45f/60f/0.73f/5f, NO length → class 5f.
  repair-turret: 6f/3f/145f/1.1f/6.1f. Class:
  0.3f/50f/5f/1f/6f (RepairTurret.java:32-37).
- **Fallback is the CLASS defaults — deliberately NOT the
  repair-point fallback of the N2226 advance helpers**,
  which stay untouched.
- **The catalog carries NO repairSpeed / repairRadius /
  length / beamWidth / pulseRadius for this family** (0 hits)
  — the driver reads header constants (Separator craftTime
  precedent).
- RepairTurret.java is in units/, NOT defense/.
- SSOT +5/+1/+1/+2 (exact est). DEFERRED #34 resolved
  (231→230).

## Godot debt (this slice)

- NEW proof `C07RepairTurretPerDefStatRowsProof` (6 keys)
  — never run.
