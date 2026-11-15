# N2231 PayloadLoader updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-3, coordinator lượt 4).

## What this slice did

- PayloadLoader shouldExport/moveIn/moveOut/load items+liquids/battery as a pure advance in `SourcePayloadLoaderBuildState.gd` (PayloadLoader.java:148-220), in Java order. moveOut REUSES the ported helper `SourceBlockProducerMoveOutPayloadState.move_out_payload_state` via preload (N2224 precedent) — signature matches completely.
- 14 result symbols; driver passes `load_tick=false` live (no timer helper — cadence deferred); no enabled guard (PayloadLoader `noUpdateDisabled = false`, Block.java:170).

## Key facts for the next agent

- **PayloadLoader HAS rotate** (`rotate = true;`, PayloadLoader.java:45) — the wave scope's "no rotate" claim was WRONG; moveIn target is rotdeg() via `block_rotate` param. The same correction applies to N2232 (PayloadUnloader inherits rotate).
- **Default acceptItem is NOT `total < capacity`** — it is `block.consumesItem(item) && items.get(item) < getMaximumAccepted(item)` (BuildingComp.java:864-866). Payload contract adds `accept_item_open` / `accept_liquid_open` flags + LiquidVoid.
- `hasArrived` is `len2 < 0.01` (Vec2.isZero compares squared length).
- The battery-charge DEFERRED row was removed together with the advance row (same Java lines :202-213).
- Register: 132 exact exprs, 0 missing. DEFERRED: 263 (260 − 3 + 6 new: timer cadence, movePayload/dumpPayload application, live front gather, acceptItem/acceptLiquid per-type rows, super.updateTile payload update, payload dict contract unify).
- Slice commit `d8f2a916` (branch `slice/N2231-payload-loader-update-tile`, đã push 17:43); integration cherry-pick `39b24a9d`; SSOT gộp `b5129382` (11568/1675/1598/2987).

## Godot debt (this slice)

- `C07PayloadLoaderUpdateTileProof` — 6 keys: move_in_arrives_at_center, load_items_on_timer_tick, load_liquids_folds_edelta, battery_charges_and_exports_when_full, should_export_folds_flags, move_out_pushes_payload. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
