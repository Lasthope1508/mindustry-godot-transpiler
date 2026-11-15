# Report — N2196: ShockwaveTower wave damage (C07)

Date: 2026-11-15. Batch: N2196 (single slice). Status: **DONE + GATE VERIFIED (2026-11-15 ~21:46 +07 — targeted 4/4, family 20/20, wiring 32/32, GREEN total 56/56; full gate Ran 5877, failures=146, skipped=5, 0 errors, all 146 verified Godot-absent). Ready to push (origin/main still b41ef1f).**

## What changed

N2195 is DONE + PUSHED (main b41ef1f); this tick starts the next ShockwaveTower fire follow-up in the N2194/N2195 handoff order — the wave damage application. N2194's fire gate sets heat 1f and resets the counter, N2195's scan stamps the observed `targets_count`, but the wave itself does nothing yet: a firing tower resets its counter and heats up while every bullet in range flies on undamaged. N2196 owns applying the wave damage. No gameplay change; RED only, nothing staged/committed/pushed.

What RED adds (5 files, not staged):

- **Test module + register script** `test_c07_shockwave_tower_wave_damage.py` + `register_c07_shockwave_tower_wave_damage.py` (N2195 pattern). SSOT baseline re-verified from disk: 11402/1645/1566/2923, audit 1335, defense shards 158/157. Expected after GREEN by the N2188 rule (one symbol per result-dict key, 3-key dict): **11405/1646/1567/2925**, audit 1335, defense shards 159/158.
- **Proof scene** `C07ShockwaveTowerWaveDamageProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6), N2195 proof shape with the N2195 placement (shockwave-tower, cell (28, 21), driver called directly). 6 keys: wave damage caps at bulletDamage 160 (pure), falls off with many targets (pure, 40 bullets → 80), low-damage bullets removed incl. the strict-`>` pin at exactly 160 (pure), hit-effect positions follow the targets (pure), absent observed_bullets stamps nothing (pure), live driver stamps wave damage + outcomes only on a fire tick (live tick, reload_counter preset 80.0).
- **Handoff** `docs/superpowers/handoffs/2026-11-15-c07-shockwave-tower-wave-damage-handoff.md` — design, frame keys (`observed_bullets` with `damage`, `x`/`y`, `team_id`, `wave_damage`, `bullet_outcomes`), proof keys, RED decisions, Java evidence.

## RED

Tests written first per the slice process. Targeted RED run: `python3 -m unittest tests.test_c07_shockwave_tower_wave_damage` (Godot 4.6.2 on PATH, port 7777 FREE): **Ran 4 in 10.489s, FAILED (failures=2, errors=2)** — registration `KeyError: 'N2196'` (no ledger entry yet), input-evidence error (same cause), state test FAIL (pure function `source_shockwave_tower_wave_damage_state` not found), proof test FAIL (Godot parse error: static function not found, 5 call sites, proof `.tscn` fails to load). All four failures are the missing implementation, exactly the RED expectation. No proof `.json` written (scene never parsed). Port 7777 free again after the run. `git diff --check` clean. Log `tools/mindustry_godot_transpiler/n2196-red.log`. EXACT_EXPRS verified verbatim against upstream at RED (66/66 present); all 66 already present in SourceShockwaveTowerBuildState.gd (cited in the N2194 fire comment), so GREEN adds no new Java citations.

## GREEN (done this tick, 21:15)

Pure function `source_shockwave_tower_wave_damage_state(frame)` (waveDamage = min(160, 160*20/N); per-target outcome with remaining damage or removed + hit_x/hit_y; absent observation or zero targets → null/[]/false) + 1 gated driver call after the N2194 fire (only when fired), stamping `frame["wave_damage"]` / `frame["bullet_outcomes"]` only when has_wave_damage is true. Register run: SSOT **11405/1646/1567/2925**, audit 1335, defense shards 159/158 — exactly as RED expected. Targeted GREEN: **Ran 4 in 15.877s, OK** (log `n2196-green.log`; proof 6 semantic keys matches:true). Neighbours: family **20/20 OK** (68.884s, log `n2196-neighbours-family.log`), wiring **32/32 OK** (120.706s, log `n2196-wiring.log`). **GREEN total 56/56 OK.** `git diff --check` clean.

## GATE (verified GREEN-equivalent ~21:46 +07)

Full gate `python3 -m unittest discover -s tests`, attempt 2 (PID 9369, main thread, ~21:30 +07), log `tools/mindustry_godot_transpiler/full-suite-n2196-gate.log`: **Ran 5877 in 992.700s, FAILED (failures=146, skipped=5), 0 errors** — exactly the expected result. All 146 failures verified from the log on disk: 145 × `self.assertIsNotNone(godot)` + 1 × `assertIsNotNone(godot, 'Godot required for hydration proof')` (the known hydration message-arg variant), every one `AssertionError: unexpectedly None` — the Godot-absent shape, no other failure kind, no `ERROR:` lines. N2196's own gate failure is the same shape (its proof-dependent `test_reference_graph_and_actual_c07_shockwave_tower_wave_damage`, line 269); its other 3 tests passed in the gate. Attempt 1 (PID 8873, worker-launched) never produced a complete log; `n2196-gate.log` is a partial duplicate (5067 results, no footer) superseded by the full-suite log. Proof JSON on disk: 9 keys, matches:true, 0 false.

## PUSH (gate verified ~21:46 +07)

Gate clean except Godot (Ran 5877, failures=146 all Godot-absent, skipped=5, 0 errors). Spec updated in the docs commit (Done/ledger 1645 → 1646 + N2196 row); GOAL.md §5 keeps the Windows proof as debt. Slice `3d1d842` (11 files, +1179) → docs `58b8b74` + GOAL `91d6030` → this hash-naming commit → push to origin main in this tick (origin/main re-checked before push: still b41ef1f).

## Deferred (NOT this slice)

- WaveEffect / shootSound / shake spawning (:84-86) and hitEffect spawning (:95 — the outcomes carry hit_x/hit_y but no effect is spawned); the shockwaveTowerUse event (:97-99); the timer cadence (:73, checkInterval 8f); sense(LAccess.progress) (:110); warmup() (:117); cyanogen liquid consumer (Blocks.java:2041); draw modeling (:126-139); bullet hitSize / rect overlap (point-in-box only).
- The remaining C07 deferred items per the N2193 handoff table — BuildTurret shouldConsume, ShieldWall broken(), MassDriver / LaunchPad rows, RepairTurret coolant, the Units.nearby live query — each its own slice; or C08 inventory (classify the 5,390 null-body functions) when asked.
- Windows Godot proof — debt in GOAL.md §5, same as N2182–N2195.
