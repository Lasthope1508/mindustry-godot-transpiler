# N2275 LiquidBridge UpdateTransport Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## Source

`updateTransport(Building other)` (LiquidBridge.java:22-26): `if(warmup >= 0.25f){ moved |= moveLiquid(other, liquids.current()) > 0.05f; }`. Warmup approach in ItemBridgeBuild.updateTile (ItemBridge.java:345-346): `warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f);` then `updateTransport(other.build);` (unlinked → `warmup = 0f;`, :337). `moveLiquid(Building next, Liquid liquid)` (BuildingComp.java:**938–978**, not :938–960): next null → 0; `next = next.getLiquidDestination(self(), liquid);` (default returns self, BuildingComp.java:980-982 — no override on ItemBridge/LiquidBridge, verified); if `next.team == team && next.block.hasLiquids && liquids.get(liquid) > 0f`: `ofract = next.liquids.get(liquid) / next.block.liquidCapacity;` `fract = liquids.get(liquid) / block.liquidCapacity * block.liquidPressure;` `flow = min(clamp(fract - ofract) * block.liquidCapacity, liquids.get(liquid));` `flow = min(flow, next.block.liquidCapacity - next.liquids.get(liquid));` if `flow > 0f && ofract <= fract && next.acceptLiquid(self(), liquid)` → transfer + return flow. Reaction branch :**954–976** (not :950–960); `return 0;` at :977. **The brief omitted the ItemBridge `acceptLiquid` OVERRIDE** (ItemBridge.java:434-439) — the brief described only the BuildingComp default. Ported: partner current must equal the moved liquid OR partner current amount < 0.2f; checkAccept passes via the linked() shortcut (always true when hadValidLink, the N2225 reasoning). Phase-conduit does NOT set liquidPressure → Block default 1f (Block.java:79); both LiquidBridge defs share liquidCapacity 100f (Blocks.java:2381/2395). `doDump()` (LiquidBridge.java:29-31) is NOT this slice (DEFERRED line 102). Reaction branch deferred — Java's own TODO says it is wrong for multi-liquid.

## Implementation

`SourceLiquidBridgeBuildState.gd`: pure `source_liquid_bridge_update_transport_state` → 5 keys {warmup, moved, flow, liquids_after, partner_liquids_after} (N2225 pattern): warmup approachDelta 1/30f toward efficiency when linked, 0f when unlinked; warmup ≥ 0.25f gate; moveLiquid pressure flow; `moved |= flow > 0.05f`. The driver wires it after the N2197 had_valid_link recompute (Java order), enabled-only; both liquid stores are written back to sprite metas (PayloadUnloader N2232 precedent). Def consts: capacity 100f, pressure 1f, warmup rate 1/30f. Initial frame gains `warmup: 0.0, moved: false`.

## Commits

Slice `1ba2f18e` (worker-N2275, branch `slice/N2275-liquid-bridge-update-transport`, 5 files, driver +165/−3, đã push, remote tip verified by ls-remote). Integration cherry-pick `3fb71dcd` on `integration/wave-advances-6-n2274-n2280` (base 253151ad). No coordinator fix needed for this slice (the wave cite fix d0ea2b64 touched its register's DEFERRED snapshot only).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 61/61, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (21/28 PASS: liquid-bridge power/should-consume + item-bridge transport/power/should-consume/link/auto-link), the fails all their Godot proof tests — 0 other failures. Proof numbers independently validated by a Python simulation of the pure logic. Full wave gate run 2 (PID 4988, launch 01:07 by coordinator lượt 10, done 01:47 +07 16/11): Ran 6210 in 2126.929s, failures=229, skipped=5, 0 errors — 229/229 Godot-absent (222 inherited + 7 new proof tests N2274–N2280). Run 1 (PID 2132, launch 00:31, done 01:07) invalid: Ran 5527, failures=231, errors=15 — all javalang-import (VM restart #6 ~00:27 wiped javalang; reinstalled 0.13.0 at 01:00).

## SSOT / DEFERRED

SSOT single-slice +5/+1/+1/+2 → 11800/1724/1655/3102; audit stays 1336. +5 symbols, not the SCOPE-estimated +4 — the 5 return keys (warmup/moved/flow/liquids_after/partner_liquids_after). DEFERRED 292 (290 − 1 resolved: updateTransport advance + 3 new: moveLiquid reaction branch, live liquids intake, inherited updateTile steps). Merged wave DEFERRED: 298 entries (DEFERRED-after-advances-6.py) — 290 − 9 resolved/removed + 17 new, resolved by entry TEXT not number.

## Godot debt

`C07LiquidBridgeUpdateTransportProof` — 6 keys: warmup_approaches_efficiency, transport_blocked_below_warmup_quarter, move_liquid_transfers_by_pressure, moved_set_when_flow_above_threshold, no_transfer_when_partner_full, warmup_zero_when_unlinked (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
