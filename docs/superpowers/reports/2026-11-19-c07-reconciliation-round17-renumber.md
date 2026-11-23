# Reconciliation round 17 — renumber N2268 → N2311 (divergence #39)

## Divergence

- origin/main 410ac5d → **6cfc8b8** (5 commits: slice 1d030ba + 4 docs). Remote **N2268 =
  Turret configured() dispatch effect** (owner
  `SourceTurretBuildState.source_turret_configured_dispatch_state`, 26 exact_exprs, 4
  symbols, 4 tests, proof "12 keys" commit-message only — probe counted 15 `proof[` lines =
  12 domain + 3 standard in the remote .gd) collides number-only with local **N2268 =
  TurretBuild.fogRadius()** (owner `SourceTurretBuildState.source_turret_fog_radius_state`,
  commit 83bf0bc round 4, 14 exact_exprs, 1 symbol, 4 tests, proof C07TurretFogRadiusProof
  **7 domain keys / 10 total, counted from JSON**). Overlap **0/14 exact_exprs, 0 symbols,
  0 tests**. Different method, same family Turret, same GD file — different function, no name
  clash.
- Probe: `hidden_files/divergence-39-n2268-renumber-impact.md` (read-only agent, read in full
  by main thread). N2311 free in both ledgers at reserve time. Nuance (merge-time, not a
  renumber blocker): remote N2268 shares **23/26 exact_exprs** with local N544–N549 +
  N1751/N1752 + N2234 + N1867 (PortGame `BuildingComp.configured()` already owned) — dedup
  decision at merge (a new Turret function calling back to PortGame states vs merging the
  slice whole); only 3 exprs truly new (signature, the `void.class` comment, the
  `lastAccessed` field). Remote N2268 is the 5th link of their control() chain (N2264 control()
  → N2265 efficiency fold → N2266 targetPosition → N2267 super.control → N2268 configured()
  dispatch). Local GD has no `source_turret_configured_dispatch_state` — merging remote adds
  a new function.

## Renumber

