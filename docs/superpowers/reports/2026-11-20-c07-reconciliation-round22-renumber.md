# Reconciliation round 22 — renumber N2272 → N2318 (divergence #43)

## Divergence

- origin/main b21b55f → **c9ab307** (5 commits: slice 5968f4f + 4 docs). Remote **N2272 =
  TurretBuild.canConsume() — heat gate** (owner
  `SourceTurretBuildState.source_turret_can_consume_heat_gate_state`, 11 exact_exprs, 1
  symbol, 4 tests, proof "11 keys" commit-message only — remote tree has the .gd + .tscn
  but NO proof JSON) collides number-only with local **N2272 = RadarBuild.canPickup()**
  (owner `SourceRadarBuildState.source_radar_can_pickup_state`, commit 52c7854, 4
  exact_exprs, 1 symbol, 4 tests, proof C07RadarCanPickupProof **6 keys** all true,
  counted from JSON). Overlap **1/4 exact_exprs — only `return false;`** (boilerplate),
  0 symbols, 0 tests. Different method, different GD file, different proof.
- Probe: `hidden_files/divergence-43-n2272-renumber-impact.md` (46 occurrences / 45 lines
  / 15 files; main thread re-verified the collision from disk: remote ledger 1721 → 1722,
  added key only N2272; local N2272 still present, N2318 free in both ledgers). Nuance
  (merge-time, not a renumber blocker): remote N2272's guard logic is already folded
  inline in local N2308 (warmup GD:384-385, `can_consume` from heat_requirement/heat_req)
  — 4/11 exprs overlap with local N2308; dedup decision at merge (replace the inline fold
  with the pure function, or keep both). Local GD has no
  `source_turret_can_consume_heat_gate_state` — merging remote adds a new function.

## Renumber

- **N2272 → N2318 (Radar canPickup), commit `837d31b`** (13 files, 898+/898-).
  Reserve N2318 by script first (status 'renumbering'). Sed: register can_pickup + test
  can_pickup + proof .gd (whole files) + register draw + draw_select + draw_place
  (whole files — the draw register carries the `N2272_DEFERRED` import alias + debt-list
  comment) + spec :342 (first occurrence only — the row label; the same line's "Batch
  N2271–N2273" history KEPT) + GOAL :403. AGENTS.md: **0 hit** N2272, no edit needed.
  No GD code file mentions N2272 (only the proof comment) — unlike #42, which touched 2
  GD files.
- Script delete: ledger key + 1 contract + 2 schemas (input+result) +
  defense_api_contracts entry + defense_slices key. Asserted each delete count before
  proceeding (ledger 1737 → 1736, contracts 1685 → 1684, schemas 3161 → 3159).
- **Chain re-register 4 registers** in import order (canPickup → draw → drawSelect →
  drawPlace), --verify **6/6 + 18/18 + 14/14 + 20/20**. Post-chain full-tree grep: N2272
  = 0 in all generated JSON (N2318 = 17 occurrences, matching the probe exactly) and 0
  in code — no sibling rule-text stragglers this time (unlike #42, where drill_sense +
  radar_draw_place needed extra re-runs). Targeted 16/16 (135 subtests, 4 test files
  incl. the 4 chain slices); family Radar 40/40 (392); wiring 32/32 (250); proof
  C07RadarCanPickupProof re-run in main, **6 keys** all true (3 domain + 3 standard,
  counted from JSON). SSOT unchanged **11716/1737/1685/3161**. Done 1737.
- **Gate #43 RUNNING (PID 7378, launch ~04:27, log
  `hidden_files/full-suite-renumber-43-gate.log`)** — renumber commit is in, gate launched
  with `disown`; result to be verified from the log when it finishes (expect Ran 6241,
  failures 237 Godot-absent, skipped 5, 0 errors — renumber changes no test count).

## Docs (this commit)

- This report + handoff (round 22). Spec row + GOAL §5 number were already renumbered in
  the renumber commit 837d31b (precedent rounds 7–21); GOAL scene hash stays `52c7854`
  (the commit that first carried the scene to Windows — the renumber changed no scene
  content).

## Handoff / next

- **Renumber #44 NEXT (after gate #43 is green):** local N2273 (Turret trackingRange,
  99a4c9f, proof 10 keys) → **N2319**. Remote N2273 = TurretBuild.shoot() —
  charge-effect part (origin 34c947c). Number-only, overlap **0/13 exact_exprs**, 0
  symbols, 0 tests. Probe: `hidden_files/divergence-44-n2273-renumber-impact.md` (68
  occurrences / 56 lines / 18 files, chain re-register 8: trackingRange → writeRead →
  isActive → minRange → status → microAccessors → unit → hasAmmo). Head of the Turret
  DEFERRED chain. Reserve N2319 by script first (next_free_n is 2319 now). After the
  chain, grep the old number in the generated JSON too (lesson #42). Then re-gate + docs
  #44.
- **Batch after #43+#44 is N2320–N2322** (`controlled()` / DrillBuild.draw() base / 3
  music getters), then **N2323–N2325** (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig
  / findMusic), then **N2326–N2328** (drawSelect / Drill.icons / play), then
  **N2329–N2331** (Turret shouldTurn / BurstDrill shouldConsume / Game reload — scope
  file `hidden_files/next-batch-scope-after-n2327.md` already exists, 26002 byte, labels
  TEMP N2329–N2331, written by the scope agent at ~04:15). Scope files:
  `hidden_files/next-batch-scope-after-n2315.md`,
  `hidden_files/next-batch-scope-after-n2319.md`,
  `hidden_files/next-batch-scope-after-n2323.md` — labels TEMP, relabel +3 after
  #42/#43/#44 (the relabel was never applied to disk, so the shift is +3 from the labels
  currently on disk). next_free_n after both renumbers + 4 batches = 2332. Reserve by
  script + write spawn lock BEFORE spawning; worktrees from latest HEAD (after docs #44);
  brief includes editor-import uid_cache + port-7777-free check + Godot symlink check.
- allocations.json: N2318 done (837d31b), next_free_n **2319** (before #44 reserve).
  N2304 held (ambient C, waits for Windows B).
- Push from Windows: local ahead/behind origin/main 34c947c — recount at push time. Merge by
  hand in the spec at push time. No force-push. Merge-time flags: remote N2272 canConsume
  gate overlaps local N2308 (4/11 exprs); remote N2273 charge effect is new (no dedup,
  first slice touching `TurretBuild.shoot()`); remote N2273 vs remote N2271 (charge sound,
  #42) are two sub-slices of the same `shoot()` — compare at merge; warmup
  ownership/dedup (remote N2253 vs local N2308, 15/34 exprs); remote recoil family
  N2254–N2258 complementary; remote N2258 vs local N741/N742; remote updateTile
  driver-tick family N2259–N2263 + N2265 + N2270 complementary; remote N2266 targetPosition
  overlaps local N2122 (16/21 exprs) + needs hasAmmo (N2313, done) + peekAmmo (T6) owned
  before it merges; remote N2267 super.control() overlaps local N552/N553/N1088/N1089
  (13/15 exprs); remote N2268 configured() overlaps local N544–N549/N1751/N1752 (23/26
  exprs); remote N2269 queuedBullets/charging overlaps local N2308 (2/24 exprs);
  `SourceItemTurretBuildState.gd` both-modified; remote adds functions to
  SourceTurretBuildState.gd (plus local N2285 status + N2297 accessors + N2307 unit() +
  N2313 hasAmmo()).
