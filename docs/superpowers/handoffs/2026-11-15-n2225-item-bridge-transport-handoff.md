# Handoff N2225 — ItemBridge Transport Advance

**Status: DONE** (coordinator lượt 4 — wave advances-2). Slice `5396a786` trên branch `slice/N2225-item-bridge-transport` (base `542b383e`, đã push 16:58, remote tip 5396a786). Integration `integration/wave-advances-2-n2224-n2228`: cherry-pick `7d2dfd87` + SSOT gộp `e76dd9c8` (11507/1669/1592/2975).

## What changed

- `SourceItemBridgeBuildState.gd`: pure `source_item_bridge_update_transport_state(frame, ...)` → 10 result symbols (transport_counter, warmup, time, time_speed, moved, incoming, items, take_rotation, partner_items, partner_incoming); driver ghi ngược cả 2 frame (partner frame là dict reference từ meta, tiền lệ N2199); `time = -8f` trong `_initial_frame` (mở rộng 9 keys mới); take() faithful qua catalog item_names_by_id; advance chạy sau recompute N2197, chỉ khi enabled.
- New: `test_c07_item_bridge_transport.py`, `register_c07_item_bridge_transport.py`, `C07ItemBridgeTransportProof.gd/.tscn` (6 keys).

## Java ground truth

ItemBridgeBuild.updateTile (:323-352) + checkIncoming (:305-322) + updateTransport (:358-370). timeSpeed approachDelta 1/60f; time += timeSpeed * delta(); warmup approachDelta toward efficiency 1/30f; transportCounter += edelta, while >= transportTime 2f: take → acceptItem → handleItem else add back + undoFlow. checkAccept rút gọn thành hasItems && same team && total < itemCapacity vì linked(source) luôn true khi hadValidLink đúng (:464-466).

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +10/+1/+1/+2 → 11480/1665/1588/2967 (slice riêng), audit 1336, legacy 0. Exact exprs 68. DEFERRED 258 (258 − 4 + 4). **KHÔNG shard nào đổi.** Family 4 module cũ 12/12 non-proof PASS.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07ItemBridgeTransportProof` — 6 keys: transport_counter_charges_with_edelta, handoff_at_transport_time, item_returns_when_partner_rejects, warmup_approaches_efficiency_when_linked, warmup_zero_when_unlinked, incoming_prunes_dead_links.

## Deferred (không trong slice này)

- timerCheckMoved / wasMoved snapshot (timer 30f, no timer infra); doDump / dumpAccumulate; checkAccept facing (chỉ cần cho nguồn non-linked); live items intake.
