# Handoff — reconciliation round 11 (renumber N2261 → N2301, divergence #32)

## Done
- **Renumber #32: local N2261 (Turret estimateDps) → N2301, commit `71a8fd1`** (11 files,
  288+/288-). Sed 25 lines; delete ledger key + 1 contract + 2 schemas + defense shard key +
  defense contract; chain re-register 9 registers in import order (estimate_dps → warmup →
  find_target → tracking_range → write_read → is_active → min_range → status →
  micro_accessors). --verify 20/20 + 44/44 + 87/87 + 18/18 + 36/36 + 17/17 + 16/16 + 25/25 +
  28/28; targeted 4/4 (40); family Turret 56/56 (791); wiring 32/32 (250); proof
  C07TurretEstimateDpsProof re-run in main, 7 keys all true. SSOT unchanged
  11696/1731/1679/3149. Done 1731.
- **VM restart #30 ~15:38** killed the first gate (PID 12911, ~98.6%, no summary). Main thread
  recreated the wiped `/usr/local/bin/godot` symlink, verified Godot 4.6.2 + javalang + pytest,
  and re-ran the gate immediately (PID 2148, ~15:41–15:59).
- **Re-gate GREEN (PID 2148): Ran 6217 in 1069.317s, failures=231, skipped=5, 0 errors** — all
  231 `unexpectedly None`. Log `hidden_files/full-suite-renumber-32-gate.log`.
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round11-renumber.md`
  + this handoff. Spec row + GOAL §5 number already renumbered in 71a8fd1.

## Next — renumber #33, then batch N2303–N2305
- **Renumber #33:** local N2262 (BurstDrill onProximityUpdate) → **N2302**. Remote N2262 =
  Turret rotate sync (origin 3da46ae). Number-only, overlap 0/6. Probe:
  `hidden_files/divergence-33-n2262-renumber-impact.md`. N2302 free in both ledgers (verified).
  Same rename-at-place technique; re-check the import chain against CURRENT HEAD before
  re-registering (round-10 lesson: the #30 probe missed the N2299 link + sound-control :130).
  Then re-gate + docs #33.
- **Batch N2303–N2305 scope** (`hidden_files/next-batch-scope-after-n2300-renumber30.md`,
  relabel N2301–N2303 → N2303–N2305 before use): Turret hasAmmo() + `controlled()` (deferred
  from N2297), BurstDrill draw(), Game SoundControl.isDark(). 3 different GD files → parallel
  OK. Reserve N2303–N2305 by script + write spawn lock BEFORE spawning; worktrees from latest
  HEAD (after docs #33); brief includes editor-import uid_cache + port-7777-free check + Godot
  symlink check + arc/mindustry-upstream symlinks in worktrees.
- allocations.json: N2301 done (71a8fd1), next_free_n 2302. N2264 still held (ambient C).
- Push from Windows: local ahead/behind origin/main 3da46ae — recount at push time. Merge by hand
  in the spec at push time. No force-push.
