# Handoff — N2128: ConsumeItemDynamic.trigger at unit completion

Date: 2026-11-12. Batch: N2128 (single slice). Status: built, registered, test module 3/4 standalone (the 4th test is the Godot proof run). **Godot proof NOT run in this VM — no Godot binary. Targeted gate TBD; full Python suite TBD. Do NOT commit until the proof runs green on Windows Godot 4.6 and the gates re-run.**

## What this batch is

The unit-completion consumption half of C06: `ConsumeItemDynamic.trigger` at unit completion, the first item on the N2127 "Next" list. One function, 5 symbols, SSOT +5/+1/+1/+2 → 11237 / 1579 / 1501 / 2793; audit 1335.

## Files changed

- `godot-mindustry/src/game/SourceUnitFactoryBuildState.gd` (+68): new `source_unit_factory_consume_state(frame, consumers, rows)` — `BuildingComp.consume()` (BuildingComp.java:1911-1915) over the family's bound actors: item rows trigger through their `RuntimeConsumer` actors (`ConsumeItemDynamic.java:53-56` / `ConsumeItems.java:45-48`, `Math.round(amount * multiplier)` clamped at what the module holds, `ItemModule.java:258-259`), liquid rows are skipped (`ConsumeLiquid` has no trigger override). The tick driver never calls it — the completion sites do (UnitFactory.java:420-436, Reconstructor.java:340-349, UnitAssembler.spawned() at UnitAssembler.java:544-571), and the live production wiring is a later slice.
- `godot-mindustry/src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd` (+1): `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_CONSUME_STATE`.
- `tools/mindustry_godot_transpiler/tests/test_c06_unit_factory_consume_trigger.py` (new, 4 tests) + `tools/mindustry_godot_transpiler/register_c06_unit_factory_consume_trigger.py` (new).
- `godot-mindustry/src/generated/` (SSOT JSONs + `unit_building_*` shards): N2128 row, 5 symbols, 1 contract, 2 schemas.
- `godot-mindustry/tools/runtime_proofs/C06UnitFactoryConsumeProof.gd` + `.tscn` (new, uid `uid://c6ufconsume12`). Proof JSON is gitignored, never stage it.
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`: totals 1578 → 1579, N2128 checklist row, Current-cube sentence, Not Done C06 leg, migration-log row.
- `docs/superpowers/reports/2026-11-12-c06-unit-factory-consume-trigger.md` (this batch's report; gate lines TBD — fill the real results after the Windows proof + gates).

## Verified numbers (do not re-derive, these are measured in this VM)

- Test module standalone: **3/4 OK** (registration, exact-evidence, source-text). The 4th test fails here only because no `godot` binary exists in this VM.
- Neighbour non-proof tests: unit-factory should-consume / consumer-binding / live-loop 9/9 OK; factory-craft registration + exact-evidence + tick-text 3/3 OK.
- Suite size: 5605 + 4 new tests = **5609** expected (206 modules).
- Proof (written, not run): 30 content keys — dagger plan removes silicon 10 + lead 10 (5/2 left), clamp removes only what is held (5/3 → 0/0), plan-less binds 0 rows, reconstructor removes silicon 40 + graphite 40 (10/10 left), unitCost 2.0 removes 20/20, assembler liquid row skipped (cyanogen 10.0 unchanged, 0 triggered), empty frame removes nothing.
- `git diff --check` clean.

## How this VM differs from the builders' machine (read before the next step)

- The full clone of the repo is ~98 MB and stalled on this VM's network, so the worktree here is a **sparse shallow clone** (`--depth 1 --filter=blob:none --sparse`) with only `godot-mindustry/src/game`, `godot-mindustry/src/generated`, `godot-mindustry/tools/runtime_proofs`, `tools/mindustry_godot_transpiler`, `docs/superpowers`, `AGENTS.md`, `README.md` checked out. Scenes, assets, `PortGame.gd` and most of `godot-mindustry` are NOT in this checkout — do not treat a missing file here as missing upstream.
- `mindustry-upstream/` here is a sparse checkout at the pinned revision `2bdedfed25932ebf11330d3584092c50e2e26d96`, expanded to all of `core/src/mindustry` so the exact-evidence tests can read their sources. It is gitignored, never stage it.
- There is **no Godot binary** in this VM and no Godot MCP (the builders used Windows Godot 4.6.2 + MCP port 7777). The proof file is written to the established pattern and its expected key values were checked against the registry data (dagger silicon 10 + lead 10, reconstructor silicon 40 + graphite 40, tank-assembler cyanogen 0.15), but it has not executed. The first Windows run may find a proof-only bug the way N2126/N2127 did — fix the proof, not the implementation, unless the failure is in the trigger itself.

## Deferred (not this slice)

- UnitAssembler plan dynamics (UnitAssembler.java:158-160): `ConsumePayloadDynamic` over `plan().requirements` (payload stacks in `UnitAssemblerBuild.blocks`, no payload module in the port yet), `ConsumeItemDynamic` over `plan().itemReq` (empty in vanilla), `ConsumeLiquidsDynamic` over `plan().liquidReq` (trigger empty).
- Live production wiring: progress advance + the call at completion (UnitFactory.java:401-403, Reconstructor.java:330-348, UnitAssembler.spawned()).
- Unit-factory frames' per-class shouldConsume wiring to the power stamp (N2127 deliberately keeps them on the N2125 enabled-only stamp).
- The battery's live `enabled` stamp (`PowerGraph.getBatteryStored` gates on `battery.enabled`, but the battery has no tick frame).
- A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948) but the port carries no per-belt efficiency yet.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Next: N2129 (candidates)

The remaining C06 work, in the order the N2125–N2128 builders considered them: UnitAssembler plan dynamics (`ConsumePayloadDynamic` over the plan's payload stacks, `ConsumeItemDynamic` over `plan().itemReq`, `ConsumeLiquidsDynamic` over `plan().liquidReq` — needs a payload-module representation first), the battery live `enabled` stamp, the disabled-belt efficiency half (needs a per-belt efficiency first), unit-factory frames' per-class shouldConsume wiring to the power stamp, then the live production wiring that calls this trigger at completion. After C06 closes, C07 (units/waves/world/campaign) is next per the completion backlog.

## Commit (not done — gates pending)

Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`): `SourceUnitFactoryBuildState.gd`, `SourceRuntimeOwnerUnitBuildingRegistry.gd`, the SSOT JSONs + `unit_building_*` shards, `test_c06_unit_factory_consume_trigger.py`, `register_c06_unit_factory_consume_trigger.py`, `C06UnitFactoryConsumeProof.gd` + `.tscn`, the design spec, the report + this handoff. Fill the real gate/suite results into the report, the handoff, the spec checklist/cube/migration rows, then commit + push, then the MEMORY.md N2128 entry. The worktree is a sparse checkout — commit from the user's full checkout, or expand the sparse checkout first and re-verify `git status` shows only these files.
