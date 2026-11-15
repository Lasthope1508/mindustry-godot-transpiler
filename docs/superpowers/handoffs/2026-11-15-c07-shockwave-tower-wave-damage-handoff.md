# Handoff — N2196 ShockwaveTower wave damage

Date: 2026-11-15. Batch: N2196 (single slice). Status: **DONE + GATE VERIFIED (21:46 tick). Targeted 4/4 OK, family 20/20 OK, wiring 32/32 OK — GREEN total 56/56. Full gate Ran 5877 in 992.700s, failures=146, skipped=5, 0 errors — all 146 verified Godot-absent (log `full-suite-n2196-gate.log`). Ready to push (origin/main still b41ef1f).**

## RED (this run, 21:0x +07 tick)

- **Test module** `tools/mindustry_godot_transpiler/tests/test_c07_shockwave_tower_wave_damage.py` (new) + **register script** `tools/mindustry_godot_transpiler/register_c07_shockwave_tower_wave_damage.py` (new) + **proof scene** `godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerWaveDamageProof.gd` (+ `.tscn`, new) written, following the N2195 proof shape with the N2195 placement (shockwave-tower, cell (28, 21), driver called directly).
- **Targeted RED run:** `python3 -m unittest tests.test_c07_shockwave_tower_wave_damage` (Godot 4.6.2 on PATH, port 7777 FREE at run start): **Ran 4 in 10.489s, FAILED (failures=2, errors=2)** — log `tools/mindustry_godot_transpiler/n2196-red.log`. All four failures are the missing implementation, exactly the RED expectation:
  1. Registration — ERROR `KeyError: 'N2196'` (no ledger entry yet).
  2. Input-evidence — ERROR `KeyError: 'N2196'` (same cause).
  3. State — FAIL `static func source_shockwave_tower_wave_damage_state` not found in SourceShockwaveTowerBuildState.gd.
  4. Proof — FAIL Godot parse error: `Static function "source_shockwave_tower_wave_damage_state()" not found in base "SourceShockwaveTowerBuildState"` (5 call sites, proof .tscn fails to load), `ERROR:` in output.
  No proof .json written (scene never parsed); port 7777 free again after the run. `git diff --check` clean.
- **Slice files for the later commit (NOT staged yet):**
  `test_c07_shockwave_tower_wave_damage.py` + `register_c07_shockwave_tower_wave_damage.py` (new),
  `C07ShockwaveTowerWaveDamageProof.gd` + `.tscn` (new),
  this handoff (new). GREEN will add: `SourceShockwaveTowerBuildState.gd` (M),
  `source_api_contracts.json` + `source_slice_ledger.json` +
  `source_state_schema.json` + `source_symbol_registry.json` (M),
  and is expected to mirror N2196 into the defense shards (see below).
  Never stage: `*.gd.uid`, proof `.json`, run logs, old gate logs.

## GREEN (DONE this run, 21:15 tick)

- Pure function `source_shockwave_tower_wave_damage_state(frame)` added to `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd` (after the N2194 fire function) + 1 gated driver call after the fire in `source_shockwave_tower_tick_buildings_state` (only when `fired`, stamping `frame["wave_damage"]` / `frame["bullet_outcomes"]` only when `has_wave_damage` true) — exactly the RED design; no new Java citations (all 66 already in the file).
- Register run: SSOT **11405/1646/1567/2925** (symbols/slices/contracts/schemas), audit 1335 — exactly the RED expectation; defense shards mirror N2196 (defense_slices 159, defense_api_contracts 158) — verified from disk.
- **Targeted GREEN: Ran 4 in 15.877s, OK** (log `n2196-green.log`; Godot 4.6.2 on PATH, port 7777 FREE). Proof 6 semantic keys matches:true (9 keys total incl. registry_valid + one_headquarter_per_ssot + matches — the N2194/N2195 counting note).
- **Neighbours: family Ran 20 in 68.884s, OK** (log `n2196-neighbours-family.log`: N2177 + N2192 + N2193 + N2194 + N2195); **wiring Ran 32 in 120.706s, OK** (log `n2196-wiring.log`: factory_live_loop, power_graph_live_update_binding, battery_power_status_binding, battery_placement_binding, adjacent_factory_live_loop, unit_factory_live_loop, turret_live_loop, continuous_liquid_turret_live_loop, power_graph_consumer_cheating). **GREEN total 56/56 OK.**
- **Gate RUNNING:** `python3 -m unittest discover -s tests`, PID 8873, launched 21:24 +07 detached via `nohup setsid` (main thread), no Godot on PATH, log `n2196-gate.log` (progress dots + F markers = expected Godot-absent shape). Expected ~21:41 +07: Ran 5877, failures=146, skipped=5, 0 errors. **Do NOT start another gate while PID 8873 is running; verify its result in the next tick before commit/push.** No proof scene runs while the gate runs.
- `git diff --check` clean (re-check at push time). Nothing staged/committed/pushed yet.

