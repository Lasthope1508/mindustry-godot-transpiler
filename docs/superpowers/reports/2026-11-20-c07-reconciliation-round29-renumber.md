# Reconciliation round 29 — renumber N2279 → N2328 (divergence #50)

## Divergence

- origin/main 7df3724 → **2e1267a** (5 commits: slice 9bfee77 2026-11-20
  04:47:58 UTC + 4 docs). Remote **N2279 = TurretBuild.updateTile() —
  activationTimer decay** (owner
  `SourceTurretBuildState.source_turret_activation_timer_state`, 5 exact_exprs,
  1 symbol `source_turret_activation_timer_state_result.activation_timer`
  (+ `...activation_timer_elapsed`), 4 tests, deferred 404, proof "5 keys"
  commit-message only — remote tree has the .gd + .tscn but NO proof JSON;
  counted from the remote .gd: 8 `proof[...]` assignments = 5 domain + 3
  standard) collides number-only with local **N2279 = TurretBuild.isActive()**
  (owner `SourceTurretBuildState.source_turret_is_active_state`,
  Turret.java:449-451, commit 40e8152 2026-11-18 13:50:58 UTC, 12 exact_exprs,
  1 symbol `source_turret_is_active_state_result.is_active`, 4 tests,
  deferred 279, proof C07TurretIsActiveProof **11 keys** all true, counted
  from JSON). Overlap **3/5 exact_exprs** — all three are field declarations /
  the `placed()` reset (`public float activationTimer = 0;`,
  `public float activationTime = 0f;`, `activationTimer = activationTime;`),
  not slice logic: remote WRITES/decays the timer in the tick, local READS it
  in the predicate. Complementary, **no dedup**. Same number, different
  method/owner.
- Probe: `hidden_files/divergence-50-n2279-renumber-impact.md` (main thread
  read it in full; 53 occurrences / 16 files, chain re-register 6). Remote
  ledger diff 7df3724 → 2e1267a: added key only N2279, removed 0, changed 0.

## Renumber

