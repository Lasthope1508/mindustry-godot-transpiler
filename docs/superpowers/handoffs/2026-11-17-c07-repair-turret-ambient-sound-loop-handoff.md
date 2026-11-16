# Handoff — N2222 RepairTurret ambient-sound live-loop gate (C07)

## Status: GREEN DONE (this run, ~03:30–03:5x +07). Gate xanh lúc ~03:58 +07 (Ran 5981, failures=172, skipped=5, 0 errors — toàn bộ Godot-absent). Slice commit 21c4e8a9. Đang làm docs + push.

## GREEN (verified from disk/logs this run)

- Pure function + 2 consts implemented in `SourceRepairTurretBuildState.gd` (after `source_repair_turret_status_state`, before `REPAIR_TURRET_SAVE_VERSION`): `source_repair_turret_ambient_sound_loop_state(frame, headless)` + `SOURCE_REPAIR_TURRET_AMBIENT_SOUND := "beamHeal"` + `SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME := 1.0`; returns `{"should_loop", "sound", "volume"}`; reuses the N2221 shouldAmbientSound leg; NO driver tick line (per RED pin).
- Register (NOT --verify) exit 0. SSOT from disk: **11472/1672/1598/2987** — exactly the expected delta (symbols +3, Done +1, contracts +1, schema +2). NO shard change (only the 4 SSOT files + family file modified).
- Targeted GREEN **4/4 OK** in 15.881s (includes the Godot proof test).
- Family RepairTurret **48/48 OK** in 165.465s (44 + 4 new).
- Wiring-standard **32/32 OK** in 123.454s (9 modules: factory live loop, placed-power-graph grouping binding, power-graph live-update binding, battery power-status binding, battery placement binding, adjacent-factory live loop, unit-factory live loop, turret live loop, power-graph consumer cheating; log `hidden_files/n2222-wiring.log`).
- **Total 84/84.** `git diff --check` clean.
- Godot proof standalone GREEN: scene `C07RepairTurretAmbientSoundLoopProof.tscn` on headless Godot 4.6.2 Linux, output line `C_07_REPAIR_TURRET_AMBIENT_SOUND_LOOP_PROOF {"loop_false_headless":true,"loop_false_no_target":true,"loop_false_zero_efficiency":true,"loop_true_target_efficiency_headed":true,"loop_volume_default_efficiency":true,"loop_volume_half_efficiency":true,"matches":true,"one_headquarter_per_ssot":true,"registry_valid":true}` — 9 keys, all true, `matches:true`, no ERROR. Port 7777 free before and after. Proof .json stays untracked (never staged).
- No VM restart during this run (javalang 0.13.0 importable).

## Gate / push (pending — main thread, after GREEN)

- Full gate MUST be launched from the main thread (a gate launched by a worker dies with the worker's session — N2219/N2220 lesson). Expected footer: Ran ~5981, failures ~172 (Godot-absent, +1 vs N2221's 171), skipped=5, 0 errors.
- Classic 5-commit pattern + push after the gate footer is verified (spec Done 1671 → 1672 + N2222 row; GOAL.md §5 Windows debt line for N2222 names the slice commit hash).
- Check `git fetch origin` + origin/main before pushing (validation agent merges regularly).

- Test `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_ambient_sound_loop.py` (4 tests), register `tools/mindustry_godot_transpiler/register_c07_repair_turret_ambient_sound_loop.py`, proof `godot-mindustry/tools/runtime_proofs/C07RepairTurretAmbientSoundLoopProof.gd` + `.tscn` (both exist at RED, N2220/N2221 pattern).
- Targeted RED (this run, log `hidden_files/n2222-red.log` in the repo root): Ran 4 in 0.227s, FAILED (failures=2, errors=2) — KeyError 'N2222' ×2 (registration + input-evidence tests, slice not yet in the ledger), state-test FAIL (missing `source_repair_turret_ambient_sound_loop_state`), reference-test FAIL (first run: `godot` not on PATH in this shell — `shutil.which('godot')` returned None, so the test failed at `assertIsNotNone(godot)`; re-run with `PATH="$HOME/workspace/godot-bin:$PATH"` gives the correct RED signal, Godot parse errors: `Static function "source_repair_turret_ambient_sound_loop_state()" not found in base "SourceRepairTurretBuildState"` ×6 — the proof scene runs and fails on the missing function). LESSON: always export `PATH="$HOME/workspace/godot-bin:$PATH"` before running targeted tests in this shell; the reference re-run output is appended to `hidden_files/n2222-red.log`.
- Register --verify 14/14 exprs present, exit 0 (9 exact + 2 inputs + 3 outputs). This script DOES implement --verify (`def verify()`, `if '--verify' in sys.argv`) — checked first, per the N2218 lesson (never run a register script with --verify unless the file implements it). Do NOT run the register script without --verify until GREEN (it writes SSOT).
- SSOT before: 11469/1671/1597/2985 (verified from disk at RED), audit 1335. N2222 NOT in the ledger. No shard change expected (RepairTurret matches no shard — N2219/N2220/N2221 precedent; verify from `git status` at GREEN).
- No VM restart during this run (javalang 0.13.0 importable). Port 7777 free before the proof run and after (checked). origin/main == HEAD == 5260285a (N2221 DONE + PUSHED).