- **N2268 → N2311 (Turret fogRadius), commit `6726d65`** (39 files, 303+/303-).
  Reserve N2311 by script first (status 'renumbering'). Sed: register fogRadius (whole file,
  7 places) + test (whole file, 9 places) + proof .gd (1 place) + spec :332 (first
  occurrence only — the row label; the same line's "renamed in place N2244->N2268" round-4
  history KEPT) + GOAL :383 + estimateDps register (whole file — alias `N2268_DEFERRED` →
  `N2311_DEFERRED` + comments + debt string) + line-targeted seds: warmup :51, trackingRange
  :26, status :23/:106, microAccessors :15/:116/:130/:137, unit :26/:115, drill_sense
  :45/:99/:110, Radar registers (canPickup :14, draw :17, drawSelect :18, drawPlace :28),
  GD comments (Radar GD :89/:134/:141/:146/:151, Turret GD :639/:668/:689/:705/:723/:747/:951,
  BurstDrill GD :402/:420/:432), test comments (10 files, 1 line each), proof .gd comments
  (trackingRange :45, status :37, unit :33, microAccessors :31). **Probe missed 1 line again**
  — BurstDrill GD :402 carries TWO occurrences of N2268 on the same line; the first sed
  replaced only the first, the second was caught by the full-tree grep after the first sed
  pass (same lesson as #37/#38: grep the whole tree after sed, and use `/g` when a line
  mentions the number twice). Caveats honored: precedent pairs "N2268/N2249" and
  "N2268/N2261" are half-stale (N2249→N2275 round 5, N2261→N2301 #32, never re-pointed then)
  — in #39 only the N2268 half was re-pointed; the stale alias `N2237_DEFERRED` in the own
  register (sense is now N2293) was NOT renamed.
- Script delete: ledger key + 1 contract + 2 schemas + defense_api_contracts entry +
  defense_slices key. Asserted each delete count before proceeding.
- **Chain re-register 11 registers** in the Turret linear chain (fogRadius → estimateDps →
  warmup → findTarget → trackingRange → writeRead → isActive → minRange → status →
  microAccessors → unit) + re-run `register_c07_drill_sense.py` (rule text mentions N2268),
  --verify **21/21 + 20/20 + 44/44 + 87/87 + 18/18 + 36/36 + 17/17 + 16/16 + 25/25 +
  28/28 + 15/15 + 31/31**; targeted 4/4 (44 subtests); family Turret 60/60 (829); wiring
  32/32 (250); proof C07TurretFogRadiusProof re-run in main, **7 domain keys (10 total)**
  all true (counted from JSON — the GOAL line already said 7 keys, correct under the
  domain-key convention).
- Literal N2268 in the ledger = **0** after the chain (N2311 = 12: 1 key + 11 deferred
  mentions — own 1 + 10 downstream × 1, matching the probe exactly). Key-by-key diff vs
  HEAD: only N2268 out / N2311 in; 10 downstream entries changed ONLY in `deferred_exprs`.
  SSOT unchanged **11699/1734/1682/3155**. Done 1734.
- **Gate #39 GREEN (PID 17277, ~22:13–22:31): Ran 6229 in 1083.354s, failures=234,
  skipped=5, 0 errors** — counted from the log: 234 FAIL headers, all 234
  `AssertionError: unexpectedly None` (Godot-absent), 0 ERROR headers. Log:
  `hidden_files/full-suite-renumber-39-gate.log`. No VM restart during the gate (uptime 3:05
  at the 22:42 check).

## Docs (this commit)

- This report + handoff (round 17). Spec row + GOAL §5 number were already renumbered in the
  renumber commit 6726d65 (precedent rounds 7–16); GOAL scene hash stays `83bf0bc` (the
  commit that first carried the scene to Windows — the renumber changed no scene content).

## Handoff / next

- **Divergence #40 (probed, read in full by main thread):** origin 6cfc8b8 → **a95971b**
  (5 commits: slice 188a1ac + 4 docs). Remote **N2269 = Turret queuedBullets counter +
  charging() gate** (owner `SourceTurretBuildState.source_turret_queued_bullets_state`, 24
  exact_exprs, 4 symbols, 4 tests, proof "12 keys" commit-message only — probe counted 12
  domain `qb_*` keys + 3 standard in the remote .gd) collides with local **N2269 =
  BurstDrill.icons()** (owner `SourceBurstDrillBuildState.source_burst_drill_icons_state`,
  commit 2b49c54 round 4, 10 exact_exprs, 1 symbol, 4 tests, proof C07BurstDrillIconsProof
  **3 domain keys / 6 total, counted from JSON**). Overlap **0/24 exact_exprs, 0 symbols,
  0 tests**. Probe: `hidden_files/divergence-40-n2269-renumber-impact.md`. **Plan: local
  N2269 → N2312** (free in both ledgers + next_free_n = 2312 — verified by the probe and
  by main thread; N2313–N2318 also free). **Do #40 next, right after this docs commit.**
  Chain re-register **8 registers** (icons → on_proximity_update → set_stats →
  ambient_volume → drill_ambient_volume → should_ambient_sound + write_read + drill_set_stats;
  drill_draw_select is comment-only, sed but no re-run). After the probe-listed sed, grep
  literal N2269 across the whole tree and sed every live reference (lesson from
  #37/#38/#39); after the chain re-register, grep literal N2269 in the ledger (lesson from
  #36). Verify: --verify + targeted (test_c07_burst_drill_icons) + family BurstDrill+Drill
  + wiring + proof C07BurstDrillIconsProof re-run (expect 3 domain keys / 6 total — count
  from JSON when run) → commit → re-gate → docs round 18.
- **Batch N2313–N2315 after docs #40** (hasAmmo / BurstDrill draw / isDark): scope file
  `hidden_files/next-batch-scope-after-n2311.md` (base 49f8137) carries pre-#40 labels
  N2312–N2314 / N2315–N2317 — **relabel +1 before spawning** (hasAmmo/draw/isDark →
  N2313–N2315, controlled() → N2316–N2318, next_free_n 2319). Reserve N2313–N2315 by script
  + write spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check + arc/mindustry-upstream
  symlinks. hasAmmo side-effect note: `ammo.swap(...)` modelling needs main-thread
  confirmation in scope before spawn. Then batch **N2316–N2318** (`controlled()` + charging
  alternate — note: remote N2269 already owns a `charging()` gate; local `charging()` slice
  scope must check overlap with remote N2269 at spawn time).
- allocations.json: N2311 done (6726d65), next_free_n **2312**. N2304 held (ambient C, waits
  for Windows B).
- Push from Windows: local ahead/behind origin/main a95971b — recount at push time. Merge by
  hand in the spec at push time. No force-push. Merge-time flags: remote updateTile
  driver-tick family charge N2259 → unit sync N2260 → logicControlTime N2261 → rotate sync
  N2262 → heatReq N2263 → efficiency fold N2265 (fold runs BEFORE warmup when merged);
  control() chain N2264 → N2266 targetPosition → N2267 super.control → **N2268 configured()
  dispatch** (remote N2268 shares 23/26 exprs with local N544–N549/N1751/N1752 — dedup
  decision at merge, only 3 exprs truly new); remote N2269 queuedBullets/charging shares
  **2/24 exprs with local N2308** (`charging()` + `queuedBullets > 0 && shoot.firstShotDelay
  > 0` — already ported in local warmup) — dedup decision at merge; remote recoil family
  N2254+N2255+N2256+N2257+N2258 complementary, no dedup; remote N2258 vs local N741/N742
  still open; warmup ownership/dedup (remote N2253 vs local N2308) still open; remote N2266
  vs local N2122 still open; remote N2267 vs local N552/N553/N1088/N1089 still open;
  `SourceItemTurretBuildState.gd` both-modified; remote adds 17 functions to
  SourceTurretBuildState.gd that local lacks (plus local N2285 status + N2297 accessors +
  N2307 unit() when merging).
