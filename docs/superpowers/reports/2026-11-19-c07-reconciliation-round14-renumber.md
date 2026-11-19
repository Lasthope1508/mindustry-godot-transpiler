# Reconciliation round 14 — renumber N2265 → N2308 (divergence #36)

## Divergence

- origin/main d2d8b6b → **c8a5ba8** (7 commits: 2 evidence 069c4f3/5929e26 + slice 92a9a63 +
  4 docs). Remote **N2265 = TurretBuild.updateEfficiencyMultiplier()** (owner
  `source_turret_efficiency_multiplier_state`, 13 exact_exprs, 1 symbol, 4 tests, proof "9 keys"
  commit-message only — no JSON in the remote tree) collides number-only with local **N2265 =
  TurretBuild.updateTile() warmup** (owner `source_turret_update_tile_warmup_state`, commit
  e50f45e batch N2265–N2267, 27 exact_exprs, 3 symbols, 4 tests, proof
  C07TurretUpdateTileWarmupProof **18 keys counted from JSON**). Overlap **2/13 exact_exprs**
  (only the `heatReq`/`heatRequirement` field declarations), **0/1 symbols, 0/4 tests**.
  Different method, different GD function, different owner.
- Probe: `hidden_files/divergence-36-n2265-renumber-impact.md`. N2308 free in both ledgers
  (verified: probe + main thread). Nuance (merge-time, not a renumber blocker): remote N2265
  is the 6th slice of their updateTile driver-tick family (charge N2259 → unit sync N2260 →
  logicControlTime N2261 → rotate sync N2262 → heatReq N2263 → efficiency fold N2265;
  N2264 control() is event-driven, outside the tick chain), complementary, no dedup; the fold
  tick runs BEFORE the warmup tick when merged (warmup lerp reads efficiency as its rate);
  9/13 remote exact_exprs already appear in other local slices (N1213/N2108–N2114/N1057/N666)
  — evidence-only. Local GD has no function `source_turret_efficiency_multiplier_state` —
  merging remote adds a new function, no name clash.
- **Correction:** the old commit e50f45e said proof "4 keys" — wrong. The JSON has 18 keys
  (15 `warmup_*` + `matches` + `registry_valid` + `one_headquarter_per_ssot`), all true.
  Same undercount class of error as N2257 (6 keys claimed, 9 real) in round 8.

## Renumber

