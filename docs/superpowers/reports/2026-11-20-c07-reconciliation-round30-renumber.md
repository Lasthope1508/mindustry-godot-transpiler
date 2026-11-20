# Reconciliation round 30 — renumber N2280 → N2332 (divergence #51)

## Divergence

- origin/main 2e1267a → **df426c4** (6 commits: slice d523d6f6 2026-11-20
  06:33 UTC + 5 docs). Remote **N2280 = TurretBuild.isActive()** (owner
  `SourceTurretBuildState.source_turret_is_active_state`, Turret.java:449-450,
  5 exact_exprs, 1 symbol
  `source_turret_is_active_state_result.is_active`, 4 tests, deferred 411,
  proof "6 keys" commit-message only — remote tree has the .gd + .tscn but NO
  proof JSON; counted from the remote .gd: 9 `proof[...]` assignments = 6
  domain + 3 standard) collides number-only with local **N2280 =
  Drill.setStats() super leg** (owner
  `SourceBurstDrillBuildState.source_drill_set_stats_state`, Drill.java:175-193,
  commit 38fd39d 2026-11-18 13:50:58 UTC, 39 exact_exprs, 4 symbols, 4 tests,
  deferred 294, proof C07DrillSetStatsProof **12 keys** all true, counted
  from JSON). Overlap **0/5 exact_exprs**. Same number, different family,
  different file, different method — number-only, same pattern as #41–#50.
