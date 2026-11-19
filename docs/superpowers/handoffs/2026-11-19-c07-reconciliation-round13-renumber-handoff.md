# Handoff — reconciliation round 13 (renumber N2263 → N2303, divergence #34)

## Done
- **Renumber #34: local N2263 (Radar progress) → N2303, commit `2d37ba5`** (15 files,
  602+/602-). Sed: register progress + test + proof .gd + write_read alias/use/comment/deferred
  + 4 downstream deferred strings + spec :336 (first occurrence only) + GOAL :391; also
  restored the #32-corrupted spec :334 batch label to 'Batch N2261–N2263'. Delete ledger key +
  1 contract + 2 schemas + defense shard key + defense contract; chain re-register 6 registers
  in import order (progress → write_read → can_pickup → draw → draw_select → draw_place).
  --verify 10/10 + 26/26 + 6/6 + 18/18 + 14/14 + 20/20; targeted 4/4 (27); family Radar 40/40
  (392); wiring 32/32 (250); proof C07RadarProgressProof re-run in main, 4 keys all true.
  SSOT unchanged 11696/1731/1679/3149. Done 1731.
- **Gate GREEN (PID 11165, ~17:07–17:25): Ran 6217 in 1073.529s, failures=231, skipped=5,
  0 errors** — all 231 `unexpectedly None`. Log `hidden_files/full-suite-renumber-34-gate.log`.
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round13-renumber.md`
  + this handoff. Spec row + GOAL §5 number already renumbered in 2d37ba5.

## Next — ambient C move, then batch N2305–N2307
- **Ambient C move:** N2264 (held) → **N2304** in allocations.json only (remote N2264 = Turret
  control() setters, origin d2d8b6b). No ledger entry, no code — reservations-only change by
  script. Then next_free_n → 2305.
- **Batch N2305–N2307 scope** (`hidden_files/next-batch-scope-after-n2306.md` — written for
  N2307–N2309 labels, relabel to N2305–N2307 before use): N2305 BurstDrill
  shouldAmbientSound + N2306 Game alwaysPlayMusic + N2307 Turret unit(). 3 different GD files
  → parallel OK. Reserve N2305–N2307 by script + write spawn lock BEFORE spawning; worktrees
  from latest HEAD (after docs #34); brief includes editor-import uid_cache + port-7777-free
  check + Godot symlink check + arc/mindustry-upstream symlinks in worktrees.
- **Queue order (main-thread decision):** hasAmmo / BurstDrill draw / isDark → N2308–N2310;
  `controlled()` → N2311–N2313 (shares SourceTurretBuildState.gd with hasAmmo, cannot batch
  together). shouldAmbientSound is a Drill-local predicate, not ambient B/C — regular batch.
- allocations.json: N2303 done (2d37ba5), next_free_n 2304. N2264 held (ambient C, moves to
  N2304 next).
- Push from Windows: local ahead/behind origin/main d2d8b6b — recount at push time. Merge by
  hand in the spec at push time. No force-push.
