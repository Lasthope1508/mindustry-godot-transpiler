# Handoff — C05 ContinuousLiquidTurret ammoTypes in the content registry (N2104)

Date: 2026-11-09. Batch: N2104 (emitter slice, no SSOT slice). Commit: 6ae9fb6.

## Done

- `mindustry_port/content_registry.py:_liquid_turret_ammo_types(initializer)` — parses a ContinuousLiquidTurret block's `ammo(...)` call (ContinuousLiquidTurret.java:28-30) into `properties["ammoTypes"]` keyed by liquid name to `{"ammoMultiplier": float}`; a bullet without an `ammoMultiplier` assignment takes the BulletType default 2f (BulletType.java:95). Fails closed to `{}` on any unresolvable pair.
- `mindustry_port/content_registry.py:_liquid_turret_consumed(initializer, class_source)` — resolves the `ConsumeLiquidFilter` amount from `ContinuousLiquidTurret.init()` (ContinuousLiquidTurret.java:40-51): the `liquidConsumed` field, 1f / 60f (:15). `_block_properties` emits one `consumeLiquid` descriptor per ammo liquid at that amount when the block has no own `consumeLiquid` calls.
- Registry regenerated (`transpile content`): sublimate now carries `ammoTypes` `{"ozone": {"ammoMultiplier": 1.2}, "cyanogen": {"ammoMultiplier": 2.0}}` and `consumeLiquid` `[{"liquid": "ozone", "amount": 1/60}, {"liquid": "cyanogen", "amount": 1/60}]`; blocks with `consumeLiquid` 50 → 51, with `ammoTypes` 0 → 1. The `content_registry_blocks` shard mirror was rebuilt with the new keys.
- New test `tools/mindustry_godot_transpiler/tests/test_content_registry.py::test_block_registry_captures_continuous_liquid_turret_ammo_types`; new proof-test module `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_ammo_registry.py`; proof `godot-mindustry/tools/runtime_proofs/ContinuousLiquidTurretAmmoRegistryProof.gd/.tscn`.
- SSOT totals unchanged (emitter batch, like N2094–N2095): 10852 symbols / 1556 slices / 1444 contracts / 2679 schemas; audit `totalSourceFunctions` stays 1335.

## Verification

- New registry test RED before the emitter change (`None != {...}`), GREEN after; full `test_content_registry` module 7 tests OK.
- Godot proof `ContinuousLiquidTurretAmmoRegistryProof` 18/18 true on the real Main scene: the catalog's sublimate carries the ammo map (ozone 1.2, cyanogen 2.0) and the two consumeLiquid descriptors at 1/60; the consumer definitions read off the block, two consumers bind for the ozone/cyanogen liquid ids at 1/60, and applying them sets the liquid filter for both liquids.
- Targeted gate (log `~/workspace/logs/targeted-n2104.log`): 5511 tests OK in 1532.986s, exit=0 (0 FAIL sections; exactly one summary line — a duplicate gate started by a cron worker at ~20:36 wrote to the same log for ~1 minute before being killed, so raw dot/F counts in the log are contaminated and only the summary line + FAIL sections were used).
- Full Python suite (log `~/workspace/logs/full-suite-n2104.log`): **5510 tests OK in 1521.635s, exit=0** (0 FAIL sections; exactly one summary line). Note: 1 test fewer than the targeted gate's 5511 — both summaries OK, delta unexplained (likely module-list timing).

## Still open

- C05 next: the tick reads the ammo map off the block (`properties["ammoTypes"]`) instead of the source-backed sublimate constant in the build state (and the constant can then be removed); a `RuntimeConsumer` can now be bound for sublimate — wiring it into the live loop is the next slice. Wiring other buildings (turrets, factories) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- `tools/mindustry_godot_transpiler/tests/test_content_registry.py`
- `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_ammo_registry.py`
- `godot-mindustry/src/generated/MindustryContentRegistry.gd`
- `godot-mindustry/src/generated/content_registry.json`
- `godot-mindustry/src/generated/source_modules/content_registry_blocks.json`
- `godot-mindustry/tools/runtime_proofs/ContinuousLiquidTurretAmmoRegistryProof.gd`
- `godot-mindustry/tools/runtime_proofs/ContinuousLiquidTurretAmmoRegistryProof.tscn`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-09-continuous-liquid-turret-ammo-registry.md`
- `docs/superpowers/handoffs/2026-11-09-continuous-liquid-turret-ammo-registry-handoff.md`
