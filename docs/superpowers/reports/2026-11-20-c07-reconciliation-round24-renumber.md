# Reconciliation round 24 — renumber N2274 → N2320 (divergence #45)

## Divergence

- origin/main 34c947c → **46d4b30** (5 commits: slice 40e856d + 4 docs). Remote **N2274
  = TurretBuild.updateTile() — unit world position part** (owner
  `SourceTurretBuildState.source_turret_unit_world_position_state`, 10 exact_exprs, 3
  symbols, 4 tests, proof "8 keys" commit-message only — remote tree has the .gd +
  .tscn but NO proof JSON) collides number-only with local **N2274 =
  RadarBuild.updateTile()** (owner
  `SourceRadarBuildState.source_radar_update_tile_state`, commit 40e54d9, 26
  exact_exprs, 6 symbols, 4 tests, proof C07RadarUpdateTileProof **10 keys** all true,
  counted from JSON). Overlap **0/10 exact_exprs**, 0 symbols, 0 tests. Different
  family/file/method (`RadarBuild.updateTile()` vs `TurretBuild.updateTile()` unit
  world position).
- Probe: `hidden_files/divergence-45-n2274-renumber-impact.md` (60 occurrences / 20
  lines / 20 files; main thread re-verified the collision from disk: remote ledger
  added key only N2274; local N2274 still present, N2320 free in both ledgers).
  Merge-time (not a renumber blocker): remote N2274 is 1 pure function + 1 driver
  tick (duo branch, after tick N2260 unit sync, before tick N2258 recoilOffset —
  both remote slices, not in the local ledger). Local GD has no
  `source_turret_unit_world_position_state` — merging remote adds a new function, no
  dedup. Remote N2274 vs local N2307 (unit()): overlap 1/10 — only `unit.tile(this);`
  (a call-site line N2307 also quotes as evidence), no dedup. Frame key `unit_tile`
  is also stamped by remote N2260 (unit sync) — check at merge who stamps it locally
  (N2307 unit() is the candidate) to avoid a key overwrite.

## Renumber

