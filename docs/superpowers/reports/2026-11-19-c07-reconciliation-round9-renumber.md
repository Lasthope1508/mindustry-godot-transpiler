# Reconciliation round 9 — renumber N2258 → N2296 (divergence #29)

## Divergence

- origin/main b02d14d → **e9dfee4** (5 commits: slice 0ba552b + 4 docs). Remote **N2258 =
  TurretBuild.updateTile() recoilOffset draw** (owner `source_turret_recoil_offset_state`, 5
  exact_exprs, 1 symbol `source_turret_recoil_offset_state_result.recoil_offset`, proof "8 keys"
  commit-message only — no JSON in the remote tree) collides number-only with local **N2258 =
  BurstDrillBuild.updateTile() liquid rows** (45 exact_exprs, 9 symbols, proof
  C07BurstDrillLiquidRowsProof **12 keys counted from disk**). Overlap 0/5 exact_exprs, 0 symbols.
  Different class, GD file, owner.
- Probe: `hidden_files/divergence-29-n2258-renumber-impact.md` (18.006 byte, read-only agent).
  Chain re-register 8 entries, all BurstDrill/Drill. N2296 free in both ledgers.
- Nuance (merge-time, not a renumber blocker): remote N2258 re-promotes a formula already in local
  N741/N742 (PortGame-era recoilOffset evidence) — decide dedup when merging remote. Remote N2258
  vs local N2258: no real scope overlap.

## Renumber

- **N2258 → N2296 (BurstDrill liquid rows), commit `6df3b1f`** (13 files, 1171+/1171-).
  Reserve N2296 by script first (status 'renumbering'). Sed: register liquid_rows (8 mentions) +
  icons (6, incl. alias `N2258_DEFERRED` → `N2296_DEFERRED`) + test (9) + 2 proof .gd + GD
  4 precedent lines + spec :330 (whole line) + GOAL :379. KEPT per round-4 precedent: spec :335
  prose (N2262 row), ledger N2259 range prose `N2248-N2258`, register/docstring prose of other
  slices, historical docs. Script delete: ledger key + 1 contract + 2 schemas + production shards
  (`production_slices.json` slices.N2258, `production_api_contracts.json` contract); defense shards
  verified absent (production slice). Chain re-register 7 registers in import order
  (icons → on_proximity_update → set_stats → ambient_volume + drill_set_stats →
  drill_ambient_volume → write_read). Key-by-key diff vs HEAD: only N2258 out / N2296 in, 7
  downstream entries changed ONLY in `deferred_exprs`, new entry byte-identical to old after the
  number swap. Ledger diff is large (1836 lines) only from key reorder — verified semantically.
- Verify: --verify liquid_rows 58/58 + chain (13/13, 49/49, 26/26, 11/11, 54/54, 11/11, 28/28);
  targeted 4/4 (141 subtests); family BurstDrill+Drill 52/52 (864); wiring 32/32 (250); proof
  C07BurstDrillLiquidRowsProof **12 keys** all true (counted from JSON). SSOT unchanged
  **11685/1728/1671/3133**. allocations.json: N2296 done, next_free_n **2297**.
- **VM restart #28 ~11:38** (uptime 0 min, mid-wiring-run): Godot symlink recreated + verified
  4.6.2/javalang/pytest 9.2.0; wiring re-run green in one pass. No work lost (family had already
  finished 52/52 before the restart).

## Re-gate — GREEN

- Full gate (main thread, PID 2679, ~11:47–12:09): **Ran 6205 in 1303.234s, failures=228,
  skipped=5, 0 errors** — counted from the log: 228 FAIL headers, all 228
  `AssertionError: unexpectedly None` (Godot-absent), 0 ERROR headers, 0 other AssertionErrors.
  Log: `hidden_files/full-suite-renumber-29-gate.log` (152601 byte). No VM restart during the gate
  (uptime 54 min at 12:09 check).

## Docs (this commit)

- This report + handoff. Spec row :330 + GOAL §5 line :379 were renumbered inside commit 6df3b1f
  itself (same as rounds 7/8). Done unchanged (1728).

## Handoff / next

- **Batch N2297–N2299** (spawned by cron 12:15, scope
  `hidden_files/next-batch-scope-after-renumber-29.md`): N2297 Turret micro-accessors, N2298
  BurstDrill senseObject/sense, N2299 Game SoundControl.shouldPlay/isPlaying. All 3 code-done in
  worktrees (verified from disk by main thread 12:32: --verify 28/28 + 31/31 + 12/12, targeted
  4/4 ×3, proofs 15 + 9 + 7 keys all true). N2297 family Turret 52/52 (727) + wiring 32/32 (250)
  green in its worktree (continuation log /tmp/n2297-family-wiring.log). N2298 wiring 4/9 modules
  in its worktree — remaining 5 modules to run before merge. N2299 family 8/8 + wiring 32/32 per
  worker (re-verify at merge in main). Merge in N order with merge-time targeted + family + wiring
  in main, then one batch gate + batch docs.
- **N2297 scope note:** the worker built 4 accessors (drawrot/warmup/canControl/logicControlled);
  `controlled()` (Turret.java:441-443) was NOT included — the scope file left it as "decide before
  spawn" and the cron's brief did not carry the main-thread decision to fold it in. It stays a
  0-hit micro-accessor: put it in the next batch (N2300–N2302) as its own micro-slice or folded
  into the next Turret slice. Do NOT re-open N2297 for it.
- Ambient C (N2264) still held — waits for Windows B (N2260).
- Push from Windows: local 65 ahead / 95 behind origin/main e9dfee4 (counted 11:51 +07; recount
  at push time). Merge by hand in the spec at push time. No force-push. Merge-time flags: warmup
  ownership/dedup (remote N2253 vs local N2265); remote recoil family N2254+N2255+N2256+N2257+N2258
  complementary, no dedup; remote N2258 vs local N741/N742 (PortGame-era recoilOffset evidence);
  `SourceItemTurretBuildState.gd` both-modified; remote adds 6 functions to
  SourceTurretBuildState.gd (plus local N2285 status() and N2297 accessors).
- Cron delivery: the stuck queue is draining (handoffs for 07:00–10:45 arrived ~10:38–11:23); the
  11:30/11:45/12:00/12:15 runs arrived as late handoffs. Main thread keeps reporting directly
  every 15 minutes.
