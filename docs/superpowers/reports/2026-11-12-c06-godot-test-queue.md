# C06 — Những thứ cần test bằng Godot

Date: 2026-11-12. Nguồn: full gate sạch hậu-merge N2128+N2129+N2130, chạy xong ~10:11 +07 —
`Ran 5617 tests in 2041.5s, FAILED (failures=3)`, 0 errors, 0 skipped.
Cả 3 lỗi đều là test proof Godot; 78 test proof còn lại đã xanh với Godot 4.6.2 trong VM.
File này chỉ liệt kê những gì còn cần test lại bằng Godot, không liệt kê lại test đã xanh.

Godot trong VM: `~/workspace/godot-bin/godot` (4.6.2-stable Linux).
Chạy lẻ một proof từ repo root:

```bash
PATH="$HOME/workspace/godot-bin:$PATH" godot --headless --path godot-mindustry \
  --scene tools/runtime_proofs/<Proof>.tscn --quit-after 300
```

Trên Windows (đường dẫn project `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`):

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path <repo>\godot-mindustry --scene tools/runtime_proofs/<Proof>.tscn --quit-after 300
```

Quy tắc: chạy từng proof một, KHÔNG chạy trong lúc gate đang chạy (mỗi scene đều
khởi động MCP autoload bind port 7777; port bận sẽ in `ERROR:` vào output và làm
fail test nào assert không có `ERROR:`). Proof JSON là file gitignored, không bao giờ stage.

## Cần test lại

- [ ] **C06DefenseProof** — `tests.test_c06_defense_leg.C06DefenseLegTests.test_reference_graph_and_actual_c06_defense_leg`
  - Scene: `godot-mindustry/tools/runtime_proofs/C06DefenseProof.tscn` (timeout 180s).
  - Proof JSON: 30 keys. Lý do fail trong gate: `matches: false` — các key
    `defense_dagger_died`, `defense_core_unharmed`, `defense_death_before_core`,
    `defense_dagger_swept` đều false (trận dagger chưa tới đích trong 300 frames).
  - Đã kiểm chứng: chạy lẻ trong VM lúc ~09:49 được `matches: true`, lúc 09:51 lại
    `matches: false`. Trên Windows (commit 983daf2, ~10:40 +07): unittest đạt 4/5 lần;
    lần fail tái hiện đúng lỗi — địch chưa chết, core bị thương, không có lỗi runtime.
    Test lại trên VM lúc ~10:47: chạy scene lẻ 5 lần, cả 5 đều `matches: true`.
    Tỉ lệ đạt tổng cộng khoảng 80%, dao động cả trên Linux lẫn Windows.
  - NGUYÊN NHÂN ĐÃ CHỨNG MINH (~11:20 +07): mỗi phát bắn cộng góc lệch ngẫu nhiên
    ±2° (`randf_range` trong `turret_random_inaccuracy_offset`, RNG tự seed mỗi lần
    chạy Godot — đây là nguồn random duy nhất trong sim). Thí nghiệm quyết định: bản
    debug copy với `seed(12345)` cố định cho 3 lần chạy giống hệt nhau từng tick
    (death_tick 545, 17 hits, ammo còn 12, core 1100.0) → RNG là nguồn dao động duy
    nhất, setup frames không ảnh hưởng. Biên: dagger 150 HP cần 17 phát trúng
    (9 dmg/phát), tối đa ~23 phát trong cửa sổ → chỉ được trượt tối đa 6 phát.
    Random này đúng theo Java gốc (Mathf.range) nên port không sai — cái mỏng là
    biên của proof scene. (File debug đã xóa.)
  - FIX ĐÃ ÁP DỤNG (~11:36 +07, theo lựa chọn của user "Seed RNG trong scene"):
    thêm `seed(12345)` đầu `_ready()` của `C06DefenseProof.gd` + comment giải thích.
    Chỉ đụng proof scene (test harness), code game và gameplay không đổi. Verify:
    chạy scene thật 3 lần, cả 3 đều `matches: true` đủ 31 key, không ERROR;
    test module `test_c06_defense_leg` 5/5 OK (gồm test chạy scene assert matches).
    Đã commit + push lên fork. Tick xong.

- [x] **DrillProximityLifecycleProof** — `tests.test_drill_proximity_lifecycle.DrillProximityLifecycleTests.test_actual_proximity_mutation_and_dominant_production`
  - Scene: `godot-mindustry/tools/runtime_proofs/DrillProximityLifecycleProof.tscn` (timeout 120s).
  - Proof JSON: 22 keys. Lý do fail trong gate: proof cho `matches: true` nhưng
    test fail ở `assertNotIn('ERROR:', output)` — MCP autoload không bind được
    port 7777 (`ERROR: [MCP Runtime] Failed to start server on port 7777: 22`).
  - Đã kiểm chứng: chạy lẻ trong VM lúc ~09:49 xanh thật (22 keys, `matches: true`).
    Trên Windows (commit 983daf2, ~10:40 +07): đạt cả hai chế độ, không lỗi cổng.
    Lỗi port 7777 chỉ xảy ra trong gate Linux, không phải lỗi thật.

- [x] **FactoryDumpSwapProof** — `tests.test_factory_dump_swap_binding.FactoryDumpSwapBindingTests.test_reference_graph_and_actual_factory_dump_swap`
  - Scene: `godot-mindustry/tools/runtime_proofs/FactoryDumpSwapProof.tscn` (timeout 180s).
  - Proof JSON: 8 keys. Lý do fail trong gate: giống DrillProximity — proof cho
    `matches: true`, test fail ở `assertNotIn('ERROR:', output)` vì MCP autoload
    không bind được port 7777.
  - Đã kiểm chứng: trên Windows (commit 983daf2, ~10:40 +07): đạt cả hai chế độ,
    không lỗi cổng. Lỗi port 7777 chỉ xảy ra trong gate Linux, không phải lỗi thật.

## N2131 — đã xanh, không cần test lại

- [x] **C06UnitAssemblerPayloadIntakeProof** — slice N2131 (payload intake),
  test `tests.test_c06_unit_assembler_payload_intake`. GREEN xong ~10:21 +07:
  scene đã viết, proof chạy lẻ GREEN (14 keys, all true), test module 4/4 OK.
  Không cần test lại — trừ khi full gate N2131 báo lỗi gì thêm.
  Chưa test trên Windows: scene/source chưa push (chờ full gate N2131 xong mới
  commit + push lên fork); test sau khi push.
  - Scene `godot-mindustry/tools/runtime_proofs/C06UnitAssemblerPayloadIntakeProof.tscn`.
    Prefix: `C_06_UNIT_ASSEMBLER_PAYLOAD_INTAKE_PROOF `.
  - Nội dung proof theo handoff N2131: stell accepted từ empty (blocks 1, total 1),
    stell accepted lần nữa (2), stell ở cap 4 (round(4 * 1.0) = 4, không < 4 → rejected),
    stell với unitCost 2.0 (cap 8, 4 held → accepted), module source cùng held payload
    (blocks 2 → accepted, blocks 3 → rejected), non-module source có held payload
    (rejected), unit payload dagger (accepted, blocks 1), unit payload quá cap (rejected),
    unknown content (rejected), plan-less (rejected).

## Đã xanh, không cần test lại

- 3 test module proof của N2128 + N2129 + N2130 (12/12 OK, 30/18/14 keys, `matches: true`,
  chạy ~08:52 +07 trên Godot 4.6.2 Linux trong VM).
- 78 test proof còn lại trong full gate sạch (chỉ 3 test trên fail).
