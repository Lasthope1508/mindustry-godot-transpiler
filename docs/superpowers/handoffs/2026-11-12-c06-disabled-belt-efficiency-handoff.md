# Handoff — N2135: disabled-belt efficiency half

Date: 2026-11-12. Batch: N2135 (single slice). Status: **GREEN DONE 2026-11-12 ~15:27 +07 (15:30 research run). Full gate VERIFIED clean except Godot ~15:42 +07 (Ran 5637, failures=86, skipped=5, 0 errors, all Godot-proof). Commit + push to origin main in the 15:45 cron run.**

## GREEN progress (15:30 research run, 2026-11-12 ~15:27 +07)

- Register script written + run: `tools/mindustry_godot_transpiler/register_c06_disabled_belt_efficiency.py` — merges the `efficiency` key into the existing `source_conveyor_advance_state_input` schema (11 → 12 keys, N2069 source_slice kept) and appends it to the existing advance contract params (trailing, after `clog_heat_before`, N2069 source_slice kept); 1 new symbol, ledger N2135 entry written. SSOT after GREEN: **11265 / 1586 / 1506 / 2803** (symbols +1, slices +1, contracts +0, schemas +0 — exactly as predicted); audit stays 1335.
- Implemented `efficiency := 1.0` trailing param in `SourceConveyorRuntimeState.source_conveyor_advance_state`; `var moved := speed * delta * time_scale * efficiency`; deferred comment updated (disabled half now implemented; live-loop gate still deferred, no per-sprite `enabled` seam in the factory path).
- Proof scene written: `godot-mindustry/tools/runtime_proofs/C06DisabledBeltEfficiencyProof.gd` + `.tscn` (prefix `C_06_DISABLED_BELT_EFFICIENCY_PROOF `), modeled on `ConveyorAdvanceProof.gd` numbers (speed 0.03, delta 1.0, time_scale 1.0).
- **Targeted tests 4/4 OK in 16.6s** (Godot on PATH) — including the Godot proof test: 5 keys all true, `matches: true`.
- **Neighbours 13/13 OK in 64.7s** (sequential): `test_conveyor_advance_binding`, `test_c06_building_update_halves`, `test_conveyor_queue_binding`, `test_conveyor_intake_binding`.
- **Full gate STARTED ~15:27 +07**: `setsid nohup python3 -m unittest discover -s tests`, PID 3514 (own session SID 3514, PPID 1 verified; 93.6% CPU, log growing, F in the expected Godot-absent shape), log `full-suite-n2135-gate.log`, no Godot on PATH. Expected: Ran ~5637, FAILED (failures=86, skipped=5), 0 errors — all 86 `assertIsNotNone(godot)` (85 inherited + the new N2135 proof test). Expected done ~15:55–16:05 +07. **Do NOT start another gate while PID 3514 is running; verify its result in the next run(s) before commit/push. Do NOT run proof scenes while it runs** (port-7777 bind ERROR fails proof tests).
- `git diff --check` not yet run on the final tree (run before commit, after gate verifies).

## RED progress (15:15 cron run, 2026-11-12 ~15:15 +07)

