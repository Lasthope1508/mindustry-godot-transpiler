# Reconciliation round 27 — renumber N2277 → N2323 (divergence #48)

## Divergence

- origin/main 5f0f72c → **9391d5a** (5 commits: slice 23b993d 2026-11-20 02:35:06
  UTC + 4 docs). Remote **N2277 = TurretBuild.updateTile() — isShooting state**
  (owner `SourceTurretBuildState.source_turret_is_shooting_state`,
  Turret.java:492, 6 exact_exprs, 1 symbol
  `source_turret_is_shooting_state_result.is_shooting`, 4 tests, deferred 401,
  proof "5 keys" commit-message only — remote tree has the .gd + .tscn but NO
  proof JSON; counted from the remote .gd: 8 `proof[...]` assignments = 5 domain
  + 3 standard) collides number-only with local **N2277 = DrillBuild.
  ambientVolume() super leg** (owner
  `SourceBurstDrillBuildState.source_drill_ambient_volume_state`,
  Drill.java:257-259 `efficiency * (size * size) / 4f`, commit f26a03d
  2026-11-18 12:31:40 UTC, 8 exact_exprs, 1 symbol
  `source_drill_ambient_volume_state_result.ambient_volume`, 4 tests, deferred
  294, proof C07DrillAmbientVolumeProof **8 keys** all true, counted from JSON).
  Overlap **0/6 exact_exprs**, 0 symbols, 0 tests. Same number, different
  family/method/owner. **Do NOT confuse local N2277 (Drill super leg) with
  local N2317 (BurstDrillBuild.ambientVolume() override, renumber #42)** — #48
  touches N2277 only.
- Probe: `hidden_files/divergence-48-n2277-renumber-impact.md` (main thread
  read it in full; 88 occurrences / 36 files, chain re-register 5). Remote
  ledger diff 5f0f72c → 9391d5a: added key only N2277, removed 0, changed 0.

## Renumber

- **N2277 → N2323 (DrillBuild ambientVolume super leg), commit `062de93`**
  (24 files, 1008+/1008-, metadata-only). Reserve N2323 by script first
  (status 'reserved', then 'done' after commit). Sed: 7 register files (30
  occurrences, incl. drill_should_ambient_sound import alias
  `N2277_DEFERRED` + rule precedent, burst_drill_write_read import alias,
  drill_sense rule text, radar_draw_place rule text) + 4 test files (12) + 2 GD
  files (4 comment occurrences) + 2 proof .gd files (2) + spec 4 lines
  (345/354/357/359, live cross-refs) + GOAL :409 (debt line). No GD function
  renamed (comments only). History docs (12 files, 15 occurrences) KEPT.
- Script delete: ledger key + contract
  `source_drill_ambient_volume_state` in `source_api_contracts.json` +
  `production_api_contracts.json` + 2 schemas (input/result) + production_slices
  key. Totals after delete 11716/1736/1684/3159.
- **Chain re-register 5** (drill_ambient_volume → burst_drill_write_read +
  drill_should_ambient_sound → drill_sense + radar_draw_place, import order),
  --verify **11/11 + 28/28 + 20/20 + 31/31 + 20/20**. Post-chain full-tree
  grep: N2277 = 0 in all generated JSON (N2323 = 20 occurrences) and 0 in code
  except historical docs. No sibling rule-text stragglers (lesson #42 check —
  none this round). Targeted 20/20 (233 subtests, 5 files); family
  BurstDrill+Drill 64/64 (1125); wiring 32/32 (250); proof
  C07DrillAmbientVolumeProof re-run in main, **8 keys** all true (5 domain + 3
  standard, counted from JSON). SSOT unchanged **11716/1737/1685/3161**. Done
  1737.
- **Near-miss caught by `git status`:** the first commit (784e9f2, 23 files)
  missed `source_symbol_registry.json` (1 line: rule text "the N2317/N2277
  super-as-param precedent" → N2323, rewritten by the radar_draw_place
  re-register). Amended into `062de93` (24 files, 1008+/1008-) before any
  gate/docs. allocations.json initially recorded the pre-amend hash 784e9f2 —
  the 10:30 cron run caught the mismatch and main thread fixed it by script
  (N2323 commit = 062de93). Lesson: after any amend, re-check the allocations
  record in the same turn.

## Gate + environment

- **Gate #48 GREEN** on the chunked runner (PID 9338, log
  `hidden_files/full-suite-renumber-48-gate.log`): **Ran 6241, failures=237,
  errors=0, skipped=5, 364/364 modules** — 237 FAIL headers, all 237
  `unexpectedly None`, 0 ERROR (counted from the log by main thread). Renumber
  #48 is fully closed.
- **VM restart #42** (boot Nov 20 03:59 UTC = 10:59 +07, `who -b`) — AFTER gate
  #48 finished, so the gate was NOT killed. Godot symlink wiped by the restart;
  main thread recreated it and verified
  `4.6.2.stable.official.71f334935`. No restart since #42 at docs time.

## Batch N2324–N2326 (spawned by cron, continuations running)

