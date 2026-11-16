# Report N2462 — Constructor live recipe config fill

**Slice:** N2462 — the Constructor tick wires the existing N2455
config pure to a frame-carried pending config action, stamping
frame["recipe"] + frame["progress"] BEFORE the shouldConsume gate —
the gate sees the new recipe the same tick. **Wave:** advances-31.
**Commit:** `8d04ed396` on
`slice/N2462-constructor-recipe-config-fill` (base `43a5c79ad`).
**Files:** 4, +403/−6 (wiring-only — no register).

## Source

Constructor.java (core/src/mindustry/world/blocks/payloads/):
config(Block.class) :32-37: `if(tile.recipe != block) tile.progress
= 0f; if(canProduce(block)){ tile.recipe = block; }`. configClear
:31/:38: recipe = null (no progress reset). The N2455 config pure
(`source_constructor_config_state`, driver :650) IS this transition,
pure-only — this slice wires it into the tick and does NOT re-port
the transition.

## Implementation

**Wiring-only (the N2413 precedent): NO new pure, NO register, SSOT
+0/+0/+0/+0, NO ledger entry.** The tick reads a pending config
action from `frame["recipe_config"]` = {action: "set"/"clear"/
"none", block: {"block": <catalog id>} or null, can_produce: bool}
(the N2449 action convention, one frame Dict) and applies the
EXISTING N2455 config pure, stamping frame["recipe"] +
frame["progress"] (0.0 only when the pure returns `progress_reset`)
BEFORE the recipe resolution, the shouldConsume gate, and the
consumption fold. Absent frame key = "none" no-op.

**Idempotency (pinned in the proof):** re-applying "set" with the
same block resets nothing (recipe == block after the first apply, so
:33's `recipe != block` is false); "clear" on a null recipe stays
null. The frame input does NOT need to be consumed — re-application
every tick is harmless.

**Placement note:** the wiring lands before the recipe resolution
(which precedes both the gate and the advance), so the dynamic
stacks + buildTime also read the new recipe the same tick — the
correct Java-order position (config is an input-handler event,
applied before the tick's consumption fold).

**Docstring update:** all "still waits / no live fill / DEFERRED
#99" mentions in the driver updated to "live since N2462" (#99 was
the OLD number in the 253 file; in the merged 246 file it is #95).
One stale comment OUTSIDE the slice scope was left untouched by the
worker: the N2455 proof file still said "the tick never calls
canProduce / config" — fixed at integration by the serial
follow-through fa7f3c028 (proof + test comments only).

**Verify-first findings:**
- Java matched the brief exactly (configClear :31/:38, config
  :32-37, reset :33 before canProduce gate :34 — verified by line
  number). No deviations.
- The tick's frame reads verified: the wiring lands BEFORE the gate
  + advance; frame["progress"] is the advance's progress key.

## Commits

- Slice: `8d04ed396` (4 files, +403/−6).
- Integration cherry-pick: `e3668750f` (clean).
- Serial follow-through at integration: `fa7f3c028` (N2455
  proof/test comments stale after N2462 — 2 files, +5/−4).

## Tests

Targeted (new module
`tests.test_c07_constructor_recipe_config_fill`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (N2216 should_consume, N2265
dynamic_item_row, N2440 draw_rows, N2455 config_filter_rows, N2153
power_status): Ran 20 (15 PASS + 5 proof Godot-absent), 0 errors.
Full gate (wave advances-31 integration, PID 8788, from 23:14): Ran 6846 tests in 1750.614s, FAILED (failures=386, skipped=5), 0 errors — 386/386 Godot-absent (379 inherited + 7 new proof tests N2462–N2468; Ran 6846 = 6818 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+0/+0/+0/+0** (wiring-only, exactly as
estimated). No register, no ledger entry, `generated/` untouched.
DEFERRED **#95 RESOLVED** (246→245 in the slice's count, by entry
TEXT; the removal is merge-side — the test pins the entry text from
the N2461 base snapshot).

## Godot debt

- NEW proof `C07ConstructorRecipeConfigFillProof` (6 keys:
  `fill_set_stamps`, `fill_set_resets_progress`, `fill_clear`,
  `fill_none`, `fill_idempotent`, `fill_gate_opens`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (a frame with NO recipe_config key
  behaves exactly as before — verified by the neighbours).
