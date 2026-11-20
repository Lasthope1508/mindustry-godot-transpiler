# Reconciliation round 25 — renumber N2275 → N2321 (divergence #46)

## Divergence

- origin/main 46d4b30 → **192a5bc** (6 commits: slice 67f5550 + 5 docs). Remote **N2275
  = TurretBuild.updateTile() — unit maxHealth state** (owner
  `SourceTurretBuildState.source_turret_unit_max_health_state`, 4 exact_exprs, 1
  symbol, 4 tests, proof "4 keys" commit-message only — remote tree has the .gd +
  .tscn but NO proof JSON) collides number-only with local **N2275 =
  RadarBuild.fogRadius()** (owner
  `SourceRadarBuildState.source_radar_fog_radius_state`, commit 205c102, 10
  exact_exprs, 1 symbol, 4 tests, proof C07RadarFogRadiusProof **9 keys** all true,
  counted from JSON). Overlap **0/4 exact_exprs**, 0 symbols, 0 tests. Different
  family/file/method (`RadarBuild.fogRadius()` vs `TurretBuild.updateTile()` unit
  maxHealth).
- Probe: `hidden_files/divergence-46-n2275-renumber-impact.md` (89 occurrences / 32
  files; main thread re-verified the collision from disk: remote ledger added key
  only N2275; local N2275 still present, N2321 free in both ledgers). Merge-time
  (not a renumber blocker): remote N2275 is 1 pure function + 1 driver tick (duo
  branch, before tick N2260 unit sync and tick N2274 world position — Java order
  `BlockUnitComp.tile()` :21 maxHealth, :22 health, :23 hitSize, :24 set). Local GD
  has no `source_turret_unit_max_health_state` — merging remote adds a new function,
  no dedup. Remote N2275 vs local N2307 (unit()): overlap 1/4 — only
  `unit.tile(this);` (a call-site line N2307 also quotes as evidence), no dedup.
  Remote N2274 + N2275 are two consecutive sub-slices of the same driver tick —
  merge both together after #45 + #46 to avoid touching `SourceTurretBuildState.gd`
  twice.

## Renumber

- **N2275 → N2321 (Radar fogRadius), commit `2db57da`** (24 files, 943+/943-).
  Reserve N2321 by script first (status 'reserved', then 'done' after commit). Sed:
  register fog_radius + draw + draw_select + draw_place + drill_sense (whole files)
  + 6 test files (whole files) + 3 proof .gd (whole files) + GD
  `SourceRadarBuildState.gd` + GD `SourceBurstDrillBuildState.gd` (whole files —
  comment cross-refs, incl. the "N2311/N2275/N2281 explicit-param precedent"
  citations in BurstDrill) + spec :321 (first occurrence only — the row label; the
  same line's "N2275 in round 5 (divergence #19...)" history KEPT) + spec :349 (the
  N2281 row cross-ref, 1 occurrence) + GOAL :361. AGENTS.md: **0 hit** N2275, no edit
  needed. No GD function renamed (comments only).
- Script delete: ledger key + 1 contract + 2 schemas (input+result) +
  defense_api_contracts entry + defense_slices key. Asserted each delete count before
  proceeding (ledger 1737 → 1736, contracts 1685 → 1684, schemas 3161 → 3159).
  `production_state_schema.json` was NOT deleted by hand — the drill_sense rule
  carrying N2275 is refreshed by re-running register_c07_drill_sense.
- **Chain re-register 5 registers** (fog_radius + drill_sense independent, then draw
  → draw_select → draw_place in import order), --verify **13/13 + 31/31 + 18/18 +
  14/14 + 20/20**. Post-chain full-tree grep: N2275 = 0 in all generated JSON
  (N2321 = 19 occurrences, incl. the refreshed production_state_schema rule) and 0
  in code except the historical "N2275 in round 5" reference (spec :321, kept by
  precedent). No sibling rule-text stragglers (lesson #42 check). Targeted 24/24
  (280 subtests, 6 files); family Radar 40/40 (392); wiring 32/32 (250); proof
  C07RadarFogRadiusProof re-run in main, **9 keys** all true (6 domain + 3 standard,
  counted from JSON). SSOT unchanged **11716/1737/1685/3161**. Done 1737.

## Gate + environment

- **Gate #46 GREEN** on the chunked runner (PID 14366, log
  `hidden_files/full-suite-renumber-46-gate.log`): **Ran 6241, failures=237, errors=0,
  skipped=5, 364/364 modules** — 237 FAIL headers, all 237 `unexpectedly None`,
  0 ERROR (counted from the log by main thread). Renumber #46 is fully closed.
