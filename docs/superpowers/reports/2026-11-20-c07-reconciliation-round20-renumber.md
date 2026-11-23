# Reconciliation round 20 — renumber N2271 → N2317 (divergence #42)

## Divergence

- origin/main 683f89a → **b21b55f** (5 commits: slice a66bf63 + 4 docs). Remote **N2271 =
  TurretBuild.shoot() — charge sound state** (owner
  `SourceTurretBuildState.source_turret_charge_sound_state`, 12 exact_exprs, 3 symbols, 4
  tests, proof "8 keys" commit-message only — remote tree has the .gd + .tscn but NO proof
  JSON) collides number-only with local **N2271 = BurstDrillBuild.ambientVolume()** (owner
  `SourceBurstDrillBuildState.source_burst_drill_ambient_volume_state`, commit 69751d1,
  8 exact_exprs, 1 symbol, 4 tests, proof C07BurstDrillAmbientVolumeProof **8 keys** all
  true, counted from JSON). Overlap **0/8 exact_exprs, 0 symbols, 0 tests**. Different
  method, different GD file, different proof.
- Probe: `hidden_files/divergence-42-n2271-renumber-impact.md` (116 occurrences / 107
  lines / 38 files; main thread re-verified the collision from disk: remote ledger 1720
  → 1721, added key only N2271; local N2271 still present, N2317 free in both ledgers).
  Nuance (merge-time, not a renumber blocker): remote N2271 is a pure function
  (3 keys `first_shot_delay` / `charge_sound` / `charge_emitted`, guard
  `firstShotDelay > 0`; only lancer sets firstShotDelay=40f + chargeSound=Sounds.chargeLancer,
  Blocks.java:3564/:3579). Local GD has no `source_turret_charge_sound_state` — merging
  remote adds a new function, no dedup; `chargeEffect` (Turret.java:749) stays deferred
  for its own slice. Remote N2271 does NOT touch `charging()` (that was #40).

## Renumber

- **N2271 → N2317 (BurstDrill ambientVolume), commit `5298682`** (26 files, 831+/831-).
  Reserve N2317 by script first (status 'renumbering'). Sed: register ambient_volume +
  drill_ambient_volume + drill_should_ambient_sound (whole files) + test ambient_volume
  (whole file) + proof BurstDrillAmbientVolume .gd (whole file) + line-targeted seds:
  drill_sense register :39/:101/:112, radar_draw_place register :23/:103, drill_set_stats
  register :50, drill_draw_select register :44, burst_drill_write_read register :47,
  tests drill_ambient_volume :31/:33, drill_sense :48/:141, radar_draw_place :38, GD
  SourceBurstDrillBuildState.gd :323/:335/:556/:568 (with /g — :323 carries 2 mentions),
  SourceRadarBuildState.gd :151, proofs C07DrillAmbientVolumeProof.gd :36/:38 +
  C07DrillSenseProof.gd :40 + spec :341 (first occurrence only — the row label; the same
  line's "Batch N2271–N2273" history KEPT) + GOAL :401. AGENTS.md:90 keeps the N2271
  history string (old worktree note, kept per precedent).
- Script delete: ledger key + 1 contract + 2 schemas (input+result) +
  production_api_contracts entry + production_slices key. Asserted each delete count
  before proceeding (ledger 1737 → 1736, contracts 1685 → 1684, schemas 3161 → 3159).
- **Chain re-register 5 registers** in import order (setStats N2309 → ambientVolume →
  Drill.ambientVolume N2277 → shouldAmbientSound N2305 → write/read), --verify
  **26/26 + 11/11 + 11/11 + 20/20 + 28/28**. Then the post-chain full-tree grep found
  **5 more N2271 occurrences in rule text** of schemas/registry owned by drill_sense
  (N2298) and radar_draw_place (N2284) — re-ran both registers (31/31 + 20/20) → N2271 =
  0 in all generated JSON. Lesson (extends #41): after a chain re-register, grep the old
  number in the generated JSON too, not just the ledger — sibling registers that were
  only comment-sedded still carry the old number in their schema rule text.
- Targeted 16/16 (158 subtests, 4 test files incl. the 4 chain slices); family
  BurstDrill+Drill 64/64 (1125); wiring 32/32 (250); proof
  C07BurstDrillAmbientVolumeProof re-run in main, **8 keys** all true (counted from JSON).
  Ledger N2271 = 0, N2317 = 31 occurrences in generated JSON (probe said 29 lines — the
  count differs because re-runs rewrote sibling rule text too). SSOT unchanged
  **11716/1737/1685/3161**. Done 1737.
- **Gate #42 RUNNING (PID 5722, launch ~03:20, log
  `hidden_files/full-suite-renumber-42-gate.log`)** — renumber commit is in, gate launched
  with `disown`; result to be verified from the log when it finishes (expect Ran 6241,
  failures 237 Godot-absent, skipped 5, 0 errors — renumber changes no test count).

## Docs (this commit)

- This report + handoff (round 20). Spec row + GOAL §5 number were already renumbered in
  the renumber commit 5298682 (precedent rounds 7–19); GOAL scene hash stays `69751d1`
  (the commit that first carried the scene to Windows — the renumber changed no scene
  content).

## Handoff / next

- **Renumber #43 NEXT (after gate #42 is green):** local N2272 (Radar canPickup,
  52c7854, proof 6 keys) → **N2318**. Remote N2272 = TurretBuild.canConsume() heat gate
  (origin c9ab307). Number-only, overlap **1/4 exact_exprs — only `return false;`**
  (boilerplate), 0 symbols, 0 tests. Probe:
  `hidden_files/divergence-43-n2272-renumber-impact.md` (46 occurrences / 45 lines / 15
  files, chain re-register 4: canPickup → draw → drawSelect → drawPlace). Head of the
  Radar DEFERRED chain. Reserve N2318 by script first (next_free_n is 2318 now).
  Merge-time: remote N2272's guard logic is already folded inline in local N2308 (warmup
  GD:384-385, `can_consume` from heat_requirement/heat_req) — 4/11 exprs overlap with
  local N2308; dedup decision at merge (replace the inline fold with the pure function,
  or keep both).
