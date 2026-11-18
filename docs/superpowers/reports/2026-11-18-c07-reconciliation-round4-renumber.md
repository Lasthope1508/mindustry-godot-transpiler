# C07 reconciliation round 4 — report (2026-11-18)

Two local slice numbers collided with remote PointDefenseTurret slices
from the Windows line. Both were number-only collisions (different
functions/files/registers/tests/proofs); per precedent the remote number
stands and the local slice renumbers. Both renames are in-place — the GD
functions already live in main, so no GD change was needed, only
register+test+proof renumbering and SSOT ledger moves.

## Divergence #15 — local N2244 vs remote N2244

- origin/main 87588c6 → **f5d19d5** (5 commits: 1 slice + 4 docs),
  merge-base still 7dfdec3. Remote: **N2244 PointDefenseTurret draw()
  body** (910e7fd, `PointDefenseBuild.draw()`, owner
  `SourcePointDefenseTurretBuildState.source_point_defense_turret_draw_state`,
  proof C07PointDefenseTurretDrawProof 6 keys, GD +26 + driver tick).
  Remote ledger 1694 slices, max N 2244.
- Local N2244 was Turret fogRadius (a5f722e, round 3, gated + docs).
- **Isabella approved 2026-11-18 ~12:27 (options widget): renumber
  local N2244 → N2268, replay after the N2265–N2267 batch merges.**

## Divergence #16 — local N2245 vs remote N2245

- origin/main f5d19d5 → **53bac8a** (5 commits: 1 slice + 4 docs),
  merge-base still 7dfdec3. Remote: **N2245 PointDefenseTurret
  write/read** (0f0683b, `PointDefenseBuild.write()/read()`, owner
  `SourcePointDefenseTurretBuildState.source_point_defense_turret_write_state`,
  proof C07PointDefenseTurretWriteReadProof 8 keys, GD +41, 2 pure
  functions, no driver tick). Remote ledger 1695 slices, max N 2245.
- Local N2245 was BurstDrill icons (caaba18, round 3, gated + docs).
- **Isabella approved 2026-11-18 ~13:09 (options widget): fold
  N2245→N2269 into round 4 (1 replay + 1 gate).** N2269 was also the
  candidate number for Turret findTarget — findTarget now takes **N2270**
  (next free, per allocations.json).

PointDefenseTurret is now 7 consecutive slices by the Windows line
(N2239–N2245). Family ownership of PointDefenseTurret is STILL undecided
— Isabella has not ruled; the suggestion stands that Windows keeps it.

## Renames (main thread, no workers)

### N2244 → N2268 Turret fogRadius → 83bf0bc (10 files, 240 ins/240 del)
- Register + test + proof comment N2244→N2268 (7 + 9 + 1 spots);
  alias N2244_DEFERRED→N2268_DEFERRED in the N2261 estimateDps
  register (plus 4 prose refs); N2261 + N2265 registers re-run to
  refresh the N2244 proof-debt prose to N2268.
- SSOT: ledger entry N2244 deleted and re-added as N2268; contract +
  schemas re-sliced (defense shards). Symbol
  `source_turret_fog_radius_state_result.fog_radius` has no slice tag
  and was NOT deleted — the renumbered register re-upserts it identical.
- --verify 21/21; targeted 4/4 (44 subtests); family Turret 28/28
  (343 subtests); wiring 32/235. grep N2244 = 0 across all SSOT JSONs.

### N2245 → N2269 BurstDrill icons → 2b49c54 (10 files, 519 ins/519 del)
- Register + test + proof comment N2245→N2269 (7 + 8 + 1 spots);
  alias N2245_DEFERRED→N2269_DEFERRED in the N2262 on-proximity
  register (plus prose); N2266 register prose updated; N2262 + N2266
  registers re-run to refresh the N2245 proof-debt prose to N2269.
- SSOT: ledger entry N2245 deleted and re-added as N2269; contract +
  schemas re-sliced (production shards, not defense). Symbol
  `source_burst_drill_icons_state_result.icons` likewise untouched.
- --verify 13/13; targeted 4/4 (28 subtests); family BurstDrill 28/28
  (575 subtests); wiring 32/235. grep N2245 = 0 across all SSOT JSONs.
- **VM restart #16 (~13:17, uptime 0 min)** hit between the icons
  register run and the N2262/N2266 re-runs — tmpfs wipe took only the
  Godot symlink. Main thread rebuilt it (Godot 4.6.2 OK), re-ran the 2
  registers, re-checked --verify 13/13 after the restart. No work lost.

SSOT totals UNCHANGED through both renames: **11615/1712/1644/3079**.
Done stays 1712 — renames, not new slices.

## Allocation guarantee (Isabella 2026-11-18 ~13:09)

"Đảm bảo đéo có phân việc ngu nữa" — after the 12:03 duplicate-worker
race (cron + main thread spawned 3 continuation workers each for
N2265–N2267, 39s apart) and the N2268/N2269 double-bookings (cron held
them for findTarget while the main thread held them as renumber
candidates). Fix, already in place: **single allocator —
`allocations.json`** is the only source of N numbers; cron + main thread
must read it + subagent.list before spawning, write the lock +
reservation BEFORE spawning, never take a reserved number, never spawn
when unsure. Current: N2264 ambient C (held), N2268/N2269 round 4
(done), N2270 findTarget (next free, unassigned). The cron body carries
the same rule.

## Gate (round 4)

Main thread, python PID 2361, ~13:21–13:38 +07, log
`full-suite-reconciled-round4-gate.log`: **Ran 6141 in 1027.064s,
failures=212, skipped=5, 0 errors** — counted directly from the log: 212
FAIL blocks, 0 ERROR blocks, all 212 `AssertionError: unexpectedly None`
(Godot-absent). Numbers identical to the N2265–N2267 gate (6141/212/5)
as expected — renames add no tests.

## Docs in this commit

- Spec: N2244 row edited in place → N2268 + N2245 row → N2269, each
  with a renumber note + round-4 gate text; the N2261/N2263 rows'
  "accessor precedent N2244/N2249" refs → N2268/N2249. Done stays 1712.
- GOAL §5: N2244 block → N2268 (scene commit 83bf0bc), N2245 block →
  N2269 (scene commit 2b49c54).

## State at docs time

- HEAD 41d2593 at gate time; this docs commit follows. SSOT
  11615/1712/1644/3079.
- origin/main verified 53bac8a (fetch succeeded ~13:40 after the
  preparation's fetch failed with a network error) — no new divergence.
  Local 25 ahead / 20 behind.
- Next slice: Turret findTarget, **N2270** (scope ready in
  `hidden_files/next-batch-scope-after-n2265.md` §1) — needs a
  main-thread decision before the number is assigned (allocations.json
  rule). Ambient C (N2264) waits for Windows B (N2260).
- Push from Windows will need a merge with origin/main 53bac8a: remote
  slices N2243/N2244/N2245 + docs commits vs local batches — hand
  reconciliation at the spec (Done line + remote rows vs local rows),
  same as rounds 1–4. No force-push.
