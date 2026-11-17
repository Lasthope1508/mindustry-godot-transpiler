# Báo cáo — N2242 PointDefenseTurret driver map live bullets → observed dicts wiring (C07)

Ngày: 2026-11-18 ~04:4x–05:50 +07. Slice trước N2241 DONE + PUSHED (main 723735c2, SSOT 11556/1691/1622/3035 — đã xác minh lại từ disk).

## Kết luận scoping

N2242 làm được, không còn blocker. 1 hàm pure mới + 1 driver tick line. Đây là wiring đầu tiên map `game["bullets"]` sống thật (ShockwaveTower N2190/N2195 chưa từng map live bullets — scan chỉ đọc frame key do test seed). GAP: live bullets chưa mang team — cần slice deferred stamp team ở spawn, nếu không should_consume chưa sống thật trong live play.

## Java đã pin (đọc từ disk)

- PointDefenseTurret.java:65-67 Groups.bullet.intersect min-dst2 pick.
- Mọi live Bullet đều có team (BulletComp.java:29 @Import Team team).
- hittable class default true (BulletType.java:143; 2 ngoại lệ damageLightning :32, fireball :45 trong Bullets.java).
- LIVE MEASUREMENT (không đoán): `game["bullets"]` dicts chỉ mang sprite/target/velocity/speed/damage/hitSize/lifetime_remaining — KHÔNG team/hittable/id/type; single writer SourceBulletSpawnState.gd:38-41, chain không truyền team.

## RED (2026-11-18 ~04:4x +07)

- RED 4 failed (Ran 4 in 1.227s, FAILED (failures=2, errors=2); KeyError 'N2242' ×2 — main-thread re-run).
- Register --verify 10/10 exit 0. NOTE: RED test file sau đó được worker sửa (Godot 4.6 `Object.get` chỉ nhận 1 arg — dòng driver PINNED trong test dùng 2 arg); sửa này chỉ là test-harness.

## GREEN (2026-11-18 ~04:4x–05:33 +07)

- 1 hàm pure mới trong `SourcePointDefenseTurretBuildState.gd`:
  - `source_point_defense_turret_live_bullets_state(live_bullets)` (:441) trả `{"observed_bullets": [...]}`.
  - + 1 driver tick line (:582, stamp `frame["observed_bullets"]` từ live `game["bullets"]` MỖI tick, vô điều kiện, ngay trước block `if frame.has("observed_bullets")`).
  - Mapping: id = sprite.get_instance_id() (tiền lệ SourcePlacedBlockState.gd:11; sprite bị freed → bullet bị drop, khớp invalidation !isAdded()); x/y = sprite.position (sprite invalid → drop); damage từ live dict; team CHỈ khi live dict mang theo (không bịa -1); hittable mặc định true (2 type false = giới hạn đã ghi, lookup theo type sau); has_type true (mọi live bullet đều được tạo với 1 type).
