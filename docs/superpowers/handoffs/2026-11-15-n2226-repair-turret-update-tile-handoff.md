# Handoff N2226 — RepairTurret updateTile Advance

**Status: DONE** (coordinator lượt 4 — wave advances-2). Slice `04494ee9` trên branch `slice/N2226-repair-turret-update-tile` (base `542b383e`, đã push 17:00, remote tip 04494ee9). Integration `integration/wave-advances-2-n2224-n2228`: cherry-pick `865eab15` + SSOT gộp `e76dd9c8` (11507/1669/1592/2975).

## What changed

- `SourceRepairTurretBuildState.gd`: pure `source_repair_turret_update_tile_advance_state(frame, ...)` → 6 result symbols (target, offset, strength, rotation, heal_amount, healed); re-acquire pure LÀM (Units.closest faithful); driver constants repairSpeed/repairRadius per-def; driver gọi sau consumption fold, enabled-gated.
- New: `test_c07_repair_turret_update_tile.py`, `register_c07_repair_turret_update_tile.py`, `C07RepairTurretUpdateTileProof.gd/.tscn` (6 keys).

## Java ground truth

RepairTurretBuild.updateTile (RepairTurret.java:187-218). Units.closest: strict dst2 < (radius + hitSize/2)² (Position.java:44-46), filter isValid + damaged (health < maxHealth − 0.001f, HealthComp.java:47-49), min dst2 strict < (first wins ties). Strength double-delta exact: Java truyền 0.08f * Time.delta làm progress, lerpDelta nhân Time.delta lần nữa. Defs repairSpeed 0.45f/3f, repairRadius 60f/145f (Blocks.java:6386-6406).

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +6/+1/+1/+2 → 11476/1665/1588/2967 (slice riêng), audit 1336, legacy 0. Exact exprs 78. DEFERRED 258. **KHÔNG shard nào đổi.** N2174 + N2212 vẫn 3/4.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07RepairTurretUpdateTileProof` — 6 keys: target_clears_when_dead_or_out_of_range, rotation_slerps_toward_target, strength_approaches_one_when_healing, heal_amount_folds_repair_speed_strength, reacquire_picks_closest_damaged_candidate, live_tick_writes_advance_frame_keys.

## Deferred (không trong slice này)

- Heal application (chỉ trả heal_amount làm pure result); timer 20-tick re-acquire cadence (driver luôn pass [] nên live chưa re-acquire); coolant multiplier branch (multiplier = 1.0, chờ coolant row).
