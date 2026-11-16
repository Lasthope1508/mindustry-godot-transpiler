# Report N2450 — ImpactReactor setBars / setStats rows

**Slice:** N2450 — ImpactReactor.setBars() + setStats(): two
pure-only pures model the net power bar and the production/warmup
stats. **Wave:** advances-29. **Commit:** `fadfdb37d` on
`slice/N2450-impact-reactor-bar-stats-rows` (base `27b5ced7f`).
**Files:** 5, driver +100/−1.

## Source

setBars() (ImpactReactor.java:45-53): addBar("power", ...) — label
`Core.bundle.format("bar.poweroutput", Strings.fixed(Math.max(
entity.getPowerProduction() - (consPower == null ? 0f :
consPower.usage), 0) * 60 * entity.timeScale(), 1))`, color
Pal.powerBar, fraction entity.productionEfficiency. setStats()
(:56-72): if hasItems: stats.add(Stat.productionTime, itemDuration
/ 60f, StatUnit.seconds); if consPower != null: max =
-(float)Math.log(0.001f) / warmupSpeed / 60f; equal =
-(float)Math.log(1f - Mathf.pow(consPower.usage / powerProduction,
1f / 5f)) / warmupSpeed / 60f; stats.add(Stat.warmupTime, t -> {
t.add(Strings.autoFixed(max, 2) + " " + StatUnit.seconds.localized()
+ " ~ " + Strings.autoFixed(equal, 2) + " " + StatUnit.seconds.
localized() + " " + StatUnit.powerEquilibrium.localized()); }).

## Implementation

Two pure-only pures (the N2442 precedent, no tick wiring):
- `source_impact_reactor_power_bar_state(power_production,
  cons_power_usage, time_scale, production_efficiency)` →
  `{label, color, fraction}`. `label` is a Dict `{key:
  "bar.poweroutput", amount: "6300.0"}` — Core.bundle.format
  composes the rendered string at the UI (the N2422 precedent);
  the pure does NOT build "Power Output: ...". `amount` is the
  Strings.fixed 1-place TRUNCATED value (N2426 lesson). `color`
  is the "Pal.powerBar" token; `fraction` is productionEfficiency
  RAW (Bar clamps [0,1] at render, Bar.java:33/:80 — the N2422
  lesson). `power_production` is the caller-supplied
  `getPowerProduction()` live read (PowerGenerator.java:156-158);
  the pure does NOT compute `powerProduction *
  productionEfficiency` — the producer fold is DEFERRED #71, still
  open.
- `source_impact_reactor_stats_state(item_duration, has_items,
  warmup_speed, cons_power_usage, power_production,
  has_cons_power)` → `{production_time_seconds,
  warmup_time_label}`. `production_time_seconds` = itemDuration /
  60f (null when !has_items); `warmup_time_label` IS the composed
  string (Java composes it inside setStats) — null when
  !has_cons_power.
New driver helpers `_strings_fixed` / `_strings_auto_fixed`
(no shared autoFixed helper exists; `fixed_one_decimal` covers
only 1 place; the inline N2426 precedent): `fixed` truncates via
`(int)(d*10^dp + 0.0001)` (Strings.java:735); `autoFixed`
truncates then strips precision (Strings.java:710-722). Float32
(Java) vs double (GDScript) verified to agree on every proof value
(all far from truncation boundaries).

**Findings beyond the brief (verify-first):**
1. **BRIEF CORRECTION — warmup label:** the brief said the label
   uses `" s "` + the `powerEquilibrium` token, but Java builds it
   from `StatUnit.localized()` = the bundle English values:
   `seconds.localized()` = `"seconds"` (`unit.seconds`,
   bundle.properties:1360), `powerEquilibrium.localized()` =
   `"power equilibrium"` (`unit.powerequilibrium`, :1357, via
   `Core.bundle.get("unit." + name.toLowerCase(...))`,
   StatUnit.java:61). The pure uses the bundle values. Label at
   the def: `"115.12 seconds ~ 21.16 seconds power equilibrium"`.
2. **Line numbers:** setBars is :45-53, setStats :56-72 (the brief
   said :44-52 / :56-70 — @Override → last statement); every cite
   in driver/test is verified exact (addBar :48, fixed :50,
   Pal.powerBar :51, fraction :52, productionTime :60, max :65,
   equal :66, t.add :68-69).
3. **Def constants verify-first:** itemDuration **140f** (overrides
   the class default 60f), powerProduction 130f, consumePower 25f,
   warmupSpeed 0.001f (the def does NOT override). Values at the
   def: net 6300.0, productionTime 2.3333333s, max 115.12s, equal
   21.16s.

## Commits

- Slice: `fadfdb37d` (5 files, driver +100/−1).
- Integration cherry-pick: `1a0eaff4e` (clean).

## Tests

Targeted (new module
`tests.test_c07_impact_reactor_bar_stats_rows`): 3/4 PASS
(registration, exact-evidence 41/41 exprs verbatim, row-state) +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). RED confirmed
first (KeyError 'N2450' + missing funcs).
Full gate (wave advances-29 integration, PID 5146, from 20:43): Ran 6790 tests in 3014.832s, FAILED (failures=372, skipped=5), 0 errors — 372/372 Godot-absent (365 inherited + 7 new proof tests N2447–N2453; Ran 6790 = 6762 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+2/+4** → 12296/1865/1803/3398 (exactly
as estimated). Power shards changed on register run
(`power_api_contracts.json`, `power_slices.json` — the N2182
precedent, ImpactReactor.java under `world/blocks/power/`). Audit
stays 1336. DEFERRED **#73 RESOLVED** (258→257, by entry TEXT; no
new entry). Remaining ImpactReactor entries (#71 producer, #72
explosion, #74 read/write, #75 per-def, #76 shouldConsume, #135
impactPower, #145 disabled-early-return) stay, pinned by the test.

## Godot debt

- NEW proof `C07ImpactReactorBarStatsRowsProof` (6 keys:
  `bar_label_net`, `bar_label_zero_floor`, `bar_fraction_raw`,
  `stats_production_time`, `stats_warmup_label`,
  `stats_gates_null`) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
