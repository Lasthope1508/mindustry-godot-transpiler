# N2246 PayloadMassDriver State Branches — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave advances-5, integration branch `integration/wave-advances-5-n2242-n2248`, base `00f5feb3`).

## Source

- PayloadDriverBuild.updateTile() branches (PayloadMassDriver.java:236-332): accepting (:236-248, bail :238-240, targetSize :243-244, align :248); shooting (:249-270, bail :251-253, targetRotation :256, payRotation :259, load :261-265, moveInPayload :267-269); fire gate (:272-294, queue :276-278, reload :280, align+angles :282-288); charge + transfer (:295-332: charge :289-290, trns :294, recPayload :303, handlePayload :306, partner writes :307-310, partner reset :316-319, self reset :322-326).
- **Scope corrections (all verified by grep)**: accepting :236-248, shooting :249-270, fire gate :272-294 (the scope merged them as :252-342). **updateTile ends :332** — the worker's :342 cites were corrected at integration (verified: :332 is the closing brace; :334+ is sense(), :341+ is updatePayload()). transferEffect lifetime 11f (:40, `new Effect(11f, 600f, ...)`). **Angles.within is `<=`** (Arc Angles.java:19-21) — unlike Angles.near STRICT `<` (N2237) — so the port uses the shared source_angles_within with no local helper. **handlePayload's payVector/payRotation writes are overwritten in the same tick by :307-308**, so the net transfer is the payload + the :307-310 values; `recPayload` is set :303 then cleared :314 in the same tick, so it is NOT a result key. **Charge is NOT reset on transfer** (Java leaves it ≥ chargeTime; the N2245 discharge drains it once charging stops). `hasArrived` = `len2() < margin` (squared length vs raw margin, N2233 precedent). `same_block` is the DEF match (payload-mass-driver vs large are different blocks).
- Defs: chargeTime 90f/100f large, range 700f/2100f large, reload 130f both, `length = 89/8f` = 11.125.

## Implementation

- `SourcePayloadMassDriverBuildState.gd`:
  - Pure `source_payload_mass_driver_state_branches_state(frame, ...)` → 21 result symbols (11 self: state, target_size, turret_rotation, pay_rotation, pay_length, loaded, pay_vector, payload, charge, charging, reload_counter + 9 partner write-back: partner_waiting_shooters, partner_state, partner_effect_delay_timer, partner_pay_vector, partner_pay_rotation, partner_pay_length, partner_loaded, partner_payload, partner_last_other + `fired`). The driver writes both frames back (N2237 precedent).
  - moveInPayload is PayloadBlock.java:181-197 with rotate=true (see the `_payload_mass_driver_move_in_payload` helper, the N2233 Vec2.approach port). The branches run only at efficiency > 0 (the no-power return :232-234 runs in the N2245 half).
  - **pay_vector is read as a Vector2** (the N2233 precedent) — the frame stores the dict form (N2245), so the tick wiring converts dict → Vector2 before the branches call and Vector2 → dict on both write-backs (merged at integration, 2 new helpers). Helpers `_to_short` / `_point2_pack` / `_point2_unpack` deduped with N2245's copies at integration (one copy kept).
  - Integration: 13-hunk hand merge (commit `39b16e35`) — constants union, `_initial_frame` union (17 keys), documented-limits merge, both pure functions verbatim (N2245 first, N2246 second), wiring union (linked + shooters snapshots shared, N2245 call → N2246 call in Java order).

## Commits

- Slice `107c2ad6` (worker-N2246, branch `slice/N2246-payload-mass-driver-branches`, 5 files +1623/−2; đã push 19:51, remote tip 107c2ad6).
- Integration cherry-pick `39b16e35` (MERGE TAY driver PMD, 13 hunk); SSOT gộp `9296c64f` (wave advances-5): 11706/1698/1620/3031 (slice riêng +21/+1/+1/+2 → 11663/1692/1614/3019).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 107/107, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2164: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 8 module: Ran 32, 24 PASS + 8 proof Godot-absent, 0 error.
- Full gate wave advances-5: Ran 6082 in 1118.145s, failures=197, skipped=5, 0 errors — 197/197 Godot-absent (190 inherited + 7 new proof tests N2242–N2248).

## SSOT / DEFERRED

- SSOT slice riêng +21/+1/+1/+2 → 11663/1692/1614/3019; audit 1336, legacy 0. **Payload shard CHANGED** (`payload_slices` + `payload_api_contracts`).
- DEFERRED 284 (283 − 1 resolved: updateTile advance entry + 2 new: transfer effects/sound/shake, updatePayload live positioning).
- DEFERRED gộp sau wave advances-5: 294 entries (283 − 11 resolved + 22 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07PayloadMassDriverBranchesProof` — 6 keys: `accepting_bails_without_shooter`, `accepting_aligns_to_shooter`, `shooting_bails_without_link`, `load_advances_to_length`, `fire_gate_requires_queue_and_angles`, `transfer_resets_both_sides`.
