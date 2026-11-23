# Reconciliation round 28 — renumber N2278 → N2327 (divergence #49)

## Divergence

- origin/main 9391d5a → **7df3724** (5 commits: slice 7d2d024f 2026-11-20
  03:50:53 UTC + 4 docs). Remote **N2278 = TurretBuild.updateTile() —
  logicControlled() live derivation** (owner
  `SourceTurretBuildState.source_turret_logic_controlled_state`, 5 exact_exprs,
  1 symbol `source_turret_logic_controlled_state_result.logic_controlled`, 4
  tests, deferred 404, proof "5 keys" commit-message only — remote tree has
  the .gd + .tscn but NO proof JSON; counted from the remote .gd: 8
  `proof[...]` assignments = 5 domain + 3 standard) collides number-only with
  local **N2278 = RadarBuild.draw()** (owner
  `SourceRadarBuildState.source_radar_draw_rotation_state` + glow owner
  `SourceRadarBuildState.source_radar_draw_glow_state`, Radar.java, commit
  c21704a, 10 exact_exprs, 2 symbols
  `source_radar_draw_rotation_state_result.rotation` /
  `source_radar_draw_glow_state_result.glow_alpha`, 4 tests, deferred 279,
  proof C07RadarDrawProof **11 keys** all true, counted from JSON).
  Overlap **0/5 exact_exprs**, 0 symbols, 0 tests at the N level. Same number,
  different family/method/owner.
- **BUT — not a pure 0-overlap collision like #41–#48.** Remote N2278 vs the
  WHOLE local ledger: **4/5 exact_exprs already owned locally** (3 by N2297
  micro-accessors: `logicControlled(){`, `return logicControlTime > 0;`, field
  `logicControlTime`; 1 by N2316 findTarget: the `validateTarget()` body line),
  and the remote symbol is **identical to N2297's symbol**. Only 1/5 is new:
  the driver line `if(!validateTarget()) target = null;` + the
  `frame["logic_controlled"]` stamp. See the probe §5 and "Merge-time flags"
  below — this is the easiest dedup mistake of #49.
- Probe: `hidden_files/divergence-49-n2278-renumber-impact.md` (main thread
  read it in full; 67 occurrences / 62 lines / 21 files, chain re-register 3).
  Remote ledger diff 9391d5a → 7df3724: added key only N2278, removed 0,
  changed 0.

## Renumber

- **N2278 → N2327 (RadarBuild draw), commit `92395c5`** (14 files,
  1265+/1265-, metadata-only). Reserve N2327 by script first (status
  'reserved', then 'done' after commit). Sed: register files (draw 9, draw
  select 6 incl. import alias `N2278_DEFERRED` → `N2327_DEFERRED`, draw place
  1) + test files (draw 8, draw select 2) + 1 GD comment (drawSelect cross-ref
  in SourceRadarBuildState.gd:146) + 1 proof .gd comment + spec 4 lines
  (344/345/346/352 — spec:344 kept both tokens as history; spec:346 sed FIRST
  occurrence only, no /g, keeping the "Batch N2276–N2278" label and the
  mindustry-wt-n2278-radar worktree name; spec:352 re-pointed the precedent
  cross-ref) + GOAL :411 (debt line). No GD function renamed (comments only).
  History docs (7 files, 14 occurrences) KEPT.
- Script delete: ledger key + 2 contracts
  (`source_radar_draw_rotation_state` + `source_radar_draw_glow_state` in
  `source_api_contracts.json`; rotation only in `defense_api_contracts.json` —
  pre-existing asymmetry, re-register reproduced it exactly) + 4 schemas
  (rotation/glow input+result) + defense_slices key. Symbol registry: 0
  occurrences — nothing to delete.
- **Chain re-register 3** (draw → draw_select → draw_place, import order),
  --verify **18/18 + 14/14 + 20/20**. Post-chain full-tree grep: N2278 = 0 in
  all generated JSON (N2327 = 16 occurrences) and 0 in code except historical
  docs. Targeted 4/4 (40 subtests); proof C07RadarDrawProof re-run in main,
  **11 keys** all true (8 domain + 3 standard, counted from JSON); family
  Radar 40/40 (392); wiring 32/32 (250). SSOT unchanged
  **11716/1737/1685/3161**. Done 1737.
- **Relabel in the same turn as the commit** (anti-label-drift rule): batch 2
  → **N2328–N2330**, batch 3 → **N2331–N2333**, batch 4 → **N2334–N2336**,
  next_free_n **2337**. `batch-queue.md` + 4 scope files relabeled by script
  `hidden_files/relabel-scope-files-after-49.py` (body only from "## 1.",
  §0/§0.1 kept as history snapshot; banner #49 prepended above banner #48;
  token shift runs DESCENDING so a just-shifted number is not shifted again).
  Verified: N2327 = 0 in the body of all 4 scope files; heading next_free_n
  2328/2331/2334/2337.
