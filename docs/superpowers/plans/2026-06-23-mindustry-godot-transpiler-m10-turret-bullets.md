# M10 Turret Bullets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the playable Godot slice shoot source-derived bullets from a source-derived duo turret at spawned source-derived enemy units.

**Architecture:** `content_registry.py` extracts turret `reload`, `range`, and first `BasicBulletType` ammo data from block initializer bodies. `MindustryBlock` exposes those values without renaming upstream property keys in generated data. `PortGame.gd` uses the generated duo block and copied source sprites to target enemies, spawn bullets, and apply generated bullet damage.

**Tech Stack:** Python 3.13, regex constructor/property extraction around `Blocks.java`, Godot 4.6.2, GDScript, Godot MCP.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M10 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M10-1 | Add failing turret fixture | `test_content_registry.py` expects `duo` properties containing `reload`, `range`, requirements, and copper `ammo` with `speed`, `damage`, `lifetime` |
| M10-2 | Extract turret metadata | `content_registry.py` parses numeric assignments and `ammo(Items.x, new BasicBulletType(...))`; full test suite reports `Ran 13 tests ... OK` |
| M10-3 | Regenerate content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` prints `content items=22 liquids=11 blocks=417 units=56` |
| M10-4 | Add Godot turret/bullet behavior | `PortGame.gd` pre-places `duo`, registers turret cells, finds enemy targets, spawns copper bullet sprites, and subtracts generated bullet damage from enemy health |
| M10-5 | Verify with MCP | Godot MCP LSP diagnostics for `Block.gd`, `PortGame.gd`, and generated registry return `diagnostics: []`; MCP runtime output for `scenes/Main.tscn` returns `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M10 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M11-1 | Parse more bullet subclasses | Fixtures cover `BasicBulletType`, `ArtilleryBulletType`, `LaserBulletType`, and `MissileBulletType` fields used by upstream content |
| M11-2 | Add health bars and death effects | MCP runtime shows units disappear cleanly, bullets are freed, and HUD counts killed enemies |
| M11-3 | Add wave definitions from sectors or maps | Source-derived spawn groups drive wave composition instead of the current dagger fallback |
