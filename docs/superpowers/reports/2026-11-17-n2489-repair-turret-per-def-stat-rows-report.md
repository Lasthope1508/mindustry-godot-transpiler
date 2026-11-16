# Report N2489 — RepairTurret per-def stat rows

**Slice:** N2489 — RepairTurret per-def stat rows (DEFERRED
#34). **Wave:** advances-34. **Commit:** `d7b3d5369` on
`slice/N2489-repair-turret-per-def-stat-rows` (base `ad308cf7e`).
**Files:** 5, +906/−1.

## Source

RepairTurret.java (core/src/mindustry/world/blocks/units/ —
NOT defense/): the class defaults :32-37 (`public float
repairRadius = 50f;` / `public float repairSpeed = 0.3f;` /
`public float length = 5f;` / `public float beamWidth = 1f;` /
`public float pulseRadius = 6f;`). The defs (Blocks.java:
6386-6406): `repairPoint = new RepairTurret("repair-point"){{`
with `repairSpeed = 0.45f;` (:6388) / `repairRadius = 60f;`
(:6389) / `beamWidth = 0.73f;` (:6390) / `pulseRadius = 5f;`
(:6392) — NO length line in the point block (:6386-6394), so
the point keeps the class 5f; `repairTurret = new
RepairTurret("repair-turret"){{` with `length = 6f;` (:6399) /
`repairSpeed = 3f;` (:6400) / `repairRadius = 145f;` (:6401) /
`beamWidth = 1.1f;` (:6403) / `pulseRadius = 6.1f;` (:6404).
The stat anchor is setStats() (:71-74): `stats.add(Stat.range,
repairRadius / tilesize, StatUnit.blocks);` + `stats.add(Stat.
repairSpeed, repairSpeed * 60f, StatUnit.perSecond);`.
length / beamWidth / pulseRadius feed drawBeam (:106-107, the
static drawBeam length / pulseRadius / beamWidth params).
repairSpeed feeds the heal advance (:207, `target.heal(
repairSpeed * strength * edelta() * multiplier)`) and
repairRadius feeds range() (:231-233) + the re-acquire range
(:216, `Units.closest(team, x, y, repairRadius,
Unit::damaged)`).

## Implementation

One pure-only per-def stats pure (the VERIFICATION slice, the
N2304 / N2442 precedent — the slice adds 10 header constants,
5 class defaults + 5 per-def rows, and ports them as one pure):
`source_repair_turret_per_def_stats_state(def_id)`
→ {repair_speed, repair_radius, length, beam_width,
pulse_radius}; an unknown def id falls back to the CLASS
defaults (the N2304 fallback precedent). The advance and draw
pures take these values as caller-supplied inputs and are
unchanged.

**Verify-first findings:**
- **The brief's "length 5f/6f" is point = class default /
  turret = def override** — confirmed from the def blocks,
  not assumed.
- **The fallback is the CLASS defaults — deliberately NOT
  the repair-point fallback of the N2226 advance helpers**
  (`_repair_speed_for_block` / `_repair_radius_for_block`),
  which stay untouched: the helpers are the live advance
  inputs, this pure is the verification row.
- **The catalog carries NO repairSpeed / repairRadius /
  length / beamWidth / pulseRadius for this family**
  (verified by grep: 0 hits for repairSpeed in
  content_registry_blocks.json), so the driver reads the
  header constants (the Separator craftTime precedent).
- The def-id strings are the catalog ids ("repair-point" /
  "repair-turret", verified in content_registry.json).

## Commits

- Slice: `d7b3d5369` (5 files, +906/−1).
- Integration cherry-pick: `24be2c81b` (clean).

## Tests

Targeted (new module
`tests.test_c07_repair_turret_per_def_stat_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (7 RepairTurret modules) Ran 28 (21
PASS + 7 proof Godot-absent), 0 errors.
Full gate (wave advances-34 integration): run 1 (PID 16663, from 02:12) KILLED by VM restart #18 ~02:32 (no footer); run 2 (PID 1769, 02:33–03:08): Ran 6930 tests in 1643.573s, FAILED (failures=407, skipped=5), 0 errors — 407/407 Godot-absent (400 inherited + 7 new proof tests N2484–N2490; Ran 6930 = 6902 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+1/+2 → 12406/1899/1853/3498** (exactly as
estimated). DEFERRED **#34 RESOLVED** (231→230, by entry TEXT).

## Godot debt

- NEW proof `C07RepairTurretPerDefStatRowsProof` (6 keys:
  `stats_point`, `stats_turret`, `stats_speed_radius`,
  `stats_beam_pulse`, `stats_class_fallback`, `stats_live_input`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
