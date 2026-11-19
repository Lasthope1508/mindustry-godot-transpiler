# Reconciliation round 16 — renumber N2267 → N2310 (divergence #38)

## Divergence

- origin/main 2adf884 → **410ac5d** (5 commits: slice 5295a7e + 4 docs). Remote **N2267 =
  BuildingComp.control() / Turret super.control()** (owner
  `SourceTurretBuildState.source_turret_super_control_state`, 15 exact_exprs, 2 symbols, 4
  tests, proof "9 keys" commit-message only — 9 domain keys counted in the remote proof
  script) collides number-only with local **N2267 = RadarBuild.write()/read()** (owner
  `SourceRadarBuildState.source_radar_write_state` + `source_radar_read_state`, commit
  4368280 batch N2265–N2267, 19 exact_exprs, 2 symbols, 4 tests, proof
  C07RadarWriteReadProof **7 domain keys / 10 total, counted from JSON**). Overlap **0/19
  exact_exprs, 0 symbols, 0 tests**. Different method, different GD file, different owner.
- Probe: `hidden_files/divergence-38-n2267-renumber-impact.md` (cron 20:15, main thread read
  in full + verified from disk ~20:26). N2310 free in both ledgers at reserve time.
  Nuance (merge-time, not a renumber blocker): remote N2267 shares 13/15 exact_exprs with
  local N552/N553/N1088/N1089 (BuildingComp.control() already owned at PortGame level) —
  dedup decision at merge (a new Turret function calling back to PortGame states vs merging
  the slice whole); only 2 exprs truly new (`enabled("to")`, `config(true, "to")`). Remote
  N2267 is the 4th link of their control() chain (N2264 control() → N2265 efficiency fold →
  N2266 targetPosition → N2267 super.control).

## Renumber