- **Second collision inside the same number:** remote N2280 DUPLICATES local
  **N2328 = Turret isActive()** (renumber #50 from N2279, commit 9eee254).
  Same java_method, same godot_owner, same symbol, same 4 test names, same
  proof path. Overlap **5/5 exact_exprs** — all five remote exprs are already
  in local N2328. The 7 extra local exprs are context only (4 class
  declarations, `public @Nullable Posc target;`,
  `public float activationTime = 0f;`, `activationTimer = activationTime;`).
  This is a content duplicate, NOT a second renumber: local N2328 is NOT
  renumbered again (remote max N is 2280, remote has no N2328). The dedup
  decision belongs to merge time (see below).
- Probe: `hidden_files/divergence-51-n2280-renumber-impact.md` (main thread
  read it in full; remote ledger diff 2e1267a → df426c4: added key only N2280,
  removed 0, changed 0; remote ledger 1730 slices / 1729 N-keys, max N2280).

## Renumber

- **N2280 → N2332 (Drill setStats super leg), commit `83c0707`** (12 files,
  708+/708-, metadata-only). Reserve N2332 by script first (next_free_n read
  from allocations.json at run time, verified absent in both ledgers).
  Sed: 3 register files (drill_set_stats 9 occurrences incl. the slice key
  at :207/:227/:233 + rule texts :141-143; burst_drill_write_read 6 incl. the
  import alias `N2280_DEFERRED` → `N2332_DEFERRED` at :63; drill_draw_select
  1 comment) + test file (8 `ledger['N2280']` refs) + 1 proof .gd comment
  + spec line 348 (FIRST occurrence only, no /g — row label `N2280:` →
  `N2332:`, keeping the "Batch N2279–N2281" history label and the
  mindustry-wt-n2280-burstdrill worktree name) + GOAL :415 (debt line). No GD
  function renamed (the GD file carries no N2280 literal — comments only).
  History docs KEPT. Spec line 347 keeps "the N2280 proof" (history prose in
  the N2328 row) and spec line 354 keeps "3 N2280-unique entries" (prose in
  the N2286 row) — precedent: prose mentions in other slices' entries stay
  unchanged.
- Script delete (assert exact key/count before deleting): ledger key N2280
  (status done, java_method Drill.setStats()) + 1 contract
  (`SourceBurstDrillBuildState.source_drill_set_stats_state` in
  `source_api_contracts.json` + the same key in
  `production_api_contracts.json`) + 2 schemas
  (`source_drill_set_stats_state_input` / `..._result`) + production_slices
  key N2280. Symbol registry: 0 occurrences — nothing to delete. Totals
  after delete 11731/1739/1689/3169.
- **Chain re-register 3** (drill_set_stats → burst_drill_write_read →
  drill_draw_select), --verify **54/54 + 28/28 + 32/32**. Nothing imports
  N2286_DEFERRED, so write_read ends the chain (drill_sense imports
  N2296_DEFERRED, should_ambient_sound imports N2323_DEFERRED — both
  untouched). Post-chain full-tree grep: N2280 = 0 in all generated JSON
  (N2332 = 13 occurrences) and 0 in code except historical docs. Targeted
  4/4 (84 subtests); proof C07DrillSetStatsProof re-run in main, **12 keys**
  all true (9 domain + 3 standard, counted from the proof JSON — 3
  booster-row keys + 3 drill-speed keys + 2 drill-tier keys + matches +
  one_headquarter_per_ssot + registry_valid); family BurstDrill+Drill 68/68
  (1280 subtests); wiring 32/32 (250). SSOT unchanged **11731/1740/1690/3171**.
  Done 1740.
- **Relabel in the same turn as the commit** (anti-label-drift rule): batch 1
  N2324–N2326 MERGED (title updated), batch 2 **N2329–N2331** unchanged
  (already spawned), batch 3 → **N2333–N2335**, batch 4 → **N2336–N2338**,
  next_free_n **2339**. `batch-queue.md` + 4 scope files relabeled by script
  `hidden_files/relabel-scope-files-after-51.py` (+ a follow-up script for
  batch-queue.md + allocations.json — the first script's batch-queue section
  failed its own assert because an earlier replacement in the same script had
  already changed the target text; lesson: a script that edits one file in
  memory must order its replacements so no later target is a substring of an
  earlier replacement, and a failed script writes NOTHING for that file —
  re-run only the failed part). Token shifts FIRST (descending), phrase
  fixes AFTER — the phrase fixes create N2332 (live refs to setStats in 3
  scope bodies) and N2332 is in the shift maps, so running them first would
  have moved them to N2333 (the #48 bug class). Verified: N2280 = 0 in all
  scope bodies (only the new banner + relabel notes mention it, by design);
  each body carries exactly 2× N2332 live refs.
- **Stale cross-references fixed during the same relabel:** the §3
  "next_free_n after this batch" lines (after-n2319 2332→2333 — N2332 was
  consumed by #51; after-n2323 2335→2336; after-n2327 2338→2339;
  after-n2315 stays 2329 — N2332 is above it).

## Gate + environment

- **Gate #51 RUNNING** on the chunked runner (PID 10288, log
  `hidden_files/full-suite-renumber-51-gate.log`, expected Ran 6253/240/0/5,
  367/367 — the new baseline is 240, +3 from the 3 new test modules of batch
  1). Renumber #51 is committed and relabeled; the gate result lands after
  this doc.
- **Gate batch N2324–N2326 GREEN** (chunked, resumed after restart #43):
  **Ran 6253, failures=240, errors=0, skipped=5, 367/367 modules** (log
  `hidden_files/full-suite-batch-n2324-n2326-gate.log`, finished ~13:51 +07).
  All 240 failures are the known Godot-absent `unexpectedly None` class —
  the baseline moved 237 → 240 because the 3 merged batch-1 test modules
  each contribute 1 reference-graph failure under the gate's Godot-absent
  PATH. Batch 1 is fully closed.
- **VM restart #43 ~13:09 +07** (boot Nov 20 06:09 UTC) killed the batch gate
  at 318/364 (Ran 4041/216/0/5); the chunked runner resumed from module 319
  (PID 5749) and finished green. Godot symlink survived the restart, verified
  `4.6.2.stable.official.71f334935`. No restart since #43 (uptime ~1h at docs
  time).

## Batch 2 N2329–N2331 (spawned by cron, waiting continuation)

- Cron 13:15 spawned batch 2 (reserve + lock by script, next_free_n 2332,
  worktrees from HEAD 27a383b): N2329 peekAmmo (7 files 256+), N2330 Drill
  canPlaceOn+setBars+drawPlanConfig (9 files 1059+), N2331 findMusic (5 files
  467+). Code + register + targeted + proof done on disk; only family +
  wiring remain (workers died on cron timeout). N2331 wiring failed 8/9 while
  running in parallel with the batch gate — suspected port-7777 flake; the
  continuation re-runs the wiring modules alone to tell flake from real.
- Continuations were DEFERRED until after renumber #51 commit + gate #51
  (to avoid port-7777 contention with the #51 proof/family work in main).
  Spawn them after gate #51 goes green, with continuation locks written to
  allocations.json BEFORE spawning, then merge in N order + batch gate + batch
  docs (Done 1740→1743), then spawn batch 3 **N2333–N2335** (drawSelect /
  Drill.icons / play+silence+keepSilent).

## Docs (this commit)

- This report + handoff (round 30). Spec rows + GOAL §5 number were already
  renumbered in the renumber commit 83c0707 (precedent rounds 7–29); GOAL scene
  hash stays `38fd39d` (the commit that first carried the scene to Windows —
  the renumber changed no scene content).

## Handoff / next

- **Gate #51** (chunked, PID 10288) is running; when it goes green, renumber
  #51 is fully closed. Then spawn batch-2 continuations (family+wiring only,
  continuation locks first), merge N2329 → N2330 → N2331, batch gate, batch
  docs, then spawn batch 3 **N2333–N2335**.
- **Divergence merge-time flags (#51, full detail in the probe §5):** remote
  N2280 vs local N2328 — same GD function name
  `source_turret_is_active_state` but DIFFERENT signatures (remote: 4
  explicit params `has_target, was_shooting, enabled, activation_timer`;
  local: `frame, target_is_null, is_shooting, activation_timer`, reads
  `enabled` from frame) and DIFFERENT driver ticks (remote stamps
  `frame["is_active"]` every tick inside `source_turret_tick_buildings_state`
  right after the `was_shooting` stamp, with a note that LaserTurret.
  shouldConsume() is the future consumer and a one-tick lag because
  updateConsumption() runs before updateTile(); local has NO tick line —
  its proof comment says isActive() is a predicate the driver reads, not a
  tick write). At merge: EITHER keep the local signature + add the tick stamp
  in local form, OR take the remote signature + fix the local test/proof —
  do NOT lose the remote tick stamp (the frame would lose the live
  `is_active` key). Local proof covers the pure function better (7 domain
  keys vs remote 6); remote adds 2 live-tick keys (incl. a timer-decay key
  `120.0 - 1/60`). A merged proof should keep both groups. Remote's comment
  says activationTimer is "decayed live by the N2279 tick" — local ownership
  of that decay is UNVERIFIED in the probe; check before taking the stamp.
  No new exact_exprs come from remote N2280 (5/5 already in local N2328).
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
- **Divergence merge-time flags (#49, full detail in the probe §5):** remote
  N2278 is the 17th updateTile sub-slice of the remote line; at merge, dedup
  the pure function + 3 pure proof keys into N2297 (KEEP the local frame-first
  signature, do NOT register a second function/symbol), take only the driver
  tick (validate line + `frame["logic_controlled"]` stamp) and its 2 driver
  proof keys; remote isShooting (N2277) computes logicControlled INLINE
  instead of reading the just-stamped frame key — decide at merge whether it
  should read the frame key for consistency (precedent #48: warmup); the
  remote fixture "N2251 proof" maps to local **N2316**, not local N2251
  (RepairTurret jitter); remote N2261 decay tick ≠ local N2301; remote
  N2274+N2275+N2276+N2277+N2278 are five consecutive sub-slices of the same
  driver tick — merge all five together, Java order :491 validate → :492
  isShooting → :502 warmup → :534-536 decay.
- **Older merge-time flags still open:** warmup ownership/dedup (remote N2253
  vs local N2308, 15/34 exprs); remote recoil family N2254–N2258
  complementary; remote N2258 vs local N741/N742; remote updateTile
  driver-tick family N2259–N2263 + N2265 + N2270 complementary; remote N2266
  targetPosition overlaps local N2122 (16/21 exprs) + needs hasAmmo (N2313,
  done) + peekAmmo (batch 2) owned before it merges; remote N2267
  super.control() overlaps local N552/N553/N1088/N1089 (13/15 exprs); remote
  N2268 configured() overlaps local N544–N549/N1751/N1752 (23/26 exprs);
  remote N2269 queuedBullets/charging overlaps local N2308 (2/24 exprs);
  `SourceItemTurretBuildState.gd` both-modified; remote adds functions to
  SourceTurretBuildState.gd (plus local N2285 status + N2297 accessors +
  N2307 unit() + N2313 hasAmmo() + N2324 controlled()).
- Push from Windows: local ahead/behind origin/main df426c4 = **121 / 217**
  (counted at docs time, HEAD 83c0707; recount at push time). Merge by hand in
  the spec at push time. No force-push.

## Cron delivery

- Cron runs 13:15 (spawned batch 2), 13:30 and 13:45 (probe #51) and 14:00
  all delivered and were verified from disk by main thread before use. Main
  thread keeps reporting directly every 15 minutes, including a one-line
  report when nothing changed.
