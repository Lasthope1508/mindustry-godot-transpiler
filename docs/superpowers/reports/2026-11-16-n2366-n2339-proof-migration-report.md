# Report N2366 — N2339 proof migration + BeamDrill fill gate removal

**Slice:** N2366 — Migrate the N2339 proof to seed `world_tiles` and
remove the N2352 `world_tiles.is_empty()` fill gate. **Wave:**
advances-18 (coordinator-serial). **Commit:** `e37ba4763` on
`integration/wave-advances-18-n2358-n2364` (no slice branch —
coordinator-serial after integration). **Files:** 10, +110/−79.

## Source

Java: BeamDrill.java:375-411 (updateFacing ray walk). The N2352 tick
stamp gated the facing-tile fill on `world_tiles` non-empty to
preserve the N2339 proof, which seeded `facing_tiles` directly. With
the proof migrated, the gate is dead weight — and it diverges from
Java (a tick with no world tiles should fill all-null rays, facing
amount 0).

## Implementation

Driver: removed `if not world_tiles.is_empty():` at
SourceBeamDrillBuildState.gd:1031 (the :396-403 cite in the plan was
the docstring, not the gate) + updated 5 docstrings — the fill now
runs EVERY enabled tick. N2339 proof migrated: seeds `world_tiles =
{"30,20": copper wall, "30,21": lead wall}` instead of facing_tiles
directly (N2346 origins for the drill at (28,20) rot 0, N2352 tick-1
precedent; the fill walks [[copper, null×4], [lead, null×4]], the
scan still counts 2; added SourceBlockGeometry preload + explicit
rotation meta 0). N2352 proof tick 3 updated: cleared world_tiles now
yields all-null rays + facing_amount 0 (was: keeps tick-2 rays, stays
1). N2352 test updated (gate pin → assertNotIn + 3 comments);
**N2363's test also pinned the gate**
(`assertIn('if not world_tiles.is_empty():')` as "N2352 untouched") —
updated to assertNotIn. The N2352 register DEFERRED facing entry
rewritten (same text in the merged DEFERRED-after-advances-18.py) +
schema description :482 + register re-run (diff limited to entry text
+ description, 4 generated files). N2346 proof SAFE (facing_amount 0
either way, untouched). `SourcePlacedBlockPortBridge.gd:14` has its
own unrelated `world_tiles.is_empty()` (placed-block Tile binding
guard) — left alone. Stale facing-entry copies remain in the
N2359/N2360/N2361/N2363 registers' embedded DEFERRED lists
(historical snapshots by design; the canonical merged file + the
owning N2352 register are updated).

## Tests

Targeted BeamDrill 9 modules Ran 36 (27 PASS + 9 proof Godot-absent),
0 other errors. Blast radius verified: the facing scan runs on
`frame.get("facing_tiles", [])` regardless of the fill gate, so
removing the gate only changes ticks that seeded facing_tiles with
mineable walls and no world_tiles — exactly the N2339 proof + N2352
proof tick 3. All other BeamDrill proofs that seed `facing_amount=1`
already get it overwritten to 0 by the scan after tick 1 with or
without the gate.
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT +0, DEFERRED 0 (entry rewrite in place).

## Godot debt

- No new proof.
- **N2339 proof `C07BeamDrillFacingScanProof` NEEDS A RE-RUN** —
  the proof fixture changed (seeds world_tiles now).
- **N2352 proof `C07BeamDrillFacingTilesFillProof` NEEDS A RE-RUN**
  — tick 3 expectations changed (all-null rays + facing_amount 0)
  and the fill gate it described is gone.
- Both noted on their GOAL.md §5 entries.
- Lesson: tests in OTHER slices can pin a removed construct — always
  grep the whole tests dir for it (N2363's pin).
