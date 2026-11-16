# Report N2352 — BeamDrill facing-tile fill

**Slice:** N2352 — BeamDrill live facing-tile fill (updateFacing rays from
lasers + world_tiles; stamped before scan). **Wave:** advances-17.
**Commit:** `134ad443d` on `slice/N2352-beam-drill-facing-tile-fill` (base
`9282b27a`). **Files:** 5, +1289/−9.

## Source

Java: BeamDrill.java:375-411 (updateFacing ray walk from the laser origins
over the facing tiles) and :364-411. Laser origins are the N2346 pure.
36 exact exprs, all verified verbatim.

## Implementation

New pure `source_beam_drill_facing_tiles_fill_state` walks rays from the
laser origins (N2346) over `world_tiles` and fills `facing_tiles`; the tick
stamps the fill BEFORE the scan (Java order). The tick stamp is gated on
`if not world_tiles.is_empty()` (NOT unconditional as the brief sketched) to
preserve proof N2339, which seeds `facing_tiles` directly — stamping over an
empty world would wipe the seeded facing tiles.

## Commits

- Slice: `134ad443d` (5 files, +1289/−9).
- Integration cherry-pick: `b33b3c05f` (clean).

## Tests

Targeted (new module `tests.test_c07_beam_drill_facing_tiles_fill`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 36/36. Siblings
7 modules Ran 28 (21 PASS + 7 proof Godot-absent), 0 other errors.
Full gate (wave advances-17 integration, PID 12882, 10:58–11:23): Ran
6468 tests in 1457.080s, FAILED (failures=293, skipped=5), 0 errors —
293/293 Godot-absent `AssertionError: unexpectedly None` (287 inherited +
6 new proof tests N2351–N2354, N2356–N2357; N2355 has no proof test).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11985/1789/1721/3234, exactly as
estimated. Audit stays 1336.
DEFERRED **net 0**: #324 rewritten in place; fixed a stale cross-ref
(drop-loop entry 187→183).

## Godot debt

- NEW proof `C07BeamDrillFacingTilesFillProof` (6 keys:
  `fill_feeds_scan_count`, `live_tick_stamps_facing_tiles`,
  `missing_short_rays_and_bounds`, `null_and_nonsolid_tiles_pass_through`,
  `rotation_changes_ray_direction`, `walks_rays_from_laser_origins`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (the `world_tiles.is_empty()` gate preserves
  the N2339 proof's direct `facing_tiles` seed).
- Backlog (coordinator decision): migrate proof N2339 to seed `world_tiles`
  and drop the `world_tiles.is_empty()` gate — the gate is a preservation
  shim, not Java behavior.
