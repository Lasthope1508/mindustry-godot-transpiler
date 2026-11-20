# Reconciliation round 26 — renumber N2276 → N2322 (divergence #47)

## Divergence

- origin/main 192a5bc → **5f0f72c** (5 commits: slice a5ccb08 + 4 docs). Remote **N2276
  = TurretBuild.updateTile() — unit health state** (owner
  `SourceTurretBuildState.source_turret_unit_health_state`, 4 exact_exprs, 1
  symbol, 4 tests, proof "4 keys" commit-message only — remote tree has the .gd +
  .tscn but NO proof JSON) collides number-only with local **N2276 =
  TurretBuild.write/read/version** (owner
  `SourceTurretBuildState.source_turret_write_state`, commit aedbfdd, 25
  exact_exprs, 5 symbols, 4 tests, proof C07TurretWriteReadProof **11 keys** all
  true, counted from JSON). Overlap **0/4 exact_exprs**, 0 symbols, 0 tests.
  Same java_class/source (Turret.java), different method/owner.
- Probe: `hidden_files/divergence-47-n2276-renumber-impact.md` (main thread
  re-verified the collision from disk: remote ledger added key only N2276; local
  N2276 still present, N2322 free in both ledgers). Merge-time (not a renumber
  blocker): remote N2276 is 1 pure function + 1 driver tick (duo branch, tile()
  :21 maxHealth N2275 → :22 health N2276 → :23 hitSize N2260 → :24 set N2274);
  local GD has no `source_turret_unit_health_state` — merging remote adds a new
  function, no dedup. Remote N2276 vs local N2307 (unit()): overlap 1/4 — only
  `unit.tile(this);` (a call-site line), no dedup. Remote N2274 + N2275 + N2276 are
  three consecutive sub-slices of the same driver tick — merge together after
  #45–#47 to avoid touching `SourceTurretBuildState.gd` three times.

## Renumber

- **N2276 → N2322 (Turret write/read/version), commit `08cb8f0`** (16 files,
  411+/411-). Reserve N2322 by script first (status 'reserved', then 'done' after
  commit). Sed: register write_read + is_active + micro_accessors +
  burst_drill_write_read (whole files) + 2 test files (whole files) + proof .gd
  (whole file) + GD `SourceTurretBuildState.gd` + GD
  `SourceBurstDrillBuildState.gd` (whole files — comment cross-refs, incl. the
  "contrast N2276 Turret" readSync note) + spec :344 (first occurrence only — the
  row label; the same line's "N2276–N2278" batch label KEPT) + spec :354 (the
  N2286 row cross-ref, 1 occurrence) + GOAL :407. Spec :345/:346 batch labels
  KEPT (historical). No GD function renamed (comments only).
- Script delete: ledger key + 3 contracts + 6 schemas (input+result of the three
  owners) + defense_api_contracts entry (1, write_state only) + defense_slices
  key. Asserted each delete count before proceeding (ledger 1737 → 1736,
  contracts 1685 → 1682, schemas 3161 → 3155). `production_state_schema.json` was
  NOT touched by hand — no N2276 rule lived there (verified: the 7th schema
  occurrence was `source_turret_drawrot_state_input` of N2297, refreshed by the
  micro_accessors re-register).
- **Chain re-register 7 registers** (write_read → is_active → min_range → status
  → micro_accessors → unit → has_ammo in import order), --verify **36/36 +
  17/17 + 16/16 + 25/25 + 28/28 + 15/15 + 21/21**. Post-chain full-tree grep:
  N2276 = 0 in all generated JSON (N2322 = 28 occurrences) and 0 in code except
  the historical "N2276–N2278" batch labels (spec :344/:345/:346, kept by
  precedent). No sibling rule-text stragglers (lesson #42 check). Targeted 32/32
  (417 subtests, 8 files); family Turret 64/64 (876); wiring 32/32 (250); proof
  C07TurretWriteReadProof re-run in main, **11 keys** all true (8 domain + 3
  standard, counted from JSON). SSOT unchanged **11716/1737/1685/3161**. Done
  1737.

## Gate + environment

- **Gate #47 GREEN** on the chunked runner (PID 4498, log
  `hidden_files/full-suite-renumber-47-gate.log`): **Ran 6241, failures=237,
  errors=0, skipped=5, 364/364 modules** — 237 FAIL headers, all 237
  `unexpectedly None`, 0 ERROR (counted from the log by main thread). Renumber
  #47 is fully closed. The renumber queue #44–#47 is now EMPTY.