- **N2267 → N2310 (Radar write/read), commit `49f8137`** (17 files, 1491+/1491-).
  Reserve N2310 by script first (status 'renumbering'). Sed: register write/read (whole file,
  8 places) + test (whole file, 8 places) + proof .gd (1 place) + spec :339 (first
  occurrence only — the row label; :337/:338 "Batch N2265–N2267" history in the N2308/N2309
  rows KEPT) + GOAL :397 + canPickup register alias `N2267_DEFERRED`→`N2310_DEFERRED`
  (whole file) + proof-debt strings in each downstream register (canPickup :55, draw :62,
  drawSelect :67, drawPlace :80) + proof .gd comments (draw :37, drawSelect :37, drawPlace
  :41). **Probe missed 1 line again** — the DEFERRED-carry comment in canPickup register
  :49 ("carried from the N2267 register..."), caught by the full-tree grep after the first
  sed pass (same lesson as #37: probes list what they found, not what exists).
- Script delete: ledger key + 2 contracts (write + read) + 4 schemas (write input/result,
  read input/result) + defense_api_contracts entry (only the write contract — the shard
  mirrors just one) + defense_slices key. Asserted each delete count before proceeding.
  (The probe said "defense_api_contracts 1 occurrence" — verified, it was exactly the write
  contract.)
- **Chain re-register 5 registers** in the linear Radar chain (write/read → canPickup →
  draw → drawSelect → drawPlace), --verify **26/26 + 6/6 + 18/18 + 14/14 + 20/20**;
  targeted 4/4 (56 subtests); family Radar 40/40 (392); wiring 32/32 (250); proof
  C07RadarWriteReadProof re-run in main, **7 domain keys (10 total)** all true (counted
  from JSON — the GOAL line already said 7 keys, correct under the domain-key convention).
- Literal N2267 in the ledger = **0** after the chain (N2310 = 16: 1 key + 15 deferred
  mentions — own 1 + downstream N2272 2 + N2278 3 + N2281 4 + N2284 5, matching the probe
  exactly). Key-by-key diff vs HEAD: only N2267 out / N2310 in; 4 downstream entries changed
  ONLY in `deferred_exprs`. SSOT unchanged **11699/1734/1682/3155**. Done 1734.
- **Gate #38 GREEN (PID 13542, ~21:34–21:52): Ran 6229 in 1112.045s, failures=234,
  skipped=5, 0 errors** — counted from the log: 234 FAIL headers, all 234
  `AssertionError: unexpectedly None` (Godot-absent), 0 ERROR headers. Log:
  `hidden_files/full-suite-renumber-38-gate.log`. No VM restart during the gate (uptime 2:17
  at the 21:55 check).

## Docs (this commit)

- This report + handoff (round 16). Spec row + GOAL §5 number were already renumbered in the
  renumber commit 49f8137 (precedent rounds 7–15); GOAL scene hash stays `4368280` (the
  commit that first carried the scene to Windows — the renumber changed no scene content).

## Handoff / next

- **Divergence #39 (probed, read in full by main thread):** origin 410ac5d → **6cfc8b8**
  (5 commits: slice 1d030ba + 4 docs). Remote **N2268 = Turret configured() dispatch
  effect** (owner `SourceTurretBuildState.source_turret_configured_dispatch_state`, 26
  exact_exprs, 4 symbols, 4 tests, proof "12 keys" commit-message only — probe counted 15
  `proof[` lines = 12 domain + 3 standard in the remote .gd) collides with local **N2268 =
  TurretBuild.fogRadius()** (14 exact_exprs, 1 symbol, 4 tests, proof 10 keys total / 7
  domain, counted from JSON). Overlap **0/14 exact_exprs, 0/1 symbols, 0/4 tests**. Probe:
  `hidden_files/divergence-39-n2268-renumber-impact.md`. **Plan: local N2268 → N2311** (free
  in both ledgers + no allocations.json entry — verified by the probe; N2310 is #38's). **Do
  #39 next, right after this docs commit.** Chain re-register **11 registers** in the
  Turret linear chain (fogRadius → estimateDps → warmup → findTarget → trackingRange →
  writeRead → isActive → minRange → status → microAccessors → unit) + re-run
  `register_c07_drill_sense.py` (rule text in its schema mentions N2268). After the
  probe-listed sed, grep literal N2268 across the whole tree and sed every live reference
  (lesson from #37/#38); after the chain re-register, grep literal N2268 in the ledger
  (lesson from #36). Caveats from the probe: the precedent pairs "N2268/N2249" and
  "N2268/N2261" are half-stale (N2249→N2275 in round 5, N2261→N2301 in #32, never
  re-pointed then) — in #39 re-point only the N2268 half, keep the stale half; the alias
  `N2237_DEFERRED` in the own register is stale since round 3 (sense is now N2293) but
  still runs correctly — do not rename it. Verify: --verify + targeted
  (test_c07_turret_fog_radius) + family Turret + wiring + proof C07TurretFogRadiusProof
  re-run (expect 7 domain keys / 10 total — count from JSON when run) → commit → re-gate →
  docs round 17.
- **Batch N2312–N2314 after docs #39** (hasAmmo / BurstDrill draw / isDark): scope file
  `hidden_files/next-batch-scope-after-n2311.md` (refreshed by a cron research agent ~21:5x,
  base 49f8137) — relabel-check against allocations.json before spawning (labels should
  already be N2312–N2314 / N2315–N2317; verify, don't assume). Reserve N2312–N2314 by
  script + write spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check + arc/mindustry-upstream
  symlinks. hasAmmo side-effect note: `ammo.swap(...)` modelling needs main-thread
  confirmation in scope before spawn. Then batch **N2315–N2317** (`controlled()` + charging
  alternate); next_free_n ends at **2318**.
- allocations.json: N2310 done (49f8137), next_free_n **2311**. N2304 held (ambient C, waits
  for Windows B).
- Push from Windows: local ahead/behind origin/main 6cfc8b8 — recount at push time (cron
  21:30 counted 86 ahead / 149 behind — main thread has not independently verified those
  counts; recount before pushing). Merge by hand in the spec at push time. No force-push.
  Merge-time flags: remote updateTile driver-tick family charge N2259 → unit sync N2260 →
  logicControlTime N2261 → rotate sync N2262 → heatReq N2263 → efficiency fold N2265 (fold
  runs BEFORE warmup when merged); control() chain N2264 → N2266 targetPosition → N2267
  super.control → **N2268 configured() dispatch** (remote N2268 shares 23/26 exprs with
  local N544–N549 + N1751/N1752 + N2234 + N1867 — PortGame `BuildingComp.configured()` —
  dedup decision at merge, only 3 exprs truly new); remote recoil family
  N2254+N2255+N2256+N2257+N2258 complementary, no dedup; remote N2258 vs local N741/N742
  still open; warmup ownership/dedup (remote N2253 vs local N2308) still open; remote N2266
  vs local N2122 still open; remote N2267 vs local N552/N553/N1088/N1089 still open;
  `SourceItemTurretBuildState.gd` both-modified; remote adds 16 functions to
  SourceTurretBuildState.gd that local lacks (plus local N2285 status + N2297 accessors +
  N2307 unit() when merging).
