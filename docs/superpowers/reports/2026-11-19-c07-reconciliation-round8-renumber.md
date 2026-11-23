# Reconciliation round 8 — renumber N2257→N2295 (divergence #28)

## Divergence #28 — verified from disk 2026-11-19 ~09:15–09:20 +07 (cron probe) + 09:2x (main thread)

- origin/main 0315a17 → **b02d14d** (5 commits: slice 2f244b5 + 4 docs). Remote **N2257 = TurretBuild.bullet()
  multi-recoil stamp** (2f244b5, owner `SourceTurretBuildState.source_turret_multi_recoil_stamp_state`, 8 exact_exprs,
  1 result symbol `cur_recoils`; commit message says "proof 9 keys" — JSON not in the remote tree, unverified).
- Local **N2257 = BurstDrillBuild.shouldConsume() gate** (62502b8; 21 exact_exprs, 1 result symbol `should_consume`,
  proof C07BurstDrillShouldConsumeProof 9 keys all true counted from disk). Different family, method, GD file,
  owner, result symbols. **Overlap exact_exprs = 0/8. Number-only collision; no GD function renamed.**
- Impact probe (read-only, cron): `~/workspace/goals/mindustry-godot-transpiler-port/hidden_files/divergence-28-n2257-renumber-impact.md`
  (0 other ledger entries mention N2257 — this slice is a LEAF in the import chain).
- Merge-time flags carried forward (not resolved by renumbering): remote N2253 warmup duplicates local N2265
  warmup scope (15/34 exact_exprs) — decide ownership/dedup when merging origin; remote N2254+N2255+N2256+N2257
  are a complementary recoil family (N2256∩N2257 = 3/8) — no dedup needed; remote N2253/N2254/N2255/N2256/N2257
  add functions to SourceTurretBuildState.gd that local HEAD does not have; `SourceItemTurretBuildState.gd`
  is both-modified at merge time.

## Decision — main thread chose the number per precedent (no widget)

- Local N2257 → **N2295**, the next free number from allocations.json (reserved before the renumber by script;
  next_free_n 2295 → 2296). The batch N2285–N2287 keeps its numbers; the batch after it moves
  N2295–N2297 → **N2296–N2298** (because #28 consumed N2295).

## Replay (main thread, 2026-11-19 ~09:28–09:50 +07)

- **N2257→N2295 (BurstDrill shouldConsume), commit fb21582** (11 files, 620+/620-): rename in place, GD function
  unchanged; sed root register/test/proof comment + spec row :329 + GOAL :377; GD comments inside the shouldConsume
  function itself (:105/:703) re-pointed. Script deleted the old ledger key + 1 contract + 2 schemas (defense shards
  do not hold production slices — verified absent). Renumbered register re-added N2295. **No chain re-register**:
  the shouldConsume register is a leaf (imports N2294_DEFERRED, nothing imports its DEFERRED); a key-by-key diff
  against HEAD proves 0 other entries changed content, and the new N2295 entry is byte-identical to the old N2257
  entry after the number swap. Prose mentions of N2257 in OTHER slices' register comments (icons :79,
  update_tile :148, liquid_rows :118) and spec rows :330/:335 kept per round-4 precedent.
- **Correction noted:** the original slice commit 62502b8 said "proof 6 keys" — WRONG; the proof JSON on disk
  has 9 keys. The correct count (9) is used everywhere here, per rule 5.
- Verify: register --verify 24/24; targeted 4/4 (60 subtests); family BurstDrill+Drill 48/48 (806 subtests);
  wiring-standard 32/32 (250 subtests, verified module-by-module — full-suite runs in parallel with the batch
  workers' Godot proofs showed flaky reference-graph failures from port-7777 contention; each module passes
  alone with the port free, including the turret reference-graph test on re-run); Godot proof
  C07BurstDrillShouldConsumeProof **9 keys all true** (counted from JSON). SSOT totals unchanged 11655/1725/1664/3119.
- **VM restart #27 ~09:38 +07** (uptime 0 min, during a wiring re-run): Godot symlink recreated + verified 4.6.2,
  pytest 9.2.0 OK; batch workers N2285/N2287 survived (still running); renumber #28 was uncommitted at the time
  so no work was lost.

## Re-gate — GREEN

- Full gate (main thread, PID 5076/5078, ~10:02–10:21): **Ran 6193 in 1083.525s, failures=225, skipped=5, 0 errors** —
  counted from the log: 225 FAIL headers, all 225 `AssertionError: unexpectedly None` (Godot-absent),
  0 ERROR headers, 0 other AssertionErrors. Log: `~/workspace/goals/mindustry-godot-transpiler-port/hidden_files/full-suite-renumber-28-gate.log` (150759 byte).
- Gate launched only after port 7777 freed (N2285 worker's proof finished ~10:02). No VM restart during the gate
  (uptime 43 min at 10:21); Godot symlink OK.

## Docs (this commit)

- Spec row N2257→N2295 in place (done inside the renumber commit) + GOAL §5 block (scene hash →
  fb21582, this commit) + this report + handoff. Done unchanged (1725); SSOT totals unchanged.
  allocations.json: N2295 done, next_free_n 2296.

## Handoff / next

- NEXT BATCH N2285–N2287: **N2287 DONE + verified from disk by main thread** (worktree `mindustry-wt-n2287-game`:
  --verify 88/88, targeted 4/4 (121 subtests), family 4/4 (121), wiring 32/32 (250), proof
  C07SoundControlLoopProof 10 keys all true, SSOT worktree 11679/1726/1667/3125; deferred chain exact:
  272 lines = N2259's 272, 4 dropped + 4 added as intended). **N2285 still running** (proof done, family/wiring
  in progress). **N2286 spawns after this gate + docs** (same GD file + register chain as the renumber).
  Merge order N2285 → N2286 → N2287 (N2287's register imports DEFERRED from N2259 only — no chain dependency
  on N2285/N2286 — but merge in N order per the batch rule).
- Ambient C (N2264) still held — waits for Windows B (N2260).
- Push from Windows: local 58 ahead / 90 behind origin/main b02d14d after this commit (counted at 09:22 +07;
  verify by count at push time). Merge by hand in the spec at push time (Done line + remote N2243–N2257 rows
  vs local rows). No force-push. Merge-time flags: warmup ownership/dedup (remote N2253 vs local N2265),
  remote recoil family N2254+N2255+N2256+N2257 (complementary, no dedup), `SourceItemTurretBuildState.gd`
  both-modified.
- **Cron delivery jam (Isabella asked to resolve it 09:55):** job healthy (runs succeed, next 10:15); 12 results
  (07:00–09:50) stuck in the delivery queue, attempt_count 0; `cron.update` (id only) returned
  `pending_results_rebound: 0` — nothing force-delivered (good: the 12 are stale). The 10:00 run was in flight
  at 10:02; whether ITS result reaches the chat is the live test — check `cron.status` after it finishes.
  Main thread keeps reporting directly every 15 minutes regardless.