## Scope (verified against upstream Java + the port this run)

- **N2196 is the ShockwaveTower wave damage application stamping `wave_damage` + `bullet_outcomes`, and nothing else.** One family (ShockwaveTower: shockwave-tower only), one pure function (`source_shockwave_tower_wave_damage_state(frame)`) + one gated driver call in the EXISTING `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd`, one proof scene. It closes the exact observable gap N2194/N2195 left open: a firing tower resets its counter and heats up while every bullet in range flies on undamaged.
- **Why this item, why now:** it is the first item in the N2194/N2195 handoff "Next" order (the ShockwaveTower fire follow-ups), and its prerequisites just landed: N2192 stamps `reload_counter`, N2193 wired the shouldConsume gate over it, N2194 built the fire gate, N2195 stamps `targets_count` from the live scan. The wave damage is the fire's payload.
- **SSOT baseline re-verified from the generated JSONs this run** (main
  b41ef1f, N2195 DONE + PUSHED): symbols **11402** + slices **1645** +
  contracts **1566** + schemas **2923**; audit `totalSourceFunctions` 1335.
  Matches the N2195 handoff exactly. Expected after N2196 by the N2188
  rule (one symbol per result-dict key, two schemas per function):
  **11405/1646/1567/2925** — the pure function returns a 3-key dict
  (`wave_damage`, `bullet_outcomes`, `has_wave_damage`); audit expected unchanged
  at 1335 — **verify at the GREEN register run, do not trust the estimate**.
