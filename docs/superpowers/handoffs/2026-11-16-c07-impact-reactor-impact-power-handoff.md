# Handoff — N2216 ImpactReactor impactPower event (C07)

## Status: GREEN COMPLETE (tests + proof) — targeted 4/4 + family 16/16 + wiring 32/32 + register --verify 33/33; proof 11 keys matches:true. Full gate + 5-commit pattern + push remain for the main thread. NOT committed, NOT pushed.

Next slice after N2215 (DONE + PUSHED, main 405423ac): the
impactPower event, `ImpactReactorBuild.updateTile()`
ImpactReactor.java:87-88 — the piece N2186 explicitly deferred
("impactPower event — own event slice").

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_impact_reactor_impact_power.py`
  (4 tests), register `tools/mindustry_godot_transpiler/register_c07_impact_reactor_impact_power.py`,
  proof `godot-mindustry/tools/runtime_proofs/C07ImpactReactorImpactPowerProof.gd` + `.tscn`.
- Targeted RED: Ran 4, failures=2, errors=2 — classic RED (KeyError
  'N2216' ×2 in the registration + exact-evidence tests, missing
  `source_impact_reactor_impact_power_state` in the state test, the
  reference test fails on Godot parse errors — 8× `Static function
  "source_impact_reactor_impact_power_state()" not found in base
  "SourceImpactReactorBuildState"` + `Failed to load script`); log
  `hidden_files/n2216-red.log` (10.815s).
- Register --verify 33/33 (31 exact + 1 input + 1 output), exit 0.
- javalang 0.13.0 OK at run start (no reinstall needed). Port 7777 free, no parallel run active. No VM restart during this run.

## Scoping pinned in RED (do not re-decide in GREEN)

- One pure function: `source_impact_reactor_impact_power_state(frame)` returning
  `{"impact_power_fired": ...}` — ONLY that key. NO delta parameter:
  the Java lines :80/:87-88 use no time at all (unlike the N2186
  warmup advance and the N2187 consume timer, which take delta).
  Inputs read from the frame: `efficiency` (folded, set by
  update_consumption_state earlier in the same tick), `power_status`
  (live, stamped by the N2142 graph update), `enabled`,
  `production_efficiency` (PREVIOUS tick's value, stamped by N2186
  last tick; absent -> 0.0, `public float productionEfficiency =
  0.0f;`, PowerGenerator.java:96). NO warmup input — the event check
  reads getPowerProduction(), which reads productionEfficiency, not
  warmup. NO new frame key is invented: `impact_power_fired` is the
  stamp this slice adds.
- KEY SUBTLETY — verified in RED from the exact Java, not taken on
  trust: `productionEfficiency` is only reassigned at
  ImpactReactor.java:100 (`productionEfficiency = Mathf.pow(warmup,
  5f);`), AFTER the event check at :87-88, so both
  getPowerProduction() calls (:80 and :87) read the SAME
  previous-tick productionEfficiency. Java order inside updateTile:
  prevOut (:80) -> warmup advance (:82-84) -> event check (:87-88)
  -> consume timer (:91-92) -> totalProgress (:98) ->
  productionEfficiency (:100). In the port, N2186 bundles the warmup
  advance + totalProgress + productionEfficiency and N2187 bundles
  the consume timer, so the driver MUST call the event function
  BEFORE the N2186 production step — otherwise the production step
  overwrites frame["production_efficiency"] with the new value and
  the event would read this tick's efficiency instead of Java's
  previous-tick one. The state test pins this order with an index
  comparison (event call < production call).
- requestedPower, read exactly (ConsumePower.java:56-60, `public
  float requestedPower(Building entity){` / `return buffered ?` /
  `(1f - entity.power.status) * capacity :` / `usage *
  (entity.shouldConsume() ? 1f : 0f);`): the impact reactor's
  consPower is plain — `consumePower(25f);` (Blocks.java:2642) ->
  `return consume(new ConsumePower(powerPerTick, 0.0f, false));`
  (Block.java:1140-1142), buffered=false, capacity=0 — so requested
  = 25.0 * (shouldConsume ? 1 : 0). ImpactReactorBuild has NO
  shouldConsume override, so the BuildingComp default applies
  (`public boolean shouldConsume(){` / `return enabled;`,
  BuildingComp.java:755-756): requested = 25.0 if enabled else 0.0.
- getPowerProduction (PowerGenerator.java:156-158, `public float
  getPowerProduction(){` / `return enabled ? powerProduction *
  productionEfficiency : 0f;`) with `powerProduction = 130f;`
  (Blocks.java:2636): production = 130.0 * production_efficiency
  if enabled else 0.0.
- The condition, kept two-step exactly like Java: `prevOut =
  consPower != null && getPowerProduction() <=
  consPower.requestedPower(this);` (ImpactReactor.java:80) then
  `if(!prevOut && consPower != null && (getPowerProduction() >
  consPower.requestedPower(this))){` / `Events.fire(Trigger.impactPower);`
  (ImpactReactor.java:87-88). consPower is non-null in the driver
  branch (the driver only calls inside has_power_consumer), so the
  `consPower != null` conjuncts are true there; the code keeps the
  two-step form so both lines are pinned verbatim. Since !prevOut
  is exactly production > requested, fired is equivalent to gate
  holds && production > requested — but the code does NOT collapse
  it, so the Java shape stays readable.
- The event check sits INSIDE the warmup hard gate
  (ImpactReactor.java:79, `if(efficiency >= 0.9999f && power.status
  >= 0.99f){`, keep on ONE comment line, the N2148 shootWarmup
  lesson: a split line fails this test) — no fire when the gate
  fails, however high production is.
- The event itself has no game-state effect beyond firing the
  achievement trigger: `trigger(Trigger.impactPower,
  powerupImpactReactor);` (GameService.java:383), `impactPower,`
  (EventType.java:26). The port has no Events/achievement system to
  fire into, so the stamp `frame["impact_power_fired"]` is the
  observable fact that it fired this tick (deferred: completing the
  achievement waits for an Events/achievement slice if one is ever
  built). This is the FIRST stamp of `frame["impact_power_fired"]`.
- Driver placement: BEFORE the N2186 production call in
  `source_impact_reactor_tick_buildings_state`
  (SourceImpactReactorBuildState.gd:128), inside the existing
  has_power_consumer branch — exactly 1 driver tick line plus its
  stamp line. The driver reads the FOLDED efficiency and live
  power.status already on the frame (N2186 precedent).
- Proof math pinned (8 semantic keys): production 65 > 25 fires
  (pe 0.5); 13 <= 25 no fire (pe 0.1); EXACT equality 25.0 no fire
  (pe 25.0/130.0 — 130.0 * (25.0/130.0) == 25.0 exactly in IEEE
  doubles, verified in Python before RED); disabled no fire
  (production 0, requested 0 -> prevOut true); efficiency gate
  fails no fire (pe 1.0, efficiency 0.5); power.status gate fails
  no fire (pe 1.0, power_status 0.5); just above threshold fires
  (pe 0.2 -> 26 > 25); cold no fire (pe 0.0 -> 0 <= 25).
- SSOT before: 11449/1665/1588/2967 (verified from disk at RED).
  Expected after register: 11450/1666/1589/2969 (symbols +1, ledger
  +1, contracts +1, schema +2 — the N2215 precedent: 1 result
  symbol, 1 input + 1 result schema; NO shard change expected —
  N2213/N2214/N2215 precedent).

## GREEN plan

1. Add `source_impact_reactor_impact_power_state` to
   `godot-mindustry/src/game/SourceImpactReactorBuildState.gd`
   (after the N2187 consume function, before the driver) with the
   EXACT lines the test pins — signature, the `var efficiency` /
   `var power_status` / `var enabled` / `var production_efficiency`
   reads, the `var power_production` / `var requested_power` /
   `var prev_out` computation, the `if not prev_out and
   power_production > requested_power:` fire, and the `return
   {"impact_power_fired": impact_power_fired}` verbatim. The
   function comment MUST contain, verbatim, every Java line the
   test asserts (gate :79, prevOut :80, warmup advance :82, event
   :87-88, consume timer :91-92, totalProgress :98,
   productionEfficiency :100, getPowerProduction :156-158,
   productionEfficiency default :96, requestedPower :56-60,
   consumePower :1140-1142, shouldConsume :755-756, powerProduction
   130f, consumePower 25f, impactPower trigger :26/:383).
2. Driver tick line in `source_impact_reactor_tick_buildings_state`,
   BEFORE the N2186 production call: call
   `source_impact_reactor_impact_power_state(frame)` — the test pins
   this exact call line and the BEFORE-production order. Stamp the
   returned `impact_power_fired` live (`frame["impact_power_fired"]`).
3. Run register (NOT --verify) to add N2216 to SSOT, targeted GREEN
   4/4, family ImpactReactor (power_status + power_production +
   consume + impact_power, 16 tests) + wiring-standard set (same 9
   modules / 32 tests as N2215), Godot proof (11 keys: 8 semantic +
   matches + 2 harness), full gate from the main thread only, then
   the classic 5-commit pattern + push. SSOT before:
   11449/1665/1588/2967.
4. Check port 7777 free before any proof run; never run proof scenes
   in parallel with another run. Check `git fetch origin` +
   origin/main before pushing (validation agent merges regularly).
   NOTE: godot is NOT on PATH in this shell — the binary lives at
   `~/workspace/godot-bin/godot`; GREEN must run the reference/proof
   tests with `PATH=~/workspace/godot-bin:$PATH`, otherwise the
   reference test fails with `godot is None`.

## GREEN (this run — PARTIAL: wiring + standalone proof interrupted by cron timeout)

- Pure `source_impact_reactor_impact_power_state(frame)` added to
  `SourceImpactReactorBuildState.gd` (after the N2187 consume
  function) with the EXACT lines the test pins, plus 1 driver tick
  line BEFORE the N2186 production call
  (`source_impact_reactor_impact_power_state(frame)`) — stamps
  `frame["impact_power_fired"]` live, the FIRST stamp of that key.
  The BEFORE-production placement is the pinned subtlety: both
  getPowerProduction() calls read the previous tick's
  productionEfficiency (ImpactReactor.java:100 reassigns it only
  after the :87-88 check).
- Targeted **4/4 OK in 15.384s** (log `hidden_files/n2216-green.log`).
  Proof JSON 11 keys, all true, `matches:true`.
- Family ImpactReactor **16/16 OK in 59.109s** (power_status +
  power_production + consume + impact_power; log `n2216-family.log`).
- Register run (not --verify): SSOT 11449/1665/1588/2967 →
  **11450/1666/1589/2969** (symbols +1, ledger +1, contracts +1,
  schema +2 — exactly as scoped). Audit report unchanged (1335).
  Register --verify **33/33**, exit 0. `git diff --check` clean.
- CORRECTION to the RED shard expectation: the register DID change
  two shards — `source_modules/power_api_contracts.json` and
  `source_modules/power_slices.json` (power_slices 113→114,
  power_api_contracts 92→93) — pure additions of the N2216 entry,
  exactly the N2186 precedent (power_slices 111→112,
  power_api_contracts 90→91). The "NO shard change" line in RED was
  the RepairTurret (N2213/N2214/N2215) precedent, which does not
  apply to ImpactReactor — power shards mirror the power-domain
  ledger/contracts. No other shard changed.
- Standalone Godot proof (Linux binary, headless): covered by the
  reference test inside the targeted GREEN run (11 keys all true,
  `matches:true`, no ERROR lines, log `n2216-green.log`).
- Port 7777 free before every proof run; no parallel run active.
  javalang 0.13.0 OK at run start (no reinstall needed). No VM
  restart during this run.
- Nothing staged, committed, or pushed (per task brief). Design spec
  / report / GOAL.md §5 NOT touched — main thread handles them with
  the gate + push.

## WIRING RERUN (cron 20:15 run, 2026-11-16 ~20:16-20:26 +07)

- The first wiring attempt in this cron run was killed by a VM/service
  restart at ~121s (uptime reset to 0 min; the run's log
  `n2216-wiring.log` shows 7 per-module sections OK but is ambiguous
  — 25 tests, first section unattributed, 2 modules unaccounted —
  so it is NOT counted as a result; kept on disk for the record).
- VM restart #26 wiped javalang — reinstalled 0.13.0 (`pip install
  --break-system-packages -r
  tools/mindustry_godot_transpiler/requirements.txt`), imports OK.
- Clean re-run into `hidden_files/n2216-wiring-rerun.log`: single
  `python3 -m unittest` invocation, 9 modules, **32 dots, Ran 32
  tests in 244.310s, OK, exit 0** (slower than N2215's 120s — first
  run after the restart). Port 7777 free before the run; no parallel
  run active.
- GREEN total now: targeted 4/4 + family 16/16 + wiring 32/32 =
  **52/52**. Proof JSON re-read from disk: 11 keys, all true,
  `matches:true` (8 semantic + matches + 2 harness).
- Re-verified by this run: register --verify **33/33 exprs present,
  exit 0**; symbols on disk 11450, contracts 1589; `git diff --check`
  clean. Working tree holds only the 7 N2216 slice files (modified)
  + handoff + proof .gd/.tscn (untracked); nothing staged.

## INCOMPLETE — needs main thread

- Full gate — MUST be launched from the main thread (worker sessions
  die with the session; N2214 precedent; a gate is ~1000s, over the
  ~900s cron timeout). Expected: Ran ~5957, failures ~166, skipped 5,
  0 errors — all Godot-absent asserts.
- Standalone proof log `n2216-proof.log` was NOT created; the proof
  evidence lives in `n2216-green.log` (reference test) + the proof
  JSON on disk — re-run the scene standalone only if a separate proof
  log is wanted.

## Remaining (main thread)

1. Full gate — MUST be launched from the main thread (worker sessions die with the session; N2214 precedent). Expected: Ran ~5957, failures ~166, skipped 5, 0 errors — all Godot-absent asserts.
2. The classic 5-commit pattern + push (slice commit, docs commit, GOAL.md §5 Windows debt line, hash-naming commit, handoff-status commit). Check `git fetch origin` + origin/main before pushing (validation agent merges regularly).

## After N2216

Accelerator battery side, or RepairTurret read/write persistence /
drawBeam rows, per backlog. (Do NOT start the C08 inventory unless
the user asks.)

## GREEN verification + gate (main thread, ~20:29 +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 16.325s; family log Ran 16 OK (59.109s, ImpactReactor N2182+N2186+N2187+N2216); wiring re-run log Ran 32 OK in 244.310s (single footer, separate file `n2216-wiring-rerun.log` — clean). GREEN total 52/52. Proof JSON 11 keys (8 semantic + matches + 2 harness), matches:true, 0 false. Register --verify 33/33 exprs present, exit 0.
- Pure function `source_impact_reactor_impact_power_state(frame)` at :127 + 1 driver tick line (:206) before the N2186 production — previous-tick efficiency subtlety per scope.
- SSOT 11449/1665/1588/2967 → **11450/1666/1589/2969** (symbols +1, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (verify at completion).
- Wiring saga: the worker's first wiring run and the main-thread loop run wrote to the SAME log file (`n2216-wiring.log`) and mixed it — only 25 tests survived in that file (7 lost: test_factory_live_loop + test_power_graph_live_update_binding). VM restart #26 ~20:20 killed the worker's first run and wiped javalang (reinstalled 0.13.0, imports OK). The worker re-ran the wiring set as ONE unittest invocation (all 9 modules) into a separate file — 32/32 clean. Lesson: never share one wiring log file between two concurrent runs.
- Gate (main thread, PID 2525, SID 2525, ~20:29): godot NOT on PATH, javalang OK, no stray gate before launch, log fresh and growing (dots + F only, 187 bytes at launch check). Parent subshell PID 2519 stays alive. Expected: Ran ~5957, failures ~166, skipped 5, 0 errors.

## Gate VERIFIED + completion (21:00 cron run, ~21:0x +07)

- Gate (main thread, PID 2525, launched ~20:29): **Ran 5957 tests in 1915.891s — FAILED (failures=166, skipped=5), 0 errors.** All 166 verified Godot-absent: 166 × `AssertionError: unexpectedly None`, 0 `ERROR:` lines, 166 `^FAIL:` lines. +4 tests / +1 failure vs N2215 (5953/165): the 4 new N2216 tests; the +1 failure is the new N2216 reference/proof test (Godot-absent in the gate — its real proof ran green headless at GREEN and again in this run's targeted re-run). The only other impact FAIL lines are the pre-existing sibling proof tests (N2182 power_status, N2186 power_production, N2187 consume). No failure names any N2216 function except that one proof test. Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2216-gate.log` (untracked, never staged).
- Re-verified by this run (21:00 cron): targeted **4/4 OK in 30.378s** (log `tools/mindustry_godot_transpiler/n2216-green-mainverify.log`, live Godot proof re-run, proof JSON re-generated 11 keys matches:true, 0 false); family ImpactReactor **16/16 OK in 101.554s** (log `n2216-family-mainverify.log`); register --verify **33/33**, exit 0; SSOT verified from disk **11450/1666/1589/2969** (symbols/ledger/contracts/schema), audit 1335; `git diff --check` clean.
- CORRECTION (shard change): the register DID change two shards — `source_modules/power_api_contracts.json` and `source_modules/power_slices.json` (pure additions of the N2216 entry, N2186 precedent). The "NO shard change (verify at completion)" line in the main-thread verification section above is WRONG; the RED expectation was also wrong for the power domain. Slice commit carries 11 files (incl. the 2 shards).
- CORRECTION (lost logs): the `n2216-green.log` / `n2216-family.log` / `n2216-wiring.log` / `n2216-wiring-rerun.log` files this handoff references are NOT on disk (lost in VM restart #26 / worker-session death; `hidden_files/` under handoffs does not exist). The numbers were re-verified this run from fresh re-runs (targeted + family, logs above) and the gate log on disk. The wiring 32/32 claim rests on the handoff's main-thread note + the gate, which re-covers all 9 wiring modules (their non-Godot tests pass inside the gate; only Godot-absent failures) — the wiring set was NOT re-run this run (time budget before the cron timeout).
- Completion: fast-forwarded origin/main 405423ac → f704a5dc (PR #13 validation merge, docs-only) before the 5 commits — no rebase needed. Slice commit (11 files) → docs commit (report + handoff + spec Done 1666 + N2216 row) → GOAL.md §5 debt line → hash-naming commit → handoff-status commit → push to origin main in this tick.