- **N2279 → N2328 (TurretBuild isActive), commit `9eee254`** (11 files,
  225+/225-, metadata-only). Reserve N2328 by script first (status
  'renumbering', then 'done' after commit). Sed: register files (is_active 8,
  min_range 3 incl. import alias `N2279_DEFERRED` → `N2328_DEFERRED`) + test
  file (is_active 8) + 1 proof .gd comment + spec line 347 (FIRST occurrence
  only, no /g — row label `N2279:` → `N2328:`, keeping the "Batch
  N2279–N2281" history label and the mindustry-wt-n2279-turret worktree name)
  + GOAL :413 (debt line). No GD function renamed (comments only). History
  docs (6 files, 14 occurrences) KEPT.
- **Probe error caught by assert:** the probe named the contract key
  `source_turret_is_active_state`, but the real key carries the prefix
  `SourceTurretBuildState.source_turret_is_active_state` (same class of
  mistake as #49's schema names). The delete script's assert stopped before
  any bad write; the key was corrected and the delete completed. Lesson:
  never trust a probe's key spelling — assert the exact key before deleting.
- Script delete: ledger key + 1 contract
  (`SourceTurretBuildState.source_turret_is_active_state` in
  `source_api_contracts.json` + the same key in `defense_api_contracts.json`)
  + 2 schemas (input/result) + defense_slices key. Symbol registry: 0
  occurrences — nothing to delete. Totals after delete 11716/1736/1684/3159.
- **Chain re-register 6** (is_active → min_range → status → micro_accessors
  → unit → has_ammo, import order), --verify **17/17 + 16/16 + 25/25 +
  28/28 + 15/15 + 21/21**. Post-chain full-tree grep: N2279 = 0 in all
  generated JSON (N2328 = 13 occurrences) and 0 in code except historical
  docs + the 4 kept "Batch N2279–N2281" labels in the spec. Targeted 24/24
  (289 subtests — all 6 chain slices, incl. the reference-graph tests run
  with Godot on PATH); proof C07TurretIsActiveProof re-run in main, **11
  keys** all true (8 domain + 3 standard, counted from the proof JSON line);
  family Turret 64/64 (876); wiring 32/32 (250). SSOT unchanged
  **11716/1737/1685/3161**. Done 1737.
- **Targeted-run gotcha (main thread's own mistake):** the first targeted run
  failed 6 reference-graph tests with `unexpectedly None` — because it was
  run with `env PATH=/usr/bin:/bin` (copied from the gate command), which
  hides `/usr/local/bin/godot` from `shutil.which`. Re-run with the normal
  PATH: 24/24 green. Targeted/family/wiring runs must use the normal PATH;
  only the chunked gate runner intentionally runs with PATH=/usr/bin:/bin
  (hence its 237 baseline Godot-absent failures).
- **Relabel in the same turn as the commit** (anti-label-drift rule): batch 2
  → **N2329–N2331**, batch 3 → **N2332–N2334**, batch 4 → **N2335–N2337**,
  next_free_n **2338**. `batch-queue.md` + 4 scope files relabeled by script
  `hidden_files/relabel-scope-files-after-50.py`. Order change vs #49: token
  shifts run FIRST (descending), phrase fixes AFTER — one phrase fix creates
  N2328 (`isActive()` N2279 → N2328) and N2328 is in the shift map, so
  running it before the shifts would have moved it to N2329 (the #48 bug
  class). Verified: N2328 appears in a body only as the isActive live ref;
  headings next_free_n 2329/2332/2335/2338.
- **Stale cross-references fixed during the same relabel** (found by auditing
  the scope bodies, not just batch labels): the "Radar — HẾT slice" lines in
  both files still listed pre-renumber numbers — fixed to arrow notation
  (precedent: canPickup N2272→N2318): draw N2278→N2327, updateTile
  N2274→N2320, fogRadius N2275→N2321; the Turret exclusion line's
  write/read/version N2276 → N2276→N2322 (stale since #47). History notes
  about past renumbers (§5 "Renumber #42 chưa xong...") left untouched —
  they describe scope-time state.

## Gate + environment

- **Gate #50 GREEN** on the chunked runner (PID 16898, log
  `hidden_files/full-suite-renumber-50-gate.log`): **Ran 6241, failures=237,
  errors=0, skipped=5, 364/364 modules** — 237 FAIL headers, all 237
  `unexpectedly None`, 0 ERROR (counted from the log by main thread; finished
  ~12:57 +07). Renumber #50 is fully closed. The slowest module was again
  `tests.test_source_symbols` (~15+ min) — no timeout, no restart.
- **No VM restart since #42** (boot Nov 20 03:59 UTC = 10:59 +07, `who -b`);
  uptime 2:04 at docs time. Godot symlink intact, verified
  `4.6.2.stable.official.71f334935`.

## Batch N2324–N2326 (continuations done, waiting merge)

- All three continuations finished and were verified from disk ~11:31–11:37:
  N2324 controlled() (7 files 246+/4-, proof 6/6, family Turret 68/68,
  wiring 32/32); N2325 DrillBuild.draw() base (9 files 1505+/0-, proof
  12/12, family 68/68 1280 subtests, wiring 32/32 — stray untracked file
  `tools/mindustry_godot_transpiler/n2325-family.log` in the worktree, do NOT
  stage); N2326 3 music getters (5 files 862+/0-, proof 13/13, family Game
  24/24 238 subtests, wiring 32/32). Base 062de93 for all three — older than
  HEAD 9eee254, but #49/#50 only renumbered Radar draw / Turret isActive and
  touch none of these slices' files; check base drift per the batch rule
  before merging.
- Merge in N order (N2324 → N2325 → N2326), one slice at a time (copy →
  register → targeted re-verify → commit), then chunked batch gate + batch
  docs (Done 1737→1740). Then spawn batch 2 (N2329–N2331 after relabel).

## Docs (this commit)

- This report + handoff (round 29). Spec rows + GOAL §5 number were already
  renumbered in the renumber commit 9eee254 (precedent rounds 7–28); GOAL scene
  hash stays `40e8152` (the commit that first carried the scene to Windows —
  the renumber changed no scene content).

## Handoff / next

- **No divergence #51:** origin/main is still **2e1267a** at docs time
  (verified by `git fetch origin`); the remote ledger's highest new key is
  still N2279, already handled by #50. The next divergence, when it arrives,
  takes the next free number from allocations.json (currently 2329) — do not
  guess it from this doc.
- **Merge batch N2324–N2326 now** (all three continuations done, gate #50
  GREEN, docs 29 done): merge in N order (N2324 → N2325 → N2326), one slice
  at a time (copy → register → targeted re-verify → commit), then chunked
  batch gate + batch docs (Done 1737→1740). Then spawn batch 2
  **N2329–N2331** (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig /
  findMusic). Reserve by script + write spawn lock BEFORE spawning; worktrees
  from latest HEAD; brief includes editor-import uid_cache + port-7777-free
  check + Godot symlink check + arc/mindustry-upstream symlinks in worktrees.
  A scope file for batch 5 already exists
  (`hidden_files/next-batch-scope-batch5.md`, numbers TBD at spawn time).
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
  done) + peekAmmo (batch 2 after #50 relabel) owned before it merges; remote
  N2267 super.control() overlaps local N552/N553/N1088/N1089 (13/15 exprs);
  remote N2268 configured() overlaps local N544–N549/N1751/N1752 (23/26
  exprs); remote N2269 queuedBullets/charging overlaps local N2308 (2/24
  exprs); `SourceItemTurretBuildState.gd` both-modified; remote adds functions
  to SourceTurretBuildState.gd (plus local N2285 status + N2297 accessors +
  N2307 unit() + N2313 hasAmmo() + N2324 controlled() once merged).
- Push from Windows: local ahead/behind origin/main 2e1267a = **116 / 211**
  (counted at docs time, HEAD 9eee254; recount at push time). Merge by hand in
  the spec at push time. No force-push.

## Cron delivery

- Cron runs 12:30, 12:45 and 13:00 all delivered on time this cycle and were
  verified from disk by main thread before use (the 12:45 run's gate #50
  count was 338/364 vs main thread's 337/364 — a one-module read-timing
  difference, not an error). Main thread keeps reporting directly every 15
  minutes, including a one-line report when nothing changed.
