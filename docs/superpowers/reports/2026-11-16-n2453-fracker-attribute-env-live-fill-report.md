# Report N2453 — Fracker attribute env live fill

**Slice:** N2453 — Fracker attribute env live fill: one live-fill
pure + tick wiring stamps frame["attribute_env"] from the env
map before the fraction recompute. **Wave:** advances-29.
**Commit:** `a1f8c0111` on
`slice/N2453-fracker-attribute-env-live-fill` (base `27b5ced7f`).
**Files:** 5, +967/−2.

## Source

SolidPump.java:124: `float fraction = Math.max(validTiles + boost
+ (attribute == null ? 0 : attribute.env()), 0);` (Fracker extends
SolidPump, Fracker.java:7). Attribute.env() (Attribute.java:31-34):
`if(Vars.state == null) return 0; return Vars.state.envAttrs.get(
this);`. `Vars.state.envAttrs` is `mindustry.world.blocks.
Attributes` — a float array indexed by attribute id (`return
arr[attr.id];`, Attributes.java:18), NOT an ObjectMap/
ObjectFloatMap. The oil-extractor def sets `attribute =
Attribute.oil;` (Blocks.java:2972; the Fracker class sets none).

## Implementation

One live-fill pure (the N2394/N2414 pattern) + tick wiring:
`source_fracker_attribute_env_live_fill_state(env_attrs,
state_present)` → `{attribute_env}`, placed after the tick
function (end of file). `env_attrs` is a caller-supplied Dict
keyed by attribute NAME (e.g. {"oil": 0.5}) — the port has no
envAttrs model, so the env map is the defined input contract (the
N2414 minimal-extension precedent); `state_present` false → 0.0
exact (the Attribute.java:32 null-state branch); a missing key →
0.0 — Java-exact, because the Attributes array default is 0.0,
never null. Tick wiring stamps `frame["attribute_env"]` before
the N2305 recompute (:806 area, enabled block), supplied-wins
(fill only when !frame.has("attribute_env")) + the
`attribute_env_live` flag (the N2394 precedent — protects the
N2224/N2305 proofs that seed attribute_env by hand).

**Verify-first findings (both brief questions resolved from Java,
not assumed):**
- Fracker attribute is **Attribute.oil** — confirmed,
  `attribute = Attribute.oil;` (Blocks.java:2972, oil-extractor
  def; the Fracker class sets none).
- `Vars.state.envAttrs` is **Attributes** — a float array indexed
  by attribute id (Attributes.java:18), not ObjectMap/
  ObjectFloatMap. Missing/unset key reads the array default 0.0,
  never null — so the pure's missing-key 0.0 is Java-exact.
- **Pin discipline:** the docstring edit is line-neutral; the :633
  frame-sync pin is verified intact (cite-sweep passes). The
  duplicate-`var` sweep found the new vars `env_filled` /
  `has_supplied_attribute_env` unique; the only repeat is the
  pre-existing `fill_cell` (N2414 :804 + N2408 :873) in sibling
  `if` blocks — legal GDScript, untouched. One GREEN fix: the
  comment phrase "envAttrs producer" was split across lines (the
  N2148 lesson) — rewrapped so the test pin matches.
- **Stale-base note:** this register built on the N2445 snapshot
  (265 entries), not the merged 258 — its list is 264. The
  coordinator's merge script audited by TEXT: the extras are
  exactly the 7 other advances-28 resolutions; only #216 is taken
  as the genuine delta.
- The N2414 proof is unaffected: it seeds `attribute_env` by hand,
  and supplied-wins preserves that seed.

## Commits

- Slice: `a1f8c0111` (5 files, +967/−2).
- Integration cherry-pick: `9ba37df45` (clean).

## Tests

Targeted (new module
`tests.test_c07_fracker_attribute_env_live_fill`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). Pin tests: cite-sweep, N2414
linked-tiles, N2305 fraction-fill non-proof tests all pass; their
2 failures are only their pre-existing Godot proof tests.
Full gate (wave advances-29 integration, PID 5146, from 20:43): Ran 6790 tests in 3014.832s, FAILED (failures=372, skipped=5), 0 errors — 372/372 Godot-absent (365 inherited + 7 new proof tests N2447–N2453; Ran 6790 = 6762 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 12292/1865/1802/3396 (exactly
as estimated). New symbol
`source_fracker_attribute_env_live_fill_state_result.attribute_env`.
DEFERRED **#216 RESOLVED** (by entry TEXT; register list 265→264
on the stale N2445 snapshot — the merge takes only #216).

## Godot debt

- NEW proof `C07FrackerAttributeEnvLiveFillProof` (6 keys:
  `env_present`, `env_missing_key`, `env_no_state`,
  `env_supplied_wins`, `env_live_tick`, `env_fraction_effect`) —
  written but NEVER run; debt in GOAL.md §5. The proof places a
  second extractor for `env_supplied_wins` (seeded env 0.7 +
  env_attrs oil 0.3 → keeps 0.7, no live flag).
- No old proof needs a re-run (supplied-wins protects the N2224 /
  N2305 / N2414 proofs).
