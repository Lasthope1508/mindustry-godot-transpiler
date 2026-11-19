# Reconciliation round 7 — renumber N2256→N2294 (divergence #27)

## Divergence #27 — verified from disk 2026-11-19 ~07:15–07:30 +07 (cron) + 08:28 (main thread)

- origin/main 6b6719d → **0315a17** (5 commits: slice 0a6a549 + 4 docs). Remote **N2256 = TurretBuild.updateTile()
  multi-recoil decay** (0a6a549, owner `SourceTurretBuildState.source_turret_multi_recoil_state`, 8 exact_exprs,
  1 result symbol `cur_recoils`; commit message says "proof 8 keys" — JSON not in the remote tree, unverified).
- Local **N2256 = BurstDrillBuild.updateTile() advance** (5f17ac9; 55 exact_exprs, 11 result symbols,
  proof C07BurstDrillUpdateTileProof 11 keys all true counted from disk). Different family, method, GD file,
  owner, result symbols. **Overlap exact_exprs = 0/8. Number-only collision; no GD function renamed.**
- Impact probe (read-only): `~/workspace/goals/mindustry-godot-transpiler-port/hidden_files/divergence-27-n2256-renumber-impact.md`
  (15 ledger entries mention N2256: 9 BurstDrill group-A + 6 Turret group-B).
- Merge-time flags carried forward (not resolved by renumbering): remote N2253 warmup duplicates local N2265
  warmup scope (15/34 exact_exprs) — decide ownership/dedup when merging origin; remote N2254+N2255+N2256
  are a complementary recoil family (N2254∩N2256 = 6/8, N2255∩N2256 = 4/8, mostly shared scaffolding;
  only 2 exprs are truly new in N2256) — no dedup needed, but re-run each slice's exact-evidence tests after
  merge; remote N2253/N2254/N2255/N2256 add functions to SourceTurretBuildState.gd that local HEAD does not have;
  `SourceItemTurretBuildState.gd` is both-modified at merge time.

## Decision — main thread chose the number per precedent (no widget)

- Following the 2026-11-19 ~07:02 lesson (technical/cosmetic number choices are decided by the main thread,
  not bounced to the user): local N2256 → **N2294**, the next free number from allocations.json (reserved
  before the renumber by script; next_free_n 2294 → 2295). The batch N2285–N2287 keeps its numbers;
  the batch after it is N2295–N2297 (because #27 consumed N2294).

## Replay (main thread, 2026-11-19 ~08:47–09:03 +07)

- **N2256→N2294 (BurstDrill updateTile), commit b68749c** (17 files, 1999+/1999-): rename in place, GD function
  unchanged; sed root register/test/proof comment + spec row :328 + GOAL :375; alias `N2256_DEFERRED` →
  `N2294_DEFERRED` in the shouldConsume + liquid_rows registers; the Turret warmup/findTarget registers' own
  deferred driver-wire lines re-pointed; proof comments in the onProximity/warmup proofs + GD comment :378
  re-pointed. Script deleted the old ledger key + 1 contract + 2 schemas (defense shards do not hold
  production slices — verified absent, not assumed); renumbered register re-added N2294.
- Chain re-register (15 entries, import order): BurstDrill N2257 → N2258 → N2269 → N2262 → N2266 →
  N2271/N2280 → N2277; Turret N2265 → N2270 → N2273 → N2276 → N2279 → N2282. Ledger now contains NO N2256
  anywhere; only the 14 downstream entries changed, each in `deferred_exprs` only (same N2256→N2294 counts,
  verified by a key-by-key diff against HEAD). Prose mentions of N2256 in OTHER slices' register docstrings,
  test comments and spec rows kept per round-4 precedent.
- Verify: register --verify root 74/74, chain 24/24 + 58/58 + 13/13 + 49/49 + 26/26 + 11/11 + 54/54 + 11/11
  + 44/44 + 87/87 + 18/18 + 36/36 + 17/17 + 16/16; targeted 4/4 (161 subtests); family BurstDrill+Drill
  48/48 (806 subtests); wiring-standard 32/32 (250 subtests); Godot proof C07BurstDrillUpdateTileProof
  **11 keys all true** (counted from JSON). SSOT totals unchanged 11655/1725/1664/3119.
- Note: the ledger diff is 3316 lines because the deleted N2256 key + re-added N2294 key reordered the file
  (N2294 now last); the semantic diff is only the renumber + 14 deferred_exprs swaps (verified key-by-key).
  Same pattern as round 6.

## Re-gate — GREEN

- Full gate (main thread, PID 11689/11690, ~09:03–09:22): **Ran 6193 tests in 1094.134s, FAILED (failures=225, skipped=5), 0 errors.**
  Verified by main thread from the log: 225 FAIL headers, all 225 `AssertionError: unexpectedly None`, 0 non-Godot fail blocks,
  0 ERROR headers — all 225 are Godot-absent reference asserts (by design, GOAL.md §5). Same totals as the
  batch N2282–N2284 gate and the round-6 gate, as expected — a rename adds no tests.
  Log: `~/workspace/goals/mindustry-godot-transpiler-port/hidden_files/full-suite-renumber-27-gate.log`.
- No VM restart during the gate (uptime 1:46 at verification); Godot symlink OK (4.6.2.stable.official.71f334935).

## Docs (this commit)

- Spec row N2256→N2294 in place (done inside the renumber commit) + GOAL §5 block (scene commit hash →
  b68749c, this commit) + this report + handoff. Done unchanged (1725); SSOT totals unchanged.
  allocations.json: N2294 done, next_free_n 2295.

## Handoff / next

- NEXT BATCH N2285–N2287 (scope `hidden_files/next-batch-scope-after-n2284.md`, re-verified
  `next-batch-scope-after-n2284-reverified.md`): Turret status(), BurstDrill write/read/version (D2),
  Game SoundControl.loop() — 3 different GD files, parallel; numbers from allocations.json,
  lock BEFORE spawn, worktrees from latest HEAD. Scope files for the following batches need their
  labels recomputed (after-n2287 → N2295–N2297; after-n2292 → N2298–N2300; after-n2298 → N2301–N2303).
- Ambient C (N2264) still held — waits for Windows B (N2260).
- Push from Windows: local 58 ahead / 90 behind origin/main b02d14d after this commit (counted at 09:22 +07;
  origin moved 0315a17 → b02d14d during the gate: remote **N2257 = Turret multi-recoil stamp** (2f244b5)
  collides number-only with local **N2257 = BurstDrill shouldConsume** — divergence #28, 0/8 expr overlap,
  renumber local N2257 → N2295 next). Merge by hand in the spec at push time (Done line + remote
  N2243–N2257 rows vs local rows). No force-push. Merge-time flags: warmup ownership/dedup
  (remote N2253 vs local N2265), remote recoil family N2254+N2255+N2256+N2257 (complementary, no dedup),
  `SourceItemTurretBuildState.gd` both-modified.