- **Batch after #43 is N2319–N2321** (`controlled()` / DrillBuild.draw() base / 3 music
  getters), then **N2322–N2324** (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig /
  findMusic), then **N2325–N2327** (drawSelect / Drill.icons / play). Scope files:
  `hidden_files/next-batch-scope-after-n2315.md`,
  `hidden_files/next-batch-scope-after-n2319.md`,
  `hidden_files/next-batch-scope-after-n2323.md` — labels TEMP, relabel +2 after #42/#43
  (the relabel for #42 alone was never applied to disk, so the shift is +2 from the
  labels currently on disk). next_free_n after both renumbers + 3 batches = 2328. Reserve
  by script + write spawn lock BEFORE spawning; worktrees from latest HEAD (after docs
  #43); brief includes editor-import uid_cache + port-7777-free check + Godot symlink check.
- allocations.json: N2317 done (5298682), next_free_n **2318** (before #43 reserve).
  N2304 held (ambient C, waits for Windows B).
- Push from Windows: local ahead/behind origin/main c9ab307 — recount at push time. Merge by
  hand in the spec at push time. No force-push. Merge-time flags: remote N2271 charge sound
  is new (no dedup); remote N2272 canConsume gate overlaps local N2308 (4/11 exprs);
  warmup ownership/dedup (remote N2253 vs local N2308, 15/34 exprs); remote recoil family
  N2254–N2258 complementary; remote N2258 vs local N741/N742; remote updateTile
  driver-tick family N2259–N2263 + N2265 + N2270 complementary; remote N2266 targetPosition
  overlaps local N2122 (16/21 exprs) + needs hasAmmo (N2313, done) + peekAmmo (T6) owned
  before it merges; remote N2267 super.control() overlaps local N552/N553/N1088/N1089
  (13/15 exprs); remote N2268 configured() overlaps local N544–N549/N1751/N1752 (23/26
  exprs); remote N2269 queuedBullets/charging overlaps local N2308 (2/24 exprs);
  `SourceItemTurretBuildState.gd` both-modified; remote adds functions to
  SourceTurretBuildState.gd (plus local N2285 status + N2297 accessors + N2307 unit() +
  N2313 hasAmmo()).
