# Report — N2133: checkTier from the module tiers

Date: 2026-11-12. Batch: N2133 (single slice). Status: GREEN done in this VM, targeted tests **24/24 OK** (N2133 4/4 + N2124 4/4 + N2129 4/4 + N2130 4/4 + N2131 4/4 + N2132 4/4). **Godot proof GREEN 2026-11-12 ~12:35 +07: Godot 4.6.2-stable Linux (build 71f334935, identical to the Windows 4.6.2 build) ran `C06UnitAssemblerCheckTierProof.tscn` headless in this VM — 7 keys, all true, `matches: true`. Inclusive full gate finished ~13:47 +07 (Ran 5629 in 1657.940s, failures=84, skipped=5, 0 errors — all 84 Godot-proof failures, no Godot binary on PATH). Committed + pushed to origin main (fork Lasthope1508) in the 14:00 cron run.**

## What changed

The assembler's `plan()` clamp already read the tier (N2124: `plans.get(Math.min(currentTier, plans.size - 1))`), but the tier itself still came from the frame's stored `current_tier` — nothing in the port computed it from the attached modules. Java derives it on every module event: `UnitAssemblerBuild.checkTier()` (UnitAssembler.java:363-377) sorts the modules by tier, then climbs from 0 while each module is the current max or one above it, stopping at the first tier gap (`//tier gap, TODO warning?`); `updateModules` (UnitAssembler.java:355) and `removeModule` (UnitAssembler.java:360) both call it after changing the module list — the tier only changes on a module event, never per tick.

N2133 adds `SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state(frame)`: it sorts the frame's `modules` ints, climbs while each is `max` or `max + 1`, breaks at the first gap, and returns `current_tier` + sorted `module_tiers` + `tier_gap` under the new owner const `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_CHECK_TIER_STATE`. The shouldConsume gate's assembler branch now derives the plan tier from checkTier when the frame carries a `modules` list (`if frame.has("modules"): tier = int(source_unit_factory_assembler_check_tier_state(frame).get("current_tier", tier))`), then calls `source_unit_factory_assembler_plan_state(block, tier)`. A frame WITHOUT a `modules` list keeps its stored `current_tier` — Java only re-derives the tier on a module event, so a module-less frame must not reset to 0. That guard keeps the N2124 proof frames (which set `current_tier` with no modules list) unaffected; the N2124 test module needs no change.

## Proof keys (new scene, 7 keys)

- `check_tier_no_modules_zero`: modules `[]` → current_tier 0, module_tiers `[]`, tier_gap false.
- `check_tier_single_tier_one`: `[1]` → 1, `[1]`, false.
- `check_tier_sequential_one_two`: `[1, 2]` → 2, `[1, 2]`, false.
- `check_tier_gap_stops_climb`: `[1, 3]` → 1, `[1, 3]`, true (3 is neither max 1 nor max+1 2).
- `check_tier_unsorted_input_sorted`: `[2, 1]` → 2, `[1, 2]`, false (sort first).
- `check_tier_duplicate_tier`: `[1, 1, 2]` → 2, `[1, 1, 2]`, false.
- `check_tier_gap_after_two`: `[1, 2, 4]` → 2, `[1, 2, 4]`, true.

## Verified numbers (measured in this VM)

- Test module `test_c06_unit_assembler_check_tier.py`: **4/4 OK** — registration (ledger N2133, 4 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (4 symbols + 14 exprs over UnitAssembler.java + UnitAssemblerModule.java, all found verbatim), source-text (checkTier function exists; gate calls `source_unit_factory_assembler_check_tier_state(frame)` behind a `frame.has("modules")` guard; proof has the 7 new keys), and the Godot proof test (7 keys, all true, `matches: true`).
- RED run (12:15 cron run): 4 tests, 2 failures + 2 errors, all expected — registration `KeyError: 'N2133'`, evidence errors on the missing ledger entry, source-text `AssertionError` (function not implemented), proof returncode 1 (scene file did not exist yet).
- Targeted run with Godot on PATH: **24/24 OK in 147.5s** (N2133 4/4 + N2124 4/4 + N2129 4/4 + N2130 4/4 + N2131 4/4 + N2132 4/4).
- `git diff --check` clean.
- SSOT +4/+1/+1/+2 → **11260 / 1584 / 1505 / 2801**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2133 4/4 + neighbours 20/20 (proof green, see above).
- Godot proof: **GREEN 2026-11-12 ~12:35 +07** — 7 keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2133 module (log `tools/mindustry_godot_transpiler/full-suite-n2133-gate.log`, 211 modules): attempts 1, 2 and 4 died when their spawning cron session ended (logs frozen at 3427 / 3417 / 3417 bytes, no summary); attempt 3 died in a VM restart ~13:12 +07 (log frozen at 5308 bytes; the restart also wiped system-wide javalang, reinstalled before attempt 4 per the known rule). Attempt 5 started detached with `setsid` ~13:19 +07 (PID 2344, own session SID 2344) and **finished ~13:47 +07: Ran 5629 in 1657.940s, FAILED (failures=84, skipped=5), 0 errors** — all 84 verified individually as Godot-proof failures (84 plain `assertIsNotNone(godot)`, 0 other failure shapes, 0 errors); the N2133 module contributes only its proof test, its 3 non-proof tests pass. Zero errors, zero non-Godot failures: the gate is clean except Godot.
- The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the live production/tick wiring, not checkTier itself.
- The live-loop module link/unlink call sites (`updateModules`/`removeModule` from `UnitAssemblerModuleBuild` link/unlink, UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet, so the frame's `modules` list is an input, not something the tick maintains.
- Battery live `enabled` stamp; disabled-belt efficiency half; unit-factory shouldConsume wiring to the power stamp; live production wiring (progress advance + the call at completion, including the intake call site `moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c06-unit-assembler-check-tier-handoff.md` for the full detail.
