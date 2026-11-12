# Report — N2128: ConsumeItemDynamic.trigger at unit completion

Date: 2026-11-12. Batch: N2128 (single slice). Status: built, registered, test module 3/4 standalone (the 4th test is the Godot proof run, which cannot run in this VM — no Godot binary). **Godot proof NOT run here — pending a Windows Godot 4.6 run. Targeted gate TBD; full Python suite TBD.**

## What changed

N2120 bound one `RuntimeConsumer` actor per consumeItem/consumeLiquid row plus one per requirement of the frame's current plan, and the tick runs those actors through `updateConsumption`'s first and second passes every tick — but `ConsumeItems` has no update body (`Consume.update` is empty, Consume.java:52), so the item stacks never left: a factory could produce forever on the same silicon and lead. Java removes them only at unit completion, through `BuildingComp.consume()` (BuildingComp.java:1911-1915), which triggers every consumer, and only the item rows remove anything, through `ConsumeItems.trigger` (ConsumeItems.java:45-48) and `ConsumeItemDynamic.trigger` (ConsumeItemDynamic.java:53-56), each removing `Math.round(amount * multiplier)` clamped at what the module holds (ItemModule.java:258-259).

N2128 adds `SourceUnitFactoryBuildState.source_unit_factory_consume_state(frame, consumers, rows)` — the unit-factory twin of `SourceFactoryBuildState.source_factory_consume_state` (N2117): item rows trigger through their bound actors, liquid rows are skipped (`ConsumeLiquid` has no trigger override; its update drains per tick), and the tick driver never calls it. The completion sites that will call it are `UnitFactoryBuild.updateTile()` (UnitFactory.java:420-436: `progress >= plan.time`, `payload = new UnitPayload(unit)`, `consume()`), `ReconstructorBuild.updateTile()` (Reconstructor.java:340-349: `progress >= constructTime`, payload unit upgraded, `consume()`), and `UnitAssemblerBuild.spawned()` (UnitAssembler.java:544-571: `consume()` first, then the unit is created and `blocks.clear()`).

## Verified numbers (measured in this VM)

- Test module `test_c06_unit_factory_consume_trigger.py`: **3/4 OK standalone** — registration, exact-evidence (all 5 symbols' `java_expr` found verbatim in the pinned upstream checkout, all 14 exact exprs found), and the source-text test. The 4th test fails here only because no `godot` binary exists in this VM (`shutil.which('godot')` is None); it runs `C06UnitFactoryConsumeProof.tscn` headless and asserts its 30 content keys.
- Neighbour modules, non-proof tests only (their proof tests fail the same way here): `test_unit_factory_should_consume`, `test_unit_factory_consumer_binding`, `test_unit_factory_live_loop` — 9/9 non-proof tests OK; `test_factory_craft` registration + exact-evidence + tick-text tests — 3/3 OK.
- SSOT +5/+1/+1/+2 → **11237 / 1579 / 1501 / 2793**; audit stays 1335. Owner mirrors into the `unit_building_*` shards. `git diff --check` clean.
- Proof `C06UnitFactoryConsumeProof`: **written, 30 content keys + `matches` (31 `proof[...]` assignments), NOT run** — it asserts a dagger-plan trigger (silicon 10 + lead 10 removed, 5/2 left), the clamp (held 5/3 removes 5/3, leaves 0/0), a plan-less trigger (0 rows, 0 removed), a reconstructor trigger (silicon 40 + graphite 40 removed, 10/10 left), unitCost 2.0 (20/20 removed), and an assembler liquid-row skip (cyanogen 10.0 unchanged, 0 triggered). Run it on Windows Godot 4.6 before committing.

## Deferred

- UnitAssembler plan dynamics (UnitAssembler.java:158-160): `ConsumePayloadDynamic` over `plan().requirements` removes payload stacks from the building's payload module (`UnitAssemblerBuild.blocks`), which the port does not model yet; `ConsumeItemDynamic` over `plan().itemReq` (empty in vanilla) and `ConsumeLiquidsDynamic` over `plan().liquidReq` (its trigger is empty; its update drains per tick).
- Live production wiring: the tick driver advances no progress and calls no consume yet — UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler `spawned()` (UnitAssembler.java:544-571) are the production slice; this slice is the trigger body it calls at completion.
- Unit-factory frames' per-class shouldConsume wiring to the power stamp; the battery's live `enabled` stamp; a disabled conveyor reading efficiency 0.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c06-unit-factory-consume-trigger-handoff.md` for the full detail.

## Gate / suite

- Test module standalone (non-proof): 3/3 OK.
- Godot proof: NOT run in this VM (no Godot binary). Pending Windows run.
- Targeted gate: TBD (needs the Godot proof green first, then a ~30 min targeted run).
- Full Python suite: TBD (5605 + 4 new tests = 5609 expected).
