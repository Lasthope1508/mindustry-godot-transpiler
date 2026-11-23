# Reconciliation round 13 — renumber N2263 → N2303 (divergence #34)

## Divergence

- origin/main 3da46ae → **b1e981f** (6 commits: slice 7a5bbc8 + 5 docs — 1 fix-up docs commit
  extra vs the usual 5). Remote **N2263 = TurretBuild.updateTile() heatReq fold** (owner
  `source_turret_heat_req_state`, 10 exact_exprs, 2 symbols, 4 tests, proof "9 keys"
  commit-message only — no JSON in the remote tree; the probe counted 9 `heat_req_*` keys in the
  remote proof script) collides number-only with local **N2263 = RadarBuild.progress()**
  (owner `SourceRadarBuildState.source_radar_progress_state`, commit abf3dd0 batch N2261–N2263,
  proof C07RadarProgressProof **4 keys counted from JSON** when that batch merged). Overlap
  0/10 exact_exprs, 0/2 symbols, 0/4 tests. Different method, different GD file, different
  owner.
- Probe: `hidden_files/divergence-34-n2263-renumber-impact.md` (19.452 byte). N2303 free in both
  ledgers (verified twice: probe + main thread). Nuance (merge-time, not a renumber blocker):
  remote N2263 is the 5th slice of their updateTile driver-tick family (charge N2259 → unit sync
  N2260 → logicControlTime N2261 → rotate sync N2262 → heatReq N2263), complementary, no dedup;
  6/10 remote exact_exprs already appear in other local slices (N1213 setBars guard, N2265
  warmup params, N1921/N1922 calculateHeat) — evidence/shared fields, different owners, no
  dedup; warmup only consumes the folded value as a param, it does not recompute it. Local GD
  has no function `source_turret_heat_req_state` — merging remote adds a new function, no name
  clash.

## Renumber

- **N2263 → N2303 (Radar progress), commit `2d37ba5`** (15 files, 602+/602-). Reserve N2303
  by script first (status 'renumbering'). Sed: register progress (whole file) + test (9 lines)
  + proof .gd :22 + write_read alias/use/comment/deferred (4 lines) + 4 downstream deferred
  strings + spec :336 (first occurrence only — the batch label 'N2261–N2263' on the same line
  is history, not the row label) + GOAL :391. KEPT per round-4 precedent: docstrings
  (write_read :22, can_pickup :17) and test comments in other slices' test files.
- **Technical note (new):** the 5 downstream entries only carry a copied 'Windows Godot proof'
  debt string naming N2263 (a live deferred pointer, not prose); the only real import link is
  write_read importing DEFERRED from progress.
- **Lesson (new):** `--verify` only verifies, it does NOT write — the first --verify run wrote
  nothing (ledger still 1730 slices, N2303 absent). The register must be run plain
  (`python3 register_....py`, which calls `main()`) to write, then --verify again.
- **Side fix:** spec :334 batch label had become 'Batch N2301–N2263' from the #32 whole-line
  `/g` sed; restored to 'Batch N2261–N2263' in the same commit.
