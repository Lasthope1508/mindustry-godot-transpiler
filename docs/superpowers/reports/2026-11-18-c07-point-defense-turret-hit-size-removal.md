# Báo cáo — N2247 PointDefenseTurret bullet hitSize + live bullet removal (C07)

Ngày: 2026-11-18 ~14:15–14:45 +07. Slice trước N2246 DONE + PUSHED (main 900527f7, SSOT 11566/1696/1629/3049).

## Kết luận scoping

N2247 làm được: hitSize overlap cho acquire + live bullet removal khi bắn lethal — 1 pure function mới + 2 dòng sửa trên hàm cũ + 1 driver tick line. Live coolant efficiency / trừ liquid / coolEffect TÁCH ra N2248 (chưa scope xong: frame không có liquids dict, catalog consumeCoolant chưa xác minh — xem handoff). Không còn blocker cho N2247. Suppression live + targets live list vẫn BLOCKED (cần frame plumbing) — không thuộc slice này.

## Java đã pin (đọc từ disk)

- PointDefenseTurret.java:66 `target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));` — intersect test hitbox đạn, min-dst2 theo tâm.
- BulletComp.java:28 `abstract class BulletComp implements Timedc, Damagec, Hitboxc, Teamc, Posc, Drawc, Shielderc, Ownerc, Bulletc, Timerc, Senseable, Settable{` — bullet là Hitboxc.
- BulletType.java:43 `public float hitSize = 4;` (class default); BulletType.java:970 `bullet.hitSize = hitSize;` (stamp lúc spawn).
- PointDefenseTurret.java:69-71 `if(target != null && !target.isAdded()){` / `target = null;` (pooled invalidation).
- PointDefenseTurret.java:85-88 `if(target.damage() > realDamage){` else `target.remove();` — damage bằng realDamage thì remove, không để lại 0.
- Blocks.java:3838 `range = 180f;`, :3835 `segment = new PointDefenseTurret("segment"){{`; GroupDefs.java:9 `@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;` (Groups.java là build-generated, không có trên disk).

## RED (lần chạy 14:15, main thread)

- Test `tools/mindustry_godot_transpiler/tests/test_c07_point_defense_turret_hit_size_removal.py` (4 tests, theo mẫu N2242).
- Chạy RED: **Ran 4, FAILED (failures=2, errors=2)** — đúng signature RED cổ điển: errors=2 là KeyError 'N2247' (registration + exact-exprs, ledger chưa có N2247); failures=2 là behavior (thiếu `"hit_size"` trong wiring) + reference-graph (proof scene chưa tồn tại). Log `goals/.../hidden_files/` — xem handoff N2247.
- javalang CHƯA cài lại sau restart VM lúc RED (ModuleNotFoundError) — đã cài lại 0.13.0 + pytest 9.2.0 trước khi chạy family/wiring (cả hai importable lúc 14:4x).

## GREEN (lần chạy 14:30, worker này)

