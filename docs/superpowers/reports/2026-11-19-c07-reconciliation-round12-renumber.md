# Reconciliation round 12 — renumber N2262 → N2302 (divergence #33)

## Divergence

- origin/main 965c45c → **3da46ae** (5 commits: slice f97d8dc + 4 docs). Remote **N2262 =
  TurretBuild.updateTile() rotate sync** (owner `source_turret_rotate_sync_state`, 6
  exact_exprs, 1 symbol, 4 tests, proof "9 keys" commit-message only — no JSON in the remote
  tree) collides number-only with local **N2262 = DrillBuild.onProximityUpdate()** (BurstDrill
  ore/dominant binding, commit e994170 batch N2261–N2263, proof C07BurstDrillOnProximityUpdateProof
  **11 keys counted from JSON** when that batch merged). Overlap 0/6 exact_exprs, 0/1 symbols,
  0/4 tests. Different method, same GD file family only by coincidence (Turret vs BurstDrill),
  different owner.
- Probe: `hidden_files/divergence-33-n2262-renumber-impact.md` (15.888 byte). N2302 free in both
  ledgers (verified twice: probe + main thread). Nuance (merge-time, not a renumber blocker):
  remote N2262 is the 4th slice of their updateTile driver-tick family (charge N2259 → unit sync
  N2260 → logicControlTime N2261 → rotate sync N2262), complementary, no dedup; local GD has no
  function `source_turret_rotate_sync_state` — merging remote adds a new function, no name clash.

## Renumber

- **N2262 → N2302 (BurstDrill onProximityUpdate), commit `314d381`** (12 files, 1851+/1851-).
  Reserve N2302 by script first (status 'renumbering', next_free_n → 2303). Sed 26 lines:
  register on_proximity_update (9) + test (9) + set_stats register alias/use/comment (4) +
  draw_select DEFERRED string (1) + proof .gd (1) + spec :335 (whole line) + GOAL :389.
  KEPT per round-4 precedent: docstrings "(the same family file N2149 / N2256 / N2258 / N2269 /
  N2262)" in other slices' registers, schema rules "set by the N2262 ore/dominant binding",
  GD comments in other slices' functions, spec :333 round-4 history line, spec :357 provenance
  line, historical docs.
- **Technical note (new):** drawSelect defines its DEFERRED string locally (no import), so its own
  deferred string naming the N2262 binding had to be sedded by hand — a live pointer, not prose.
  `production_state_schema.json` keeps its 2 N2262 mentions (rule strings in the N2283/N2298
  schemas, not `source_slice`).
