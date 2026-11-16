# Handoff — N2208: MassDriver sense(progress) / acceptItem (mass-driver) (C07)

Date: 2026-11-16. Batch: N2208 (single slice). Status: **DONE + PUSHED (2026-11-16 ~12:1x +07 — slice 1cd99dfc, main 91239e10). Targeted 4/4 OK, family 12/12 OK, wiring 32/32 OK — GREEN total 48/48. Full gate Ran 5925, failures=158, skipped=5, 0 errors — all 158 verified Godot-absent. SSOT 11433/1658/1580/2951, audit 1335.**

## GREEN (DONE 2026-11-16 ~11:3x +07, this run)

- Two pure functions added to `SourceMassDriverBuildState.gd` after the N2171 power row (:73-94): `source_mass_driver_sense_state(frame, sensor)` (absent `reload_counter` → 0.0 → sense 1.0; `clampf(1.0 - reload_counter, 0.0, 1.0)`; non-progress → `{"handled": false, ...}`) + `source_mass_driver_accept_item_state(frame, item_capacity, link_valid)` (`items_total < item_capacity and link_valid`, absent `items_total` → 0.0). No driver tick line for either (N2206 precedent). One-line Java-quote comments per the test's assertIn list.
- Register script run (not just --verify): SSOT **11433/1658/1580/2951** (symbols +2, ledger +1, contracts +2, schema +4 — exactly as expected at RED); audit 1335 unchanged; no source_modules shard change (no shard selection matches MassDriver.java, N2171 precedent).
- Targeted **4/4 OK in 15.906s** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2208-green.log`): includes the Godot proof run — proof `C07MassDriverSenseProgressAcceptItemProof` 6 semantic keys, `matches: true`, 0 false, no ERROR. Port 7777 was FREE at run start. javalang 0.13.0 present (no reinstall, no VM restart since N2207). `git diff --check` clean.
- Next: full gate from the MAIN THREAD (workers must NOT launch gates) — **DONE: gate verified ~11:54 +07 (see "Gate verified" below)** — then report/spec/GOAL + commit + push only when all green.

## Scope

MassDriver sense(progress) override + acceptItem predicate (MassDriver.java:224-228, 285-288, file at `mindustry-upstream/core/src/mindustry/world/blocks/distribution/MassDriver.java`):

```java
@Override
public double sense(LAccess sensor){
    if(sensor == LAccess.progress) return Mathf.clamp(1f - reloadCounter);
    return super.sense(sensor);
}
```

```java
@Override
public boolean acceptItem(Building source, Item item){
    //mass drivers that output only cannot accept items
    return items.total() < itemCapacity && linkValid();
}
```

Two new pure functions in `SourceMassDriverBuildState.gd` (next to the N2171 power row, no driver tick line for either — sense is a logic read, acceptItem is an intake predicate, the N2206 precedent):

- `source_mass_driver_sense_state(frame, sensor)` — frame key `reload_counter` (float, absent → 0.0, Java init `public float reloadCounter = 0f;`, MassDriver.java:117); sensor == "progress" returns `{"handled": true, "sense_value": clampf(1.0 - reload_counter, 0.0, 1.0), "sense_value_is_nan": false}`; any other sensor returns `{"handled": false, "sense_value": null, "sense_value_is_nan": true}` (fall through to super.sense, MassDriver.java:226).
- `source_mass_driver_accept_item_state(frame, item_capacity, link_valid)` — frame key `items_total` (float, absent → 0.0, fresh ItemModule totals 0); returns `{"accept_item": items_total < item_capacity and link_valid}`. Per-def itemCapacity passed in by the caller (mass-driver 120, Blocks.java:2170; class default 10, Block.java:75), the N2207 precedent. linkValid() is a world query (world.build(link) instanceof MassDriverBuild …, MassDriver.java:346-349), so the caller passes `link_valid` in; computing it from link state is its own later slice.

RED decisions (pinned in the test):
- Sensor spelling is "progress" (LAccess.java:28 lists `progress,`).
- Absent `reload_counter` → 0.0 → sense 1.0 (fresh driver fully reloaded — the Java init behavior, NOT NaN).
- Clamp edge: reloadCounter 1.0 (just fired, fire() sets `reloadCounter = 1f;`, MassDriver.java:291) senses 0.0; 0.5 senses 0.5.
- Absent `items_total` → 0.0 → a fresh driver with a valid link accepts items (Java init behavior).
- No driver tick line for either function; no new frame key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no simulate_factory wiring change. The logic-processor dispatch hook and the intake/dump integration that calls acceptItem are their own later slices.
- Do NOT extend the generic SourceBlockSenseState.laccess_state (Block-level sense, no frame input); do NOT confuse sense with progress() (`public float progress(){` + `return 0f;`, BuildingComp.java:617-619).

Deferred: MassDriver updateTile advance (link/state-machine / reloadCounter / waitingShooters / rotation align / fire / dumpAccumulate, MassDriver.java:133-221); link/config rows; fire/bullet rows; handlePayload rows; sense/draw/drawConfigure/drawPlace/icons rows; read/write rows; link-validity computation from link state; logic-processor sense dispatch hook; intake/dump integration calling acceptItem; spawn_occupied/allow_update frame inputs, moveOutPayload(), net drone sync. C07–C12 remain open.

## Exact exprs (24, all verified verbatim at scoping)

- `public double sense(LAccess sensor){` (MassDriver.java:224)
- `if(sensor == LAccess.progress) return Mathf.clamp(1f - reloadCounter);` (MassDriver.java:225)
- `return super.sense(sensor);` (MassDriver.java:226)
- `public float reloadCounter = 0f;` (MassDriver.java:117)
- `public boolean acceptItem(Building source, Item item){` (MassDriver.java:285)
- `return items.total() < itemCapacity && linkValid();` (MassDriver.java:287)
- `protected boolean linkValid(){` (MassDriver.java:346)
- `if(link == -1) return false;` (MassDriver.java:347)
- `return world.build(this.link) instanceof MassDriverBuild other && other.block == block && other.team == team && within(other, range);` (MassDriver.java:348)
- `public class MassDriver extends Block{` (MassDriver.java:27)
- `public class MassDriverBuild extends Building implements RotBlock{` (MassDriver.java:115)
- `reloadCounter = Mathf.clamp(reloadCounter - edelta() / reload);` (MassDriver.java:143)
- `reloadCounter = 1f;` (MassDriver.java:291)
- `default -> Float.NaN; //gets converted to null in logic` (BuildingComp.java:2123)
- `public float progress(){` + `return 0f;` (BuildingComp.java:617-619)
- `progress,` (LAccess.java:28)
- `itemCapacity = 120;` + `reload = 200f;` + `range = 440f;` (Blocks.java:2170-2172)
- `public int itemCapacity = 10;` (Block.java:75)
- `protected int total;` + `public int total(){` + `return total;` (ItemModule.java:25, 174-175)

## RED (DONE 2026-11-16 ~11:2x +07, this run)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_mass_driver_sense_progress_accept_item.py` (20,278 bytes, 4 tests, N2206 pattern) + register script `tools/mindustry_godot_transpiler/register_c07_mass_driver_sense_progress_accept_item.py` (17,584 bytes, DEFERRED carried from N2207 via import) + proof `godot-mindustry/tools/runtime_proofs/C07MassDriverSenseProgressAcceptItemProof.gd` (6,593 bytes) + `.tscn` (244 bytes) written.
- Register --verify: **31/31 exprs present, exit 0** (24 exact + 7 input/output exprs).
- RED run: **Ran 4 tests in 10.543s, FAILED (failures=2, errors=2) — classic RED** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2208-red.log`, 18,618 bytes): registration ERROR KeyError 'N2208' (register runs at GREEN); evidence ERROR KeyError 'N2208'; state FAIL missing `source_mass_driver_sense_state`; proof FAIL Godot parse error (functions not found yet). Port 7777 was FREE at run start. SSOT baseline 11431/1657/1578/2947 (unchanged from N2207 — register not run at RED). javalang 0.13.0 confirmed present (no reinstall needed — no VM restart since N2207). Godot 4.6.2-stable Linux on PATH via ~/workspace/godot-bin.
- Next: GREEN (two pure functions in `SourceMassDriverBuildState.gd` with one-line Java-quote comments per the test's assertIn list, proof scene 6 keys, register script run → expected SSOT **11433/1658/1580/2951** — symbols +2, ledger +1, contracts +2, schema +4; no source_modules shard change — no shard selection matches MassDriver.java, the N2171 precedent), then targeted 4/4 → neighbours (MassDriver family) → wiring 32/32 → Godot proof → full gate (main thread only) → commit + push only when all green.

## Notes

- N2207 DONE + PUSHED before this run (slice 6d642065, main ef6f8086; origin/main == local HEAD at run start). Worktree clean except untracked `*.gd.uid` (never stage) + pre-existing untracked gate logs.
- Another agent is using Godot to test the fail errors (user, 2026-11-13 ~08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted runs use PATH="$HOME/workspace/godot-bin:$PATH".
- N2208 proof not yet run on Windows Godot (debt in GOAL.md §5 will be added at completion, same as N2175–N2207).
- Workers must NOT launch gates; only the main thread launches, into a fresh log (N2168 collision lesson; duplicate-gate incident at N2207, PID 10001 killed by main thread).
- Next after N2208: RepairTurret coolant, Units.nearby live query. (Do NOT start the C08 inventory unless the user asks.)

## GREEN verification + gate (main thread, ~11:37 +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 15.520s; family log Ran 12 OK (44.183s); wiring log Ran 32 OK (125.528s). GREEN total 48/48. Proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false. Register --verify 31/31 exprs present, exit 0.
- Functions `source_mass_driver_sense_state(frame, sensor)` at :72 and `source_mass_driver_accept_item_state(frame, item_capacity, link_valid)` at :81 — both NO driver tick line by design (sense is a logic read, acceptItem is an intake predicate; N2206/N2203 precedent).
- SSOT 11431/1657/1578/2947 → **11433/1658/1580/2951** (symbols +2, ledger +1, contracts +2, schema +4; audit 1335). NO shard change (MassDriver.java matches NO shard selector — N2171 precedent).
- Gate (main thread, PID 17650, SID 17650, ~11:37): godot NOT on PATH, javalang OK, log fresh and growing (dots + F's only, 294 bytes at launch check). Parent subshell PID 17647 stays alive. Expected: Ran ~5925, failures ~158, skipped 5, 0 errors.

## Gate verified + push (main thread, ~11:54–12:0x +07)

- Gate FINISHED ~11:54 +07 (log `tools/mindustry_godot_transpiler/full-suite-n2208-gate.log`, 107,531 bytes, untracked — never staged): **Ran 5925 tests in 1019.502s — FAILED (failures=158, skipped=5), 0 errors, 0 `ERROR:` lines.** All 158 failures verified Godot-absent: 158 × `AssertionError: unexpectedly None` (157 plain `assertIsNotNone(godot)` + 1 with the 'Godot required for hydration proof' message arg). Failure-list diff vs N2207's gate: exactly ONE new entry — the N2208 proof test itself (`test_reference_graph_and_actual_c07_mass_driver_sense_progress_accept_item`), Godot-absent in the gate by design (its real Godot proof ran green headless at GREEN; same pattern as the N2171/N2206 mass-driver proof tests already in the list). No duplicate gate this run. Gate clean except Godot — the expected signature.
- Report `docs/superpowers/reports/2026-11-16-c07-mass-driver-sense-progress-accept-item.md` written; design spec Done 1657 → 1658 + N2208 row; GOAL.md §5 adds N2208 Windows debt naming the slice commit.
- Slice commit (9 files) + docs commit + GOAL commit, rebased cleanly onto origin/main `705a3329` (validation wave17 merge, docs/evidence only) before push. Post-rebase hashes: slice `1cd99dfc`, docs `7b1d4523`, GOAL `9f7549f9`. Post-rebase sanity: targeted Ran 4 OK in 16.039s. Push to origin main in this tick; hash-naming + handoff-status commits follow (see Status).