- **N2265 → N2308 (Turret warmup), commit `c4c89ee`** (16 files, 446+/446-). Reserve N2308
  by script first (status 'renumbering'). Sed: register warmup (whole file, 10 places) + test
  warmup (9 places) + proof .gd (1 place) + find_target register (:36 comment, :78 alias,
  :160 comment, :168 use) + micro_accessors register (:17 comment, :117 rule string) + test
  find_target :42 + test micro_accessors :28 + proof MicroAccessorsProof.gd :32 + GD
  SourceTurretBuildState.gd :667 (micro-accessors comment naming the warmup leg) + GOAL :393 +
  spec :337 (first occurrence only — the row label; the batch label 'Batch N2265–N2267' on
  the same line is history). KEPT per round-4 precedent: spec :332 (row N2268 fogRadius
  naming "N2261+N2265 registers re-run" — prose precedent in another slice's entry) and the
  N2266/N2267/N2297 rows naming N2265 (other slices' entries).
- Script delete: ledger key + 1 contract + 2 schemas + defense_api_contracts entry + defense
  shard key. Asserted each delete count before proceeding.
- **Chain re-register 9 registers** in import order (warmup → find_target → tracking_range →
  write_read → is_active → min_range → status → micro_accessors → unit), --verify **44/44 +
  87/87 + 18/18 + 36/36 + 17/17 + 16/16 + 25/25 + 28/28 + 15/15**; targeted 4/4 (90
  subtests); family Turret 60/60 (829); wiring 32/32 (250); proof
  C07TurretUpdateTileWarmupProof re-run in main, **18 keys** all true (counted from JSON).
- **Lesson (new, probe missed a link):** the probe was written before N2307 (Turret unit())
  merged, so its chain list had 8 registers. After re-registering those 8, a literal grep
  found 4 `N2265` strings still in the ledger — all in N2307's `deferred_exprs` (unit()
  imports DEFERRED from micro_accessors N2297, making it the 9th chain link). Fixed by
  re-running `register_c07_turret_unit.py` plain + --verify 15/15; literal N2265 in the
  ledger = 0 afterwards (N2308 = 37: 1 key + 36 deferred mentions, 9 entries × 4 strings).
  **Rule: after any chain re-register, grep the old number literally in the ledger; if any
  remains, find the entry holding it and re-run that entry's register.**
- Key-by-key diff vs HEAD: only N2265 out / N2308 in; 8 downstream entries changed ONLY in
  `deferred_exprs`; 1 contract + 2 schemas + defense contract changed `source_slice`;
  defense shard key swapped. SSOT unchanged **11699/1734/1682/3155**. Done 1734.
- **Gate #36 — first attempt KILLED by VM restart #32 (~19:37 +07):** PID 15834 died mid-run,
  log frozen at 5905 bytes with 0 "Ran" lines (kept as
  `hidden_files/full-suite-renumber-36-gate-killed-by-restart32.log`). Symlink Godot restored
  + verified 4.6.2, gate re-run immediately per rule 3.
- **Gate #36 RERUN GREEN (PID 2723, ~19:48–20:06): Ran 6229 in 1096.514s, failures=234,
  skipped=5, 0 errors** — counted from the log: 234 FAIL headers, all 234 `AssertionError:
  unexpectedly None` (Godot-absent), 0 ERROR headers, 0 other AssertionErrors. Log:
  `hidden_files/full-suite-renumber-36-gate-rerun.log`. No VM restart during the rerun
  (uptime 49 min at the 20:26 check). Ran +12 / failures +3 vs the batch gate — exactly the
  3 new slices from batch N2305–N2307.

## Docs (this commit)

- This report + handoff (round 14). Spec row + GOAL §5 number were already renumbered in the
  renumber commit c4c89ee (precedent rounds 7–13); GOAL scene hash stays `e50f45e` (the
  commit that first carried the scene to Windows — the renumber changed no scene content).

## Handoff / next

- **Divergence #37 (already probed + verified by main thread from disk):** origin c8a5ba8 →
  2adf884 (5 commits: slice a421f48 + 4 docs). Remote N2266 = TurretBuild.targetPosition(pos)
  collides with local **N2266 = BurstDrill.setStats()**. Overlap 0/21 exact_exprs, 0 symbols,
  0 tests. Plan: local N2266 → **N2309**, chain re-register 6 registers in probe §5b order
  (setStats → ambientVolume → Drill.ambientVolume → Drill.setStats → write/read → 
  shouldAmbientSound). Probe: `hidden_files/divergence-37-n2266-renumber-impact.md`. Do #37
  next, right after this docs commit. Merge-time: remote N2266 shares 16/21 exprs with local
  N2122 (Predict evidence) — dedup decision at merge; remote targetPosition calls `hasAmmo()`
  + `peekAmmo()` — hasAmmo (now N2311 after the #38 shift) + peekAmmo (T6 queue, no number
  yet) must be owned before merging remote N2266.
- **Divergence #38 (probed 20:18–20:23 +07, verified by main thread from disk):** origin
  2adf884 → **410ac5d** (5 commits: slice 5295a7e + 4 docs). Remote N2267 =
  BuildingComp.control() / Turret super.control() (enabled/config, 15 exact_exprs, 2 symbols,
  4 tests, proof "9 keys" commit-message only — 9 domain keys counted from the remote .gd)
  collides with local **N2267 = RadarBuild.write()/read()** (19 exact_exprs, 2 symbols,
  4 tests, proof 7 domain keys / 10 keys total from JSON). Overlap **0/19 exact_exprs, 0
  symbols, 0 tests**. Plan: local N2267 → **N2310**, chain re-register 5 registers in the
  linear Radar chain (write/read → canPickup → draw → drawSelect → drawPlace). Probe:
  `hidden_files/divergence-38-n2267-renumber-impact.md`. **Do #37 first, #38 second** — both
  edit the same SSOT files, in N order, each with its own gate + docs. Merge-time: remote
  N2267 shares 13/15 exprs with local N552/N553/N1088/N1089 (BuildingComp.control() already
  owned at PortGame level) — dedup decision at merge (Turret function calling back to the
  PortGame states vs merging the slice whole); only 2 exprs are truly new
  (`enabled("to")`, `config(true, "to")`).
- **Batch labels shift +1 again (3rd time):** hasAmmo / BurstDrill draw / isDark →
  **N2311–N2313**; `controlled()` (+ charging alternate) → **N2314–N2316**. next_free_n after
  #37 + #38 + both batches = **2317**. Scope file `hidden_files/next-batch-scope-after-n2307.md`
  (refreshed 19:33–19:35, base c4c89ee) still carries the pre-#38 labels N2310–N2312 /
  N2313–N2315 — relabel before spawning. hasAmmo side-effect note stands: the `ammo.swap(...)`
  modelling (ammo list as param in/out) needs main-thread confirmation in scope before spawn.
- allocations.json: N2308 done (c4c89ee), next_free_n **2309**. N2285/N2287 stale 'reserved'
  entries fixed to done (fd76c4f/81d116f) after a cron flag — both had merged in batch
  N2285–N2287 but their reservation status was never updated.
- Push from Windows: local ahead/behind origin/main 410ac5d — recount at push time. Merge by
  hand in the spec at push time. No force-push. Merge-time flags: remote updateTile driver-tick
  family now charge N2259 → unit sync N2260 → logicControlTime N2261 → rotate sync N2262 →
  heatReq N2263 → efficiency fold N2265 (fold runs BEFORE warmup when merged); control() chain
  N2264 → N2266 targetPosition → N2267 super.control (remote N2264 already owns Turret
  control(), local `controlled()` still unported); remote recoil family
  N2254+N2255+N2256+N2257+N2258 complementary, no dedup; remote N2258 vs local N741/N742
  (PortGame-era recoilOffset evidence) still open; warmup ownership/dedup (remote N2253 vs
  local N2308) still open; remote N2266 vs local N2122 (Predict evidence) still open; remote
  N2267 vs local N552/N553/N1088/N1089 still open; `SourceItemTurretBuildState.gd`
  both-modified; remote adds 15 functions to SourceTurretBuildState.gd that local lacks (plus
  local N2285 status + N2297 accessors + N2307 unit() when merging).
