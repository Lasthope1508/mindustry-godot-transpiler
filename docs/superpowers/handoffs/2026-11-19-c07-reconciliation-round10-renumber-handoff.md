# Handoff — reconciliation round 10 (renumber N2259 → N2300, divergence #30)

## Done
- **Renumber #30: local N2259 (ambient A, Game headless) → N2300, commit `1faeb9b`** (8 files,
  1802+/1802-). Sed 25 lines; delete ledger key + 1 contract + 2 schemas; chain re-register
  3 registers in import order (game_headless → sound_control_loop → should_play).
  --verify 7/7 + 88/88 + 12/12; targeted 12/12 (180); family Game 12/12 (180); wiring 32/32
  (250); proof C07GameHeadlessProof re-run in main, 6 keys all true. SSOT unchanged
  11696/1731/1679/3149. Done 1731.
- **Re-gate GREEN (PID 8681, ~14:39–14:57): Ran 6217 in 1084.276s, failures=231, skipped=5,
  0 errors** — all 231 `unexpectedly None`. Log `hidden_files/full-suite-renumber-30-gate.log`.
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round10-renumber.md`
  + this handoff. Spec row + GOAL §5 number already renumbered in 1faeb9b.
- **Divergence #31: NO action** (remote N2260, local has no N2260). Probe:
  `hidden_files/divergence-31-n2260-renumber-impact.md`.

## Next — renumber #32, then batch N2302–N2304
- **Renumber #32:** local N2261 (Turret estimateDps) → **N2301**. Remote N2261 = Turret
  logicControlTime decay (origin 965c45c). Number-only, overlap 0/6. Probe:
  `hidden_files/divergence-32-n2261-renumber-impact.md`. N2301 free in both ledgers (verified).
  Same rename-at-place technique; re-check the import chain against CURRENT HEAD before
  re-registering (round-10 lesson: the #30 probe missed the N2299 link + sound-control :130).
  Then re-gate + docs #32.
- **Batch N2302–N2304 scope** (`hidden_files/next-batch-scope-after-n2300-renumber30.md`,
  relabel N2301–N2303 → N2302–N2304 before use): Turret hasAmmo() (Turret.java:698-712) +
  `controlled()` (Turret.java:441-443, deferred from N2297), BurstDrill draw()
  (BurstDrillBuild.draw, biggest render slice — may split arrows/glow), Game
  SoundControl.isDark() (SoundControl.java:286-301). 3 different GD files → parallel OK.
  Reserve N2302–N2304 by script + write spawn lock BEFORE spawning; worktrees from latest HEAD
  (after docs #32); brief includes editor-import uid_cache + port-7777-free check + Godot
  symlink check + arc/mindustry-upstream symlinks in worktrees.
- allocations.json: N2300 done (1faeb9b), next_free_n 2301. N2264 still held (ambient C).
- Push from Windows: local ahead/behind origin/main 965c45c — recount at push time. Merge by hand
  in the spec at push time. No force-push.
