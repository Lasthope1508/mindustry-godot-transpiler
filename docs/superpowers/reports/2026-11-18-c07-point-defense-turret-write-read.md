# Báo cáo — N2245 PointDefenseTurret write/read (C07)

Ngày: 2026-11-18 ~12:00–12:45 +07. Slice trước N2244 DONE + PUSHED (main f5d19d55, SSOT 11561/1694/1625/3041 — đã xác minh lại từ disk).

## Kết luận scoping

N2245 làm được: thân `PointDefenseBuild.write()` + `read()` (PointDefenseTurret.java:117-128) — chỉ persist đúng rotation của turret, không persist target (re-acquire bằng retarget timer), không persist reloadCounter (nạp lại mỗi tick). Không có revision guard (khác RepairTurret.read(), N2217) nên read khôi phục vô điều kiện, không cần tham số revision hay frame. PointDefenseTurret không override `version()` nên save version là BuildingComp default 0, pin bằng const `POINT_DEFENSE_TURRET_SAVE_VERSION := 0`. KHÔNG có driver tick line (save/load, tiền lệ N2217). Không còn blocker. Suppression live + targets live list vẫn BLOCKED (cần frame plumbing) — không thuộc slice này.

## Java đã pin (đọc từ disk)

- PointDefenseTurret.java:117-121 `public void write(Writes write){` — :118 `super.write(write);`, :119 `write.f(rotation);` (chỉ 1 field của chính nó).
- PointDefenseTurret.java:123-128 `public void read(Reads read, byte revision){` — :124 `super.read(read, revision);`, :125 `rotation = read.f();` (khôi phục vô điều kiện, không `if(revision >= 1){`).
- Rotation default 90.0: `public float rotation = 90;`, BaseTurret.java:114.
- Save version default 0: `public byte version(){` / `return 0;`, BuildingComp.java:669-671 (PointDefenseTurret không override version()).
- Target không persist — re-acquire: `if(timer(timerTarget, retargetTime)){` / `target = Groups.bullet.intersect(...).min(...)`, PointDefenseTurret.java:65-67.
- reloadCounter không persist — nạp lại mỗi tick: `reloadCounter += edelta();`, PointDefenseTurret.java:79; `public float reloadCounter;`, ReloadTurret.java:26.
- Đối chiếu: RepairTurret.read() có revision guard (RepairTurret.java:246-248, tiền lệ N2217) — PointDefenseTurret thì không.

## RED (cron 12:00, worker)

- RED 4 failed — registration KeyError 'N2245', evidence KeyError 'N2245', state pins missing (pure functions chưa viết), proof test Godot-absent (`assertIsNotNone(godot)` — godot NOT on PATH, baseline của gate, KHÔNG phải regression).
- Register --verify: 20/20 exprs present.
- Port 7777 free; javalang OK; HEAD == origin/main == f5d19d55 (N2244, đã push).

## GREEN (cron 12:00 worker + main-thread xác minh lại)

- 2 pure functions trong `SourcePointDefenseTurretBuildState.gd`: `source_point_defense_turret_write_state(frame)` (:513) → `{"rotation": frame.get("rotation", 90.0)}` (absent → 90.0 class default, BaseTurret.java:114) + `source_point_defense_turret_read_state(saved_rotation)` (:530) → `{"rotation": saved_rotation}`. Const `POINT_DEFENSE_TURRET_SAVE_VERSION := 0`. NO driver tick line (save/load, tiền lệ N2217).
- Register script chạy: SSOT **11561/1694/1625/3041 → 11563/1695/1627/3045**; defense shard slices 173 → 174, contracts 172 → 173.
- Targeted **4/4 OK** (52 subtests, 13.89s worker — main-thread re-run 4/4 in 15.752s, log goals/.../hidden_files/n2245-targeted-main.log).
- Family PointDefenseTurret **32/32 OK** (8 module, 299 subtests, 110.37s worker — main-thread re-run 8/8 modules OK, log goals/.../hidden_files/n2245-family-main.log).
- Wiring-standard **32/32 OK** (9 module, 130.46s, main-thread run, log goals/.../hidden_files/n2245-wiring-main.log).
- **Tổng 68/68 OK** (targeted + family + wiring). `git diff --check` sạch (main thread xác minh lại sau khi viết docs).
- Godot proof headless Linux: scene `C07PointDefenseTurretWriteReadProof.tscn` (.gd + .tscn mới), exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretWriteReadProof.json` (untracked, KHÔNG stage — file ignored): **8 semantic key + 2 harness key, 11/11 true, matches:true** (JSON viết 05:12 UTC = 12:12 +07, đã xác minh lại từ disk) — write_returns_current_rotation, write_returns_only_rotation, write_defaults_to_90_when_absent, write_read_round_trip, read_restores_saved_rotation, read_restores_saved_rotation_second_value, read_returns_only_rotation, version_is_0.
- Deferred pool: **284 → 284** (không resolve entry nào; +1 nợ proof Windows N2245).

## Gate 1 — toàn bộ (main thread, PID 11556, ~12:2x–12:40 +07)

- Ran **6073** trong 1067.969s, failures=**195**, skipped=5, errors=**0** — cả 195 đều là `AssertionError: unexpectedly None` (Godot-absent; đếm trực tiếp trong log: `unexpectedly None` = 195, `FAIL:` = 195, `ERROR:` = 0). Test reference N2245 nằm trong 195 (gate log Godot-absent như dự kiến). KHÔNG phải regression. Log `tools/mindustry_godot_transpiler/full-suite-n2245-gate.log` (untracked, KHÔNG stage).
- Đối chiếu footer: Ran 6069 → 6073 (+4 test N2245); failures 194 → 195 (+1 test reference của slice mới, Godot-absent); errors 0 → 0. Khớp đúng dự kiến.
- VM clock chạy UTC — file mtime ~05:xx UTC = ~12:xx +07.

## Môi trường

- Worker cron 12:00 làm xong GREEN nhưng timeout trước khi viết handoff đầy đủ; gate 1 launch từ main thread, sống tới footer.
- Gate launch guard: ps ở exec riêng (không gate nào đang chạy); javalang + pytest OK; godot KHÔNG trên PATH; port 7777 free.

## Hashes

- 5-commit xong: slice 0f0683b7, docs 61a5ad16, GOAL 5ad7ff5d — đã push lên origin main (main 5ad7ff5d).
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: PointDefenseTurret setStats (:36-42) + icons (:31-34) rows, live coolant efficiency / trừ liquid / coolEffect, bullet hitSize, live bullet removal. Suppression live + targets live list vẫn BLOCKED (cần frame plumbing). (KHÔNG bắt đầu C08 inventory trừ khi user yêu cầu.)
