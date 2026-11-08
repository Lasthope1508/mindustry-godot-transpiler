# Handoff — C05 thorium reactor consumers (N2094–N2095)

Date: 2026-11-08. Commit: pending (targeted gate running).

## Done

- N2094 `_consume_liquid_descriptors` now resolves field references in the amount expression through `field_values` (initializer assignments, then class field defaults) — the thorium reactor's `consumeLiquid(Liquids.cryofluid, heating / coolantPower).update(false)` (Blocks.java:2629) resolves to 0.04 with `update: false` (heating 0.02f, coolantPower 0.5f in NuclearReactor.java:45).
- N2095 `_consume_item_descriptors` extracts `consumeItem(Items.<name>)` (amount defaults to 1) and `consumeItems(with(Items.<a>, <n>, ...))` into `consumeItem` registry descriptors, with the same boost/optional/update selector flags as liquid consumers; assigned `itemConsumer = consumeItem(...)` calls are skipped (booster item, already captured by `_boost_item`).
- The thorium reactor now carries `consumeLiquid: [{cryofluid, 0.04, update: false}]` and `consumeItem: [{thorium, 1}]`. 42 blocks carry `consumeItem`, 50 carry `consumeLiquid`, no block lost a `consumeLiquid`.
- Runtime binding verified with a throwaway Godot scene on the real Main scene: bound consumer liquid id 3 (cryofluid), amount 0.04, update=false — a required non-update consumer. The live `LiquidConsumerHydrationProof` still passes.
- Tests: `test_content_registry.py` (new thorium reactor test) + `test_liquid_consumer_hydration.py` (real-registry assertions for the thorium reactor).
- No SSOT delta — this is an emitter/registry change, not a runtime SSOT slice. SSOT ledger stays 10819 / 1548 / 1436 / 2663; audit 1335.

## Verification status

- Targeted gate: **4958 tests OK in 722.238s, exit=0** (log `~/workspace/logs/targeted-n2094b.log`). The first run had 89 failures, all in `test_source_symbols` — the regenerated registry changed 42 blocks' `properties`, so the `content_registry_blocks` SSOT shard mirror was stale. Rebuilding the shard with `source_ssot.build_extension_shard` fixed it.
- Full Python suite: 5484 tests OK in 1365.723s, exit=0 (log `~/workspace/logs/full-suite-n2094.log`).
- Full Python suite: running (log `~/workspace/logs/full-suite-n2094.log`).

## Next

- C05 continues: the multiplier callbacks, live TeamRules cheating, and cache invalidation on Block reinit/reload. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