- Script delete: ledger key + 1 contract
  (`SourceRadarBuildState.source_radar_progress_state`) + 2 schemas + defense shard key +
  defense contract (Radar is a defense family — the shards DO contain it, unlike the Game slice
  in #30).
- Chain re-register **6 registers** in import order (progress → write_read → can_pickup → draw
  → draw_select → draw_place), --verify **10/10 + 26/26 + 6/6 + 18/18 + 14/14 + 20/20**;
  targeted 4/4 (27 subtests); family Radar 40/40 (392); wiring 32/32 (250); proof
  C07RadarProgressProof re-run in main, **4 keys** all true (counted from JSON — the file has 7
  keys including `matches` + `one_headquarter_per_ssot` + `registry_valid`).
- Key-by-key diff vs HEAD: only N2263 out / N2303 in; 5 downstream entries changed ONLY in
  `deferred_exprs`; 1 contract + 2 schemas + defense contract changed `source_slice`; defense
  shard key swapped. New N2303 entry byte-identical to old N2263 after the number swap. SSOT
  unchanged **11696/1731/1679/3149**. Done 1731.
- **Gate GREEN (PID 11165, ~17:07–17:25): Ran 6217 in 1073.529s, failures=231, skipped=5,
  0 errors** — counted from the log: 231 FAIL headers, all 231 `AssertionError: unexpectedly
  None` (Godot-absent), 0 ERROR headers, 0 other AssertionErrors. Log:
  `hidden_files/full-suite-renumber-34-gate.log` (154473 byte). No VM restart during the gate
  (uptime 1:53 at the 17:31 check).

## Docs (this commit)

- This report + handoff (round 13). Spec row + GOAL §5 number were already renumbered in the
  renumber commit 2d37ba5 (precedent rounds 7/8/9/10/11/12); GOAL scene hash stays `abf3dd0`
  (the commit that first carried the scene to Windows — the renumber changed no scene content).

## Handoff / next

- **Divergence #35 (already probed + verified by main thread from disk):** origin b1e981f →
  d2d8b6b (5 commits: slice 64c41a1 + 4 docs). Remote N2264 = Turret control() setters
  collides with the local HELD number N2264 (ambient C, allocations.json status 'held' — no
  ledger entry, no code). Plan: ambient C **N2264 → N2304** (reservations-only change in
  allocations.json, no sed/commit needed), then batch relabel +1. Do it after this docs commit,
  before reserving the batch.
- **Batch N2305–N2307 after that** (NOT N2304–N2306 — N2304 goes to ambient C): N2305
  BurstDrill `DrillBuild.shouldAmbientSound()` (Drill.java:252-254, pure gate) + N2306 Game
  `SoundControl.alwaysPlayMusic()` (SoundControl.java:266-268, 3 bool flags OR) + N2307 Turret
  `TurretBuild.unit()` (Turret.java:434-439, unit sync + return). Scope file:
  `hidden_files/next-batch-scope-after-n2306.md` (read-only probe; all 3 slices 0-hit
  exact-class in both ledgers — re-check labels N2305–N2307 before use, the file was written
  for N2307–N2309 labels).
- **Queue order (main-thread decision, from docs #33):** hasAmmo / BurstDrill draw / isDark →
  N2308–N2310; `controlled()` → N2311–N2313 (shares SourceTurretBuildState.gd with hasAmmo,
  cannot batch together). `shouldAmbientSound` is a Drill-local boolean predicate, NOT part of
  the ambient B/C chain — regular batch, no separate ambient track.
  `SourceSoundControlState.gd` exists (N2287 + N2299 merged), so N2306's home is settled.
- allocations.json: N2303 done (2d37ba5), next_free_n **2304** (fixed after renumber #34: the
  reserve step had forgotten to bump it from 2303). N2264 still held (ambient C, moves to
  N2304 next).
- Push from Windows: local ahead/behind origin/main d2d8b6b — recount at push time. Merge by hand
  in the spec at push time. No force-push. Merge-time flags: remote updateTile quintet (charge
  N2259 → unit sync N2260 → logicControlTime N2261 → rotate sync N2262 → heatReq N2263) plus
  control() setters N2264 is complementary, no dedup; remote N2263 shares evidence with local
  N1213/N2265/N1921/N1922; warmup ownership/dedup (remote N2253 vs local N2265) still open;
  remote recoil family N2254+N2255+N2256+N2257+N2258 complementary, no dedup; remote N2258 vs
  local N741/N742 (PortGame-era recoilOffset evidence) still open; `SourceItemTurretBuildState.gd`
  both-modified; remote adds 12 functions to SourceTurretBuildState.gd that local lacks (plus
  local N2285 status + N2297 accessors when merging).