- **5 wrong labels left by script #48 found and fixed in the same turn**
  (grep per line): "N2331 draw base" → **N2325**; "N2333 findMusic" →
  **N2330**; "N2325→N2326" (3 getters) → **N2324–N2326**; "tách khỏi N2318"
  → **N2325**; "N2324 draw base" + "N2324 draw" → **N2325**. Cause: script
  #48's phrase-map created N2325 and its later token-map shifted it again.
  Lesson: a phrase-map that creates a new N must not be re-shifted by a later
  token-map.
- **Correction:** the round 27 handoff (commit f45c887) said next_free_n 2340
  after the #49 relabel — wrong (last batch number is 2336, so next_free_n is
  2337). allocations.json + MEMORY.md were already corrected; the correct
  value is used everywhere from this round on.

## Gate + environment

- **Gate #49 GREEN** on the chunked runner (PID 11353, log
  `hidden_files/full-suite-renumber-49-gate.log`): **Ran 6241, failures=237,
  errors=0, skipped=5, 364/364 modules** — 237 FAIL headers, all 237
  `unexpectedly None`, 0 ERROR (counted from the log by main thread; finished
  ~12:09 +07). Renumber #49 is fully closed. The slowest module was
  `tests.test_source_symbols` (~15+ min, ~99% CPU) — no timeout, no restart.
- **No VM restart since #42** (boot Nov 20 03:59 UTC = 10:59 +07, `who -b`);
  uptime 1:20 at docs time. Godot symlink intact, verified
  `4.6.2.stable.official.71f334935`.

## Duplicate continuation spawn #2 + continuation-lock rule

- Main thread spawned 3 continuations N2324–N2326 ~11:02; cron run 11:00
  spawned the same 3 continuations, same worktrees, **1 second later** (cron
  cannot see main's agents — subagent.list is per-job — and main cannot close
  a scheduled job's agents). Cron's N2325 died on its 900s timeout; cron's
  N2324/N2326 were cancelled ~11:18 (no result). Only main's set ran and all
  three finished (verified from disk).
- **Isabella approved 2026-11-20 ~11:18 +07: CONTINUATION-LOCK rule** — whoever
  spawns a continuation (cron or main thread) writes a lock `continuation`
  {by, at, status running} into allocations.json BEFORE spawning; a running /
  in_progress lock means do NOT spawn, only report; a lock > 60 min with no
  worker visible means report to main thread, do not spawn over it. Rule added
  to the cron body ~11:19 (verified by grep on the saved job) and to MEMORY.md.

## Batch N2324–N2326 (continuations done, waiting merge)

- All three continuations finished and were verified from disk ~11:31–11:37:
  N2324 controlled() (7 files 246+/4-, proof 6/6, family Turret 68/68,
  wiring 32/32); N2325 DrillBuild.draw() base (9 files 1505+/0-, proof
  12/12, family 68/68 1280 subtests, wiring 32/32 — worker killed 1 orphaned
  pytest from the duplicate cron set to free port 7777; stray untracked file
  `tools/mindustry_godot_transpiler/n2325-family.log` in the worktree, do NOT
  stage); N2326 3 music getters (5 files 862+/0-, proof 13/13, family Game
  24/24 238 subtests, wiring 32/32). Base 062de93 for all three — older than
  HEAD 92395c5, but #49 only renumbered Radar draw and touches none of these
  slices' files; check base drift per the batch rule before merging.
- Merge in N order (N2324 → N2325 → N2326), one slice at a time (copy →
  register → targeted re-verify → commit), then chunked batch gate + batch
  docs (Done 1737→1740). Then spawn batch 2 (labels shift again after #50 —
  see next section).

## Docs (this commit)

- This report + handoff (round 28). Spec rows + GOAL §5 number were already
  renumbered in the renumber commit 92395c5 (precedent rounds 7–27); GOAL scene
  hash stays `c21704a` (the commit that first carried the scene to Windows —
  the renumber changed no scene content).

## Handoff / next

- **Divergence #50 ARRIVED during gate #49** (origin 7df3724 → **2e1267a**, 5
  commits: slice 9bfee77 + 4 docs). Remote **N2279 = TurretBuild.updateTile()
  — activationTimer decay** (owner
  `SourceTurretBuildState.source_turret_activation_timer_state`, 5 exact_exprs,
  proof "5 keys" commit-message only — 8 `proof[...]` assignments = 5 domain +
  3 standard, counted from the remote .gd) collides number-only with local
  **N2279 = TurretBuild.isActive()** (commit 40e8152, 12 exact_exprs, proof
  C07TurretIsActiveProof **11 keys** all true). Overlap **3/5 exact_exprs** —
  all three are field declarations / the `placed()` reset
  (`activationTimer = 0`, `activationTime = 0f`,
  `activationTimer = activationTime`), not slice logic: remote WRITES/decays
  the timer in the tick, local READS it in the predicate — complementary, no
  dedup. **Plan: local N2279 → N2328** (next_free_n, read directly from
  allocations.json at probe time; no N2328 reservation, ledger has no N2328
  key). Probe: `hidden_files/divergence-50-n2279-renumber-impact.md` (53
  occurrences / 16 files, chain re-register 6: is_active → min_range → status
  → micro_accessors → unit → has_ammo; renumber commit expected 11 files;
  read before starting). **Relabel `batch-queue.md` + 4 scope files IN THE
  SAME TURN as the renumber commit:** batch 2 → N2329–N2331, batch 3 →
  N2332–N2334, batch 4 → N2335–N2337, next_free_n **2338**. Batch 1
  (N2324–N2326, waiting merge) does NOT change. Old worktree
  `mindustry-wt-n2279-turret` is dirty/stale (unfinished isActive copy, already
  merged as 40e8152) — do NOT merge from it.
