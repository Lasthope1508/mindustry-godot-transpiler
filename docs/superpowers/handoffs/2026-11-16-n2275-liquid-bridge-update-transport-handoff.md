# N2275 LiquidBridge UpdateTransport Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## What this slice did

LiquidBridge updateTransport advance: warmup gate (≥ 0.25f) + moveLiquid pressure flow + moved flag. Pure `source_liquid_bridge_update_transport_state` → 5 keys (warmup, moved, flow, liquids_after, partner_liquids_after). Warmup approaches efficiency at 1/30f when linked, 0f when unlinked; `moved |= flow > 0.05f`.

## Key facts for the next agent

- **The brief omitted the ItemBridge `acceptLiquid` OVERRIDE** (ItemBridge.java:434-439) — ported: partner current must equal the moved liquid OR partner current amount < 0.2f; checkAccept passes via the linked() shortcut (always true when hadValidLink, N2225 reasoning).
- **moveLiquid is BuildingComp.java:938–978** (not :938–960); reaction branch :954–976 (not :950–960); `return 0;` at :977. Reaction branch deferred (Java's own TODO: wrong for multi-liquid).
- `getLiquidDestination` default returns self (BuildingComp.java:980-982, no override on ItemBridge/LiquidBridge). Phase-conduit does NOT set liquidPressure → Block default 1f (Block.java:79). Both LiquidBridge defs share liquidCapacity 100f (Blocks.java:2381/2395).
- The driver wires the advance after the N2197 had_valid_link recompute (Java order), enabled-only; both liquid stores written back to sprite metas (N2232 precedent). doDump is NOT this slice.
- SSOT +5/+1/+1/+2 → 11800/1724/1655/3102 (audit 1336). +5, not the SCOPE-estimated +4 (5 return keys). Exact-evidence 61/61. DEFERRED 292 (−1 resolved + 3 new: moveLiquid reaction branch, live liquids intake, inherited updateTile steps).

## Godot debt (this slice)

`C07LiquidBridgeUpdateTransportProof` — 6 keys: warmup_approaches_efficiency, transport_blocked_below_warmup_quarter, move_liquid_transfers_by_pressure, moved_set_when_flow_above_threshold, no_transfer_when_partner_full, warmup_zero_when_unlinked (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_liquid_bridge_update_transport`. Do NOT mark done until it passes there.
