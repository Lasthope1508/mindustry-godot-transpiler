# Reconciliation round 5 — renumber N2248→N2274 + N2249→N2275 (divergence #19)

## Divergence #19 — verified from disk 2026-11-18 ~17:35–17:40 +07

- origin/main 680efbb → **3fc0661** (6 commits: 1 slice + 5 docs). Remote **N2248 = PointDefenseTurret live coolant state**
  (997082d, proof C07PointDefenseTurretCoolantProof 12 keys, 10th straight PointDefenseTurret slice N2239–N2248, Windows line).
  Remote ledger 1698 slices, max N 2248, remote has NO N2249.
- Local **N2248 = Radar updateTile** (b040e56) and **N2249 = Radar fogRadius** (32bb63e). Only N2248 collided;
  N2249 had not collided yet, but the Windows line takes numbers consecutively (~1 slice/hour) so its next slice would be N2249.
- **Decision 2026-11-18 17:42 +07 (Isabella, options widget): renumber BOTH** — N2248→N2274 + N2249→N2275, replay after the
  batch N2271–N2273 gate, then re-gate + docs. N2274/N2275 were reserved in allocations.json before the replay; next_free_n 2276.

## Replay (main thread, sequential — same GD file SourceRadarBuildState.gd)

- **N2248→N2274 (Radar updateTile), commit 40e54d9**: rename in place, GD function unchanged; sed N2248→N2274 in register/test/proof comment
  + 3 cross-ref comments in SourceRadarBuildState.gd; old ledger key + 1 contract + 2 schemas deleted by script, register re-ran to re-add as N2274.
  Register --verify 36/36; targeted 4/4 (85 subtests); family Radar 28/28 (273 subtests); wiring-standard 32/32 (250 subtests);
  proof C07RadarUpdateTileProof **10 keys all true** (verified from JSON). SSOT totals unchanged 11623/1716/1652/3095.
- **N2249→N2275 (Radar fogRadius), commit 205c102**: same technique. Register --verify 13/13; targeted 4/4 (36 subtests);
  family Radar 28/28 (273 subtests); wiring-standard 32/32 (250 subtests); proof C07RadarFogRadiusProof **9 keys all true** (verified from JSON).
  Also fixed a stale cross-ref in this register's deferred_exprs prose (N2173/N2248 → N2173/N2274). SSOT totals unchanged.
- Prose mentions of N2248/N2249 in OTHER slices' registers/tests/proofs and in historical reports were left as-is (round-4 precedent);
  only the renamed slices' own identifiers and the spec/GOAL rows were renumbered.
- Self-correction: the first N2274 commit message draft said the updateTile proof had "8 keys" — that number was invented, not verified.
  Main thread caught it by counting the proof JSON (10 keys, all true) BEFORE reporting, amended the commit (053a61f → 40e54d9) and corrected the message.
  Rule 5 of the new working method exists for exactly this failure mode.

## Re-gate — GREEN

- Full gate (main thread, PID 7460, ~18:18–18:36): **Ran 6157 tests in 1055.371s, FAILED (failures=216, skipped=5), 0 errors.**
  Verified by main thread from the log: 216 FAIL headers, all 216 `AssertionError: unexpectedly None`, 0 non-Godot fail blocks,
  0 ERROR headers — all 216 are Godot-absent reference asserts (by design, GOAL.md §5). Same totals as the batch gate, as expected —
  a rename adds no tests. Log: tools/mindustry_godot_transpiler/full-suite-round5-renumber-gate.log.
- No VM restart during the gate (uptime 1:28 at verification); Godot symlink OK.

## Docs (this commit)

- Spec rows N2248→N2274 + N2249→N2275 in place (with renumber + re-gate notes) + GOAL §5 blocks (scene commits → 40e54d9 / 205c102)
  + this report + handoff. Done count unchanged (1716); SSOT totals unchanged.

## Handoff / next

- **The 17:42 stop order lifts with this commit.** Work resumes under the 7-rule working method (MEMORY.md "CÁCH LÀM MỚI", cron body).
- Next batch (scope hidden_files/divergence-19-and-next-batch-scope.md §1): Turret write/read/version, DrillBuild ambientVolume super leg,
  Radar draw — 3 different GD files, spawn in parallel, numbers from **N2276** (allocations.json lock BEFORE spawn, worktrees from latest HEAD).
- Ambient C (N2264) still waits for Windows B (N2260).
- Push from Windows: local **37 ahead / 37 behind** origin/main 3fc0661 after this commit. Merge by hand in the spec at push time
  (Done line + remote N2243–N2248 rows vs local rows). No force-push.
