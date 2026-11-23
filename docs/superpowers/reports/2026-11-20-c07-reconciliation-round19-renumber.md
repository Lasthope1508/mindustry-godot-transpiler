# Reconciliation round 19 — renumber N2270 → N2316 (divergence #41)

## Divergence

- origin/main 38067ef → **683f89a** (5 commits: slice b8e7f57 + 4 docs). Remote **N2270 =
  TurretBuild.updateEfficiencyMultiplier() — "power heat fold"** (owner
  `SourceTurretBuildState.source_turret_heat_requirement_state`, 13 exact_exprs, 2 symbols,
  4 tests, proof "12 keys" commit-message only — probe counted 16 `proof[` lines in the
  remote .gd) collides number-only with local **N2270 = TurretBuild.findTarget()** (owner
  `SourceTurretBuildState.source_turret_find_target_state`, commit 8e9ee6a, 50 exact_exprs,
  5 symbols, 4 tests, proof C07TurretFindTargetProof **14 keys** all true, counted from
  JSON). Overlap **0/13 exact_exprs, 0 symbols, 0 tests**. Different method, different GD
  function, different proof.
- Probe: `hidden_files/divergence-41-n2270-renumber-impact.md` (written by cron 01:00 after
  two earlier probe agents were cut by the cron timeout before writing; main thread
  re-verified the collision from disk: remote ledger 1719 → 1720, added key only N2270).
  N2316 free in both ledgers at reserve time. Nuance (merge-time, not a renumber blocker):
  remote N2270 shares **8/13 exact_exprs with remote N2265** (same method
  updateEfficiencyMultiplier — the Windows line split it into 2 slices: N2265 efficiency
  fold + N2270 heat-requirement fold); when both remote slices merge they are 2 parts of
  one method. Local GD has no `source_turret_heat_requirement_state` — merging remote adds
  a new function; the fold runs BEFORE warmup when merged (same note as #36).

## Renumber

- **N2270 → N2316 (Turret findTarget), commit `103dbae`** (21 files, 3821+/3821-).
  Reserve N2316 by script first (status 'renumbering'). Sed: register find_target (whole
  file) + test find_target (whole file) + proof .gd (1 place) + tracking_range register
  (whole file — alias `N2270_DEFERRED` → `N2316_DEFERRED` + comments) + precedent
  re-points per #27/#39: burst_drill_ambient_volume register :13/:43/:103/:104,
  radar_draw register :10/:20, tests burst_drill_ambient_volume :25/:97, radar_draw :24,
  tracking_range :34/:42, proofs BurstDrillAmbientVolume :30, TrackingRange :39, GD
  SourceBurstDrillBuildState.gd:313 + SourceTurretBuildState.gd:996 (both comment-only,
  /g flag) + spec :340 (first occurrence only — the row label; the same line's "Batch
  N2270" history KEPT) + GOAL :399. Full-tree grep after the first sed pass found **0
  missed live references** (only spec :343 prose in the N2273 entry + AGENTS.md:90 history
  + old reports/handoffs, all kept per precedent).
- Script delete: ledger key + 5 contracts + 10 schemas (input+result × 5 functions) +
  defense_api_contracts entry (1, find_target only) + defense_slices key. Asserted each
  delete count before proceeding.
- **Chain re-register 9 registers** in import order (findTarget → trackingRange →
  writeRead → isActive → minRange → status → microAccessors → unit → hasAmmo), --verify
  **87/87 + 18/18 + 36/36 + 17/17 + 16/16 + 25/25 + 28/28 + 15/15 + 21/21**; plus
  **burst_drill_ambient_volume 11/11** — its input schema carried the N2270 precedent in
  rule text (production_state_schema.json), re-run after the sed so the JSON matches the
  register source (lesson from #39's drill_sense re-run). Targeted 4/4 (132 subtests);
  family Turret 64/64 (876); wiring 32/32 (250); proof C07TurretFindTargetProof re-run in
  main, **14 keys** all true (counted from JSON).
- Literal N2270 in the ledger = **0** after the chain (N2316 = 46: 1 key + 45 deferred
  mentions, matching the pre-renumber 46 occurrences). SSOT unchanged
  **11716/1737/1685/3161**. Done 1737.
- **Gate #41 GREEN on rerun (PID 1716, ~02:41–03:00): Ran 6241 in 1094.830s,
  failures=237, skipped=5, 0 errors** — counted from the log: 237 FAIL headers, all 237
  `AssertionError: unexpectedly None` (Godot-absent), 0 ERROR headers. Log:
  `hidden_files/full-suite-renumber-41-gate.log` (158238 byte). Attempt 1 (PID 7689,
  launch ~02:12) was killed by VM restart #34/35 (~02:17–02:41; uptime 0 min at the 02:41
  check, symlink Godot gone — recreated and verified 4.6.2 before relaunch); its log is
  preserved as `hidden_files/full-suite-renumber-41-gate-killed-by-restart34.log` (5869
  byte, no "Ran"). No VM restart during the green rerun (uptime 22 min at the 03:03
  check).

## Docs (this commit)

- This report + handoff (round 19). Spec row + GOAL §5 number were already renumbered in
  the renumber commit 103dbae (precedent rounds 7–18); GOAL scene hash stays `8e9ee6a`
  (the commit that first carried the scene to Windows — the renumber changed no scene
  content).

## Handoff / next

- **Divergence #42 (already verified, renumber NEXT):** origin/main 683f89a → **b21b55f**
  (5 commits: slice a66bf63 + 4 docs). Remote **N2271 = TurretBuild.shoot() — charge
  sound state** (owner `source_turret_charge_sound_state`, 12 exact_exprs, 3 symbols, 4
  tests, proof "8 keys" commit-message only, no proof JSON in the remote tree) vs local
  **N2271 = BurstDrillBuild.ambientVolume()** (8 exact_exprs, proof
  C07BurstDrillAmbientVolumeProof **8 keys** all true). Number-only, overlap **0/8
  exact_exprs, 0 symbols, 0 tests**. Probe:
  `hidden_files/divergence-42-n2271-renumber-impact.md` (116 occurrences / 38 files, chain
  re-register 5). Plan: local N2271 → **N2317** (N2316 is held for #41; N2317 free in
  both ledgers). Head of the BurstDrill/Drill DEFERRED fork — chain re-register 5
  registers (setStats N2309 → ambientVolume → Drill.ambientVolume N2277 →
  shouldAmbientSound N2305 → write/read), metadata-only. Merge-time: remote N2271 is a
  pure function (no driver tick), 3 keys `first_shot_delay` / `charge_sound` /
  `charge_emitted`; local GD has no `source_turret_charge_sound_state` — merge adds it, no
  dedup; `chargeEffect` (Turret.java:749) stays deferred for its own slice.
- **Divergence #43 (already verified, renumber AFTER #42):** origin/main b21b55f →
  **c9ab307** (5 commits: slice 5968f4f + 4 docs). Remote **N2272 =
  TurretBuild.canConsume() — heat gate** (owner
  `source_turret_can_consume_heat_gate_state`, 11 exact_exprs, 1 symbol, 4 tests, proof
  "11 keys" commit-message only, no proof JSON in the remote tree) vs local **N2272 =
  RadarBuild.canPickup()** (4 exact_exprs, proof C07RadarCanPickupProof **6 keys** all
  true). Number-only, overlap **1/4 exact_exprs — only `return false;`** (boilerplate),
  0 symbols, 0 tests. Probe: `hidden_files/divergence-43-n2272-renumber-impact.md` (46
  occurrences / 15 files, chain re-register 4). Plan: local N2272 → **N2318** (N2317 is
  held for #42; N2318 free in both ledgers). Head of the Radar DEFERRED chain — chain
  re-register 4 registers (canPickup → draw → drawSelect → drawPlace), metadata-only.
  **Do #42 first, #43 second** — both touch the same SSOT files, in N order. Merge-time:
  remote N2272's guard logic is already folded inline in local N2308 (warmup GD:384-385,
  `can_consume` from heat_requirement/heat_req) — 4/11 exprs overlap with local N2308;
  dedup decision at merge (replace the inline fold with the pure function, or keep both).
- **Batch after the renumbers is N2319–N2321** (`controlled()` / DrillBuild.draw() base /
  3 music getters), then **N2322–N2324** (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig
  / findMusic), then **N2325–N2327** (drawSelect / Drill.icons / play). Scope files:
  `hidden_files/next-batch-scope-after-n2315.md`,
  `hidden_files/next-batch-scope-after-n2319.md`,
  `hidden_files/next-batch-scope-after-n2323.md` — labels TEMP, relabel +2 after #42/#43
  (the relabel for #42 alone was never applied to disk, so the shift is +2 from the
  labels currently on disk). next_free_n after both renumbers + 3 batches = 2328. Reserve
  by script + write spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check.
- allocations.json: N2316 done (103dbae), next_free_n **2317** (before #42 reserve).
  N2304 held (ambient C, waits for Windows B).
- Push from Windows: local ahead/behind origin/main c9ab307 — recount at push time. Merge by
  hand in the spec at push time. No force-push. Merge-time flags: warmup ownership/dedup
  (remote N2253 vs local N2308, 15/34 exprs); remote recoil family N2254–N2258
  complementary; remote N2258 vs local N741/N742; remote updateTile driver-tick family
  N2259–N2263 + N2265 + N2270 complementary (charge → unit sync → logicControlTime →
  rotate sync → heatReq → efficiency fold → heat fold); remote N2266 targetPosition overlaps
  local N2122 (16/21 exprs) + needs hasAmmo (N2313, done) + peekAmmo (T6) owned before it
  merges; remote N2267 super.control() overlaps local N552/N553/N1088/N1089 (13/15 exprs);
  remote N2268 configured() overlaps local N544–N549/N1751/N1752 (23/26 exprs); remote
  N2269 queuedBullets/charging overlaps local N2308 (2/24 exprs); remote N2271 charge sound
  is new (no dedup); remote N2272 canConsume gate overlaps local N2308 (4/11 exprs) —
  dedup decision at merge; `SourceItemTurretBuildState.gd` both-modified; remote adds
  functions to SourceTurretBuildState.gd (plus local N2285 status + N2297 accessors +
  N2307 unit() + N2313 hasAmmo()).