- Cron 10:45 (after #48 commit + gate GREEN) reserved + spawned batch
  **N2324–N2326** (controlled() / DrillBuild.draw() base / 3 music getters)
  from HEAD 062de93, per the fixed cron body. All three workers were cut by the
  cron 900s timeout + restart #42 after targeted + proof were done: proofs
  counted from disk — N2324 C07TurretControlledProof 6/6, N2325 C07DrillDrawProof
  12/12, N2326 C07SoundControlGetMusicProof 13/13, all true. Only family +
  wiring remained. **Three continuations spawned ~11:0x** (family + wiring
  only, no redo of targeted/proof). Merge + batch gate + docs follow when they
  report.

## Docs (this commit)

- This report + handoff (round 27). Spec rows + GOAL §5 number were already
  renumbered in the renumber commit 062de93 (precedent rounds 7–26); GOAL scene
  hash stays `f26a03d` (the commit that first carried the scene to Windows —
  the renumber changed no scene content).

## Handoff / next

- **Divergence #49 ARRIVED during gate #48** (origin 9391d5a → **7df3724**, 5
  commits: slice 7d2d024f + 4 docs). Remote **N2278 = TurretBuild.updateTile()
  — logicControlled() live derivation** (owner
  `SourceTurretBuildState.source_turret_logic_controlled_state`, 5 exact_exprs,
  1 symbol, 4 tests, proof "5 keys" commit-message only, no proof JSON)
  collides number-only with local **N2278 = RadarBuild.draw()** (commit
  c21704a, 10 exact_exprs, 2 symbols, 4 tests, proof C07RadarDrawProof **11
  keys** all true). Overlap **0/5 exact_exprs**, 0 symbols, 0 tests (main thread
  re-verified from disk; N2327 free in both ledgers). **Plan: local N2278 →
  N2327** (reserved by script ~11:10, status 'renumbering'). Probe:
  `hidden_files/divergence-49-n2278-renumber-impact.md` (67 occurrences / 21
  files, chain re-register 3: draw 18/18 → draw_select 14/14 → draw_place
  20/20; read before starting). **Renumber takes N2327, so the whole queue
  shifts +1 — relabel `batch-queue.md` + 4 scope files IN THE SAME TURN as the
  renumber commit** (anti-label-drift rule): batch 2 → N2328–N2330, batch 3 →
  N2331–N2333, batch 4 → N2334–N2336, next_free_n 2340. Batch 1 (N2324–N2326,
  running) does NOT change.
- **Divergence merge-time flags:** remote N2277 isShooting is new (no dedup;
  it IS the frame-tracking slice ~15 local Turret slices deferred on — when it
  merges, their `'Turret frame tracking for isShooting / reloadCounter / reload'`
  deferred entries must drop the isShooting part, keeping reloadCounter/reload
  if unowned; warmup local N2308 must read `frame["is_shooting"]` instead of
  computing inline); remote N2274/N2275/N2276/N2277 are four consecutive
  sub-slices of the same driver tick — merge all four together; remote N2278
  logicControlled is DIFFERENT from #44–#48: 4/5 of its exprs are already owned
  in local (3 by N2297 micro-accessors, 1 by N2316 findTarget/validateTarget)
  and its symbol is identical to N2297's — dedup the pure function + 3 pure
  proof keys into N2297, take only the driver tick (validate line
  `if(!validateTarget()) target = null;` + `frame["logic_controlled"]` stamp)
  and its 2 driver proof keys; remote N2278 vs remote N2277 complement each
  other (isShooting stamp reads logicControlled inline; N2278 stamps the frame
  key for validate); remote N2274–N2278 are five consecutive sub-slices of the
  same driver tick — merge all five together; remote N2273 charge effect is new
  (first slice touching `TurretBuild.shoot()`); remote N2273 vs remote N2271
  (charge sound) are two sub-slices of the same `shoot()` — compare at merge;
  warmup ownership/dedup (remote N2253 vs local N2308, 15/34 exprs); remote
  recoil family N2254–N2258 complementary; remote N2258 vs local N741/N742;
  remote updateTile driver-tick family N2259–N2263 + N2265 + N2270
  complementary; remote N2266 targetPosition overlaps local N2122 (16/21 exprs)
  + needs hasAmmo (N2313, done) + peekAmmo (in batch 2 after relabel) owned
  before it merges; remote N2267 super.control() overlaps local
  N552/N553/N1088/N1089 (13/15 exprs); remote N2268 configured() overlaps
  local N544–N549/N1751/N1752 (23/26 exprs); remote N2269 queuedBullets/charging
  overlaps local N2308 (2/24 exprs); `SourceItemTurretBuildState.gd`
  both-modified; remote adds functions to SourceTurretBuildState.gd (plus local
  N2285 status + N2297 accessors + N2307 unit() + N2313 hasAmmo()).
- Push from Windows: local ahead/behind origin/main 7df3724 = **112 / 206**
  (counted at docs time, HEAD 062de93; recount at push time). Merge by hand in
  the spec at push time. No force-push.