- No new VM restart since #41 (boot Nov 20 02:09 UTC, `who -b`); Godot symlink
  intact, version `4.6.2.stable.official.71f334935`.

## Docs (this commit)

- This report + handoff (round 26). Spec row + GOAL §5 number were already
  renumbered in the renumber commit 08cb8f0 (precedent rounds 7–25); GOAL scene
  hash stays `aedbfdd` (the commit that first carried the scene to Windows — the
  renumber changed no scene content).

## Handoff / next

- **Divergence #48 ARRIVED during gate #47** (origin 5f0f72c → **9391d5a**, 5
  commits: slice 23b993d + 4 docs). Remote **N2277 = TurretBuild.updateTile() —
  isShooting state** (owner `SourceTurretBuildState.source_turret_is_shooting_state`,
  6 exact_exprs, 1 symbol, 4 tests, proof "5 keys" commit-message only, no proof
  JSON) collides number-only with local **N2277 = DrillBuild.ambientVolume()
  super leg** (owner `SourceBurstDrillBuildState.source_drill_ambient_volume_state`,
  8 exact_exprs, 1 symbol, 4 tests, proof C07DrillAmbientVolumeProof **8 keys**
  all true). Overlap **0/6 exact_exprs**, 0 symbols, 0 tests (main thread
  re-verified from disk; N2323 free in both ledgers). **Plan: local N2277 →
  N2323** (reserve by script first, next_free_n is 2323 now). Probe:
  `hidden_files/divergence-48-n2277-renumber-impact.md` (88 occurrences / 36 files,
  chain re-register 5: ambient_volume → burst_drill_write_read +
  drill_should_ambient_sound → drill_sense + radar_draw_place; read before
  starting). **Do NOT confuse local N2277 (Drill super leg) with local N2317
  (BurstDrill override, renumber #42)** — #48 touches N2277 only.
- After #48 (chunked gate + docs round 27): relabel 4 scope files (+1 vs current
  labels) and spawn batch **N2324–N2326** (controlled() / DrillBuild.draw() base /
  3 music getters), then **N2327–N2329** (peekAmmo / Drill canPlaceOn+setBars+
  drawPlanConfig / findMusic), **N2330–N2332** (drawSelect / Drill.icons / play),
  **N2333–N2335** (Turret shouldTurn / BurstDrill shouldConsume / Game reload).
  next_free_n after #48 + 4 batches = **2336**. Reserve by script + write spawn
  lock BEFORE spawning; worktrees from latest HEAD (after docs #48); brief
  includes editor-import uid_cache + port-7777-free check + Godot symlink check +
  arc/mindustry-upstream symlinks in worktrees.
- **Divergence merge-time flags:** remote N2277 isShooting is new (no dedup; it IS
  the frame-tracking slice ~15 local Turret slices deferred on — when it merges,
  their `'Turret frame tracking for isShooting / reloadCounter / reload'`
  deferred entries must drop the isShooting part, keeping reloadCounter/reload if
  unowned); remote N2274/N2275/N2276/N2277 are four consecutive sub-slices of the
  same driver tick — merge all four together; remote N2273 charge effect is new
  (first slice touching `TurretBuild.shoot()`); remote N2273 vs remote N2271
  (charge sound) are two sub-slices of the same `shoot()` — compare at merge;
  warmup ownership/dedup (remote N2253 vs local N2308, 15/34 exprs); remote recoil
  family N2254–N2258 complementary; remote N2258 vs local N741/N742; remote
  updateTile driver-tick family N2259–N2263 + N2265 + N2270 complementary; remote
  N2266 targetPosition overlaps local N2122 (16/21 exprs) + needs hasAmmo (N2313,
  done) + peekAmmo (in batch N2327–N2329 after relabel) owned before it merges;
  remote N2267 super.control() overlaps local N552/N553/N1088/N1089 (13/15
  exprs); remote N2268 configured() overlaps local N544–N549/N1751/N1752 (23/26
  exprs); remote N2269 queuedBullets/charging overlaps local N2308 (2/24 exprs);
  `SourceItemTurretBuildState.gd` both-modified; remote adds functions to
  SourceTurretBuildState.gd (plus local N2285 status + N2297 accessors + N2307
  unit() + N2313 hasAmmo()).
- Push from Windows: local ahead/behind origin/main 9391d5a = **110 / 201**
  (counted 2026-11-20 ~09:5x +07; recount at push time). Merge by hand in the
  spec at push time. No force-push.