- 1 pure function mới trong `SourcePointDefenseTurretBuildState.gd`: `source_point_defense_turret_bullet_removal_state(live_bullets, removed_id)` (:519) → `{"remaining_bullets": [...], "removed": bool}` (identity theo sprite instance id, tiền lệ N2242; id absent thì removed=false, list không đổi; non-dict giữ nguyên).
- 2 dòng sửa trên hàm cũ: wiring N2242 thêm `"hit_size": float(bullet.get("hitSize", 4.0))` vào observed dicts (:515, default BulletType 4f); acquire N2239 đổi point-in-rect thành hitbox-overlap `|bx - x| <= range + hit_size/2`, `|by - y| <= range + hit_size/2` (:209-212, min-dst2 vẫn theo tâm đạn).
- 1 driver tick line (:832): khi `target_removed` thì gọi removal và `game.set("bullets", ...)` viết list đã lọc lại vào live list (tiền lệ game.set của SourceBulletTargetRuntimeState.gd).
- Cập nhật test N2239 `test_c07_point_defense_turret_target_acquire.py` sang dạng overlap (nó pin dòng point-in-rect cũ) — comment + 3 assertIn.
- Register script `tools/mindustry_godot_transpiler/register_c07_point_defense_turret_hit_size_removal.py` (mới): `--verify` **14/14** exprs. SSOT **11566/1696/1629/3049 → 11568/1697/1630/3051** (+2 symbols, +1 Done, +1 contract, +2 schema); defense shard slices 175 → 176, contracts 174 → 175; audit stays 1335.
- Targeted **4/4 OK** (15.826s, gồm cả chạy proof headless).
- Family PointDefenseTurret **40/40 OK** (10 module, log goals/.../hidden_files/n2247-family-main.log) — first pass 9/10: target_acquire FAILED (failures=1, KHÔNG phải port flake — behavior test pin dòng point-in-rect cũ, đã sửa test sang overlap; rerun isolated 4/4 OK trong 13.342s, log goals/.../hidden_files/n2247-family-rerun-acquire.log).
- Wiring-standard **32/32 OK** (9 module, pytest, 123.05s, log goals/.../hidden_files/n2247-wiring-main.log) — pass ngay lần đầu, không flake.
- **Tổng 76/76 OK** (targeted + family + wiring). `git diff --check` sạch.
- Godot proof headless Linux: scene `C07PointDefenseTurretHitSizeRemovalProof.tscn` (.gd + .tscn mới), exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretHitSizeRemovalProof.json` (untracked, KHÔNG stage — file ignored): **8 semantic key + 2 harness key, 11/11 true, matches:true** (JSON viết 07:38 UTC = 14:38 +07) — hitsize_maps_live_bullet_hit_size, hitsize_defaults_to_bullet_type_default, hitsize_acquires_bullet_touching_range_edge, hitsize_ignores_bullet_fully_outside_range, removal_drops_lethally_shot_bullet_from_live_list, removal_keeps_damaged_bullet_in_live_list, removal_keeps_other_bullets, removal_reports_removed_false_when_id_absent.
- Deferred: N2247 deferred_exprs 289 entries (N2246: 288; +1 nợ proof Windows N2247). Số "pool 284" ở row N2246 không tái tạo được từ ledger (đếm trực tiếp: tổng 19427, defense-shard 5932, family point-defense distinct 290) nên không ghi số pool mới — chỉ ghi số đếm được.

## Gate — XANH (main thread)

- Gate 1 (main thread, PID 5686, ~14:4x) CHẾT do VM restart ~15:0x — log `full-suite-n2247-gate.log` đóng băng 5763 byte (5577 dots / 181 F / 0 E, không footer, chết ở ~92% = 5758/6081).
- Gate 2 (main thread, PID 1799, ~15:0x–15:20, log `full-suite-n2247-gate2.log`): **Ran 6081 in 1088.050s, FAILED (failures=197, skipped=5, errors=0)** — tất cả 197 đều `AssertionError: unexpectedly None` (Godot-absent), đếm 197 FAIL header = 197 assert, khớp kỳ vọng Ran 6081 / failures 197. Gate xanh theo quy ước repo (failures toàn Godot-absent).

## Môi trường

- Port 7777 free lúc chạy RED, family, wiring (không có agent validation giữ port lần này — family/wiring không gặp flake nào).
- VM uptime 27 phút lúc bắt đầu run (đã restart): javalang + pytest đã cài lại (0.13.0 / 9.2.0, importable).
- VM clock chạy UTC — file mtime ~07:xx UTC = ~14:xx +07.

## Hashes

- Chưa commit/push: slice CHƯA đủ điều kiện (gate chưa xanh). Worktree: BuildState .gd (sửa), test N2247 (mới), test target_acquire (sửa 3 assertIn + comment), register script N2247 (mới), proof .gd + .tscn (mới), SSOT JSONs (6 file sửa), spec Done 1696 → 1697 + row N2247, GOAL §5 + dòng nợ N2247, report + handoff này. KHÔNG stage `*.gd.uid` (noise, untracked).
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: gate (main thread launch) → 5-commit + push N2247 → N2248 live coolant (xác minh 2 điểm mở trong handoff trước khi RED: frame liquids ở đâu, catalog consumeCoolant key). Suppression live + targets live list vẫn BLOCKED (cần frame plumbing).
