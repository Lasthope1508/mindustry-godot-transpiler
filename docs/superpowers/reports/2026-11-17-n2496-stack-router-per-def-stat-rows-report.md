# Report N2496 — StackRouter per-def stat rows

**Slice:** N2496 — StackRouter per-def stat rows (DEFERRED #55).
**Wave:** advances-35. **Commit:** `eaa6633f1` on
`slice/N2496-stack-router-per-def-stat-rows` (base `67e525a68`).
**Files:** 5, +976/−1.

## Source

The def block (Blocks.java:2255-2268): `requirements(...,
with(Items.surgeAlloy, 5, Items.tungsten, 1));` (:2256),
`health = 130;` (:2257), `speed = 6f;` (:2259). **Speed is
the plain 6f form, NOT the StackConveyor def's 5f/60f** —
a different unit (router speed is the updateTile charge
cap, StackRouter.java:30), as the brief suspected.
**Brief scoping nuance: the class defaults span THREE
files, not just StackRouter.java** — size 1 / health /
requirements from Block.java (:215/:190/:356), speed 5f
from DuctRouter.java:19 (overrides Router.java:13's 8f);
only itemCapacity 10 (:20) + glow 1f/Pal.redLight (:15-16)
come from StackRouter.java itself. The def sets NO
size/itemCapacity/glow lines, so the surge-router row
carries class values for those four fields. Exactly ONE
StackRouter def exists (single `new StackRouter(` in
Blocks.java, :2255) — a 1-def family, but the pure still
takes `def_id` (the N2490 precedent).

## Implementation

One pure-only per-def stats pure (the N2304 / N2442
verification-slice precedent):
`source_stack_router_per_def_stats_state(def_id)` → {size,
speed, item_capacity, health, glow_alpha, glow_color,
requirements} — the surge-router rows, the CLASS defaults
for an unknown def id. **Health fallback judgment call
(coordinator ACCEPTED — same decision as N2495/N2497):**
the class health field is the −1 sentinel (Block.java:190,
"-1 to use scaledHealth"), not a stat value. The fallback
reports the init-resolved 40 (Block.java:1378-1394:
`scaledHealth = 40;`, scaling 1f with no requirements,
`Mathf.round(1*1*40, 5)`), the value Java actually presents
after init — never −1. The pure, test, proof, and register
all document the resolution explicitly
(SourceBlockInitHealthSourceTextState precedent). The
catalog id `surge-router` is verified in
content_registry_blocks.json (health 130 / speed 6.0 /
requirements match); the catalog carries no
size/itemCapacity/glow rows, so the driver reads header
constants.

**Verify-first findings:**
- The brief's numbers were all confirmed — no brief
  errors, no cite corrections needed.
- Only the 4 canonical JSON files changed — NO shard
  changes (no shard selector matches this owner,
  confirming the register docstring note).
- No new DEFERRED entry (the pure is complete as a pure;
  advance/draw/stats call-site wiring waits for its own
  slices, the N2421 precedent).

## Commits

- Slice: `eaa6633f1` (5 files, +976/−1).
- Integration cherry-pick: `0367af235` (clean).

## Tests

Targeted (new module
`tests.test_c07_stack_router_per_def_stat_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (9 StackRouter modules incl. DuctRouter
handle-stack) Ran 36 (27 PASS + 9 proof Godot-absent), 0 errors.
Full gate (wave advances-35 integration, PID 8638, 03:22–04:02): Ran 6958 tests in 1827.705s, FAILED (failures=414, skipped=5), 0 errors — 414/414 Godot-absent (407 inherited + 7 new proof tests N2492–N2498; Ran 6958 = 6930 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+7/+1/+1/+2 → 12428/1906/1860/3512** (exactly as
estimated). DEFERRED **#55 RESOLVED** (225→224, by entry TEXT).

## Godot debt

- NEW proof `C07StackRouterPerDefStatRowsProof` (6 keys:
  `stats_router`, `stats_speed_capacity`,
  `stats_health_glow`, `stats_requirements`,
  `stats_class_fallback`, `stats_live_input`) — written but NEVER
  run; debt in GOAL.md §5. The live input composes the N2442 stats
  pure (100.0 def / 120.0 class items/s), the N2433 draw glow
  (alpha 1.0/0.5), and the N2240 advance (progress 5.0 + eff 2.0
  crosses cap 6.0 → unloading, progress fmod = 1.0, 0 handoffs).
- No old proof needs a re-run.
