# M9 Unit Registry Wave Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add source-derived Mindustry units to the generated Godot registry and spawn a first enemy wave in the playable scene.

**Architecture:** The transpiler extracts unit constructor data from `core/src/mindustry/content/UnitTypes.java` into `content_registry.json` and `MindustryContentRegistry.gd`. Godot loads that data through a new `MindustryUnitType` model, then `PortGame.gd` renders source-derived unit sprites and simulates simple movement toward the core.

**Tech Stack:** Python 3.13, `javalang` for item/liquid fixtures, regex scan for `UnitTypes.java` constructors, Godot 4.6.2, GDScript, Godot MCP.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M9 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M9-1 | Add failing unit registry fixture | `test_content_registry.py` expects one `dagger` unit with `speed`, `health`, `hitSize`, texture path, and `counts.units` |
| M9-2 | Extract generated units | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` prints `content items=22 liquids=11 blocks=417 units=56` |
| M9-3 | Load units in Godot catalog | `ContentCatalog.gd` preloads `UnitType.gd`, fills `units`, registers `by_type["unit"]`, and returns counts with `units` |
| M9-4 | Spawn source-derived wave | `PortGame.gd` selects `dagger`, loads `res://assets/core/assets-raw/sprites/units/dagger.png`, spawns enemies on `World/UnitLayer`, and updates core health/wave HUD |
| M9-5 | Verify with tests and MCP | Python tests report `Ran 13 tests ... OK`; MCP LSP diagnostics for changed scripts return `diagnostics: []`; MCP debug output for `scenes/Main.tscn` returns `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M9 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M10-1 | Extract weapon and bullet metadata from unit/block source | Tests prove bullet speed/damage/reload are generated from upstream source, not hardcoded |
| M10-2 | Add turret targeting and bullet sprites | MCP runtime shows `duo` can fire at spawned units without parser/runtime errors |
| M10-3 | Add enemy damage/death and rewards | Playable scene removes units when health reaches zero and records source-derived kill state |
