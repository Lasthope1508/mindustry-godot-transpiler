# Reconciliation round 18 — renumber N2269 → N2312 (divergence #40)

## Divergence

- origin/main 6cfc8b8 → **a95971b** (5 commits: slice 188a1ac + 4 docs). Remote **N2269 =
  Turret queuedBullets counter + charging() gate** (owner
  `SourceTurretBuildState.source_turret_queued_bullets_state`, 24 exact_exprs, 4 symbols, 4
  tests, proof "12 keys" commit-message only — probe counted 12 domain `qb_*` keys + 3
  standard in the remote .gd) collides number-only with local **N2269 = BurstDrill.icons()**
  (owner `SourceBurstDrillBuildState.source_burst_drill_icons_state`, commit 2b49c54 round 4,
  10 exact_exprs, 1 symbol, 4 tests, proof C07BurstDrillIconsProof **3 domain keys / 6
  total, counted from JSON**). Overlap **0/24 exact_exprs, 0 symbols, 0 tests**. Different
  method, different GD file, different owner.
- Probe: `hidden_files/divergence-40-n2269-renumber-impact.md` (cron read-only probe, read in
  full by main thread). N2312 free in both ledgers at reserve time (also N2313–N2318 free).
  Nuance (merge-time, not a renumber blocker): remote N2269 shares **2/24 exact_exprs with
  local N2308** (`public boolean charging(){` + `return queuedBullets > 0 &&
  shoot.firstShotDelay > 0;` — `charging()` already ported inside local warmup) — dedup
  decision at merge; the other 13 local slices sharing ≥1 expr are generic literals
  (Weapon.shoot, `reload = 80f`, block defs), no dedup meaning. Remote N2269 is a pure
  function, no driver tick; `updateShooting()` runs from `updateTile()` — when merging, the
  queuedBullets gate sits relative to the warmup fold (local N2308 owns updateTile/warmup).
  Local GD has no `source_turret_queued_bullets_state` — merging remote adds a new function.

## Renumber

- **N2269 → N2312 (BurstDrill icons), commit `9cd9f9a`** (17 files, 1546+/1546-).
  Reserve N2312 by script first (status 'renumbering'). Sed: register icons (whole file, 7
  places) + on_proximity_update register (whole file — alias `N2269_DEFERRED` → 
  `N2312_DEFERRED` + comment + use) + test icons (whole file, 8 places) + proof .gd (1
  place) + spec :333 (first occurrence only — the row label; the same line's round-4 history
  "renamed in place N2245->N2269" + "N2262 alias N2245_DEFERRED->N2269_DEFERRED" KEPT) +
  GOAL :385 + line-targeted seds: set_stats :40/:113, drill_should_ambient_sound :35,
  drill_set_stats :49, drill_draw_select :43, drill_ambient_volume :28,
  burst_drill_ambient_volume :35. **This probe listed everything** — the full-tree grep
  after the first sed pass found NO missed live reference (only spec :333 history + old
  reports/handoffs, both kept per precedent). First clean probe since #36.
