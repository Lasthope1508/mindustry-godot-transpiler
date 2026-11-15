# N2230 TractorBeamTurret updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-3, integration branch `integration/wave-advances-3-n2229-n2234`, base `ff82ab1d`).

## Source

- TractorBeamBuild.updateTile (TractorBeamTurret.java:78-139): activation (:79-82) `if(activationTimer > 0){ activationTimer -= Time.delta; return; }` (activationTime = 0f, BaseTurret.java:27 — never fires for parallax, but modeled); eff/edelta (:84) `float eff = efficiency * coolantMultiplier, edelta = eff * delta();`; retarget (:87-90) via Units.closestEnemy; coolant consume (:92-106); any = false (:108); look-at guard (:111) `target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f`; rotation moveToward rotateSpeed * edelta; lastX/lastY; strength lerpDelta → 1f 0.1f; shoot cone: damageContinuousPierce(damage * eff * timeScale * blockDamage(team)), status apply, any = true, impulseNet((force + (1f - dst/range) * scaledForce) * edelta); else strength → 0.
- Units.closestEnemy (Units.java:296-313): team derelict → null; rect scan; filter !dead, predicate, team != derelict, targetable(team), !inFogTo(team); dst2 = e.dst2(x,y) − hitSize²; accept if dst2 < range² AND (result==null OR dst2 < cdist OR priority > cpriority) AND priority >= cpriority — a HIGHER-priority unit wins even if farther; equal priority needs strictly closer. checkTarget (UnitComp.java:74-76): (isGrounded() && targetGround) || (isFlying() && targetAir). Parallax: targetAir = true, targetGround = false (:29) → flying units only.
- **Eff ordering trap**: eff/edelta are computed at :84 BEFORE the coolant branch (:92-106) → this tick uses the OLD multiplier; the new multiplier only affects the next tick. The advance + proof pin this (coolant-base damage stays 0.5 even though the multiplier becomes 1.05).
- **coolantMultiplier has NO separate reset**: grep over all of core/src — the build field is only written at :75 (init 1f) and :105. Formula :105 yields 1f when used=0; with no target the multiplier stays. The block-level coolantMultiplier (BaseTurret :32 = 5f, ctor :46 = 1f) is a DIFFERENT field, only read by ReloadTurret.
- **Coolant is null for parallax — confirmed**: def Blocks.java:3640-3653 has only `consumePower(3.3f)`; the `coolant = consumeCoolant(0.1f)` line at :3638 belongs to the block BEFORE parallax. BaseTurret.init :50-51 findConsumer returns null.
- Def parallax (Blocks.java:3640-3653, single def): force **16f** (class 0.3f), scaledForce **9f** (class 0f), range 300f, damage **0.5f** (class 0f), rotateSpeed **12** (class 10f), consumePower 3.3f, size 2. Class: retargetTime 5f (:21), shootCone 6f (:23), status none (:31), statusDuration 300 (:32).

## Implementation

- `SourceTractorBeamTurretBuildState.gd`:
  - Pure `source_tractor_beam_turret_update_tile_advance_state(frame, ...)` → 11 result symbols: target, activation_timer, coolant_multiplier, coolant_used, rotation, strength, last_target_position, damage_dealt, status_applied, impulse, any (14 inputs).
  - Retarget cadence deferred — pure takes explicit `candidates` list + `retarget_tick` bool; `false` keeps the target even with candidates; `true` + empty list overwrites target to null (Java's unconditional assignment). The candidate list is a rect-scan enemy-only result per contract, so closestEnemy has NO same-team check (the `team() != team` check lives only in the look-at guard).
  - Damage/impulse/status are PURE RESULTS, never applied to a live unit. `Vec2.limit` only clamps the max length, never sets the length (proof: impulse (−22,0) at distance 100 / (−10,0) unclamped at distance 10).
  - `within` is STRICT dst2 < dst². `targetPriority` default 0f. `delta()` = Time.delta * timeScale (no efficiency fold); damage uses `timeScale` directly, not delta.
  - **The `SourceTractorBeamTurretBuildUpdateTile*State.gd` files are DEAD for live gameplay** (17 files: 14 modules + FlowState + FlowPortBridge + PortBridge). They only connect to each other via preload/extends (PortBridge preloads 12 modules; FlowPortBridge→ConstructBuild→BuildingDisplay→BuildingCompState→… is an inheritance chain, nobody calls a tractor-beam method) + contract JSON + old module proofs + test_playable file-mapping. NO live caller: `PortGame.gd` has 0 matches for "tractor", the driver preloads none of them, and the only live tick is `SourceFactoryRuntimeState` → driver `source_tractor_beam_turret_tick_buildings_state`. NOT modified; the pure advance is written in the driver per the N2219–N2228 pattern, with this conclusion recorded in the driver comment + register docstring.

## Commits

- Slice `57ec6873` (worker-N2230, survived VM restart 4, branch `slice/N2230-tractor-beam-update-tile`, 5 files +1468/−8; đã push 17:42, remote tip 57ec6873).
- Integration cherry-pick `1b785fdb`; SSOT gộp `b5129382` (wave advances-3): 11568/1675/1598/2987 (slice riêng +11/+1/+1/+2 → 11518/1670/1593/2977).

## Tests

- RED đúng mẫu trước GREEN (KeyError N2230 + thiếu advance function).
- Targeted post-register: 3/4 PASS (registration, exact-evidence 102/102, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2152 power + N2218 gate: 6/8 PASS, 2 fail đều là proof Godot-absent — không regression.
- Targeted wave (6 module): Ran 24, 18 PASS + 6 proof Godot-absent. Neighbours 12 module power+gate: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-3: Ran 5993 in 1036.683s, failures=175, skipped=5, 0 errors — 175/175 Godot-absent (169 inherited + 6 new proof tests N2229–N2234).

## SSOT / DEFERRED

- SSOT slice riêng +11/+1/+1/+2 → 11518/1670/1593/2977; audit 1336, legacy 0. Defense shards đổi (`defense_slices` + `defense_api_contracts`). Note: the N2218 "no shard" note was stale — defense_slices selects by java_source under `/world/blocks/defense/` (N2217/N2218 are already in the shard at HEAD); corrected in this register's docstring.
- DEFERRED 260 (260 − 1 resolved + 1 new merged "TractorBeamTurret updateTile live fill" — timer cadence + live enemy scan fill + coolant live fill + damage/impulse/status application + sound loop/laser draw).
- DEFERRED gộp sau wave advances-3: 265 entries (260 − 14 resolved + 19 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07TractorBeamUpdateTileProof` — 8 keys: retarget_picks_closest_flying_enemy, priority_beats_distance, rotation_moves_and_strength_rises, impulse_folds_force_and_range, coolant_consume_folds_heat_capacity, strength_decays_without_target, activation_timer_blocks_update, live_tick_writes_advance_frame_keys. Proof arithmetic hand-checked: rotation 90→78 in one tick (12×edelta), 90→66 with coolantMultiplier 2.0; strength 0→0.1/tick, >0.99 after 60 ticks, 1→0.9 decay; live tick parallax cell (28,21)→(228,172): damage 0.25, impulse (0,−12.05).
