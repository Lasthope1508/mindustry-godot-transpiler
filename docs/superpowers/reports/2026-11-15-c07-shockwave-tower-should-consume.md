# Report — N2187: ShockwaveTower shouldConsume gate (C07)

Date: 2026-11-15. Batch: N2186 + N2187 + N2189 (integration branch
`integration/batch-n2186-n2187-n2189`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2187 (parallel wave 1, coordinator-verified). Slice commit `b1467f88`
on `slice/N2187-shockwave-tower-should-consume`; SSOT commit `68c1464f`; coordinator
fix `6820289b` (60x Time.delta — see GREEN). Integration cherry-picks: slice
`b69ba59d`, fix `ffcf9ccb`.

## What changed

The second deferred **shouldConsume gate** from the N2185 "Next":
ShockwaveTowerBuild overrides shouldConsume with `reloadCounter < reload`
(ShockwaveTower.java:121-122). Before this slice the driver ran with
should_consume=true whenever enabled, so a shockwave tower kept drawing power
even while its reload counter was full. Now the gate feeds the consumption fold:
when `reloadCounter >= reload` the folded efficiency is 0.

Single def: `shockwave-tower` (Blocks.java:2038). Class `reload = 60f * 1.5f`
= 90f (ShockwaveTower.java:26); the counter starts at `Mathf.random(reload)`
(ShockwaveTower.java:67) and advances by edelta each tick. The gate is a pure
function `SourceShockwaveTowerBuildState.source_shockwave_tower_should_consume_state`.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_shockwave_tower_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_shockwave_tower_should_consume.py`
written by worker-N2187. Register script: EXACT_EXPRS = the 27 verified exprs
(all 27 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 243 entries (copy forward from N2185, minus the resolved ShockwaveTower
gate entry, plus new deferrals).

RED run: registration + exact-evidence fail with `KeyError: 'N2187'` (slice not
registered yet) and the row-state test fails on the missing function; the proof
test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure gate + counter advance in `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd`:
  `source_shockwave_tower_should_consume_state` returns the gate value from the
  frame counter vs reload; the driver advances `reloadCounter` by edelta each
  tick and folds the gate into the consumption pass via
  `update_consumption_state` (should_consume = gate). Header quotes all 27 exact
  exprs, each on ONE comment line. All documented limits recorded in the pure
  function's comment.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11382/1637/1558/2907**
  (+2/+1/+1/+2 from baseline 11380/1636/1557/2905); audit 1335 unchanged; ledger
  N2187 status done. **Defense shard DID change** (ShockwaveTower.java lives
  under `/world/blocks/defense/`): defense_slices 154→155, defense_api_contracts
  153→154, purely additive N2187 mirrors.
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 27/27,
  row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all).
  The proof scene is written but NEVER run; see GOAL.md §5 debt.
- **Coordinator fix `6820289b` (the 60x Time.delta lesson, same as N2186):**
  the worker passed raw `seconds` as Time.delta (60x too slow — Java Time.delta
  = seconds × 60, arc Time.java:26). Fixed to `game_source_delta(game, seconds)`
  and the proof expectation fixed with it
  (`reload_counter_advances_by_edelta` now expects 10.0+1.0). Targeted re-run
  after the fix: still 3/4 + Godot-absent.

## Neighbours (batch)

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

- Slice: `b1467f88` — C07: N2187 ShockwaveTower shouldConsume gate, 5 files (+496/−4),
  on `slice/N2187-shockwave-tower-should-consume`.
- SSOT: `68c1464f` — C07: N2187 SSOT registration (11382/1637/1558/2907), 6 files (+463).
- Coordinator fix: `6820289b` — C07: N2187 coordinator fix (60x Time.delta → game_source_delta).
- Integration: slice cherry-pick `b69ba59d` + fix cherry-pick `ffcf9ccb` on
  `integration/batch-n2186-n2187-n2189`; batch SSOT `ca44caa0` (combined
  11386/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2186/N2187/N2189.
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- The shockwave fire itself (bullet spawn / wave damage) — its own slice.
- The reload counter's random init (`Mathf.random(reload)`) — the port binds the
  counter deterministically; the stagger only desynchronizes first-fire timing.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07ShockwaveTowerShouldConsumeProof`, commit carrying the scene `b1467f88`
  (proof expectation fixed in `6820289b`), 9 keys
  (`gate_true_below_reload`, `gate_false_at_reload`, `gate_false_above_reload`,
  `efficiency_zero_when_gate_false`, `efficiency_folds_power_when_gate_true`,
  `reload_counter_advances_by_edelta`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_shockwave_tower_should_consume` with Godot 4.6.2 on PATH,
  port 7777 free.
- Next: N2189 (LightBlock updateTile, same batch), then the remaining shouldConsume
  gates — most are blocked on frame-state infra (config/link, items, liquids,
  payload, targets) — see the N2188 blocker in STATUS.md.
