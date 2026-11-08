# C05 thorium reactor consumers — N2094–N2095

Date: 2026-11-08. Batch: N2094–N2095 (two slices, first C05 batch, emitter — not an SSOT slice, so the SSOT ledger stays 10819 / 1548 / 1436 / 2663).

## What changed

The thorium reactor's consumers were unresolved in the content registry: its cryofluid amount is the field expression `heating / coolantPower` (Blocks.java:2629), which the emitter could not resolve, and `consumeItem` was not extracted at all. Both are now resolved.

- N2094 `_consume_liquid_descriptors(initializer, field_values)` — the amount expression now resolves field references through `field_values`: the block initializer's numeric assignments first (`heating = 0.02f`), then the implementation class's field defaults (`coolantPower = 0.5f`, NuclearReactor.java:45). The thorium reactor's `consumeLiquid(Liquids.cryofluid, heating / coolantPower).update(false)` resolves to 0.04 with `update: false`. (Lesson: javalang parses a bare identifier as a `MemberReference` with `qualifier == ''`, not `None` — the lookup must test `not node.qualifier`.)
- N2095 `_consume_item_descriptors(initializer)` — extracts `consumeItem(Items.<name>)` (amount defaults to 1, Block.java:1167-1173) and `consumeItems(with(Items.<a>, <n>, ...))` into `consumeItem` registry descriptors, with the same boost/optional/update selector flags as liquid consumers. Assigned calls (`itemConsumer = consumeItem(...)`) are the booster item and are skipped (already captured by `_boost_item`).

The registry now carries, for the thorium reactor, `consumeLiquid: [{cryofluid, 0.04, update: false}]` and `consumeItem: [{thorium, 1}]`. Across all blocks, 42 carry `consumeItem` and 50 carry `consumeLiquid`, with no block losing a `consumeLiquid`.

## Verification

- New test `test_block_registry_resolves_thorium_reactor_consumers` (synthetic upstream) — RED before the change, GREEN after.
- The real-registry hydration test now asserts the thorium reactor's consumers.
- Runtime binding verified with a throwaway Godot scene on the real Main scene: the bound consumer is liquid id 3 (cryofluid), amount 0.04, update=false — classified as a required non-update consumer (update_consumers 0, non_optional_consumers 1). The live `LiquidConsumerHydrationProof` still passes.
- Targeted gate: the content-registry + hydration + emitter + parity + symbols + playable + drill-booster tests — **4958 tests OK in 722.238s, exit=0** (log `~/workspace/logs/targeted-n2094b.log`). The first run had 89 failures, all in `test_source_symbols`: the regenerated registry changed 42 blocks' `properties`, so the `content_registry_blocks` SSOT shard mirror was stale (the shard's `properties` must equal the registry's). Rebuilding the shard with `source_ssot.build_extension_shard` fixed it (only `content_registry_blocks.json` changed; the other content-registry shards were already in sync).
- Full Python suite: **5484 tests OK in 1365.723s, exit=0** (log `~/workspace/logs/full-suite-n2094.log`).
- Full Python suite: **5484 tests OK in 1365.723s, exit=0** (log `~/workspace/logs/full-suite-n2094.log`).

## SSOT delta

None — this is an emitter/registry change, not a runtime SSOT slice. The SSOT ledger stays 10819 / 1548 / 1436 / 2663; audit `totalSourceFunctions` stays 1335.

## Still open

- C05: the multiplier callbacks (actual source `multiplier` instead of the default-only binding), live TeamRules cheating, and the descriptor/apply/adapter cache invalidation on Block reinit/reload. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open. A live thorium-reactor placement proof (placed reactor consuming thorium + cryofluid in the world) is a future slice.
