# Report — N2186: LaunchPad shouldConsume gate (C07)

Date: 2026-11-15. Batch: N2186 + N2187 + N2189 (integration branch
`integration/batch-n2186-n2187-n2189`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2186 (parallel wave 1, coordinator-verified). Slice commit `41f25eae`
on `slice/N2186-launch-pad-should-consume`; SSOT commit `5a97799c`; coordinator fix
`6d098b3c` (60x Time.delta — see GREEN). Integration cherry-picks: slice `879fa13e`,
fix `65a9f597`.

## What changed

The first deferred **shouldConsume gate** from the N2185 "Next": LaunchPadBuild
overrides shouldConsume with `return launchCounter < launchTime;`
(LaunchPad.java:92-95). Before this slice the driver ran with
should_consume=true whenever enabled, so a launch pad kept drawing power even
after its counter reached launchTime. Now the gate feeds the consumption fold:
when `launchCounter >= launchTime` the folded efficiency is 0 and the pad draws
no power.

Two defs, per-def launchTime stamped from Blocks.java (class default 1f):
`launch-pad` — `launchTime = 60f * 20` = 1200.0 (Blocks.java:6794);
`advanced-launch-pad` — `launchTime = 60f * 30` = 1800.0 (Blocks.java:6804).
The counter advances by edelta each tick (efficiency × Time.delta × timeScale)
and the gate is a pure function
`SourceLaunchPadBuildState.source_launch_pad_should_consume_state`.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_launch_pad_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_launch_pad_should_consume.py`
written by worker-N2186. Register script: EXACT_EXPRS = the 21 verified exprs
(all 21 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 243 entries (copy forward from N2185, minus the resolved LaunchPad gate
entry, plus new deferrals).

RED run: registration + exact-evidence fail with `KeyError: 'N2186'` (slice not
registered yet) and the row-state test fails on the missing function; the proof
test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure gate + counter advance in `godot-mindustry/src/game/SourceLaunchPadBuildState.gd`:
  `source_launch_pad_should_consume_state` returns the gate value from the frame
  counter vs the per-def launchTime; the driver advances `launchCounter` by edelta
  each tick and folds the gate into the consumption pass via
  `update_consumption_state` (should_consume = gate). Header quotes all 21 exact
  exprs, each on ONE comment line. All documented limits recorded in the pure
  function's comment.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07LaunchPadShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11382/1637/1558/2907**
  (+2/+1/+1/+2 from baseline 11380/1636/1557/2905); audit 1335 unchanged; ledger
  N2186 status done. **No shard changed** (LaunchPad.java is not under a shard
  selection path).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 21/21,
  row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- **Coordinator fix `6d098b3c` (the 60x Time.delta lesson):** the worker's driver
  passed raw `seconds` as Time.delta. `_process(delta)` gives real seconds
  (~1/60 per tick) but Java Time.delta = seconds × 60 (arc Time.java:26), so the
  counter ran 60x too slow vs Java. Fixed to the canonical
  `game_source_delta(game, seconds)` helper (the N2093/N2189 precedent) and the
  proof expectation fixed with it (`counter_advances_by_edelta` now expects
  1.0/tick). Targeted re-run after the fix: still 3/4 + Godot-absent.
  The same bug was found in N2187/N2191 and fixed the same way; N2189/N2190/
  N2192/N2193/N2195 were correct from the start. The pre-existing conduit
  precedent (`SourceConduitRuntimeState` passing raw delta) is itself the bug —
  fixed separately as N2196.

## Neighbours (batch — see the batch-1 report section in each slice report)

Family run 10:20 +07 (41 modules, 164 tests) + new targeted 9/12 + wiring-standard
set (9 modules / 32 tests): **155/208 PASS**, 53 failures ALL verified
`AssertionError: unexpectedly None` (41 family + 3 new targeted + 9 wiring),
0 other failures, 0 `ERROR:` lines — no regression. Log
`tools/mindustry_godot_transpiler/batch1-neighbours.log` (untracked).

## Gate (batch)

Full gate launched from the coordinator main thread 10:20 +07 via
`setsid nohup python3 -m unittest discover -s tests`, PID 12303, SID 12303.
Finished 10:39 +07: **Ran 5849 tests in 1131.248s, FAILED (failures=139,
skipped=5)** — 0 errors, 0 `ERROR:` lines. All 139 verified Godot-absent
(139 × `AssertionError: unexpectedly None`), exactly as expected (136 inherited
+ 3 new: N2186/N2187/N2189 proof tests). Log
`tools/mindustry_godot_transpiler/full-suite-batch1-gate.log` (untracked).
Note: the gate tested the pre-fix N2186/N2187 code (fixes cherry-picked after);
the runtime 60x bug does not affect static test outcomes, so the gate result
stands. Targeted re-run after the fix cherry-picks: 9/12 (3 Godot-absent).

## Commits

- Slice: `41f25eae` — C07: N2186 LaunchPad shouldConsume gate, 5 files (+497/−4),
  on `slice/N2186-launch-pad-should-consume`.
- SSOT: `5a97799c` — C07: N2186 SSOT registration (11382/1637/1558/2907), 4 files (+392).
- Coordinator fix: `6d098b3c` — C07: N2186 coordinator fix (60x Time.delta → game_source_delta).
- Integration: slice cherry-pick `879fa13e` + fix cherry-pick `65a9f597` on
  `integration/batch-n2186-n2187-n2189`; batch SSOT `ca44caa0` (combined
  11386/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2186/N2187/N2189.
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- Launch sequence (beginLaunch / endLaunch / the actual launch fire) — its own slice.
- The launch counter's interaction with item payloads — waits for items infra.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07LaunchPadShouldConsumeProof`, commit carrying the scene `41f25eae` (proof
  expectation fixed in `6d098b3c`), 9 keys
  (`gate_open_below_launch_time`, `gate_closed_at_launch_time`,
  `gate_closed_above_launch_time`, `counter_advances_by_edelta`,
  `efficiency_zero_when_gate_closed`, `efficiency_kept_when_gate_open`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_launch_pad_should_consume` with Godot 4.6.2 on PATH, port 7777 free.
- Next: N2187 (ShockwaveTower gate, same batch), N2189 (LightBlock updateTile),
  then the remaining shouldConsume gates — most are blocked on frame-state infra
  (config/link, items, liquids, payload, targets) — see the N2188 blocker in
  STATUS.md and the batch-1 handoff Next sections.