- State at RED time: main at 2d7c85c (N2134 merged + pushed); working tree clean except untracked `*.gd.uid` files (never stage), untracked gate logs, and one untracked `tools/mindustry_godot_transpiler/targeted-env-fix.log` (pre-existing env noise, not this slice).
- **javalang was MISSING at run start** (`ModuleNotFoundError: No module named 'javalang'`) — the 14:30 N2134 run had it present, so the VM must have restarted (or the system pip env was wiped) between ~14:45 and 15:15. Reinstalled 0.13.0 from `tools/mindustry_godot_transpiler/requirements.txt` (the repo-root `requirements.txt` path in MEMORY is stale — the file lives under `tools/mindustry_godot_transpiler/`). Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c06_disabled_belt_efficiency.py` (4 tests). RED run: **Ran 4 tests in 0.267s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2135'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `var moved := speed * delta * time_scale * efficiency` does not exist yet;
  - proof: `assertIsNotNone(godot)` — no Godot binary on PATH in the cron shell (the gate-expected Godot-absent shape; with Godot on PATH it would be returncode 1, scene file does not exist yet — the new proof scene is GREEN work).
- `git diff --check` clean (no tracked changes yet — only the new untracked test module).

## What this batch is

The disabled-belt efficiency half, the next item on the N2134 "Next" list (and the N2134 deferred line: "disabled-belt efficiency half (BuildingComp.java:1943-1948 — a disabled conveyor reads efficiency 0 in Java, the port carries no per-belt efficiency yet)"). A conveyor carries no consumers, so `updateConsumption` takes the first branch (BuildingComp.java:1943-1948): `potentialEfficiency = enabled && productionValid() ? 1f : 0f; efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;` — efficiency 1 when enabled, 0 when disabled. The belt moves by `float moved = speed * edelta();` (Conveyor.java:266), and `edelta()` is `efficiency * delta()` (BuildingComp.java:1927-1929). The port's `SourceConveyorRuntimeState.source_conveyor_advance_state` hardcodes efficiency 1 — `var moved := speed * delta * time_scale` — and carries an explicit deferred comment saying so. A disabled belt therefore still advances in the port. This slice gives the advance step its own per-belt efficiency input (trailing optional param, default 1.0, so the enabled belt and every existing caller are unaffected).

## Exact upstream evidence (all 12 exprs verified verbatim in this VM)

- The movement (Conveyor.java:266): `float moved = speed * edelta();`
- The edelta helper (BuildingComp.java:1927-1929): `public float edelta(){` / `return efficiency * delta();`
- The no-consumers branch (BuildingComp.java:1942-1948): `public void updateConsumption(){` / `if(!block.hasConsumers || cheating()){` / `potentialEfficiency = enabled && productionValid() ? 1f : 0f;` / `efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;`
- The disabled branch (BuildingComp.java:1953-1956): `//disabled -> nothing works` / `if(!enabled){` / `potentialEfficiency = efficiency = optionalEfficiency = 0f;` / `shouldConsumePower = false;`
- The updateTile gate (Conveyor.java:52): `noUpdateDisabled = false;` — a disabled conveyor's `updateTile` is never called in Java (see Deferred: the live-loop enabled gate is a follow-up, not this slice).

## Design (decided in RED, implement in GREEN)

- **One new symbol, no new contract/schema.** `source_conveyor_advance_state_input.efficiency` — java_expr `float moved = speed * edelta();`, java_source `core/src/mindustry/world/blocks/distribution/Conveyor.java`, java_method `ConveyorBuild.updateTile()`, godot_owner `SourceConveyorRuntimeState.source_conveyor_advance_state`, type `float`. It joins the EXISTING `source_conveyor_advance_state_input` schema (11 keys → 12) and the EXISTING advance contract params (trailing, after `clog_heat_before`).
- **Function change:** `source_conveyor_advance_state(..., clog_heat_before: float, efficiency := 1.0)` — trailing optional param with default 1.0, so the live tick path (`SourceFactoryRuntimeState`, line 607), `C06BuildingUpdateProof`, and `ConveyorAdvanceProof` keep calling with 11 positional args unchanged. `var moved := speed * delta * time_scale * efficiency`. Update the deferred comment in the function to record the disabled half is now implemented (keep the Java citations).
- **No live-path wiring in this slice.** The factory advance caller passes no efficiency (default 1.0) — there is no per-sprite `enabled` seam in the factory path (`SourceFactoryRuntimeState.gd` and `SourcePlacedBlockState.gd` contain no `enabled` reads), so wiring the live loop to freeze a disabled belt needs a sprite-enabled seam of its own; that is the deferred follow-up below. The slice delivers the per-belt efficiency in the pure advance function + the Godot proof, same scope shape as the N2134 stamp (pure function + proof, wiring deferred where no seam exists).
- Ledger N2135 entry: `status: done`, `java_source: core/src/mindustry/world/blocks/distribution/Conveyor.java`, `java_class: mindustry.world.blocks.distribution.Conveyor.ConveyorBuild`, `java_method: ConveyorBuild.updateTile()`, `godot_owner: SourceConveyorRuntimeState.source_conveyor_advance_state`, `exact_exprs`: the 12 exprs above, `source_symbols`: the 1 new symbol, `tests`: the 4 test names of the new module, `runtime_proof: /root/C06DisabledBeltEfficiencyProof`, `deferred_exprs`: live-loop belt enabled gate, unit-factory shouldConsume wiring to the power stamp, live production wiring, Units.canCreate live evaluation, lastTier/progress reset, module link/unlink call sites, C06–C12 open.
- Register script `register_c06_disabled_belt_efficiency.py` (GREEN, modeled on the N2134 one + `register_c06_building_update_halves.py`, which touched the same advance function): writes the ledger N2135 entry + the 1 symbol; MERGES the `efficiency` key into the existing `source_conveyor_advance_state_input` schema and appends it to the existing advance contract params — **verify `upsert_source_state_schema` / `upsert_source_api_contract` merge rather than replace** (the N2134 script upserts whole new schemas/contracts; the building-update-halves script copied an existing symbol before re-upserting — read it first). Expected SSOT after GREEN: **11265 / 1586 / 1506 / 2803** — symbols +1 and slices +1 are certain; contracts/schemas +0 (updated in place, not new) — verify from the rebuilt shards, do not assume. Audit stays 1335.
- Proof updates: NEW scene `C06DisabledBeltEfficiencyProof` (.tscn + .gd, prefix `C_06_DISABLED_BELT_EFFICIENCY_PROOF `; proof JSON is gitignored, never stage it). Model on `ConveyorAdvanceProof.gd` (same direct calls to the pure advance function, 12th arg `efficiency`). 5 keys:
  - `disabled_belt_ys_frozen`: efficiency 0, items at ys [0.0, 0.5] → ys unchanged.
  - `disabled_belt_xs_frozen`: efficiency 0, xs [0.2, -0.3] → xs unchanged (x drift is `moved * 2`, so 0 too).
  - `disabled_belt_no_pass_ready`: efficiency 0, single item at 0.98 → `pass_ready` false (moved 0, never reaches 1.0).
  - `enabled_belt_advances`: efficiency 1.0 explicit, same frame → ys advance by `speed * delta * time_scale` (0.03 with the ConveyorAdvanceProof numbers).
  - `half_efficiency_half_moved`: efficiency 0.5 → ys advance exactly half the enabled distance.
  - Edge noted, NOT asserted: with efficiency 0 and an item ALREADY at ys >= 1.0, the pure function still reports `pass_ready: true` (the pass check reads the stored position, not `moved`). In Java that state cannot arise for a disabled belt because `updateTile` is never called (`noUpdateDisabled = false`); the live-loop enabled gate (deferred) is what prevents it in the port. The proof uses 0.98 for the no-pass key so it stays true.
- The `test_conveyor_advance_binding.py` registration assertions (N2069/N2070: contract params == schema keys, return keys) need NO change: the new param is appended to BOTH the contract params and the schema keys, so the equality still holds. The `ConveyorAdvanceProof` and `C06BuildingUpdateProof` scenes need NO change (11-arg calls hit the default 1.0).

## Files changed (RED only)

- `tools/mindustry_godot_transpiler/tests/test_c06_disabled_belt_efficiency.py` (new, 4 tests): registration (ledger N2135, 1 new symbol, contract params + schema keys, runtime proof, test names, deferred_exprs), exact-evidence (1 symbol + 12 exprs over Conveyor.java + BuildingComp.java), source-text (advance signature carries `efficiency := 1.0`; `moved` multiplies by efficiency; proof has the 5 new keys), Godot proof (`C06DisabledBeltEfficiencyProof.tscn`, prefix `C_06_DISABLED_BELT_EFFICIENCY_PROOF `, the 5 keys true).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests, 2 failures + 2 errors, all expected** — registration `KeyError: 'N2135'`, evidence errors on the missing ledger entry, source-text `AssertionError` (efficiency param not implemented), proof `assertIsNotNone(godot)` (no Godot on PATH in the cron shell).
- Exact-expr pre-check: **12/12 exprs found verbatim** in the 2 slice sources (Conveyor.java, BuildingComp.java).
- `git diff --check` clean.
- State at RED time: main at 2d7c85c (N2134 merged + pushed to the fork 2026-11-12 ~15:09); SSOT 11264 / 1585 / 1506 / 2803; audit 1335.

## GREEN work remaining (next run)

1. ~~Write + run the register script~~ — done ~15:27, SSOT 11265/1586/1506/2803, audit 1335.
2. ~~Implement the `efficiency := 1.0` param~~ — done.
3. ~~Write the new proof scene `C06DisabledBeltEfficiencyProof` (5 keys)~~ — done.
4. ~~Targeted tests GREEN 4/4 (Godot on PATH) + neighbours (conveyor modules, sequential)~~ — done: targeted 4/4 in 16.6s, neighbours 13/13 in 64.7s.
5. Full Python gate (212 modules) — **VERIFIED ~15:42 +07 (15:45 cron run)**: setsid attempt (PID 3514, ~15:27) finished clean first try — **Ran 5637 in 886.985s, FAILED (failures=86, skipped=5), 0 errors**; all 86 verified individually as `assertIsNotNone(godot)` (`AssertionError: unexpectedly None` ×86, 0 ERROR headers, 0 other failure shapes). The N2135 module contributes only its proof test; its 3 non-proof tests pass. Gate clean except Godot. Log `tools/mindustry_godot_transpiler/full-suite-n2135-gate.log`.
6. ~~Godot proof GREEN (5 keys, all true, `matches: true`)~~ — done via the targeted proof test ~15:27 (standalone run before the gate started).
7. Report + design-spec N2135 row + Status Summary 1585→1586 + changelog row + this handoff — done in the 15:45 cron run; commit + push now.

## Next (after N2135 lands)

- Unit-factory shouldConsume wiring to the power stamp, live production wiring (progress + call at completion). Then C07–C12 per the completion backlog.

## Deferred (not this slice)

- **Live-loop belt enabled gate:** `simulate_factory` still advances a disabled belt's queue (it passes no efficiency, and reads no per-sprite `enabled`). In Java a disabled conveyor's `updateTile` never runs (`noUpdateDisabled = false`, Conveyor.java:52). Wiring the live loop to skip/freeze disabled belts needs a sprite-`enabled` seam (`SourcePlacedBlockState` has none) — a follow-up slice, not this one. The pure advance function now takes the efficiency; the caller is the missing half.
- Unit-factory frames' per-class shouldConsume wiring to the power stamp; live production wiring (progress + call at completion).
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the live production/tick wiring.
- The live-loop module link/unlink call sites: `updateModules`/`removeModule` are called from `UnitAssemblerModuleBuild` link/unlink (UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Commit

Not yet — GREEN done (targeted 4/4, Godot proof 5 keys GREEN, SSOT 11265 / 1586 / 1506 / 2803); full gate verified clean except Godot (finished ~15:42 +07: Ran 5637, failures=86, skipped=5, 0 errors, all Godot-proof). Commit + push to origin main in the 15:45 cron run.