- Proof `C07PointDefenseTurretLiveBulletsWiringProof.gd` + `.tscn` (mới): 8 key semantic đã pin.
- Register --verify 10/10; main() exit 0. SSOT từ disk: **11557/1692/1623/3037** — đúng delta dự kiến (symbols +1, Done +1, contracts +1, schema +2). N2242 trong ledger, status done. Defense shard change: defense_slices 170 → 171, defense_api_contracts 169 → 170.
- Targeted **4/4 OK** (main-thread re-run với godot trên PATH: Ran 4 tests in 16.267s, OK).
- Family PointDefenseTurret **20/20 OK** trong 68.038s (5 module: power_status N2151 + target_acquire N2239 + aim_shoot N2240 + should_consume_cooling N2241 + live_bullets_wiring — worker log, sau khi sửa 3 scene dưới).
- Wiring-standard **32/32 OK** (9 module, 250 subtests, pytest 124.51s — worker log).
- **Tổng 56/56 OK.** `git diff --check` sạch (kiểm tra lại trước commit).
- Godot proof headless Linux: scene `C07PointDefenseTurretLiveBulletsWiringProof.tscn`, exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretLiveBulletsWiringProof.json` (untracked, KHÔNG stage — file ignored): **8 semantic key / 11 trong JSON, matches:true** — wiring_assigns_stable_id_from_sprite, wiring_clears_pooled_target_when_bullet_leaves_live_list, wiring_defaults_hittable_true, wiring_excludes_bullet_without_team, wiring_maps_live_bullet_position_from_sprite, wiring_marks_has_type_true, wiring_reads_team_and_hittable_when_present, wiring_stamps_observed_bullets_every_tick (proof ~05:33 +07, mtime JSON 22:33 UTC).
- Deferred pool: **282 → 284** (+2 hợp lệ: +1 nợ proof Windows N2242 VÀ +1 entry spawn-side team stamp; resolve 0).

## Harness fixes (worker, KHÔNG đụng gameplay/driver)

NEIGHBOUR REGRESSION (hậu quả có chủ đích của wiring, KHÔNG phải bug driver — xem `goal hidden_files/n2242-neighbour-regression.md`): family 17/20 trước khi sửa scene — N2239 target_acquire FAIL (4 key acquire False), N2240 aim_shoot FAIL, N2241 should_consume_cooling FAIL (should_consume_true_when_enabled_with_target + should_consume_false_when_disabled False). Gốc rễ: driver ghi đè frame observed_bullets do scene seed bằng [] (game["bullets"] trống trong scene) → không bao giờ acquire. Sửa 3 proof scene (worker 05:15, harness-only): seed live bullets trong `game["bullets"]` (Sprite2D + team + damage + hittable) thay vì frame observed_bullets. Lượt family đầu sau sửa scene FAIL (failures=2) do lỗi PARSE GDScript trong 2 scene viết lại ("Expected indented block after function declaration" tại :9 của AimShoot + ShouldConsumeCoolant .gd) — worker sửa indentation, lượt thứ hai pass 20/20.

## Gate toàn bộ (main thread, PID 3999, ~05:3x–05:50 +07)

- Ran **6061** trong 1116.723s, failures=**192**, skipped=5, errors=**0** — cả 192 đều là `AssertionError: unexpectedly None` (Godot-absent; đếm trực tiếp trong log: `unexpectedly None` = 192, `FAIL:` = 192, `ERROR:` = 0, KeyError = 0). Test reference N2242 nằm trong 192 (gate log Godot-absent như dự kiến). KHÔNG phải regression. Log `tools/mindustry_godot_transpiler/full-suite-n2242-gate.log` (untracked, KHÔNG stage).
- Đối chiếu footer: Ran 6057 → 6061 (+4 test N2242); failures 191 → 192 (+1 test reference của slice mới, Godot-absent); errors 0 → 0. Khớp đúng dự kiến trong handoff (handoff ghi "~191" của worker là SAI 1, đúng là 192 theo mẫu +1/slice).
- origin/main không di chuyển trước khi push: local main đã ở 723735c2 == origin/main (fetch lúc ~06:00), không cần fast-forward.

## Môi trường

- Worker 04:15 timeout ở phase khảo sát (không để lại gì); worker 04:45 GREEN xong nhưng family 17/20; worker 05:15 sửa 3 scene + chạy targeted/family/wiring xong nhưng timeout trước docs/gate/commit, và gate nó launch đã CHẾT cùng session (log 233 byte, 224 dots / 8 F / 0 E, không footer — main thread relaunch). Logs worker ở goal hidden_files/n2242-*.log.
- VM clock chạy UTC — file mtime ~22:3x UTC = ~05:3x +07.

## Hashes

- 5-commit xong: slice af2d4208, docs f5bbd03c, GOAL 4ec00cbc — đã push lên origin main (main 4ec00cbc).
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: spawn-side team stamp slice (deferred entry N2242) để should_consume sống thật trong live play; suppression live + targets live list vẫn BLOCKED. (KHÔNG bắt đầu C08 inventory trừ khi user yêu cầu.)
