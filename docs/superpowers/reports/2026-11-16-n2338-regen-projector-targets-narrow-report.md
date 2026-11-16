# Report N2338 — RegenProjector updateTargets hitbox + privileged narrow

**Slice:** N2338 — RegenProjector updateTargets hitbox + privileged narrow
refinement (chained after the N2277 rect scan). **Wave:** advances-15.
**Commit:** `12436d1a` on `slice/N2338-regen-projector-update-targets-hitbox`
(base `c89f1d09`). **Files:** 9, +2810/−6.

## Source

Java: `BlockIndexer.eachBlock` intersects the team buildingTree quadtree
with the rect (BlockIndexer.java:364-380); the predicate admits a building
only if `pred.get(b) && !b.block.privileged` (:372). `privileged` defaults
false (Block.java:148). **FOUR privileged defs** (not three — the brief,
SCOPE, and the N2277 docstring all missed world-switch): world-processor
:6955, world-cell :6965, world-message :6974, **world-switch :6981**
(Blocks.java). Hitbox overlap is STRICT Rect.overlaps (Rect.java:274-276 —
exact edge touch is OUT). hit_size = size × tilesize
(BuildingComp.java:2048).

## Implementation

New pure `source_regen_projector_update_targets_narrow_state(targets,
candidates, team_id, building_x, building_y)` → `{targets}` (NOT
`{candidates}` as the brief suggested — N2277 entries carry no
x/y/hit_size/privileged, so the narrow takes both N2277 targets + raw
candidates). Pass 1: keep N2277 rect members, drop privileged only (join
by pos; a member without a candidate is kept — privileged defaults false).
Pass 2: admit same-team straddlers with hitbox STRICT overlap vs the rect,
rebuilding the N2277 entry format (pos/block_health/health/damaged epsilon
0.001f/heal_suppressed). Tick: N2277 scan → narrow → frame["targets"];
tick candidates carry hit_size + privileged: false. Defaults: hit_size
missing → 0.0 (overlap falls back to center, STRICT); privileged missing →
false; missing x/y → excluded; non-Dict → skipped. The worker also fixed
the N2277 docstring (4 privileged defs).

Scope corrections: (1) four privileged defs, not three (world-switch
:6981); (2) the brief was WRONG about seeding — the N2277 proof does NOT
seed hydrogen; the worker seeded per the N2325 pattern (hydrogen 1.0 +
power_status 1.0 + any_targets true).

## Commits

- Slice: `12436d1a` (9 files, +2810/−6).
- Integration cherry-pick: `d6034c19` (clean — including its generated
  JSON files, the first of four advances-15 slice commits that did not
  revert generated/).

## Tests

Targeted (new module `tests.test_c07_regen_projector_targets_narrow`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). RED confirmed (KeyError
N2338). Exact-evidence 13/13. Siblings 7 modules Ran 28 = 21 PASS + 7
proof, 0 other failures.
Full gate (wave advances-15 integration, PID 1755, 08:31–08:52): Ran 6415 tests in 1285.515s, FAILED (failures=280, skipped=5), 0 errors — 280/280 Godot-absent `AssertionError: unexpectedly None` (275 inherited + 5 new proof tests N2338/N2339/N2340/N2342/N2343).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11970/1777/1709/3210 (exactly the SCOPE
estimate): 1 symbol (BlockIndexer.java); purely additive +507/−0; no shard
changed. Audit stays 1336.
DEFERRED net 0 (resolve #249 hitbox+privileged + 1 new: live privileged
flag fill — the tick passes privileged=false for all live candidates since
the catalog has no privileged flag).

## Godot debt

- NEW proof `C07RegenProjectorTargetsNarrowProof` (**5 keys**, not 6:
  `narrow_admits_hitbox_straddler`, `narrow_excludes_at_exact_hitbox_edge`,
  `narrow_excludes_privileged`, `narrow_keeps_rect_entries_intact`,
  `live_tick_passes_narrowed_targets`) — written but NEVER run; debt in
  GOAL.md §5.
- N2277 does NOT need a re-run (only substring pins touched; the live tick
  still passes).