- **VM restart #41 at 09:09 +07** (boot Nov 20 02:09 UTC, `who -b`) — AFTER gate
  #46 finished (~09:07), so the gate was NOT killed. `/usr/local` tmpfs was wiped
  as usual; cron recreated the Godot symlink at 02:18 UTC and verified
  `4.6.2.stable.official.71f334935` (main thread re-verified: symlink present,
  version matches). No gate rerun needed.

## Docs (this commit)

- This report + handoff (round 25). Spec row + GOAL §5 number were already renumbered
  in the renumber commit 2db57da (precedent rounds 7–24); GOAL scene hash stays
  `205c102` (the commit that first carried the scene to Windows — the renumber changed
  no scene content).

## Handoff / next

- **Renumber #47 NEXT (last of the queue):** local N2276 (Turret write/read/version,
  25 exact_exprs, proof C07TurretWriteReadProof 11 keys all true) → **N2322**.
  Remote N2276 = TurretBuild.updateTile() unit health (4 exact_exprs, origin
  5f0f72c, 5 commits: slice a5ccb08 + 4 docs). Number-only, overlap **0/4
  exact_exprs**, 0 symbols, 0 tests (main thread re-verified from disk; N2320/N2321/
  N2322 free in both ledgers). Probe:
  `hidden_files/divergence-47-n2276-renumber-impact.md` (read before starting).
  Reserve N2322 by script first (next_free_n is 2322 now).
- After #47 (chunked gate + docs round 26): spawn batch **N2323–N2325**
  (controlled() / DrillBuild.draw() base / 3 music getters), then **N2326–N2328**
  (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig / findMusic), then
  **N2329–N2331** (drawSelect / Drill.icons / play), then **N2332–N2334** (Turret
  shouldTurn / BurstDrill shouldConsume / Game reload — scope file
  `hidden_files/next-batch-scope-after-n2327.md` exists). Scope files need relabel
  after the renumber queue (labels on disk are TEMP, pre-#42):
  `next-batch-scope-after-n2315.md` +6 → N2323–N2325,
  `next-batch-scope-after-n2319.md` +6 → N2326–N2328,
  `next-batch-scope-after-n2323.md` +5 → N2329–N2331,
  `next-batch-scope-after-n2327.md` +3 → N2332–N2334. next_free_n after 4 renumbers
  + 4 batches = **2335**. Reserve by script + write spawn lock BEFORE spawning;
  worktrees from latest HEAD (after docs #47); brief includes editor-import uid_cache +
  port-7777-free check + Godot symlink check.
- allocations.json: N2321 done (2db57da), next_free_n **2322**. N2304 held (ambient C,
  waits for Windows B).
- Push from Windows: local ahead/behind origin/main 5f0f72c = **108 / 196** (counted
  2026-11-20 ~09:2x +07; recount at push time). Merge by hand in the spec at push
  time. No force-push. Merge-time flags: remote N2275 unit maxHealth is new (no
  dedup; 1/4 overlap with local N2307 is a call-site line); remote N2274 + N2275 are
  consecutive sub-slices of the same driver tick — merge together; remote N2273
  charge effect is new (no dedup, first slice touching `TurretBuild.shoot()`); remote
  N2273 vs remote N2271 (charge sound) are two sub-slices of the same `shoot()` —
  compare at merge; remote N2276 unit health — check overlap at merge (probe #47);
  warmup ownership/dedup (remote N2253 vs local N2308, 15/34 exprs); remote recoil
  family N2254–N2258 complementary; remote N2258 vs local N741/N742; remote updateTile
  driver-tick family N2259–N2263 + N2265 + N2270 complementary; remote N2266
  targetPosition overlaps local N2122 (16/21 exprs) + needs hasAmmo (N2313, done) +
  peekAmmo (in batch N2326–N2328) owned before it merges; remote N2267 super.control()
  overlaps local N552/N553/N1088/N1089 (13/15 exprs); remote N2268 configured()
  overlaps local N544–N549/N1751/N1752 (23/26 exprs); remote N2269 queuedBullets/
  charging overlaps local N2308 (2/24 exprs); `SourceItemTurretBuildState.gd`
  both-modified; remote adds functions to SourceTurretBuildState.gd (plus local N2285
  status + N2297 accessors + N2307 unit() + N2313 hasAmmo()).
