# Report N2484 — MendProjector heal effect rows

**Slice:** N2484 — MendProjector heal effect rows (DEFERRED #124).
**Wave:** advances-34. **Commit:** `e5daf198e` on
`slice/N2484-mend-projector-heal-effect-rows` (base `ad308cf7e`).
**Files:** 5, +826/−4.

## Source

MendProjector.java (core/src/mindustry/world/blocks/defense/):
the heal effect call :115 (`Fx.healBlockFull.at(other.x,
other.y, other.block.size, baseColor, other.block);`) inside the
eachBlock lambda :112-117 — AFTER the heal :113 (`other.heal(...)`)
+ recentlyHealed :114, BEFORE `any = true` :116. baseColor is
`Color.valueOf("84f491")` (:23); BOTH defs do NOT override it
(Blocks.java:1919-1942, 0 hits). The size travels as the rotation
arg of the overload `Effect.at(x, y, rotation, color, data)`
(Effect.java:133). The renderer body `healBlockFull`
(Fx.java:2781-2787, 20-tick) reads e.color + e.data
(Block.fullIcon) but NOT e.rotation — the size is still recorded
faithfully because the CALL passes it.

## Implementation

One pure-only FX call record (no tick wiring — the effect spawn
call site waits for audio/effect slices, the N2482 precedent):
`source_mend_projector_heal_effect_state(healed, x, y, size,
base_color, block_id)` → {heal_effect_call} — {effect:
"Fx.healBlockFull", x, y, size, color: base_color, block:
block_id} when healed, null when not (the N2397 null-when-absent
precedent). The healed verdict is a caller-supplied input from
the N2242 heal scan (damaged && !heal_suppressed && charge
crossed).

**Verify-first findings:**
- **The brief was wrong about N2399** — N2399 is the
  RegenProjector mendMap flush live heal application, NOT
  MendProjector. The healed verdict of this slice comes ONLY
  from the N2242 heal scan. The correction is recorded in the
  register docstring; the proof composes N2242 only.
- The baseColor token carries the STRING form "baseColor"
  (the N2373 draw-rows precedent), not a resolved Color.
- The effect fires PER healed building (inside the lambda) —
  one call record per healed building, not one per tick.
- All 13 EXACT_EXPRS verified verbatim from Java before
  writing.

## Commits

- Slice: `e5daf198e` (5 files, +826/−4).
- Integration cherry-pick: `a4b5794ad` (clean).

## Tests

Targeted (new module
`tests.test_c07_mend_projector_heal_effect_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (11 MendProjector modules) Ran 40 (30
PASS + 10 proof Godot-absent), 0 errors. No old test broke (the
N2242 heal scan stays green).
Full gate (wave advances-34 integration): run 1 (PID 16663, from 02:12) KILLED by VM restart #18 ~02:32 (no footer); run 2 (PID 1769, 02:33–03:08): Ran 6930 tests in 1643.573s, FAILED (failures=407, skipped=5), 0 errors — 407/407 Godot-absent (400 inherited + 7 new proof tests N2484–N2490; Ran 6930 = 6902 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2 → 12402/1899/1853/3498** (exactly as
estimated). DEFERRED **#124 RESOLVED** (231→230, by entry TEXT).
The neighbour entries #125 (mendSound) and #126 (recentlyHealed)
stay — the test registration pins all three conditions.

## Godot debt

- NEW proof `C07MendProjectorHealEffectRowsProof` (6 keys:
  `fx_on_heal`, `fx_null_when_not_healed`, `fx_position`,
  `fx_size`, `fx_color_block`, `fx_live_input` — live input
  composes the N2242 scan: mender charge 199 + heat 1 = 200 ≥
  reload 200, heal 100×4/100×1 = 4.0) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run.