- Script delete: ledger key + 1 contract
  (`SourceBurstDrillBuildState.source_burst_drill_on_proximity_update_state`) + 2 schemas +
  production shard key + production contract (BurstDrill is a production family — the shards DO
  contain it, unlike the Game slice in #30).
- Chain re-register **7 registers** in import order (on_proximity_update → set_stats →
  ambient_volume + drill_set_stats → drill_ambient_volume → burst_drill_write_read +
  drill_draw_select), --verify **49/49 + 26/26 + 11/11 + 54/54 + 11/11 + 28/28 + 32/32**;
  targeted 4/4 (108 subtests); family BurstDrill+Drill 56/56 (922); wiring 32/32 (250); proof
  C07BurstDrillOnProximityUpdateProof re-run in main, **11 keys** all true (counted from JSON —
  the file has 11 keys including `matches`).
- Key-by-key diff vs HEAD: only N2262 out / N2302 in; 6 downstream entries changed ONLY in
  `deferred_exprs`; 1 contract + 2 schemas + production contract changed `source_slice`;
  production shard key swapped. New N2302 entry byte-identical to old N2262 after the number
  swap. SSOT unchanged **11696/1731/1679/3149**. Done 1731.
- **Gate GREEN (PID 6232, ~16:22–16:40): Ran 6217 in 1079.997s, failures=231, skipped=5,
  0 errors** — counted from the log: 231 FAIL headers, all 231 `AssertionError: unexpectedly
  None` (Godot-absent), 0 ERROR headers, 0 other AssertionErrors. Log:
  `hidden_files/full-suite-renumber-33-gate.log` (154473 byte). No VM restart during the gate
  (uptime 1:16 at the 16:54 check).

## Docs (this commit)

- This report + handoff (round 12). Spec row + GOAL §5 number were already renumbered in the
  renumber commit 314d381 (precedent rounds 7/8/9/10/11); GOAL scene hash stays `e994170` (the
  commit that first carried the scene to Windows — the renumber changed no scene content).

## Handoff / next

- **Divergence #34 (already probed + verified by main thread from disk):** origin 3da46ae →
  b1e981f (6 commits: slice 7a5bbc8 + 5 docs — 1 fix-up docs commit extra vs the usual 5).
  Remote N2263 = Turret heatReq fold collides number-only with local N2263 = Radar progress
  (overlap 0/10 exact_exprs, 0/2 symbols). Probe:
  `hidden_files/divergence-34-n2263-renumber-impact.md`. Plan: local **N2263 → N2303**
  (free in both ledgers, verified; next_free_n 2303) — renumber #34, same rename-at-place
  technique, then re-gate + docs #34.
- **Batch N2304–N2306 after that** (NOT N2303–N2305 — N2303 goes to renumber #34):
  N2304 BurstDrill `DrillBuild.shouldAmbientSound()` (Drill.java:252-254, pure gate:
  efficiency > 0.01 && items.total() < itemCapacity, params explicit) + N2305 Game
  `SoundControl.alwaysPlayMusic()` (SoundControl.java:266-268, 3 bool flags OR) + N2306 Turret
  `TurretBuild.unit()` (Turret.java:434-439, unit sync + return). Scope file:
  `hidden_files/next-batch-scope-after-renumber-34.md` (read-only probe, 16:49–16:54; all 3
  slices 0-hit exact-class in both ledgers, 0 overlap with remote N2259–N2263).
- **Main-thread decision on the queue-jump flag (§2 #4 of that scope file):** the older
  hasAmmo / BurstDrill draw / isDark trio stays queued for the batch AFTER (N2307–N2309 =
  hasAmmo Turret + BurstDrill draw + isDark Game; `controlled()` goes to the batch after that,
  N2310–N2312, because hasAmmo and controlled() share SourceTurretBuildState.gd and cannot run
  in one batch). `shouldAmbientSound` is a Drill-local boolean predicate, NOT part of the
  ambient B/C chain (B = RepairTurret driver tick, Windows line; C = SoundControl.updateLoops
  mixer, N2264 held) — it stays in the regular batch, no separate ambient track needed.
  `SourceSoundControlState.gd` exists (N2287 + N2299 merged), so N2305's home is settled.
- allocations.json: N2302 done (314d381), next_free_n **2303**. N2264 still held (ambient C).
- Push from Windows: local ahead/behind origin/main b1e981f — recount at push time (cron
  16:45 counted 75 ahead / 122 behind). Merge by hand in the spec at push time. No force-push.
  Merge-time flags: remote updateTile quintet (charge N2259 → unit sync N2260 →
  logicControlTime N2261 → rotate sync N2262 → heatReq N2263) is complementary, no dedup;
  remote N2262/N2263 share evidence with local N742/N2270/N2297 (evidence only); warmup
  ownership/dedup (remote N2253 vs local N2265) still open; remote recoil family
  N2254+N2255+N2256+N2257+N2258 complementary, no dedup; remote N2258 vs local N741/N742
  (PortGame-era recoilOffset evidence) still open; `SourceItemTurretBuildState.gd`
  both-modified; remote adds 11 functions to SourceTurretBuildState.gd that local lacks (plus
  local N2285 status + N2297 accessors when merging).
