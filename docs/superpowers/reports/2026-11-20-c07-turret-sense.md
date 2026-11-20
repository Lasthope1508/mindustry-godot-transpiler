# Báo cáo — N2283 Turret sense() LAccess dispatch (C07) [DONE + PUSHED]

Ngày: 2026-11-20 ~17:0x +07 (GREEN), gate xong 17:38:33 +07, push ~17:5x +07.

## Trạng thái

- N2282 DONE + PUSHED (origin/main a7b1a81c).
- N2283 DONE + PUSHED (slice TBD, docs TBD, GOAL TBD, status TBD, hashes TBD): Turret sense() LAccess dispatch — `public double sense(LAccess sensor){ return switch(sensor){ case ammo -> totalAmmo; case ammoCapacity -> maxAmmo; case rotation -> rotation; case shootX -> World.conv(targetPos.x); case shootY -> World.conv(targetPos.y); case shooting -> isShooting ? 1 : 0; case progress -> progress(); default -> super.sense(sensor); }; }` (Turret.java:405-419) — 7 case Turret đều có input live hoặc catalog: ammo → totalAmmo live, ammoCapacity → maxAmmo 30 (class default, duo không override), rotation → frame live (absent → 90.0), shootX/Y → World.conv(targetPos) = coord/8, shooting → frame live is_shooting, progress → frame live progress (N2282 tick). Default → super.sense (BuildingComp.java:2093-2126, ~25 cases) là slice riêng sau — pure function trả handled=false + NaN làm cầu nối. KHÔNG có driver tick (sense là logic read, tiền lệ N2206/N2208/N2223).

## Làm được lượt này (GREEN + gate xong)

- 1 pure function `source_turret_sense_state` (5 params frame, sensor, total_ammo, max_ammo, tilesize; 3 keys: handled, sense_value, sense_value_is_nan) trong SourceTurretBuildState.gd:224, ngay TRƯỚC `source_turret_progress_state` (mirror Java order — sense :405-419 trước progress :425-427).
- KHÔNG có driver tick: sense là logic read; mọi input live đã được proof N2240/N2277/N2282 chứng minh trên frame; logic-processor dispatch hook là slice riêng sau.
- Proof 10 keys: matches:true, 13/13 true (đọc trực tiếp từ C07TurretSenseProof.json — GREEN ~17:0x +07). 10 key semantic: ammo live total (7 → 7.0), ammoCapacity default (30 → 30.0), rotation default (absent → 90.0), rotation custom (135.0 → 135.0), shootX converted ({x:80,y:24} → 10.0), shootY converted (→ 3.0), shooting true (→ 1.0), shooting false (→ 0.0), progress live (0.5 → 0.5), unhandled sensor ("health" → handled false, null, is_nan true).
- `register_c07_turret_sense.py --verify`: 35/35 exprs present (27 exact + 5 input + 3 output, re-run độc lập lượt cron 17:45 +07, exit 0). SSOT đo từ đĩa: 11662/1733/1667/3125 (symbols +3, Done +1, contracts +1, schemas +2); defense slices 210, contracts 209. Đúng kỳ vọng scope.

## Test xanh/đỏ

- Xanh: targeted 4/4 (80 subtests, 16.22s re-run độc lập lượt cron 17:45 +07, Godot trên PATH — lưu ý: lần chạy đầu không có Godot trên PATH nên test reference-graph fail `unexpectedly None`; chạy lại với godot-bin trên PATH thì 4/4 xanh, đúng mẫu gate); neighbours 199 passed (650.15s, exit 0, log hidden_files/n2283-neighbours.log); wiring 32 tests OK trong một batch (Ran 32 in 124.385s, không flake, log hidden_files/n2283-wiring.log); `git diff --check` OK.
- Gate: xong — main-thread GATE-START 10:19:04Z, GATE-EXIT 1 10:38:33Z (log full-suite-n2283-gate.log, chain log hidden_files/n2283-chain.log). Ran 6225 trong 1167.030s, failures=233, skipped=5 — xác minh độc lập: 233 FAIL = 233 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2282).
- Đỏ: không có test đỏ ngoài 233 failure Godot-absent trong gate (mẫu đã biết).

## Blocker

- Không có blocker.

## Bước tiếp theo

- Push N2283 đang chạy (slice + docs + GOAL + status + hashes, theo mẫu N2280/N2281/N2282).
- Slice tiếp theo: chọn từ deferred list — ứng viên đầu: super.sense() delegation (BuildingComp.sense :2093-2126, ~25 cases, N2283 để lại handled=false làm cầu nối); logic-processor dispatch hook (LExecutor sense → turret sense); senseObject() (BuildingComp.java:2128-2136). calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; shootp live wiring cần logic executor; `controlled()` cần player unit; LaserTurret shouldConsume cần bullets live list; validateTarget effective-team live wiring chờ findTarget slice.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-20-c07-turret-sense-handoff.md.
