# N2225 ItemBridge Transport Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-2, integration branch `integration/wave-advances-2-n2224-n2228`, base `542b383e`).

## Source

- ItemBridgeBuild.updateTile (ItemBridge.java:323-352) + checkIncoming (:305-322) + updateTransport (:358-370): timerCheckMoved (deferred — no timer infra); timeSpeed approachDelta 1/60f; time += timeSpeed * delta(); checkIncoming prune; hadValidLink recompute (**already done by N2197 — not redone**); !linked → doDump + warmup = 0; else incoming registration + warmup approachDelta toward efficiency 1/30f + transportCounter += edelta, while >= transportTime 2f: items.take → acceptItem → handleItem (moved=true) else add back + undoFlow.
- Build fields (ItemBridge.java:198-203): link=-1, incoming, warmup, **time = -8f** (not 0!), timeSpeed, wasMoved/moved/hadValidLink, transportCounter; itemCapacity 10; single def phase-conveyor.
- checkAccept facing: in the transport path, `linked(source)` (ItemBridge.java:464-466) is **always true when hadValidLink holds** — linkValid(this, partner) checkDouble is the same condition both ways, and `source.link == partner pos` by construction — so checkAccept returns true via the shortcut and acceptItem reduces to `hasItems && same team && total < itemCapacity`. Facing/geometry (`Edges.getFacingEdge` + `relativeTo`, :445-458) is only needed for non-linked sources (a conveyor feeding from the side) → deferred as its own entry.
- Advance runs after the N2197 recompute, only when enabled (`noUpdateDisabled = true` — Java-exact here, BuildingComp.java:2274-2277, not a pragmatic choice like N2195).

## Implementation

- `SourceItemBridgeBuildState.gd`:
  - Pure `source_item_bridge_update_transport_state(frame, source_delta, time_scale, transport_time, item_capacity, had_valid_link, tile_pos, partner, incoming_valid, item_order)` → 10 result symbols: transport_counter, warmup, time, time_speed, moved, incoming, items, take_rotation, partner_items, partner_incoming (8 self + 2 partner).
  - The driver writes back BOTH frames (the partner frame is a dict reference from meta, N2199 precedent). `tile_pos` is a separate param because the frame carries no self pos.
  - `take()` is faithful: rotation runs over the catalog `item_names_by_id` (content-id order Java iterates), `take_rotation` is a frame key; `undoFlow` is a documented no-op (it only touches flow cacheSums, the port has no flow state).
  - Reuses existing helpers, no re-implementation: `SourceMathState.source_approach_delta` (approachDelta scales by RAW Time.delta), `SourceDrillInventoryRuntimeState` (add/remove/total), `game_source_delta` + `time_scale` live.
  - `time = -8f` in `_initial_frame` (extended with 9 new keys; the N2197 test only asserts a substring so it does not break).
  - doDump DEFERRED (like N2195): `doDump → dumpAccumulate → dump()` needs proximity + neighbor acceptItem/canDump the bridge driver does not gather; the helper exists in `SourceBuildingItemDumpState` but no driver wires it for bridges. The unlinked branch still models `warmup = 0f`.

## Commits

- Slice `5396a786` (worker-N2225, branch `slice/N2225-item-bridge-transport`, 5 files +1115/−3; đã push 16:58, remote tip 5396a786).
- Integration cherry-pick `7d2dfd87`; SSOT gộp `e76dd9c8` (wave advances-2): 11507/1669/1592/2975 (slice riêng +10/+1/+1/+2 → 11480/1665/1588/2967).

## Tests

- RED đúng mẫu trước GREEN (KeyError N2225 + thiếu pure function).
- Targeted post-register: 3/4 PASS (registration, exact-evidence 68/68, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Family check: 4 old modules (power/shouldConsume/link/auto-link) 12/12 non-proof PASS, only the 4 proof tests fail Godot-absent as before — no family regression.
- Targeted wave (5 module): Ran 20, 15 PASS + 5 proof Godot-absent. Neighbours 12 module power+gate+link: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-2: Ran 5969 in 1029.991s, failures=169, skipped=5, 0 errors — 169/169 Godot-absent (164 inherited + 5 new proof tests N2224–N2228).

## SSOT / DEFERRED

- SSOT slice riêng +10/+1/+1/+2 → 11480/1665/1588/2967; audit 1336, legacy 0. **KHÔNG shard nào đổi** — chỉ 4 file SSOT canonical.
- DEFERRED 258 (258 − 4 + 4): removed the `ItemBridge updateTile advance` (N2179) AND `ItemBridge updateTransport advance` (N2197) entries — both resolve here, same content with different wording — plus `checkIncoming / incoming rows` and `acceptItem / checkAccept rows`; added timerCheckMoved/wasMoved snapshot, doDump/dumpAccumulate, checkAccept facing, live items intake.
- DEFERRED gộp sau wave advances-2: 260 entries (258 − 8 resolved + 10 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07ItemBridgeTransportProof` — 6 keys: transport_counter_charges_with_edelta (with timeSpeed/time with was_moved, time −8f), handoff_at_transport_time (incl. double-handoff in 1 tick), item_returns_when_partner_rejects (incl. take-null still subtracts the counter), warmup_approaches_efficiency_when_linked, warmup_zero_when_unlinked (counter frozen when unlinked), incoming_prunes_dead_links (incl. partner registration, no duplicate, ghost prune).
