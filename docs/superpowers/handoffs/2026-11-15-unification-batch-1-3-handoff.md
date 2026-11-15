# Bàn giao: unification batch 1–3 (2026-11-15, coordinator lượt 5)

## Đã xong

Branch `integration/unification-batch-1-3` (base `8a2c302e`, SSOT gộp `ed2e9251`, docs commit này): toàn bộ batch 1–3 đã vào wave line.

- **B1**: 14 cherry-pick (8 nhóm slice+fix), hash map đầy đủ trong report.
- **B2**: 3 merge tay — N2186/N2238 (LaunchPad driver, 6 hunk,
  `5726e0ee` + test fix `ff725ce0`), N2195/N2202 (BeamDrill,
  `d7512292`; `_initial_frame` không conflict như dự đoán),
  N2189/N2241 (LightBlock, `00e6588b`, proof 8 key).
- **B3**: SSOT gộp `ed2e9251` = **11642/1691/1613/3017** (schemas 3017,
  không phải 3018 như phương án dự báo — overlap LightBlock là −2 vì
  input + result là 2 entry; đã verify bằng JSON diff). DEFERRED gộp
  283 entries (`DEFERRED-after-unification.py`).
- **B4**: targeted Ran 40 failures=10 toàn Godot-absent; neighbours
  Ran 44 failures=11 toàn Godot-absent; 0 errors.
- **B5**: full gate full gate (PID 21602, launch ~19:10, done 19:29 +07) Ran 6054 in 1114.842s, failures=190, skipped=5, 0 errors — 190/190 Godot-absent (182 inherited + 8 new proof tests N2186/N2187/N2190/N2191/N2192/N2193/N2194/N2195).
- **B6**: 9 report + 9 handoff batch mang nguyên văn; 10 dòng spec
  (9 slice + N2196); GOAL.md §4/§5; branch đã push.
- **Nợ Godot: 66 proofs + 1 re-run (N2196).** 8 proof mới: N2186,
  N2187, N2190, N2191, N2192, N2193, N2194, N2195 (mỗi proof 6 key).
  N2189 gộp vào proof N2241 (nay 8 key, entry §5 đã cập nhật).

## Việc tiếp theo (cho lượt sau)

1. **Re-scope advances-5** (Mend heal scan build trên N2193 — N2193
   giờ đã có trong ledger; scope cũ trong SCOPE-advances-5-wave.md SAI
   ở điểm này; BuildTurret; PayloadMassDriver) rồi spawn worker song
   song tối đa (1 slice = 1 worktree + 1 branch, nhãn worker-NXXXX).
2. Second consumers → C08–C12 theo `DESIGN-frame-state-infra.md`.
3. Backlog coordinator-serial (không chặn): disabled early return
   driver-wide; raw-delta audit; N2198 tick cross-def fix; N2160/N2181
   cite-cleanup; SourceMathState.random_seed_int; moveInPayload dedup;
   payload dict contract; timer-infra; N2232 power-production wiring;
   TractorBeam dead files (KHÔNG xóa khi chưa có ý user).
4. N2197 chưa có dòng spec checklist riêng (chỉ được nhắc trong dòng
   N2188/N2198/N2199) — khoảng trống có từ trước, bổ sung khi rảnh.
5. Nhắc lại: KHÔNG chạy Godot trên VM này; KHÔNG push/merge/rebase
   main; KHÔNG đổi số N2186/N2187 khi chưa có user chốt số mới.
   Merge-to-main sau này: remote N2186/N2187 (ImpactReactor live reads)
   giữ số; của mình đổi số mới.

## Trạng thái repo

- Local main vẫn `de9ab89c`; remote main `63a277b6` (không đụng).
- 72 branch trên GitHub trước unification (18:58); branch này push ngay sau docs commit theo push-as-you-go.
- Worktree unification:
  `~/workspace/mindustry-parallel/wt-integration-unification-batch`.