- **N2274 → N2320 (Radar updateTile), commit `4b69cc5`** (16 files, 2652+/2652-).
  Reserve N2320 by script first (status 'reserved', then 'done' after commit). Sed:
  register update_tile + fog_radius + draw + draw_select + draw_place (whole files)
  + test update_tile + test draw (whole files) + proof .gd (whole file) + GD
  `SourceRadarBuildState.gd` (whole file — 4 comment cross-refs, precedent round 5)
  + spec :320 (first occurrence only — the row label; the same line's "N2274 in
  round 5 (divergence #19...)" history KEPT) + GOAL :359. AGENTS.md: **0 hit** N2274,
  no edit needed.
- Script delete: ledger key + 1 contract + 2 schemas (input+result) +
  defense_api_contracts entry + defense_slices key. Asserted each delete count before
  proceeding (ledger 1737 → 1736, contracts 1685 → 1684, schemas 3161 → 3159).
- **Chain re-register 5 registers** in import order (update_tile → fog_radius → draw
  → draw_select → draw_place), --verify **36/36 + 13/13 + 18/18 + 14/14 + 20/20**.
  (The Radar chain is not one linear import chain — update_tile / fog_radius /
  progress derive DEFERRED from N2227, not from each other; N2274 spreads through
  literal strings + the draw import chain. progress / write_read / can_pickup were
  NOT re-run: 0 occurrences of N2274 in their sources and ledger entries.) Post-chain
  full-tree grep: N2274 = 0 in all generated JSON (N2320 = 15 occurrences) and 0 in
  code except the historical "N2274 in round 5" reference (spec :320, kept by
  precedent). No sibling rule-text stragglers (lesson #42 check). Targeted 20/20
  (240 subtests, 5 chain files); family Radar 40/40 (392); wiring 32/32 (250); proof
  C07RadarUpdateTileProof re-run in main, **10 keys** all true (7 domain + 3
  standard, counted from JSON). SSOT unchanged **11716/1737/1685/3161**. Done 1737.

## Gate

- **Gate #45 GREEN** on the chunked runner (PID 10688, log
  `hidden_files/full-suite-renumber-45-gate.log`): **Ran 6241, failures=237, errors=0,
  skipped=5, 364/364 modules** — 237 FAIL headers, all 237 `unexpectedly None`,
  0 ERROR (counted from the log by main thread). Renumber #45 is fully closed. No
  new restart since #40 (boot 06:28:31 +07).

## Docs (this commit)

- This report + handoff (round 24). Spec row + GOAL §5 number were already renumbered
  in the renumber commit 4b69cc5 (precedent rounds 7–23); GOAL scene hash stays
  `40e54d9` (the commit that first carried the scene to Windows — the renumber changed
  no scene content).

## Handoff / next

- **Renumber #46 NEXT:** local N2275 (Radar fogRadius, 10 exact_exprs, proof 9 keys)
  → **N2321**. Remote N2275 = TurretBuild.updateTile() unit maxHealth (4
  exact_exprs, origin 192a5bc). Number-only, overlap **0/4**. Probe:
  `hidden_files/divergence-46-n2275-renumber-impact.md` (chain re-register 5 — read
  the probe before starting). Reserve N2321 by script first (next_free_n is 2321 now).
- **Renumber #47:** local N2276 (Turret write/read/version, 25 exact_exprs, proof
  C07TurretWriteReadProof 11 keys all true) → **N2322**. Remote N2276 =
  TurretBuild.updateTile() unit health (4 exact_exprs, origin 5f0f72c, 5 commits: slice
  a5ccb08 + 4 docs). Number-only, overlap **0/4 exact_exprs**, 0 symbols, 0 tests
  (main thread re-verified from disk; N2320/N2321/N2322 free in both ledgers). Probe:
  `hidden_files/divergence-47-n2276-renumber-impact.md`.
- Order is strict: #46 → #47, one at a time, chunked gate + docs after each. Then
  spawn batch **N2323–N2325** (controlled() / DrillBuild.draw() base / 3 music
  getters), then **N2326–N2328** (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig /
  findMusic), then **N2329–N2331** (drawSelect / Drill.icons / play), then
  **N2332–N2334** (Turret shouldTurn / BurstDrill shouldConsume / Game reload — scope
  file `hidden_files/next-batch-scope-after-n2327.md` exists). Scope files need
  relabel after the renumber queue (labels on disk are TEMP, pre-#42):
  `next-batch-scope-after-n2315.md` +6 → N2323–N2325,
  `next-batch-scope-after-n2319.md` +6 → N2326–N2328,
  `next-batch-scope-after-n2323.md` +5 → N2329–N2331,
  `next-batch-scope-after-n2327.md` +3 → N2332–N2334. next_free_n after 4 renumbers
  + 4 batches = **2335**. Reserve by script + write spawn lock BEFORE spawning;
  worktrees from latest HEAD (after docs #47); brief includes editor-import uid_cache +
  port-7777-free check + Godot symlink check.
- allocations.json: N2320 done (4b69cc5), next_free_n **2321**. N2304 held (ambient C,
  waits for Windows B).
- Push from Windows: local ahead/behind origin/main 5f0f72c = **106 / 196** (counted
  2026-11-20 ~08:3x +07; recount at push time). Merge by hand in the spec at push
  time. No force-push. Merge-time flags: remote N2274 unit world position is new (no
  dedup; 1/10 overlap with local N2307 is a call-site line); remote N2273 charge
  effect is new (no dedup, first slice touching `TurretBuild.shoot()`); remote N2273
  vs remote N2271 (charge sound) are two sub-slices of the same `shoot()` — compare
  at merge; remote N2275 unit maxHealth vs local N2308 warmup — check overlap at
  merge (probe #46); remote N2276 unit health — check overlap at merge (probe #47);
  warmup ownership/dedup (remote N2253 vs local N2308, 15/34 exprs); remote recoil
  family N2254–N2258 complementary; remote N2258 vs local N741/N742; remote updateTile
  driver-tick family N2259–N2263 + N2265 + N2270 complementary; remote N2266
  targetPosition overlaps local N2122 (16/21 exprs) + needs hasAmmo (N2313, done) +
  peekAmmo (in batch N2326–N2328) owned before it merges; remote N2267 super.control()
  overlaps local N552/N553/N1088/N1089 (13/15 exprs); remote N2268 configured()
  overlaps local N544–N549/N1751/N1752 (23/26 exprs); remote N2269 queuedBullets/
  charging overlaps local N2308 (2/24 exprs); `SourceItemTurretBuildState.gd`
  both-modified; remote adds functions to SourceTurretBuildState.gd (plus local N2285
  status + N2297 accessors + N2307 unit() + N2313 hasAmmo()).