## Scoping pinned in RED (do not re-decide in GREEN)

- N2221 captured when the turret plays its ambient sound (shouldAmbientSound() = target != null && efficiency > 0f) and what status it reports — but nothing in the port captured the live-loop call that actually loops the sound each tick. N2222 captures the gate decision BuildingComp.update() evaluates.
- Java: BuildingComp.update() (BuildingComp.java:2262, inside `public void update(){`): `if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){` (:2270) then `control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());` (:2271). RepairTurret constructor sets the sound + volume scale (RepairTurret.java:66-67): `ambientSound = Sounds.beamHeal;` / `ambientSoundVolume = 1f;` — both defs share them (same class constructor). The Block defaults they override (Block.java:351, :353): `public Sound ambientSound = Sounds.none;` / `public float ambientSoundVolume = 0.05f;`. ambientVolume() is the folded efficiency (BuildingComp.java:2015-2017): `public float ambientVolume(){` / `return efficiency;`. The shouldAmbientSound() leg reuses the N2221 pure function (RepairTurret.java:182, `return target != null && efficiency > 0f;`).
- One pure function on the same family file N2174/N2188/N2209/N2212-N2215/N2217/N2219-N2221 built (place after `source_repair_turret_status_state`, before `REPAIR_TURRET_SAVE_VERSION`):
  - `static func source_repair_turret_ambient_sound_loop_state(frame: Dictionary, headless: bool) -> Dictionary:` returning `{"should_loop": should_loop, "sound": SOURCE_REPAIR_TURRET_AMBIENT_SOUND, "volume": volume}` where `should_loop = (not headless) and ambient_sound != "none" and should_ambient_sound` (the N2221 `source_repair_turret_should_ambient_sound_state(frame)["should_ambient_sound"]` leg), `volume = SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME * efficiency` with `efficiency = float(frame.get("efficiency", 1.0))` (N2174 missing-stamp precedent).
  - Consts: `const SOURCE_REPAIR_TURRET_AMBIENT_SOUND := "beamHeal"` and `const SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME := 1.0` (RepairTurret.java:66-67).
  - NO driver tick line: the loop call is a sound side effect (`control.sound.loop`) with no sink in the port yet, and nothing consumes an ambient-loop stamp — the driver tick line + sound-loop sink wait for a game-level headless-source slice (the port has no game-level headless flag; `headless` arrives as an explicit bool param, the SourceBlockGeometry precedent). Do NOT invent a frame `headless` key or a `DisplayServer` read in the driver at GREEN.
- Three new result symbols: `source_repair_turret_ambient_sound_loop_state_result.should_loop`, `.sound`, `.volume`. Slice sources: RepairTurret.java + BuildingComp.java (update() gate + ambientVolume()) + Block.java (ambient defaults).
- Proof math pinned (6 semantic keys): loop_true_target_efficiency_headed (headless false, has_target true, efficiency 1.0 → should_loop true, sound "beamHeal", volume 1.0) / loop_false_headless (headless true → false) / loop_false_no_target (has_target false → false) / loop_false_zero_efficiency (efficiency 0.0 → false) / loop_volume_half_efficiency (efficiency 0.5 → true, volume 0.5) / loop_volume_default_efficiency (no efficiency key → folds 1.0, volume 1.0, true). Proof output line prefix `C_07_REPAIR_TURRET_AMBIENT_SOUND_LOOP_PROOF `, scene `tools/runtime_proofs/C07RepairTurretAmbientSoundLoopProof.tscn`.
- Expected GREEN SSOT delta: symbols +3, Done +1, contracts +1, schema +2 → 11472/1672/1598/2987 (verify from disk; NO shard change expected).

## GREEN — DONE (see GREEN section above; 84/84 + proof 9 keys matches:true)

1. Implement the pure function + 2 consts in `SourceRepairTurretBuildState.gd` exactly as pinned above (Java lines as their own comment lines — the N2221 lesson: paraphrased comments break the verbatim `assertIn`).
2. Run the register script (NOT --verify) → verify SSOT from disk.
3. Targeted GREEN 4/4 (remember `PATH="$HOME/workspace/godot-bin:$PATH"`), family RepairTurret, wiring-standard 32/32. `git diff --check` clean.
4. Godot proof (headless Godot 4.6.2-stable Linux in this VM; check port 7777 free before/after). Proof .json stays untracked (never staged).
5. Full gate from the main thread (a gate launched by a worker dies with the worker's session — N2219/N2220 lesson).

## Gate / push (pending — main thread, after GREEN)

- Classic 5-commit pattern + push after the gate footer is verified (spec Done 1671 → 1672 + N2222 row; GOAL.md §5 Windows debt line for N2222 names the slice commit hash).
- Check `git fetch origin` + origin/main before pushing (validation agent merges regularly).

## After N2222

Next deferred C07 item per backlog: RepairTurret config-display / sense rows (checked at N2222 RED: RepairTurret.java carries NO sense/config overrides — the rows would be BuildingComp-level work, bigger and unpinned; the explicit N2221 deferred item took precedence), or the next family. (Do NOT start the C08 inventory unless the user asks.)

## Commits

- 21c4e8a9 C07: N2222 RepairTurret ambient-sound live-loop gate (pure function + 2 consts + proof 9 keys) — 9 files, 933 insertions.
