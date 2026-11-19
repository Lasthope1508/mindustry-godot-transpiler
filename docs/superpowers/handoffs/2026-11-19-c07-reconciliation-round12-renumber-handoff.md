# Handoff — reconciliation round 12 (renumber N2262 → N2302, divergence #33)

## Done
- **Renumber #33: local N2262 (BurstDrill onProximityUpdate) → N2302, commit `314d381`** (12
  files, 1851+/1851-). Sed 26 lines; delete ledger key + 1 contract + 2 schemas + production
  shard key + production contract; chain re-register 7 registers in import order
  (on_proximity_update → set_stats → ambient_volume + drill_set_stats → drill_ambient_volume →
  burst_drill_write_read + drill_draw_select). --verify 49/49 + 26/26 + 11/11 + 54/54 + 11/11 +
  28/28 + 32/32; targeted 4/4 (108); family BurstDrill+Drill 56/56 (922); wiring 32/32 (250);
  proof C07BurstDrillOnProximityUpdateProof re-run in main, 11 keys all true. SSOT unchanged
  11696/1731/1679/3149. Done 1731.
- **Gate GREEN (PID 6232, ~16:22–16:40): Ran 6217 in 1079.997s, failures=231, skipped=5,
  0 errors** — all 231 `unexpectedly None`. Log `hidden_files/full-suite-renumber-33-gate.log`.
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round12-renumber.md`
  + this handoff. Spec row + GOAL §5 number already renumbered in 314d381.

## Next — renumber #34, then batch N2304–N2306
- **Renumber #34:** local N2263 (Radar progress) → **N2303**. Remote N2263 = Turret heatReq
  fold (origin b1e981f). Number-only, overlap 0/10. Probe:
  `hidden_files/divergence-34-n2263-renumber-impact.md`. N2303 free in both ledgers (verified).
  Same rename-at-place technique; re-check the import chain against CURRENT HEAD before
  re-registering (round-10 lesson: the #30 probe missed the N2299 link + sound-control :130).
  Then re-gate + docs #34.
- **Batch N2304–N2306 scope** (`hidden_files/next-batch-scope-after-renumber-34.md`):
  N2304 BurstDrill shouldAmbientSound + N2305 Game alwaysPlayMusic + N2306 Turret unit().
  3 different GD files → parallel OK. Reserve N2304–N2306 by script + write spawn lock BEFORE
  spawning; worktrees from latest HEAD (after docs #34); brief includes editor-import uid_cache
  + port-7777-free check + Godot symlink check + arc/mindustry-upstream symlinks in worktrees.
- **Queue order (main-thread decision):** hasAmmo / BurstDrill draw / isDark stays for
  N2307–N2309; `controlled()` goes to N2310–N2312 (shares SourceTurretBuildState.gd with
  hasAmmo, cannot batch together). shouldAmbientSound is a Drill-local predicate, not ambient
  B/C — regular batch, no separate ambient track.
- allocations.json: N2302 done (314d381), next_free_n 2303. N2264 still held (ambient C).
- Push from Windows: local ahead/behind origin/main b1e981f — recount at push time. Merge by
  hand in the spec at push time. No force-push.