- **Merge order after this commit:** renumber #50 FIRST (it takes N2328 and
  relabels the queue), then merge batch N2324–N2326, then batch gate + batch
  docs, then spawn batch 2 **N2329–N2331** (peekAmmo / Drill
  canPlaceOn+setBars+drawPlanConfig / findMusic). Reserve by script + write
  spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check +
  arc/mindustry-upstream symlinks in worktrees.
- **Divergence merge-time flags (#49, full detail in the probe §5):** remote
  N2278 is the 17th updateTile sub-slice of the remote line; at merge, dedup
  the pure function + 3 pure proof keys into N2297 (KEEP the local frame-first
  signature, do NOT register a second function/symbol), take only the driver
  tick (validate line + `frame["logic_controlled"]` stamp) and its 2 driver
  proof keys (`logic_controlled_stamped_to_frame`,
  `logic_controlled_driver_rescues_validate`) — those 2 keys have no home in
  local and go with a driver-tick proof, NOT into
  C07TurretMicroAccessorsProof; remote isShooting (N2277) computes
  logicControlled INLINE instead of reading the just-stamped frame key —
  decide at merge whether it should read the frame key for consistency
  (precedent #48: warmup); the remote fixture "N2251 proof" maps to local
  **N2316**, not local N2251 (RepairTurret jitter); remote N2261 decay tick ≠
  local N2301; remote N2274+N2275+N2276+N2277+N2278 are five consecutive
  sub-slices of the same driver tick — merge all five together, Java order
  :491 validate → :492 isShooting → :502 warmup → :534-536 decay.
- **Divergence merge-time flags (#50, full detail in the probe §3):** remote
  N2279 is the first remote slice touching `updateTile()`'s activationTimer
  part; at merge, check the tick-driver order (Java decay Turret.java:561-564
  runs before aim/shoot continues) against where isActive is read; remote
  proof notes the duo never overrides `activationTime` (always 0.0, guard
  never fires — vacuous-guard precedent like N2270/N2263); decay is not
  clamped; `elapsed` is computed on the tick's INPUT timer. Local proof pins
  the predicate at positive / zero / negative timer — no contradiction.
  Cross-reference with the other remote updateTile slices (N2274 unit world
  position, N2275 unit maxHealth, N2276 unit health, N2278 logicControlled)
  so the driver ticks are not merged as one blob.
- **Older merge-time flags still open:** warmup ownership/dedup (remote N2253
  vs local N2308, 15/34 exprs); remote recoil family N2254–N2258
  complementary; remote N2258 vs local N741/N742; remote updateTile
  driver-tick family N2259–N2263 + N2265 + N2270 complementary; remote N2266
  targetPosition overlaps local N2122 (16/21 exprs) + needs hasAmmo (N2313,
  done) + peekAmmo (batch 2 after #50 relabel) owned before it merges; remote
  N2267 super.control() overlaps local N552/N553/N1088/N1089 (13/15 exprs);
  remote N2268 configured() overlaps local N544–N549/N1751/N1752 (23/26
  exprs); remote N2269 queuedBullets/charging overlaps local N2308 (2/24
  exprs); `SourceItemTurretBuildState.gd` both-modified; remote adds functions
  to SourceTurretBuildState.gd (plus local N2285 status + N2297 accessors +
  N2307 unit() + N2313 hasAmmo() + N2324 controlled() once merged).
- Push from Windows: local ahead/behind origin/main 2e1267a = **114 / 211**
  (counted at docs time, HEAD 92395c5; recount at push time). Merge by hand in
  the spec at push time. No force-push.

## Cron delivery

- Cron runs 12:00 and 12:15 both delivered on time this cycle (probe #50 and
  gate #49 GREEN) and both were verified from disk by main thread before use.
  Main thread keeps reporting directly every 15 minutes, including a one-line
  report when nothing changed. A scope file for batch 5 already exists
  (`hidden_files/next-batch-scope-batch5.md`, numbers TBD at spawn time).
