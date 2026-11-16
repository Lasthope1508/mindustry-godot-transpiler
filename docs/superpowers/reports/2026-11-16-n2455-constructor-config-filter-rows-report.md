# Report N2455 — Constructor config / filter rows

**Slice:** N2455 — Constructor canProduce() + config(Block) +
setStats(): three pure-only pures model the producibility gate, the
recipe config transition, and the output/buildSpeed stats. **Wave:**
advances-30. **Commit:** `e04f7d484` on
`slice/N2455-constructor-config-filter-rows` (base `4e4dc1a7c`).
**Files:** 5, +1049/−1.

## Source

canProduce() (Constructor.java:54-56): `b.isVisible() && b.size >=
minBlockSize && b.size <= maxBlockSize && !(b instanceof CoreBlock)
&& !state.rules.isBanned(b) && b.environmentBuildable() &&
(filter.isEmpty() || filter.contains(b))`. config(Block.class,
:32-37): `if(tile.recipe != block) tile.progress = 0f; if(canProduce(
block)){ tile.recipe = block; }`. configClear (:31/:38, registered
twice, same lambda): recipe = null. setStats (:41-47): `stats.add(
Stat.output, "@x@ ~ @x@", minBlockSize, minBlockSize, maxBlockSize,
maxBlockSize); stats.addPercent(Stat.buildSpeed, buildSpeed);`.
config() (:73-75): returns recipe. buildConfiguration (:66-70):
ItemSelection.buildTable with filter.isEmpty() ?
content.blocks().select(canProduce) : filter.

## Implementation

Three pure-only pures (no tick wiring — the live recipe config fill
is DEFERRED #99, a separate slice):
- `source_constructor_can_produce_state(block, min_block_size,
  max_block_size, filter)` → `{can_produce}`. All 7 Java conditions
  in Java order over a caller-supplied block Dict {name, is_visible,
  size, is_core_block, is_banned, environment_buildable} (the N2435
  precedent) + a filter name Array (empty = no filter).
- `source_constructor_config_state(action, block, current_recipe,
  can_produce)` → `{recipe, progress_reset, configure_call}`.
  Action ∈ {"set", "clear", "none"} (the N2449 precedent). **The
  reset runs BEFORE the canProduce gate** (:33 before :34), so a
  non-producible block still resets progress while the recipe stays;
  "clear" sets recipe null with NO reset; `configure_call` =
  `{method: "ItemSelection.buildTable", current_recipe}` (the UI is
  NOT ported, the N2443 picker precedent). The pure's `recipe` IS
  the post-action `config()` value (:73-75).
- `source_constructor_stats_state(min_block_size, max_block_size,
  build_speed)` → `{output_stat, build_speed_stat}`. output_stat =
  {key: "output", format: "@x@ ~ @x@", values: [min, min, max,
  max]}; build_speed_stat = {key: "buildSpeed", value: RAW}
  (addPercent formats at display, Stats.java:37-38 — the N2451
  precedent).

**Verify-first findings:**
- **Brief correction (pin numbers):** the brief said to pin
  write/read #84 and per-def #86 — but #84/#86 in the merged 253
  file are **LightBlock** entries, not Constructor; there is no
  Constructor write/read or per-def entry in the merged base. The
  worker pinned the real remaining Constructor gaps instead: **#99
  (live recipe config fill)** and **#169 (frame items intake)** —
  both asserted STAY in the test. No new DEFERRED entry added.
- **Def overrides verified:** constructor: filter 7 entries
  (Blocks.java:6666), buildSpeed 0.6f (:6662), min/max class
  defaults 1/2; large-constructor: empty filter, min 3 / max 4,
  buildSpeed 0.75f (Blocks.java:6675-6677); class buildSpeed default
  0.4f (BlockProducer.java:22).
- Stat tokens exact (`output` Stat.java:68, `buildSpeed`
  Stat.java:30). Blocks are content singletons, so Dict
  value-equality stands in for Java reference equality in
  `tile.recipe != block` (documented in driver + register).

## Commits

- Slice: `e04f7d484` (5 files, +1049/−1).
- Integration cherry-pick: `6245f61b4` (clean).

## Tests

Targeted (new module
`tests.test_c07_constructor_config_filter_rows`): 3/4 PASS
(registration, exact-evidence 34/34 exprs verbatim, row-state) +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-30 integration, PID 1777, from 22:30): Ran 6818 tests in 1589.793s, FAILED (failures=379, skipped=5), 0 errors — 379/379 Godot-absent (372 inherited + 7 new proof tests N2455–N2461; Ran 6818 = 6790 + 28 new tests, exact arithmetic; run 1 PID 13870 killed by VM restart #16 ~22:29, no footer).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+3/+6** → 12318/1872/1815/3422 (exactly
as estimated). Shards touched: `payload_api_contracts.json`,
`payload_slices.json`. Audit totalSourceFunctions unchanged 1336.
DEFERRED **#8 RESOLVED** (253→252, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07ConstructorConfigFilterRowsProof` (6 keys:
  `can_produce_visible`, `can_produce_size_gate`,
  `can_produce_filter`, `config_set`, `config_clear`, `stats_def`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
