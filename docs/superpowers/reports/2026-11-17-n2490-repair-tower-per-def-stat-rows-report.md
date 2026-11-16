# Report N2490 — RepairTower per-def stat rows

**Slice:** N2490 — RepairTower per-def stat rows (DEFERRED
#36). **Wave:** advances-34. **Commit:** `ddfa5a197` on
`slice/N2490-repair-tower-per-def-stat-rows` (base `ad308cf7e`).
**Files:** 5, +715/−1.

## Source

Blocks.java: the def block :6575-6583 (`unitRepairTower = new
RepairTower("unit-repair-tower"){{`, :6575) with `requirements(
Category.units, with(Items.graphite, 90, Items.silicon, 90,
Items.tungsten, 80));` (:6576), `size = 2;` (:6578), `range =
100f;` (:6579) and `healAmount = 1.5f;` (:6580). The def is the
ONLY RepairTower def — no second def exists, so there is no
family split to manage. The class defaults
(RepairTower.java:21/24, Block.java:215/356): `public float
range = 80f;` (RepairTower.java:21), `public float healAmount =
1f;` (RepairTower.java:24), `public int size = 1;`
(Block.java:215) and `public ItemStack[] requirements = {};`
(Block.java:356). RepairTower extends Block (`public class
RepairTower extends Block{`, RepairTower.java:18).
Blocks.load():188 is the real enclosing method for the ledger
entry.

## Implementation

One pure-only stats pure (the N2304 / N2442 verification-slice
precedent): `source_repair_tower_per_def_stats_state(def_id)`
→ {size, range, heal_amount, requirements} — the def's rows
for unit-repair-tower, with the CLASS defaults (size 1, range
80f, healAmount 1f, no requirements) for an unknown def id
(the N2304 fallback precedent).

**Verify-first findings:**
- The requirements dict is the {item: amount} dict from the
  def (the SourceAcceleratorBuildState capacities precedent:
  {"copper": 8000, ...}); the catalog carries the same rows
  as an Array of {item, amount} dicts (content_registry.json,
  unit-repair-tower).
- The brief was confirmed on all points — def values, class
  fallbacks, and the single-def family.

## Commits

- Slice: `ddfa5a197` (5 files, +715/−1).
- Integration cherry-pick: `db98566f1` (clean).

## Tests

Targeted (new module
`tests.test_c07_repair_tower_per_def_stat_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (7 RepairTower modules) Ran 28 (21
PASS + 7 proof Godot-absent), 0 errors.
Full gate (wave advances-34 integration): run 1 (PID 16663, from 02:12) KILLED by VM restart #18 ~02:32 (no footer); run 2 (PID 1769, 02:33–03:08): Ran 6930 tests in 1643.573s, FAILED (failures=407, skipped=5), 0 errors — 407/407 Godot-absent (400 inherited + 7 new proof tests N2484–N2490; Ran 6930 = 6902 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2 → 12405/1899/1853/3498** (exactly as
estimated). DEFERRED **#36 RESOLVED** (231→230, by entry TEXT).

## Godot debt

- NEW proof `C07RepairTowerPerDefStatRowsProof` (6 keys:
  `stats_tower`, `stats_size`, `stats_heal_range`,
  `stats_requirements`, `stats_class_fallback`,
  `stats_live_input`) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run.