- **Shard check (done this run):** YES, a shard selects ShockwaveTower.java — like N2192/N2193/N2194/N2195. The `defense_slices` shard selects `java_source` containing `/world/blocks/defense/` (source_ssot_modules.json), and `defense_api_contracts` mirrors owners from it. Verified from disk: N2195 IS in both shards today (defense_slices 158 slices, defense_api_contracts 157 contracts, per the N2195 handoff GREEN section). **So the GREEN register run is expected to mirror N2196 into both defense shards** (the N2177/N2192/N2193/N2194/N2195 precedent) — the register script's shard-rebuild loop writes all registered JSONs including shards. Verify the shard diffs at GREEN.
- **Environment (checked this run):** port 7777 FREE at RED run start (no Godot running) and free again after; javalang 0.13.0 importable (no reinstall needed); Godot binary at `~/workspace/godot-bin/godot` (4.6.2-stable, build 71f334935) but NOT on PATH in the worker shell — the RED proof run exported `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177 lesson). Worktree clean except pre-existing untracked `*.gd.uid` noise + old gate/run logs (never stage). No VM restart during this run (uptime 43 min at the 21:00 check — boot ~20:18, restart #14).

## Java source evidence (all verified verbatim this run — read + grep 2026-11-15 ~21:0x)

- `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);` (ShockwaveTower.java:87)
- `for(var target : targets){` (ShockwaveTower.java:89)
- `if(target.damage > waveDamage){` (ShockwaveTower.java:90)
- `target.damage -= waveDamage;` (ShockwaveTower.java:91)
- `}else{` (ShockwaveTower.java:92)
- `target.remove();` (ShockwaveTower.java:93)
- `hitEffect.at(target.x, target.y, waveColor);` (ShockwaveTower.java:95)
- `@Import float x, y, damage, lastX, lastY, time, lifetime;` (BulletComp.java:31 — `target.damage` is the bullet's damage float)
- `public void remove(){` (BulletComp.java:83)
- `public float bulletDamage = 160;` (ShockwaveTower.java:27)
- `public float falloffCount = 20f;` (ShockwaveTower.java:28)
- `public Effect hitEffect = Fx.hitSquaresColor;` (ShockwaveTower.java:35)
- `public Color waveColor = Pal.accent, heatColor = Pal.turretHeat, shapeColor = Color.valueOf("f29c83");` (ShockwaveTower.java:33)
- Full updateTile re-read this run (ShockwaveTower.java:72-99): fire gate :73, scan :74-79, `if(targets.size > 0){` :81, heat/counter :82-83, waveEffect/sound/shake :84-86, wave damage :87, loop :89-96, event :97-99, heat decay :104. Matches the N2195 handoff evidence verbatim.
- Register script's EXACT_EXPRS verified verbatim against upstream at RED (66/66 present, 0 missing, checked by script this run — same 66-entry list as N2195); `slice_sources` identical to N2195 (9 sources).
- All 66 exact exprs are already present in SourceShockwaveTowerBuildState.gd (verified by grep this run — 0 missing, the wave-damage lines are cited in the N2194 fire function's comment), so GREEN adds no new Java citations, only the pure function + driver call.

## Design (decided in scoping, to confirm at GREEN)

- New pure function `source_shockwave_tower_wave_damage_state(frame)` in
  the EXISTING `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd`
  (dict-return style), returning `{"wave_damage": Variant, "bullet_outcomes": Array, "has_wave_damage": bool}`:
  reuses the N2195 scan filter over the same observed bullet list
  (`observed_bullets`, an array of dicts with team/hittable/x/y/**damage**, world coords), the tower world position (`x`/`y` frame keys), and the tower team (`team_id`); waveDamage = `minf(160.0, 160.0 * 20.0 / float(targets.size()))` (bulletDamage 160, falloffCount 20f — capped at 160 for few targets, falling off as 3200 / N for many); per target bullet, `if damage > waveDamage` → outcome `{"damage": damage - waveDamage, "removed": false, ...}` else outcome `{"damage": null, "removed": true, ...}` (the STRICT comparison: a bullet at exactly waveDamage is removed, not left at 0); every outcome carries `hit_x` / `hit_y` = the target's own x / y (the hitEffect fires for EVERY target, removed or not, :95). Absent `observed_bullets` (or absent `x`/`y`/`team_id`) or zero targets in range → `{"wave_damage": null, "bullet_outcomes": [], "has_wave_damage": false}` and the driver stamps nothing. Pinned GREEN shape (the test asserts these exact strings):
  `frame.get("observed_bullets", null)`, `frame.get("x", null)`, `frame.get("y", null)`, `frame.get("team_id", null)`, `bullet.get("team", null)`, `bullet.get("hittable", false)`, `bullet.get("damage", 0.0)`, `absf(float(bullet.get("x", 0.0)) - float(tower_x)) > 170.0`, `absf(float(bullet.get("y", 0.0)) - float(tower_y)) > 170.0`, `minf(160.0, 160.0 * 20.0 / float(targets.size()))`, `return {"wave_damage": null, "bullet_outcomes": [], "has_wave_damage": false}`, `return {"wave_damage": wave_damage, "bullet_outcomes": bullet_outcomes, "has_wave_damage": true}`.
- **Frame keys: `observed_bullets` (Array, observed-only input — entries now also carry `damage`), `x` / `y` (float, tower world coords), `team_id` (int, already stamped), `wave_damage` (float, stamped only on a fire tick with a wave), `bullet_outcomes` (Array of outcome dicts, stamped only with a wave).** The wave damage is the ONLY writer of `wave_damage` / `bullet_outcomes`.
- **Driver change — one gated call + comment** in
  `source_shockwave_tower_tick_buildings_state`, AFTER the N2194 fire
  call (the Java order: the wave :87-96 runs inside the fire gate after
  the targets.size check :81), inside the powered/enabled/not-cheating
  block, gated on the local `fired` dict (`bool(fired.get("fired", false))`),
  stamping `frame["wave_damage"]` / `frame["bullet_outcomes"]` only when
  `has_wave_damage` is true. The setup / power row / `update_consumption_state` / `apply_update_consumption_state` / charge / scan / fire calls are unchanged.
- **Proof scene (written at RED):** new
  `C07ShockwaveTowerWaveDamageProof.gd` (+ `.tscn`, no `.json` tracked),
  following the N2195 proof shape with the N2195 placement
  (shockwave-tower, cell (28, 21), driver called directly, not
  simulate_factory). 6 keys:
  1. `wave_damage_caps_at_bullet_damage` — pure: tower (0, 0) team 1, 4 enemy hittable bullets damage 500 → wave_damage 160, every outcome damage 340, removed false.
  2. `wave_damage_falls_off_with_many_targets` — pure: 40 enemy hittable bullets damage 500 → wave_damage 80, every outcome damage 420, removed false.
  3. `low_damage_bullets_removed` — pure: 4 bullets, damages 100, 160, 161, 500 → wave 160: 100 → removed (damage null), 160 → removed (strict `>`, exactly waveDamage is removed), 161 → damage 1.0, 500 → damage 340.0.
  4. `hit_effect_positions_follow_targets` — pure: the capped wave's 4 outcomes carry hit_x/hit_y equal to each target's own x/y, in scan order.
  5. `absent_observed_bullets_stamps_nothing` — pure: frame with x/y/team_id but NO `observed_bullets` key → wave_damage null, outcomes [], has_wave_damage false; present-but-empty list → the same (zero targets means no wave).
  6. `live_driver_stamps_wave_damage_on_fire` — live tick: tower at cell (28, 21) → world (224, 168), team 1; observed_bullets stamped on the frame before the tick: 2 enemy hittable in range with damage 500 at (324, 168) and (224, 68), same-team hittable at the tower, enemy non-hittable at the tower, enemy hittable out of range at (395, 168) (+171); reload_counter preset 80.0 so the N2194 fire runs — the N2193 shouldConsume gate reads the preset counter as fully charged and zeroes efficiency, but the fire reads potential_efficiency (1.0 from the stamped power_status), exactly like Java, so the fire still fires and the wave applies: wave_damage == 160.0, 2 outcomes, each damage 340.0, removed false.

## RED decisions (frame keys, proof keys, exact vs deferred)

- **The wave damage re-filters the observed list; it does not consume `targets_count`.** Java's loop iterates `targets` — the scanned list itself (:89). The port's driver stamps only the count (N2195), not the list, so the pure function must re-apply the identical N2195 filter to the same `observed_bullets` to recover the targets. The filter duplication is inherent to the pure-over-frame shape (the function takes only the frame); the test pins the filter strings a second time so a drift between scan and wave fails loudly.
- **The wave damage does NOT mutate live bullets — it returns outcomes.** The port has no live bullet objects (no Groups.bullet equivalent, the N2195 RED finding); the observed bullets are plain input dicts. The pure function returns one outcome dict per target (`damage` remaining or null, `removed`, `hit_x`, `hit_y`) and the driver stamps the array on the frame. A real bullet-mutation path — if the port ever gains live bullets — is a later slice; this slice does not invent it.
- **A bullet without a `damage` key reads 0.0 and is removed.** The observed-bullet schema is the port's own input contract; Java always has `target.damage` (BulletComp.java:31). Defaulting absent to 0.0 keeps the function total over the observed list (0.0 never exceeds the wave damage, so the bullet is removed — the only deterministic reading of "no damage recorded"). The test pins `bullet.get("damage", 0.0)`.
- **Driver gates the call on the fire, not the pure function.** The pure function knows only whether a wave *could* run (observation + targets); whether the tower *did* fire this tick lives in the N2194 fire's local `fired` dict. The driver calls the wave damage only when `fired` is true — the wave lives inside the fire gate in Java (:81-96), so a charged-but-unfired tick damages nothing. The pure function stays fire-agnostic and testable on its own.
- **Stamped outcomes persist on the frame until the next fire (like heat).** Java has no such frame state; the port's frame keys persist by nature (`reload_counter` persists the same way). The driver does NOT clear `wave_damage` / `bullet_outcomes` on non-fire ticks — clearing would invent a reset Java never performs.
- **Wave damage is min(160, 3200/N) — never more than bulletDamage, never divided by zero.** `Math.min(bulletDamage, bulletDamage * falloffCount / targets.size)` with bulletDamage 160 (ShockwaveTower.java:27) and falloffCount 20f (:28); N=0 never reaches the division because the `targets.size > 0` gate (:81) and the has_wave_damage false return guard it.
- **No RNG.** The wave damage is a pure computation; the proof scene seeds no RNG (the C06DefenseProof lesson: seeded RNG only in proof scenes, and none is needed here).
- **Exact exprs (this slice, all verified verbatim above):** the same 66-entry list as N2195 (fire gate :73, charge, scan :74-79, targets gate :81, heat/counter :82-83, Fx/sound/shake :84-86, wave damage :87, loop :89-95, event :97-99, heat decay :104, sense :110, warmup :117, shouldConsume :121-122, timer state + method, class fields :23-34, :46-47, edelta, canConsume, potentialEfficiency assignment, update gate, shouldConsume default, row read, null fold, hasConsumers, offset derivation, per-def block Blocks.java:2040-2044, tilesize, worldx/drawx). The register script's EXACT_EXPRS were verified verbatim against upstream at RED (66/66 present).
- **Deferred (NOT N2196):** waveEffect / shootSound / shake spawning (:84-86 — the outcomes carry hit_x/hit_y but no effect is spawned); hitEffect spawning (:95, same); the shockwaveTowerUse event (:97-99); the timer cadence (:73, checkInterval 8f — no per-building Interval state in the port, and the scan runs every tick where Java scans only on a timer tick); sense(LAccess.progress) (:110); warmup() returns heat (:117); cyanogen liquid consumer (Blocks.java:2041); draw modeling (:126-139); bullet hitSize / rect overlap (point-in-box only). Windows Godot proof — debt in GOAL.md §5.
- **DEFERRED chain gap, recorded at RED:** the register script carries DEFERRED by import from `register_c07_shockwave_tower_bullet_scan` (runtime value verbatim, never retyped — the N2191/N2192/N2193/N2194/N2195 lesson, with the same NOTE left for the next slice). The inherited 166-entry list contains NO ShockwaveTower entries except the 8 re-pinned by N2192/N2193/N2194/N2195 (the N2192 RED note, still true). The N2196 register script adds 2 new entries (Windows Godot proof debt + a re-pin of the still-deferred fire follow-ups from N2196's own standpoint). **The wave damage itself is NOT carried as deferred: it is THIS slice** — the inherited N2195 entry still names it as waiting, which is stale history, superseded by this slice.
- **Test module:** `test_c07_shockwave_tower_wave_damage.py` + `register_c07_shockwave_tower_wave_damage.py`, following the N2195 registration pattern (test file asserts the ledger `godot_owner` + `source_symbols` for the new pure function; register script rebuilds SSOT). Neighbours to run at GREEN: the N2177 shockwave-tower module (`tests.test_c07_shockwave_tower_power_status`, 4 tests) + the N2192 module (`tests.test_c07_shockwave_tower_charge`, 4 tests) + the N2193 module (`tests.test_c07_shockwave_tower_should_consume`, 4 tests) + the N2194 module (`tests.test_c07_shockwave_tower_fire`, 4 tests) + the N2195 module (`tests.test_c07_shockwave_tower_bullet_scan`, 4 tests) + the wiring 9 modules / 32 tests.

## NOT done (push only — gate verified 21:46 tick)

- **Gate VERIFIED (21:46 tick):** attempt 2 (PID 9369, main thread, ~21:30 +07) COMPLETED — log `tools/mindustry_godot_transpiler/full-suite-n2196-gate.log`: **Ran 5877 in 992.700s, FAILED (failures=146, skipped=5), 0 errors** — exactly the expected result. All 146 failures verified from disk: 145 × `self.assertIsNotNone(godot)` + 1 × `assertIsNotNone(godot, 'Godot required for hydration proof')` (the known hydration message-arg variant the plain awk undercounts by 1), every one `AssertionError: unexpectedly None`; no other failure kind, zero `ERROR:` lines, 146 `Traceback` blocks = 146 FAIL lines. N2196's own gate failure is the same Godot-absent shape (proof-dependent test, line 269); its other 3 tests passed in the gate. Attempt 1 (PID 8873, worker-launched) never produced a complete log; `n2196-gate.log` is a partial duplicate (4937 dots + 130 F, 5067 results, no footer, mtime 21:27 +07) superseded by the full-suite log — no VM restart (uptime 1:31, boot ~20:18 +07, restart #14), dmesg not readable in this VM so no OOM verdict either way; the death cause of the partial log is not established and does not matter, the completed gate stands on its own log. Proof JSON re-verified from disk: 9 keys, matches:true, 0 false. origin/main re-fetched at 21:46: still b41ef1f, no new merges.
- **Remaining:** spec (Done/ledger 1645 → 1646 + N2196 row, in the docs commit) → GOAL.md §5 (Windows proof stays debt) → slice commit + push. Windows Godot proof stays debt in GOAL.md §5.
- **Next after N2196:** the remaining ShockwaveTower fire follow-ups (Fx/sound/shake, shockwaveTowerUse event, timer cadence), then BuildTurret shouldConsume, ShieldWall broken(), MassDriver / LaunchPad rows, RepairTurret coolant, the Units.nearby live query — each its own slice; or C08 inventory when asked.

## Gate attempt 2 (launched main thread ~21:30 +07)

- Gate attempt 1 (PID 8873, worker-launched) NEVER RAN — verified by main thread: no python/unittest process, and NO `full-suite-n2196-gate.log` file exists at all (the redirect would have created it). The worker's "gate running" status was stale; no VM restart (uptime 1:10). Same worker-session death pattern as N2191/N2193/N2194 (fourth occurrence).
- Neighbours: the worker claimed family 20/20 but left NO `n2196-neighbours.log` on disk. Main thread re-ran all 5 family modules itself (N2177 power_status, N2192 charge, N2193 should_consume, N2194 fire, N2195 bullet_scan): 5/5 OK. Each module is established Ran 4, so 20/20. Log `n2196-neighbours.log` now exists (5 OK lines; the loop's `tail -2` kept only the blank + OK lines, not the Ran lines — counts established from each module's own targeted runs).
- Gate attempt 2 (main thread, PID 9369, SID 9369, ~21:30): `which godot` → NOT on PATH (correct baseline); javalang OK; log truncated fresh and growing (dots + F's, 304 bytes at launch check). Parent subshell PID 9365 stays alive. Expected: Ran ~5877, failures ~146, skipped 5, 0 errors.
- GREEN verified by main thread from the logs on disk: targeted Ran 4 OK in 15.877s (`n2196-green.log`); wiring 32/32 OK (`n2196-wiring.log`: Ran 32, OK). GREEN total 56/56.
- Proof JSON: 9 keys total (6 semantic + registry_valid + one_headquarter_per_ssot + matches), matches:true, 0 false.

## DONE this run (21:5x +07 tick)

- Gate attempt 2 FINISHED (Ran 5877 in 992.700s, failures=146, skipped=5, 0 errors — all 146 verified Godot-absent from `full-suite-n2196-gate.log`) → report
  (`docs/superpowers/reports/2026-11-15-c07-shockwave-tower-wave-damage.md`)
  → spec (Done/ledger 1645 → 1646 + N2196 row, in the docs commit — the
  N2190 miss is NOT repeated) → GOAL.md §5 (Windows proof stays debt) →
  slice commit `3d1d842` (11 files, +1179) → docs `58b8b74` + GOAL
  `91d6030` commits → this hash-naming commit → push to origin main in
  this tick (origin/main re-checked before push: still b41ef1f).
