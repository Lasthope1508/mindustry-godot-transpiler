# Reconciliation round 6 — renumber N2250→N2288 + N2251→N2289 + N2252→N2290 + N2253→N2291 + N2254→N2292 + N2255→N2293 (divergences #21–#26)

## Divergences #21–#26 — verified from disk 2026-11-18 ~22:28 → 2026-11-19 ~06:1x +07

- origin/main moved 87588c6 → 6b6719d over six rounds. Remote took N2250–N2255 for Windows-line slices
  (ItemTurret aim/reload/shoot, ItemTurret validateTarget, ItemTurret bullet() spawn, Turret warmup lerp,
  Turret recoil+heat decay, Turret shoot stamp) while local already held N2250–N2255
  (Radar.icons, RepairTurret drawBeam jitter, RepairTurret drawBeam pulse, Turret shouldConsume,
  Turret progress, Turret sense). All six collisions are number-only: different families/methods,
  0 exact_expr overlap on the checked pairs; no GD function renamed.
- Impact probes (read-only, in `~/workspace/goals/mindustry-godot-transpiler-port/hidden_files/`):
  `divergence-21-n2250-renumber-impact.md` … `divergence-26-n2255-renumber-impact.md`.
- Merge-time flags carried forward (not resolved by renumbering): remote N2253 warmup duplicates local
  N2265 warmup scope (15/34 exact_exprs) — decide ownership/dedup when merging origin; remote
  N2254+N2255 are a complementary pair (11/14 exprs shared, different owners, no registry collision,
  no dedup needed); remote N2253/N2254/N2255 add 3 functions to SourceTurretBuildState.gd that local
  HEAD does not have; `SourceItemTurretBuildState.gd` is both-modified at merge time.

## Decision — main thread chose A''' (2026-11-19 ~07:02 +07, no widget re-sent)

