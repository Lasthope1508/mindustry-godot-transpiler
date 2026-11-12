# Report — N2135: disabled-belt efficiency half

Date: 2026-11-12. Batch: N2135 (single slice). Status: GREEN done in this VM, targeted tests **4/4 OK**. **Godot proof GREEN 2026-11-12 ~15:27 +07: Godot 4.6.2-stable Linux (build 71f334935, identical to the Windows 4.6.2 build) ran `C06DisabledBeltEfficiencyProof.tscn` headless in this VM — 5 keys, all true, `matches: true`. Inclusive full gate finished ~15:42 +07 (Ran 5637 in 886.985s, failures=86, skipped=5, 0 errors — all 86 Godot-proof failures, no Godot binary on PATH). Committed + pushed to origin main (fork Lasthope1508) in the 15:45 cron run.**

## What changed

A conveyor carries no consumers, so `BuildingComp.updateConsumption` takes the first branch (BuildingComp.java:1943-1948): `potentialEfficiency = enabled && productionValid() ? 1f : 0f; efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;` — efficiency 1 when enabled, 0 when disabled (`//disabled -> nothing works`, BuildingComp.java:1953-1956). The belt moves by `float moved = speed * edelta();` (Conveyor.java:266), and `edelta()` is `efficiency * delta()` (BuildingComp.java:1927-1929). The port's `SourceConveyorRuntimeState.source_conveyor_advance_state` hardcoded efficiency 1 — `var moved := speed * delta * time_scale` — with an explicit deferred comment saying so, so a disabled belt still advanced in the port.

N2135 gives the advance step its own per-belt efficiency input: one new symbol `source_conveyor_advance_state_input.efficiency`, merged into the EXISTING `source_conveyor_advance_state_input` schema (11 → 12 keys, N2069 source_slice kept) and appended to the EXISTING advance contract params (trailing, after `clog_heat_before`, N2069 source_slice kept). The function gains a trailing optional param `efficiency := 1.0`, so the live tick path (`SourceFactoryRuntimeState`, line 607), `C06BuildingUpdateProof`, and `ConveyorAdvanceProof` keep calling with 11 positional args unchanged: `var moved := speed * delta * time_scale * efficiency`. The deferred comment in the function now records the disabled half as implemented (live-loop gate still deferred — see below). No live-path wiring in this slice: the factory advance caller passes no efficiency (default 1.0) — there is no per-sprite `enabled` seam in the factory path (`SourceFactoryRuntimeState.gd` and `SourcePlacedBlockState.gd` contain no `enabled` reads), so wiring the live loop to freeze a disabled belt needs a sprite-enabled seam of its own; that is the deferred follow-up.

## Proof keys (new scene, 5 keys)

- `disabled_belt_ys_frozen`: efficiency 0, items at ys [0.0, 0.5] → ys unchanged.
- `disabled_belt_xs_frozen`: efficiency 0, xs [0.2, -0.3] → xs unchanged (x drift is `moved * 2`, so 0 too).
- `disabled_belt_no_pass_ready`: efficiency 0, single item at 0.98 → `pass_ready` false (moved 0, never reaches 1.0).
- `enabled_belt_advances`: efficiency 1.0 explicit, same frame → ys advance by `speed * delta * time_scale` (0.03 with the ConveyorAdvanceProof numbers).
- `half_efficiency_half_moved`: efficiency 0.5 → ys advance exactly half the enabled distance.

Edge noted, NOT asserted: with efficiency 0 and an item ALREADY at ys >= 1.0, the pure function still reports `pass_ready: true` (the pass check reads the stored position, not `moved`). In Java that state cannot arise for a disabled belt because `updateTile` is never called (`noUpdateDisabled = false`, Conveyor.java:52); the live-loop enabled gate (deferred) is what prevents it in the port. The proof uses 0.98 for the no-pass key so it stays true.

## Verified numbers (measured in this VM)

- Test module `test_c06_disabled_belt_efficiency.py`: **4/4 OK in 16.6s** (Godot on PATH) — registration (ledger N2135, 1 new symbol, contract params + schema keys, runtime proof, test names, deferred_exprs), exact-evidence (1 symbol + 12 exprs over Conveyor.java + BuildingComp.java, all found verbatim), source-text (advance signature carries `efficiency := 1.0`; `moved` multiplies by efficiency; proof has the 5 new keys), and the Godot proof test (5 keys, all true, `matches: true`).
- RED run (15:15 cron run): 4 tests, 2 failures + 2 errors, all expected — registration `KeyError: 'N2135'`, evidence errors on the missing ledger entry, source-text `AssertionError` (efficiency param not implemented), proof `assertIsNotNone(godot)` (no Godot on PATH in the cron shell).
- Neighbours (conveyor modules, sequential, Godot on PATH): **13/13 OK in 64.7s** — `test_conveyor_advance_binding`, `test_c06_building_update_halves`, `test_conveyor_queue_binding`, `test_conveyor_intake_binding`. No port-7777 collision (sequential run, per the known lesson).
- `git diff --check` clean.
- SSOT +1/+1/+0/+0 → **11265 / 1586 / 1506 / 2803**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2135 4/4 (proof green, see above).
- Godot proof: **GREEN 2026-11-12 ~15:27 +07** — 5 keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2135 module (log `tools/mindustry_godot_transpiler/full-suite-n2135-gate.log`, 212 modules): started detached with `setsid` ~15:27 +07 (PID 3514, own session SID 3514) and **finished ~15:42 +07: Ran 5637 in 886.985s, FAILED (failures=86, skipped=5), 0 errors** — all 86 verified individually as Godot-proof failures (86 × `assertIsNotNone(godot)` / `AssertionError: unexpectedly None`, 0 ERROR headers, 0 other failure shapes); the N2135 module contributes only its proof test, its 3 non-proof tests pass. Zero errors, zero non-Godot failures: the gate is clean except Godot. First attempt finished clean — no session-end death this time.
- The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- **Live-loop belt enabled gate:** `simulate_factory` still advances a disabled belt's queue (it passes no efficiency, and reads no per-sprite `enabled`). In Java a disabled conveyor's `updateTile` never runs (`noUpdateDisabled = false`, Conveyor.java:52). Wiring the live loop to skip/freeze disabled belts needs a sprite-`enabled` seam (`SourcePlacedBlockState` has none) — a follow-up slice, not this one. The pure advance function now takes the efficiency; the caller is the missing half.
- Unit-factory frames' per-class shouldConsume wiring to the power stamp; live production wiring (progress + call at completion).
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the live production/tick wiring.
- The live-loop module link/unlink call sites: `updateModules`/`removeModule` are called from `UnitAssemblerModuleBuild` link/unlink (UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c06-disabled-belt-efficiency-handoff.md` for the full detail.
