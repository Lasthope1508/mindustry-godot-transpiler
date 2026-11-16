# Handoff N2328 — BaseShield live bullet + enemy-unit scans

## What this slice did

Wired the BaseShield live scans: 2 new filter pures (bullet rect broad
phase + enemy-unit STRICT within) feed the N2236 advance (replacing the
`[], []` literals). 6 files, +1019/−13, commit `51d72e56` on
`slice/N2328-base-shield-scans`.

## Key facts for the next agent

- Pure 1 `source_base_shield_supplied_bullets_state(candidates, rad,
  building_x, building_y)` → `{bullets}`: RECT broad phase only — NO
  team/hittable filter here (the N2236 advance does the narrow check).
  Missing x/y → EXCLUDED.
- Pure 2 `source_base_shield_supplied_enemy_units_state(candidates, rad,
  building_x, building_y, team_id)` → `{enemy_units}`: enemy team +
  STRICT within (dst2 < (rad + 10 + hitSize/2)² — exactly at the range is
  OUT). Missing x/y → EXCLUDED; missing hit_size → 0.0 (N2226 precedent);
  missing team → own team (excluded).
- **The rad problem:** rad is computed INSIDE the advance (after the
  lerp), but the tick needs rad BEFORE the advance call. The driver
  computes `rad_after` with the SAME shared lerp helper + const the
  advance uses — deterministic, same result. The `rad > 1` gate lives at
  the TICK (mirror Java :93): rad <= 1 → both scans empty.
- Candidates ride frame `bullet_candidates` / `enemy_unit_candidates`
  (default [] — frame inputs; live Groups.bullet / Units queries still
  defer).
- **The N2236 test pin was updated in this slice** (:249, `[], []` →
  live call).
- All brief/SCOPE cites verified correct (BaseShield lerp :89 / rad :91 /
  gate :93 / intersect :96 / nearbyEnemies :97; unitConsumer :38–56;
  Units.nearbyEnemies :482–488).
- SSOT +2/+1/+2/+4 (exactly the SCOPE estimate; 2 pures → 2 contracts +
  4 schemas). DEFERRED net 0 (−1+1).

## Godot debt (this slice)

- NEW proof `C07BaseShieldScansProof` (6 keys) — never run.
