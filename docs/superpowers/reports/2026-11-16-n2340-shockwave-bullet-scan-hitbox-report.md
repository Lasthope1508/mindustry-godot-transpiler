# Report N2340 — ShockwaveTower bullet scan hitbox refinement

**Slice:** N2340 — ShockwaveTower bullet scan hitbox refinement (chained
after the N2327 rect scan). **Wave:** advances-15. **Commit:** `851c9a1e`
on `slice/N2340-shockwave-hitbox-refinement` (base `c89f1d09`). **Files:**
13, +1618/−8.

## Source

Java: `BulletType.hitSize = 4` default (BulletType.java:43);
`bullet.hitSize = hitSize` (BulletType.java:970);
`rect.setCentered(x, y, hitSize, hitSize)` (HitboxComp.java:67) — the
hitbox is a hitSize-sided square centered on the bullet. STRICT overlap
per Rect.java:274-276, via QuadTree.java:190-191 / EntityGroup.java:195-198
(`Groups.bullet.intersect`).

## Implementation

New pure `source_shockwave_tower_supplied_bullets_hitbox_state(candidates,
range_value, tower_x, tower_y)` → `{"bullets": refined}`, chained AFTER
the N2327 rect scan (rect → hitbox, N2335 pattern). The tick passes the
refined list into the N2247 advance. The N2327 pure and the N2247 advance
are untouched (code verified unchanged; only a doc-comment sentence added
to each). Missing `hit_size` defaults to **4.0** (the BulletType default —
NOT N2335's 0.0; bullets have a type default). The pure filters
hitbox-overlap ONLY (no team/hittable re-filter).

## Commits

- Slice: `851c9a1e` (13 files, +1618/−8).
- Integration cherry-pick: `9ce53c35` (conflict in the 4 canonical
  generated JSONs — resolved --ours; the register re-run at SSOT merge
  regenerated the entries).

## Tests

Targeted (new module `tests.test_c07_shockwave_tower_bullet_scan_hitbox`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). RED confirmed (2F+2E).
Exact-evidence 11/11. Siblings ShockwaveTower Ran 28 = 21 PASS + 7 proof
Godot-absent, 0 other failures.
Full gate (wave advances-15 integration, PID 1755, 08:31–08:52): Ran 6415 tests in 1285.515s, FAILED (failures=280, skipped=5), 0 errors — 280/280 Godot-absent `AssertionError: unexpectedly None` (275 inherited + 5 new proof tests N2338/N2339/N2340/N2342/N2343).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11970/1777/1709/3210 (exactly the SCOPE
estimate): 1 symbol
(`source_shockwave_tower_supplied_bullets_hitbox_state_result.bullets`,
java_source arc-core Rect.java — arc-source precedent exists, 498 symbols).
Audit stays 1336.
DEFERRED net 0 (resolve #321 center-in-rect vs QuadTree hitbox overlap +
1 new: rect broad phase drops straddling hitboxes — the N2327 rect still
drops center-outside straddlers before the refinement ever sees them, the
same documented-deviation shape as N2335's #333).

## Godot debt

- NEW proof `C07ShockwaveTowerBulletScanHitboxProof` (6 keys:
  `refine_admits_straddling_hitbox`, `refine_admits_edge_hitbox`,
  `refine_drops_degenerate_edge_hitbox` (hitSize-0 point on edge/corner
  dropped — the STRICT boundary), `refine_defaults_missing_hit_size`,
  `refine_empty_stays_empty`, `live_tick_passes_refined_bullets`) —
  written but NEVER run; debt in GOAL.md §5. The live tick seeds cyanogen
  10.0 (N2331 pattern). All 6 key expectations were verified by simulating
  the pure logic in Python (incl. the live tick: 2 targets, waveDamage
  160, 500→340, heat 0.9875, counter 0, clock 0).
- Follow-through: N2327 + N2318 test pins updated (FULL call pin, N2335
  precedent — the advance call now takes `refined_bullets`; the N2327 test
  also pins the refinement call + rect < refine < advance ordering).
  **N2327 does NOT need a re-run from N2340** (its proof scene is
  untouched, and the simulated live-tick bullets through rect→refine —
  no `hit_size` keys → default 4.0 — give the same outcome, 1 target
  `enemy_in`; N2341's cyanogen fix to that scene is separate).
- Caveat: the worker started `tests.test_source_symbols` (SSOT-integrity
  neighbours) as extra safety; it produced zero output after ~15 min at
  ~76% CPU (giant module, likely just slow) and was killed — out of the
  assigned targeted+siblings scope; the coordinator's full gate runs it.
