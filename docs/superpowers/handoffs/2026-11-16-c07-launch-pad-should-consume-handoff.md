# Handoff: N2205 — C07 LaunchPad shouldConsume gate

Date: 2026-11-16. Batch: N2205 (single slice). Status: **GREEN + gate LAUNCHED (main thread ~08:06 +07). Targeted 4/4 OK, family 8/8 OK, wiring 32/32 OK — GREEN total 44/44. Full gate Ran ~5913 expected, failures ~155, skipped 5, 0 errors. Report/spec/GOAL + commit/push NOT done.**

## Scope (verified against upstream Java + the port this run)

- **N2205 is the LaunchPad shouldConsume gate, and nothing else.** One family
  (LaunchPad: launch-pad + advanced-launch-pad share the implementation),
  one pure function (`source_launch_pad_should_consume_state`) + 1 driver
  line in `source_launch_pad_tick_buildings_state`, one proof scene. It
  closes the exact observable gap N2172 left open: LaunchPadBuild
  overrides shouldConsume (LaunchPad.java:92-95,
  `return launchCounter < launchTime;`) — once the launch counter is full,
  Java stops consuming — yet the port's driver hardcodes
  `should_consume = enabled` (SourceLaunchPadBuildState.gd:109), so a pad
  whose counter is full keeps consuming power as if the gate were open.
  updateConsumption forces efficiency to zero when the gate is false
  (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();`
  + 1992, `if(!update){`).
- **Why this item, why now:** the next deferred item after N2204 per the
  N2204 handoff ("After N2204: MassDriver / LaunchPad rows, RepairTurret
  coolant, Units.nearby live query"), and the smallest deferred row left
  in that group: one boolean over one frame key (`launch_counter`) plus
  the per-def `launchTime` constant, reusing the N2172 driver seam that
  already exists. It needs no cross-building state, no inventory tracking,
  no entity spawn, and no sense-dispatch hook.
- **Why LaunchPad beats MassDriver here:** MassDriverBuild has NO
  shouldConsume override (grep 2026-11-16: no `shouldConsume` in
  MassDriver.java), so the BuildingComp default (`return enabled;`,
  BuildingComp.java:755-756) already applies and there is no MassDriver
  shouldConsume slice to take. MassDriver's smallest remaining rows are
  sense(progress) and acceptItem, and both need more state than this gate
  (see "Why not the other deferred items").
- **Precedent:** the shouldConsume-gate pattern is established — N2201
  BuildTurret (`source_build_turret_should_consume_state`, plans_count
  absent → `should_consume = enabled`), N2191 RepairTower, N2188
  RepairTurret. N2205 follows it exactly: pure function + 1 driver line,
  targeted 4 tests, proof with 6 semantic keys (N2201 shape).
- **Frame key:** the port tracks no `launch_counter` yet
  (SourceLaunchPadBuildState.gd `_initial_frame()` returns `{}`, tick
  stamps only block_implementation / team_id / rules_state / cheating /
  enabled; grep confirms no `launch_counter` key outside comments). The
  pure function reads it with an absent → 0.0 default, so an absent key
  means "counter not observed yet" and preserves the N2172 behavior
  (`should_consume = enabled`) until the future updateTile-advance slice
  stamps `launch_counter` live — the same absent-default pattern as N2201
  plans_count and N2202 break_timer. The updateTile advance itself
  (launchCounter += edelta(), LaunchPad.java:146) is NOT this slice.
- **Per-def launchTime (open RED decision, do NOT guess now):** the
  launchTime differs per def — launch-pad 60f * 20 = 1200f
  (Blocks.java:6790-6797), advanced-launch-pad 60f * 30 = 1800f
  (Blocks.java:6800-6809); the class default is 1f (LaunchPad.java:32).
  The RED run must decide whether the pure function takes
  `(frame, launch_time)` with the driver passing the def value from the
  catalog, or the driver stamps `launch_time` on the frame first — and
  must verify what the catalog actually carries for these defs. Either
  way the gate is `launch_counter < launch_time` per def, not a single
  hardcoded constant.
- **SSOT baseline re-verified from the generated JSONs this run**
  (origin/main b72e66e0, N2204 DONE + PUSHED): symbols **11427** + slices
  **1654** + contracts **1575** + schemas **2941**; audit
  `totalSourceFunctions` 1335; defense shards **167/166**. N2205 touches
  `core/src/mindustry/world/blocks/campaign/LaunchPad.java`, so the
  defense shards are untouched — the register script's shard selection
  must be re-verified at RED time (no `campaign_slices.json` /
  `distribution_slices.json` shard files exist yet; the N2172 register
  rebuilds extension shards from `source_ssot_modules.json`).
- **Environment (checked this run):** port 7777 FREE; javalang 0.13.0
  importable (no reinstall needed; uptime 1:12, no VM restart during
  this run); Godot binary exists at `~/workspace/godot-bin/godot`
  (4.6.2-stable, symlink) but is NOT on PATH in the worker shell — the
  GREEN proof run must export `PATH="$HOME/workspace/godot-bin:$PATH"`
  first (the N2177 lesson), and the full gate must run with godot NOT
  on PATH, launched from the main thread (worker-launched gates die
  with the session — 9 recorded deaths). Worktree clean except
  pre-existing untracked `*.gd.uid` noise (never stage). HEAD b72e66e0.
- **Expected shape (estimate, verify at each step):** targeted 4/4;
  proof 6 semantic keys + `matches` + 2 harness keys; neighbours family
  + wiring 32/32; full gate Ran ~5913, failures ~155, skipped 5,
  0 errors — all Godot-absent (extrapolated from N2204: Ran 5909,
  failures 154). Files to write: `tools/mindustry_godot_transpiler/tests/test_c07_launch_pad_should_consume.py`,
  `tools/mindustry_godot_transpiler/register_c07_launch_pad_should_consume.py`,
  `godot-mindustry/tools/runtime_proofs/C07LaunchPadShouldConsumeProof.gd` / `.tscn`,
  this handoff, design-spec row, GOAL.md pointer (5-commit pattern).

## Java source evidence (all verified verbatim this run — grep 2026-11-16 ~07:3x)

- `public boolean shouldConsume(){` (LaunchPad.java:92) + `return launchCounter < launchTime;` (LaunchPad.java:94) — with the `//TODO add launch costs, maybe legacy version` comment (:93)
- `public float launchCounter;` (LaunchPad.java:84)
- `public float launchTime = 1f;` (LaunchPad.java:32) — class default; defs override it
- `launchTime = 60f * 20;` (Blocks.java:6794, launch-pad; size 3, itemCapacity 100, consumePower 4f, acceptMultipleItems = true)
- `launchTime = 60f * 30;` (Blocks.java:6804, advanced-launch-pad; size 4, itemCapacity 100, consumePower 8f, liquidCapacity 40f, consumeLiquid oil 9f/60f)
- `public boolean shouldConsume(){` + `return enabled;` (BuildingComp.java:755-756) — the default MassDriver uses and LaunchPad overrides
- `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960) + `if(!update){` (BuildingComp.java:1992)
- `public float edelta(){` + `return efficiency * delta();` (BuildingComp.java:1927-1928)
- `public class LaunchPadBuild extends Building{` (LaunchPad.java:83)
- Prior slices in this family: N2172 LaunchPad power.status (register_c07_launch_pad_power_status.py), N2171 MassDriver power.status. The N2172 register's DEFERRED list already names this exact row: "LaunchPad shouldConsume gate (launchCounter < launchTime, LaunchPad.java:92-95) -- needs launchCounter state the tick does not track yet; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent)."

## Why not the other deferred items

- **MassDriver updateTile** (MassDriver.java:133-221): the idle/accepting/shooting state machine + link validation + waitingShooters set + reload drain + rotation align + fire + dumpAccumulate — the biggest row in the group; it must itself split into several slices (reload drain alone, state transitions, fire), not one slice.
- **MassDriver sense(progress)** (MassDriver.java:224-228, `Mathf.clamp(1f - reloadCounter)`): formula is one line, but it needs a `reload_counter` frame key the port does not track plus a hook into the generic sense dispatch (SourceBlockSenseState / SourceBlockRuntimePortBridge `source_block_sense_laccess_state`) — no per-family sense slice precedent exists yet, so the surface is bigger than a driver-line gate.
- **MassDriver acceptItem** (MassDriver.java:285-288, `items.total() < itemCapacity && linkValid()`): needs `linkValid()` (MassDriver.java:346-349, `world.build(link)` + same-block/team/range checks) — cross-building tile/link state plus an items-total input, neither tracked on the frame.
- **MassDriver fire / handlePayload** (MassDriver.java:290-317 / 319-340): bullet spawn (MassDriverBolt, DriverBulletData) and payload receipt — new subsystems, not a gate.
- **MassDriver link/config / read-write / draw** (MassDriver.java:58-59, 266-282, 346-349 / 358-372 / 230-264): config, serialization, presentation — each its own slice.
- **LaunchPad updateTile** (LaunchPad.java:143-161): launchCounter advance + consume() + LaunchPayload entity spawn + items.clear + sound/Fx — the entity spawn is a new subsystem, and it also needs an items.total frame input. Own slice(s) after the gate.
- **LaunchPad sense(progress)** (LaunchPad.java:98-101, `Mathf.clamp(launchCounter / launchTime)`): same sense-dispatch hook as the MassDriver sense row; own slice.
- **LaunchPad acceptItem** (LaunchPad.java:138-140): needs items.total + first item + acceptMultipleItems — inventory frame state the port does not track yet.
- **LaunchPad draw / read-write / config-display** (LaunchPad.java:104-140 / 211-222 / 164-...): presentation / serialization / campaign sector config — each its own slice.
- **LaunchPad liquid consumer row** (advanced-launch-pad consumeLiquid oil 9f/60f, Blocks.java:6808): second consumer on one def — own slice.
- **RepairTurret coolant, Units.nearby live query:** still deferred after the MassDriver/LaunchPad rows, per the N2204 Next order.

## Next: RED N2205, then GREEN, gate, push

- Write RED tests first (4 targeted: counter below launchTime → consume; counter at/above launchTime → no consume; absent launch_counter → `should_consume = enabled` (N2172 behavior); disabled → no consume) → confirm classic RED failure (KeyError 'N2205' + missing pure function) → implement `source_launch_pad_should_consume_state` + 1 driver line → register --verify (EXACT_EXPRS verbatim in upstream) → targeted 4/4 → proof headless (PATH export first, port 7777 free) → neighbours (family + wiring 32/32) → full gate from the main thread, godot NOT on PATH → report/spec/GOAL → slice commit + docs + GOAL + hash-naming commits → push (5-commit pattern).
- After N2205: LaunchPad sense(progress), then LaunchPad updateTile advance (launchCounter advance + launch), then MassDriver sense(progress) / acceptItem, then the MassDriver updateTile split (reload drain → state transitions → fire), then RepairTurret coolant, then Units.nearby live query.

## GREEN verification + gate (main thread, ~08:02–08:06 +07)

- GREEN verified by main thread: targeted Ran 4 OK in 15.278s (re-run — the 07:45 worker left NO `n2205-green.log`); family N2172 + N2205 both OK (8/8); wiring 9/9 modules OK (32/32). GREEN total 44/44. Proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false.
- Function `source_launch_pad_should_consume_state(frame, launch_time)` at :82, driver at :183. Per-def launchTime from SOURCE_LAUNCH_PAD_LAUNCH_TIMES (launch-pad 1200.0, advanced-launch-pad 1800.0, class default 1.0) — the RED open decision resolved from Blocks.java:6790-6810.
- Note: the 08:00 worker mistook this main-thread verification run for "the N2205 worker" (its PID 13345 unittest / 13347 Godot BatteryPlacementProof were my own wiring loop). No parallel worker was running; no port collision occurred.
- Gate (main thread, PID 13554, SID 13554, ~08:06): godot NOT on PATH, javalang OK, log fresh and growing (dots + F's only, 298 bytes at launch check). Parent subshell PID 13551 stays alive. Expected: Ran ~5913, failures ~155, skipped 5, 0 errors.

## Gate attempt 1 DIED — VM restart #20; attempt 2 relaunched (15-min report run, ~08:30 +07)

- VM restart #20 ~08:20 +07 (uptime 10 min at 08:30 check): gate attempt 1 (PID 13554) died mid-run; its log stopped at 5596 bytes (dots + F's only, no summary footer) — preserved as `full-suite-n2205-gate-attempt1.log`. javalang wiped again (ModuleNotFoundError).
- Recovery this run: javalang 0.13.0 reinstalled (import OK); port 7777 FREE; godot NOT on PATH.
- Gate attempt 2 launched ~08:31 +07: `setsid nohup python3 -m unittest discover -s tests > full-suite-n2205-gate.log 2>&1 < /dev/null`, PID 3114, SID 3114. Verified alive at +49s, log 3698 bytes and growing (dots only so far). Expected footer ~08:48: Ran ~5913, failures ~155, skipped 5, 0 errors — all Godot-absent.
- Slice itself still GREEN 44/44 (targeted 4/4, family 8/8, wiring 32/32, proof matches:true) — only the full gate is pending. NO commit/push yet: push waits for the gate footer.

## Gate saga (main thread, ~08:33 +07)

- Gate attempt 1 (main thread, PID 13554, ~08:06): DIED on **VM restart #20** (~08:20, uptime 13 min at the 08:33 check). Log had reached 5582 bytes at the 08:15 check; no footer. Restart #20 also wiped javalang — the 08:30 worker reinstalled 0.13.0 (verified OK now).
- Gate attempt 2 (worker-launched, PID 3114, ~08:31): DIED with the worker session — log stopped at 3710 bytes (3572 dots + 133 F + 0 E + 5 s), no footer. 10th worker-session gate death on record. The worker's "relaunch" claim was true about the launch but the gate did not survive its session, as always.
- Gate attempt 3 (main thread, PID 3298, SID 3298, ~08:33): godot NOT on PATH, javalang OK, log fresh and growing (dots + F's only, 322 bytes at launch check). Parent subshell PID 3295 stays alive. Expected: Ran ~5913, failures ~155, skipped 5, 0 errors.