- Isabella objected to being asked to decide the renumber by widget mid-task ("con chó nào lại giao task
  ngu giờ hỏi giữa chừng thằng nào trả lời được?"). Main thread owned it and chose **A'''** without
  asking again: the A/B options differed only in numbers (next batch is N2294–N2296 either way), and A
  matches the round 3/4/5 precedent (renumber to high numbers, keep the batch's numbers).
  **A''' = N2250→N2288, N2251→N2289, N2252→N2290, N2253→N2291, N2254→N2292, N2255→N2293;
  batch N2285–N2287 kept; next batch N2294–N2296; next_free_n 2294.**
- Lesson recorded: technical/cosmetic decisions that differ only in numbers are decided by the main
  thread per precedent, not bounced to the user mid-task.

## Replay (main thread, sequential, N ascending)

- **N2250→N2288 (Radar icons), commit 3760228** (10 files, 513+/513-): --verify 12/12; targeted 4/4
  (24 subtests); family Radar 40/40 (392); wiring 32/32 (250); proof C07RadarIconsProof **5 keys** all true.
- **N2251→N2289 (RepairTurret drawBeam jitter), commit 128c9f9** (9 files, 757+/757-): --verify 37/37;
  targeted 4/4 (67); family RepairTurret 96/96 (1115); wiring 32/32 (250);
  proof C07RepairTurretDrawBeamJitterProof **11 keys** all true.
- **N2252→N2290 (RepairTurret drawBeam pulse), commit ca0a252** (11 files, 601+/601-): --verify pulse 21/21
  + jitter 37/37; targeted 4/4 (46); family RepairTurret 96/96 (1115, re-run after VM restart #26);
  wiring 32/32 (250); proof C07RepairTurretDrawBeamPulseProof **11 keys** all true. Includes the
  cross-mention fix: jitter register/test (N2252→N2290) + pulse register/test/proof (N2251→N2289) +
  jitter register re-run so entry N2289 carries the pulse-phase chain.
- **N2253→N2291 (Turret shouldConsume), commit 4edf8ca** (11 files, 202+/202-): --verify 16/16;
  targeted 4/4 (34); family Turret 48/48 (667); wiring 32/32 (250);
  proof C07TurretShouldConsumeProof **8 keys** all true. GD comments :149/:200/:311/:897.
  2 self-pointers fixed in its register; 10 downstream entries still carried the N2253 pointer at
  commit time (fixed in the later steps).
- **N2254→N2292 (Turret progress), commit 0573346** (12 files, 193+/193-): --verify progress 12/12 +
  shouldConsume 16/16; targeted 4/4 (28); family Turret 48/48 (667); wiring 32/32 (250);
  proof C07TurretProgressProof **8 keys** all true. Includes sed of the progress pointer in the
  shouldConsume register (:44/:94/:95 → N2292) + shouldConsume register re-run. GD comments :255/:311.
- **N2255→N2293 (Turret sense), commit 23a5ed1** (14 files, 400+/400-): --verify sense 42/42 +
  progress 12/12 + shouldConsume 16/16; targeted 4/4 (82 subtests); family Turret 48/48 (667);
  wiring 32/32 (250); proof C07TurretSenseProof **12 keys** all true (counted from JSON — corrects the
  old "8 keys" claim, which was wrong). Includes the full chain re-register of 11 Turret registers in
  import order (shouldConsume→progress→sense→fog_radius→estimate_dps→warmup→find_target→
  tracking_range→write_read→is_active→min_range), so every downstream deferred string now names
  N2291/N2292/N2293; sense register's N2253/N2254 prose refs re-pointed to N2291/N2292 (incl. the
  sense_value rule, now in the registry).
- Technique (same as rounds 3/4/5): rename in place, GD function unchanged; sed register/test/proof
  comment + GD comments + spec + GOAL; script deletes the old ledger key + contracts/schemas (by
  `source_slice`) + defense shards; renumbered register re-adds the entry. One slice per commit
  (never two registers before committing the first). Insertion counts from `git diff --cached --stat`,
  proof key counts from the JSON files — never from worker reports.
- Prose mentions of the old numbers in OTHER slices' registers/tests/proofs and in historical reports
  were left as-is (round-4 precedent); only the renamed slices' own identifiers, the chain pointers
  (machine pointers, not prose), and the spec/GOAL rows were renumbered.
- **SSOT totals unchanged through all six renumbers: 11655/1725/1664/3119. Done 1725.** Ledger now
  contains NO N2250–N2255 anywhere (checked: no key, no `source_slice`, no deferred string).

## VM restart #26 (~07:36 +07, during the N2290 verification)

- `/usr/local` tmpfs wiped: Godot symlink gone. Main thread recreated it and verified
  4.6.2.stable.official.71f334935. A wiring run failed transiently (godot missing from PATH) and was
  re-run green after recovery; the N2290 family run (proc_8c3fd06e8afb) was cut by the restart and
  re-run (96/96, 1115 subtests). No work lost. Uptime 1 minute at verification.

## Re-gate — GREEN

- Full gate (main thread, PID 7991/7992, ~08:27–08:46): **Ran 6193 tests in 1102.971s, FAILED (failures=225, skipped=5), 0 errors.**
  Verified by main thread from the log: 225 FAIL headers, all 225 `AssertionError: unexpectedly None`, 0 non-Godot fail blocks,
  0 ERROR headers — all 225 are Godot-absent reference asserts (by design, GOAL.md §5). Same totals as the
  batch N2282–N2284 gate, as expected — a rename adds no tests.
  Log: `~/workspace/goals/mindustry-godot-transpiler-port/hidden_files/full-suite-renumber-21-26-gate.log`.
- No VM restart during the gate (uptime 1:10 at verification); Godot symlink OK (4.6.2.stable.official.71f334935).

## Docs (this commit)

- Spec rows N2250→N2288 … N2255→N2293 in place (done inside each renumber commit) + GOAL §5 6 blocks
  (scene commit hashes → 3760228 / 128c9f9 / ca0a252 / 4edf8ca / 0573346 / 23a5ed1, this commit)
  + this report + handoff. Done unchanged (1725); SSOT totals unchanged.
  allocations.json updated by script: N2288–N2293 done, next_free_n 2294.

## Cron 15-minute delivery failure (2026-11-19 ~08:28 +07)

- Cron `mindustry-15m-report` kept firing on schedule (07:15/07:30/08:00 succeeded; 07:00/07:45 hit
  the 900s timeout; 08:15 running) but **5 finished reports sat pending delivery to chat** — Isabella
  saw no report after 06:45 although the cron had written them to `~/memory/2026-11-19.md`.
  Main thread reported directly at 08:28 instead (renumber done, gate running, divergence #27 new)
  and will keep reporting directly every 15 minutes until the delivery path unclogs. The 5 stuck
  reports are NOT re-sent (content already stale).

## Handoff / next

- **Divergence #27** (from cron 07:15/07:30, verified from disk by main thread 08:28): origin/main
  6b6719d → **0315a17**, remote **N2256 = Turret multi-recoil decay** (0a6a549) collides with local
  **N2256 = BurstDrill updateTile** (proof 11 keys). Number-only, overlap 0/8; probe
  `hidden_files/divergence-27-n2256-renumber-impact.md` (15 ledger entries mention N2256).
  Renumber N2256→**N2294** (next_free_n) AFTER this gate + docs, then re-gate + docs #27, then spawn
  the batch. Local 55 ahead / 85 behind origin 0315a17.
- NEXT BATCH N2285–N2287 (scope `hidden_files/next-batch-scope-after-n2284.md`, re-verified
  `next-batch-scope-after-n2284-reverified.md`): Turret status(), BurstDrill write/read/version (D2),
  Game SoundControl.loop() — 3 different GD files, parallel; numbers from allocations.json,
  lock BEFORE spawn, worktrees from latest HEAD. Scope files for the following batches need their
  labels recomputed after the #27 renumber (after-n2287 → N2295–N2297; after-n2292 → N2298–N2300;
  after-n2298 → N2301–N2303).
- Ambient C (N2264) still held — waits for Windows B (N2260).
- Push from Windows: local 55 ahead / 85 behind origin/main 0315a17 after this commit. Merge by hand
  in the spec at push time (Done line + remote N2243–N2256 rows vs local rows). No force-push.
  Merge-time flags: warmup ownership/dedup (remote N2253 vs local N2265), remote N2254+N2255+N2256
  recoil family (complementary, no dedup), `SourceItemTurretBuildState.gd` both-modified.
