# Handoff — N2133: checkTier from the module tiers

Date: 2026-11-12. Batch: N2133 (single slice). Status: **DONE + PUSHED 2026-11-12 ~14:05 +07 (14:00 cron run): full gate attempt 5 FINISHED clean except Godot (Ran 5629 in 1657.940s, failures=84, skipped=5, 0 errors — all 84 verified `assertIsNotNone(godot)`), targeted 24/24 OK, Godot proof GREEN (7 keys). Commit + push to origin main (fork Lasthope1508) — see "Commit" below.**

## RED progress (12:15 cron run, 2026-11-12 ~12:15-12:20 +07)

- State at RED time: main at a016800 (N2132 merged + pushed); working tree clean except untracked `*.gd.uid` files (never stage), untracked gate logs, and the Windows queue doc `docs/superpowers/reports/2026-11-12-c06-godot-test-queue.md` (another thread — never stage).
- javalang 0.13.0 present, Godot 4.6.2 present (`~/workspace/godot-bin/godot` symlink; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c06_unit_assembler_check_tier.py` (4 tests). RED run: **Ran 4 tests in 1.6s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2133'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `source_unit_factory_assembler_check_tier_state` does not exist yet;
  - proof: Godot returncode 1, `Cannot open file 'res://tools/runtime_proofs/C06UnitAssemblerCheckTierProof.tscn'` — the new proof scene is GREEN work.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module).

## What this batch is

The tier-climb half of the assembler work, the next item on the N2132 "Next" list: `UnitAssemblerBuild.checkTier()` (UnitAssembler.java:363-377) derives `currentTier` from the attached `UnitAssemblerModuleBuild` modules — sort by tier, climb while each module is the current max or one above it, stop at the first tier gap. The port's `plan()` clamp already reads the tier (N2124: `plans.get(Math.min(currentTier, plans.size - 1))`), but the tier itself still comes from the frame's stored `current_tier` — nothing in the port computes it from the modules yet.

## Exact upstream evidence (all 14 exprs verified verbatim in this VM)

- `UnitAssemblerBuild.checkTier()` (UnitAssembler.java:363-377): `public void checkTier(){` / `modules.sort(b -> b.tier());` / `int max = 0;` / `if(mod.tier() == max || mod.tier() == max + 1){` / `max = mod.tier();` / `currentTier = max;` — plus the gap comment `//tier gap, TODO warning?` on the else branch.
- The field it writes (UnitAssembler.java:326): `public int currentTier = 0;` — and the module list it reads (UnitAssembler.java:323): `public Seq<UnitAssemblerModuleBuild> modules = new Seq<>();`.
- The call sites (UnitAssembler.java:355, 360): `updateModules` does `modules.addUnique(build);` then `checkTier();`; `removeModule` does `modules.remove(build);` then `checkTier();` — the tier only changes on a module event, never per tick.
- The module tier (UnitAssemblerModule.java:22, 85-86): `public int tier = 1;` / `public int tier(){` / `return tier;` — a module block's tier is content-defined, default 1.
- The consumer of the tier (UnitAssembler.java:383-385): `return plans.get(Math.min(currentTier, plans.size - 1));` — already in the port (N2124).

## Design (decided in RED, implement in GREEN)

- **New function, no new contracts beyond the function itself.** `SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state(frame)` — the frame's `modules` list is the module tiers (each `UnitAssemblerModuleBuild.tier()`; the frame carries them as a plain list of ints, same minimal-frame convention as the N2129 `blocks` dict). Returns `source_owner` (new const `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_CHECK_TIER_STATE` in `SourceRuntimeOwnerUnitBuildingRegistry.gd`), `current_tier`, `module_tiers` (the sorted list), `tier_gap` (whether a gap stopped the climb).
- **Gate wiring (same pattern as N2132):** the shouldConsume assembler branch derives the plan tier from the module tiers when the frame carries them — `if frame.has("modules"): tier = int(source_unit_factory_assembler_check_tier_state(frame).get("current_tier", tier))` — then `source_unit_factory_assembler_plan_state(block, tier)`. A frame WITHOUT a `modules` list keeps its stored `current_tier` (Java only re-derives the tier on a module event, so a module-less frame must not reset to 0). This guard is what keeps the N2124 proof frames — which set `current_tier` with no modules list — unaffected. No existing test module asserts `frame.get("current_tier", 0)` in the gate (checked in RED), so the wiring breaks no neighbour.
- **4 new symbols** (N2129 pattern — input + results, no bare function symbol):
  - `source_unit_factory_assembler_check_tier_state_input.frame` — java_expr `public Seq<UnitAssemblerModuleBuild> modules = new Seq<>();`
  - `source_unit_factory_assembler_check_tier_state_result.current_tier` — java_expr `currentTier = max;`
  - `source_unit_factory_assembler_check_tier_state_result.module_tiers` — java_expr `modules.sort(b -> b.tier());`
  - `source_unit_factory_assembler_check_tier_state_result.tier_gap` — java_expr `//tier gap, TODO warning?`
  - All `java_source` UnitAssembler.java, all `godot_owner` `SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state`.
- Ledger N2133 entry: `status: done`, `java_source: core/src/mindustry/world/blocks/units/UnitAssembler.java`, `java_class: mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild`, `java_method: UnitAssemblerBuild.checkTier()`, `godot_owner: SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state`, `exact_exprs`: the 14 exprs above, `source_symbols`: the 4 new symbols, `tests`: the 4 test names of the new module, `runtime_proof: /root/C06UnitAssemblerCheckTierProof`, `deferred_exprs`: lastTier/progress reset, live production wiring, unit-factory power-stamp wiring, battery live `enabled` stamp, disabled-belt efficiency half, Units.canCreate live evaluation, C06–C12 open.
- Register script `register_c06_unit_assembler_check_tier.py` (GREEN, modeled on the N2132 one): writes the ledger N2133 entry + the 4 symbols; rebuilds the SSOT shards. Expected SSOT after GREEN: **11260 / 1584 / 1504+? / 2799+?** — symbols +4 and slices +1 are certain; contracts/schemas deltas TBD at GREEN (N2129 precedent for a new function was +1 contract / +2 schema; verify from the rebuilt shards, do not assume). Audit stays 1335.
- Proof updates: NEW scene `C06UnitAssemblerCheckTierProof` (.tscn + .gd, prefix `C_06_UNIT_ASSEMBLER_CHECK_TIER_PROOF `; proof JSON is gitignored, never stage it). 7 keys:
  - `check_tier_no_modules_zero`: modules `[]` → current_tier 0, module_tiers `[]`, tier_gap false.
  - `check_tier_single_tier_one`: `[1]` → 1, `[1]`, false.
  - `check_tier_sequential_one_two`: `[1, 2]` → 2, `[1, 2]`, false.
  - `check_tier_gap_stops_climb`: `[1, 3]` → 1, `[1, 3]`, true (3 is neither max 1 nor max+1 2).
  - `check_tier_unsorted_input_sorted`: `[2, 1]` → 2, `[1, 2]`, false (sort first).
  - `check_tier_duplicate_tier`: `[1, 1, 2]` → 2, `[1, 1, 2]`, false.
  - `check_tier_gap_after_two`: `[1, 2, 4]` → 2, `[1, 2, 4]`, true.
  - Model the scene on `C06UnitAssemblerPayloadProof.gd` (same Main.tscn boot, `enter_campaign_playable_slice`, call the function directly on frames — checkTier is pure, no block needed).
- The N2124 test module needs NO change: its proof test asserts returncode 0, no `ERROR:`, one proof line, `matches` true — all still hold because the gate guard keeps module-less frames on their stored tier.

## Files changed (RED only)

- `tools/mindustry_godot_transpiler/tests/test_c06_unit_assembler_check_tier.py` (new, 4 tests): registration (ledger N2133, 4 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (4 symbols + 14 exprs over UnitAssembler.java + UnitAssemblerModule.java), source-text (checkTier function exists; gate calls `source_unit_factory_assembler_check_tier_state(frame)` behind a `frame.has("modules")` guard; proof has the 7 new keys), Godot proof (`C06UnitAssemblerCheckTierProof.tscn`, prefix `C_06_UNIT_ASSEMBLER_CHECK_TIER_PROOF `, the 7 keys true).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests, 2 failures + 2 errors, all expected** — registration `KeyError: 'N2133'`, evidence errors on the missing ledger entry, source-text `AssertionError` (function not implemented), proof returncode 1 (scene file does not exist yet).
- Exact-expr pre-check: **14/14 exprs found verbatim** in the 2 slice sources (UnitAssembler.java, UnitAssemblerModule.java).
- `git diff --check` clean.
- State at RED time: main at a016800 (N2132 merged + pushed to the fork 2026-11-12 ~12:05); SSOT 11256 / 1583 / 1504 / 2799; audit 1335.

## GREEN progress (12:30 cron run, 2026-11-12 ~12:30-12:45 +07)

- Register script written + run: `tools/mindustry_godot_transpiler/register_c06_unit_assembler_check_tier.py` (modeled on the N2129 one: ledger N2133 entry + 4 new symbols + 1 contract + 2 schemas). **SSOT verified: 11260 / 1584 / 1505 / 2801** — symbols +4, slices +1, contracts +1, schemas +2, exactly as expected; audit stays 1335.
- Owner const added: `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_CHECK_TIER_STATE` in `SourceRuntimeOwnerUnitBuildingRegistry.gd`.
- Function implemented in `SourceUnitFactoryBuildState.gd`: `source_unit_factory_assembler_check_tier_state(frame)` — sort the frame's `modules` ints, climb while each is max or max + 1, break at the first gap (`tier_gap`), return `current_tier` + sorted `module_tiers` + `tier_gap`.
- Gate wiring in `source_unit_factory_should_consume_state`: assembler branch derives `tier` from checkTier when `frame.has("modules")`, else keeps the stored `current_tier`; `source_unit_factory_assembler_plan_state(block, tier)`. Comment updated.
- Proof scene written: `C06UnitAssemblerCheckTierProof` (.tscn + .gd, prefix `C_06_UNIT_ASSEMBLER_CHECK_TIER_PROOF `, 7 keys + 2 registry keys).
- **Targeted tests GREEN 24/24 in 147.5s** (N2133 4/4 + N2124 4/4 + N2129 4/4 + N2130 4/4 + N2131 4/4 + N2132 4/4, Godot on PATH).
- **Godot proof GREEN** (via the proof test + proof JSON): 7 keys all true, `matches: true`, registry keys true, no `ERROR:`.
- `git diff --check` clean.
- **Full gate attempt 1 DIED ~12:40 +07** (same session-end signature as N2131 attempt 2 / N2132 attempt 1): PID 10934 gone, no python/unittest process left, log frozen at 3427 bytes (last write 12:40:35 +07, tail `F..F..` — the expected Godot-proof shape). Frozen log preserved as `full-suite-n2133-gate-attempt1.log`.
- **Full gate attempt 2 STARTED ~12:46 +07** (12:45 cron run): `setsid nohup python3 -m unittest discover -s tests`, PID 11744 (own session SID 11744), log `full-suite-n2133-gate.log` (growing: 981 → 2050 bytes in 15 s, dots only so far), no Godot on PATH. javalang 0.13.0 verified present before restart. Expected done ~13:05-13:15 +07; expected **Ran ~5629, FAILED (failures=84, skipped=5), 0 errors** — all 84 `assertIsNotNone(godot)` (83 inherited + the new N2133 proof test).
- **Full gate attempt 2 DIED ~12:48 +07** (same session-end signature): PID 11744 gone, no python/unittest process left, log frozen at 3417 bytes (last write 12:48:00 +07). Frozen log preserved as `full-suite-n2133-gate-attempt2.log`.
- **Full gate attempt 3 STARTED ~12:51 +07** (main-thread restart after the 12:45 report): `setsid nohup python3 -m unittest discover -s tests`, PID 12128 (own session SID 12128, verified; log growing 3414 → 3425 bytes, dots + F in the expected Godot-proof shape), no Godot on PATH. javalang 0.13.0 verified present before restart. Expected done ~13:20-13:25 +07; expected **Ran ~5629, FAILED (failures=84, skipped=5), 0 errors** — all 84 `assertIsNotNone(godot)`. **Do NOT start another gate while PID 12128 is running; verify its result in the next run(s) before commit/push.**

## Gate attempt 3 death + attempt 4 (13:15 cron run, 2026-11-12 ~13:15-13:17 +07)

- **Attempt 3 DIED ~13:12 +07 — VM RESTART, not session-end:** `uptime` shows the VM booted ~13:12 +07 (up 4 min at 13:16); attempt-3 log frozen at 5308 bytes (last write 13:12:07 +07, dots only). Frozen log preserved as `full-suite-n2133-gate-attempt3.log`. The restart also wiped system-wide javalang (per the known rule: /usr/local is tmpfs-backed) — `import javalang` failed on check.
- **javalang 0.13.0 reinstalled** (`pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt`, loader check OK) before restarting the gate.
- **Full gate attempt 4 STARTED ~13:16 +07:** `setsid nohup python3 -m unittest discover -s tests`, PID 2103 (own session SID 2103, PPID 2099, verified; log `full-suite-n2133-gate.log` growing: 1543 → 1544 bytes in ~30 s, dots only so far), no Godot on PATH. Expected done ~13:35-13:50 +07; expected **Ran ~5629, FAILED (failures=84, skipped=5), 0 errors** — all 84 `assertIsNotNone(godot)` (83 inherited + the new N2133 proof test). **Do NOT start another gate while PID 2103 is running; verify its result in the next run(s) before commit/push.** Do NOT run proof scenes while it runs (port-7777 bind ERROR fails proof tests).
- **Full gate attempt 4 DIED ~13:18 +07** (same session-end signature): PID 2103 gone, no python/unittest process left, log frozen at 3417 bytes (last write 13:18:18 +07). Frozen log preserved as `full-suite-n2133-gate-attempt4.log`.
- **Full gate attempt 5 STARTED ~13:19 +07** (main-thread restart after the 13:15 report; same launch method as attempt 3, which survived 15+ min): `setsid nohup python3 -m unittest discover -s tests`, PID 2344 (own session SID 2344, verified; log growing 1648 → 2456 bytes in 10 s, dots only so far), no Godot on PATH. javalang 0.13.0 verified present before restart. Expected done ~13:40-13:50 +07; expected **Ran ~5629, FAILED (failures=84, skipped=5), 0 errors** — all 84 `assertIsNotNone(godot)`. **Do NOT start another gate while PID 2344 is running; verify its result in the next run(s) before commit/push.**

## Gate attempt 5 check (13:45 cron run, 2026-11-12 ~13:45-13:46 +07)

- **Attempt 5 STILL RUNNING, healthy:** PID 2344 alive, 99.2% CPU, elapsed 26:16, log `full-suite-n2133-gate.log` at 5322 bytes and growing (mtime 13:45:23 +07). Content so far: 5249 dots + **68 F + 0 E** — the expected Godot-proof shape (Fs accumulating, zero errors); first F at position 2. ~300 tests remain of ~5629. No VM restart since 13:12 (uptime 33 min); javalang 0.13.0 present.
- **No action taken:** no new gate started, no proof scene run (port-7777 rule), no commit/push — gate not finished yet. Next run: verify the gate's final result (expected Ran ~5629, failures=84, skipped=5, 0 errors, all Godot-absent), then report + spec/handoff updates + commit/push N2133.

## Gate attempt 5 FINISHED + commit/push (14:00 cron run, 2026-11-12 ~14:00-14:05 +07)

- **Attempt 5 FINISHED ~13:47 +07** (PID 2344, started ~13:19, setsid, own session SID 2344): log `full-suite-n2133-gate.log` (58592 bytes, last write 13:47 +07). **Ran 5629 tests in 1657.940s, FAILED (failures=84, skipped=5), 0 errors.** Verified individually: all 84 FAIL blocks contain `AssertionError: unexpectedly None` (`assertIsNotNone(godot)`), 0 FAIL blocks of any other shape, 0 ERROR — including the N2133 proof test (expected: no Godot on PATH during the gate). The gate is clean except Godot. No VM restart since 13:12 (uptime 48 min at 14:00); javalang 0.13.0 present.
- SSOT re-verified independently from the shards: **11260 / 1584 / 1505 / 2801**, audit 1335 (ledger slices 1584, N2133 status done).
- Report written: `docs/superpowers/reports/2026-11-12-c06-unit-assembler-check-tier.md`. Design spec updated: Status Summary 1583→1584, N2133 checklist row, N2133 changelog row. This handoff updated.
- `git diff --check` clean. Commit + push — see "Commit" below.

## GREEN work remaining (next run)

1. ~~Write + run the register script: ledger N2133 entry + 4 new symbols; SSOT 11260 / **1584** / 1504+? / 2799+? (verify contracts/schemas from the rebuilt shards), audit 1335.~~ **Done 12:30 run — SSOT 11260 / 1584 / 1505 / 2801, audit 1335.**
2. ~~Add the owner const `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_ASSEMBLER_CHECK_TIER_STATE` to `SourceRuntimeOwnerUnitBuildingRegistry.gd`.~~ **Done.**
3. ~~Implement `source_unit_factory_assembler_check_tier_state(frame)` in `SourceUnitFactoryBuildState.gd` (sort, climb, gap-break, return current_tier + module_tiers + tier_gap).~~ **Done.**
4. ~~Wire the shouldConsume assembler branch: tier from checkTier when `frame.has("modules")`, else the stored `current_tier`; plan call uses the derived tier.~~ **Done.**
5. ~~Write the new proof scene `C06UnitAssemblerCheckTierProof` (.tscn + .gd, 7 keys).~~ **Done.**
6. ~~Targeted tests GREEN 4/4 (Godot on PATH) + neighbours (N2124/N2129/N2130/N2131/N2132 modules — the gate wiring touches the assembler branch).~~ **Done — 24/24 in 147.5s.**
7. Full Python gate (211 modules) — **attempt 1 DIED ~12:40 +07 (session-end, log frozen 3427 bytes, preserved as `full-suite-n2133-gate-attempt1.log`); attempt 2 DIED ~12:48 +07 (session-end, log frozen 3417 bytes, preserved as `full-suite-n2133-gate-attempt2.log`); attempt 3 DIED ~13:12 +07 (VM RESTART, log frozen 5308 bytes, preserved as `full-suite-n2133-gate-attempt3.log`); attempt 4 DIED ~13:18 +07 (session-end, log frozen 3417 bytes, preserved as `full-suite-n2133-gate-attempt4.log`); attempt 5 STARTED ~13:19 +07, PID 2344 (own session SID 2344, verified), log `full-suite-n2133-gate.log` (growing).** Expected Ran ~5629, failures=84 (83 inherited + the new N2133 proof test), skipped=5, 0 errors, all Godot-proof asserts. **Do NOT start another gate while PID 2344 is running; verify its result in the next run(s) before commit/push.**
8. ~~Godot proof GREEN (7 keys, all true, `matches: true`) — run the scene headless in this VM; do NOT run proof scenes while a gate runs (port-7777 bind ERROR fails proof tests).~~ **Done — verified via the proof test + proof JSON before the gate started. Do NOT run proof scenes while PID 2344 runs.**
9. When the gate is verified clean except Godot: report + design-spec N2133 row + Status Summary 1583→1584 + changelog row + this handoff, then commit + push to the fork (origin main) only when the slice is fully done. Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`, gate logs, or the Windows queue doc).

## Next (after N2133 lands)

- Battery live `enabled` stamp, disabled-belt efficiency half, unit-factory shouldConsume wiring to the power stamp, live production wiring (progress + call at completion). Then C07–C12 per the completion backlog.

## Deferred (not this slice)

- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447: `if(lastTier != currentTier){ if(lastTier >= 0f){ progress = 0f; } lastTier = lastTier == -2 ? -1 : currentTier; }`) — belongs to the live production/tick wiring, not checkTier itself.
- The live-loop module link/unlink call sites: `updateModules`/`removeModule` are called from `UnitAssemblerModuleBuild` link/unlink (UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet, so the frame's `modules` list is an input, not something the tick maintains.
- Live production wiring: progress advance + the call at completion (UnitFactory.java:401-403, Reconstructor.java:330-348, UnitAssembler.spawned()), plus the intake call site (`moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- Unit-factory frames' per-class shouldConsume wiring to the power stamp; battery live `enabled` stamp; disabled-belt efficiency half.
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Commit

Committed + pushed to origin main (fork Lasthope1508) in the 14:00 cron run — see the commit for the hash. Gate verified clean except Godot (Ran 5629, failures=84, skipped=5, 0 errors, all Godot-proof).