- Script delete: ledger key + 1 contract + 2 schemas + production_api_contracts entry +
  production_slices key. Asserted each delete count before proceeding. (No defense shard —
  production slices live in `source_modules/production_*`, per the #37 lesson.)
- **Chain re-register 8 registers** in import order (icons → on_proximity_update →
  set_stats → ambient_volume → drill_ambient_volume → should_ambient_sound + write_read +
  drill_set_stats; drill_draw_select is comment-only, sed but no re-run), --verify
  **13/13 + 49/49 + 26/26 + 11/11 + 11/11 + 20/20 + 28/28 + 54/54**; targeted 4/4 (28
  subtests); family BurstDrill+Drill 60/60 (966 — includes shouldAmbientSound N2305, 4 tests
  more than the 56/56 at #33); wiring 32/32 (250); proof C07BurstDrillIconsProof re-run in
  main, **3 domain keys (6 total)** all true (counted from JSON — the GOAL line already said
  6 keys, correct under the domain-key convention).
- Literal N2269 in the ledger = **0** after the chain (N2312 = 9: 1 key + 8 deferred
  mentions, matching the probe exactly). Key-by-key diff vs HEAD: only N2269 out / N2312 in;
  7 downstream entries changed ONLY in `deferred_exprs`. SSOT unchanged
  **11699/1734/1682/3155**. Done 1734.
- **Gate #40 GREEN (PID 21632, ~22:59–23:17): Ran 6229 in 1083.724s, failures=234,
  skipped=5, 0 errors** — counted from the log: 234 FAIL headers, all 234
  `AssertionError: unexpectedly None` (Godot-absent), 0 ERROR headers. Log:
  `hidden_files/full-suite-renumber-40-gate.log`. No VM restart during the gate (uptime 3:54
  at the 23:31 check).

## Docs (this commit)

- This report + handoff (round 18). Spec row + GOAL §5 number were already renumbered in the
  renumber commit 9cd9f9a (precedent rounds 7–17); GOAL scene hash stays `2b49c54` (the
  commit that first carried the scene to Windows — the renumber changed no scene content).

## Handoff / next

- **Origin moved again, NOT a divergence:** origin/main a95971b → **38067ef** (2 commits:
  merge 38067ef + validate 4b7ab71, Godot evidence N2433–N2435 native draw proofs). Remote
  ledger 1719 → 1719, 0 added/removed/changed keys — verified by main thread from disk.
  No probe needed.
- **Batch N2313–N2315 (hasAmmo / BurstDrill draw / isDark) — SPAWNED by cron 23:15, CUT
  SHORT by the cron 900s timeout (recurring pattern, see #40 gate note).** All 3 workers
  stopped before GREEN+proof; none committed. Disk state verified by main thread:
  N2313 (hasAmmo) + N2314 (draw) wrote nothing (read-only prep only); N2315 (isDark) wrote
  the GD function + test + register in its worktree (uncommitted, no verify/proof yet).
  Worktrees (base 9cd9f9a): `~/workspace/mindustry-wt-n2313-turret`,
  `~/workspace/mindustry-wt-n2314-burstdrill`, `~/workspace/mindustry-wt-n2315-game`.
  Allocations: N2313–N2315 reserved (owner cron), next_free_n **2316**, spawn_lock active.
  **Main thread spawns 3 CONTINUATION workers next** (main-thread spawns are not subject
  to the cron 900s limit): N2313 continuation (full slice, hasAmmo side-effect note:
  `ammo.swap(...)` modelling needs main-thread confirmation in scope before spawn — read
  the scope file's hasAmmo section first); N2314 continuation (full slice); N2315
  continuation (verify existing code first: register --verify, targeted, family, wiring,
  proof — do not rewrite what is already written). Scope:
  `hidden_files/next-batch-scope-after-n2312.md` (refreshed by cron ~23:0x, base 9cd9f9a,
  labels N2313–N2315 / N2316–N2318 — verify against allocations.json before spawning).
  Merge in N order, then gate once, then docs batch.
- Then batch **N2316–N2318** (`controlled()` + charging alternate — note: remote N2269
  already owns a `charging()` gate; local `charging()` slice scope must check overlap with
  remote N2269 at spawn time); next_free_n ends at **2319**.
- allocations.json: N2312 done (9cd9f9a), next_free_n **2313** (before batch reserve;
  batch reserve moved it to 2316). N2304 held (ambient C, waits for Windows B).
- Push from Windows: local ahead/behind origin/main 38067ef — recount at push time. Merge by
  hand in the spec at push time. No force-push. Merge-time flags: remote updateTile
  driver-tick family charge N2259 → unit sync N2260 → logicControlTime N2261 → rotate sync
  N2262 → heatReq N2263 → efficiency fold N2265 (fold runs BEFORE warmup when merged);
  control() chain N2264 → N2266 targetPosition → N2267 super.control → **N2268 configured()
  dispatch** (remote N2268 shares 23/26 exprs with local N544–N549/N1751/N1752 — dedup
  decision at merge, only 3 exprs truly new); remote N2269 queuedBullets/charging shares
  **2/24 exprs with local N2308** — dedup decision at merge; remote recoil family
  N2254+N2255+N2256+N2257+N2258 complementary, no dedup; remote N2258 vs local N741/N742
  still open; warmup ownership/dedup (remote N2253 vs local N2308) still open; remote N2266
  vs local N2122 still open; remote N2267 vs local N552/N553/N1088/N1089 still open;
  `SourceItemTurretBuildState.gd` both-modified; remote adds 17 functions to
  SourceTurretBuildState.gd that local lacks (plus local N2285 status + N2297 accessors +
  N2307 unit() when merging).
