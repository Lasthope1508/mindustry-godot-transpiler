# M11 Source Waves Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the hardcoded enemy wave fallback with source-derived default Mindustry wave groups.

**Architecture:** The content registry extracts `waveVersion` and `new SpawnGroup(unit){{...}}` entries from `mindustry/game/Waves.java`. The generated GDScript registry exposes `WAVES`. `PortGame.gd` uses those generated groups and a GDScript equivalent of `SpawnGroup.getSpawned(wave)` to decide which units spawn each wave.

**Tech Stack:** Python 3.13, regex extraction for constrained `SpawnGroup` initializer data, Godot 4.6.2, GDScript, Godot MCP.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M11 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M11-1 | Add failing wave fixture | `test_content_registry.py` creates `mindustry/game/Waves.java` and expects `registry["waves"]` with `version` and two `SpawnGroup` entries |
| M11-2 | Extract default waves | `content_registry.py` reads `Waves.java`, maps unit fields to generated unit ids, and writes `waves` plus `const WAVES` |
| M11-3 | Regenerate upstream registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` prints `content items=22 liquids=11 blocks=417 units=56` |
| M11-4 | Use source waves in gameplay | `PortGame.gd` loads all unit textures, calculates source-equivalent `SpawnGroup.getSpawned`, and spawns generated unit groups per wave |
| M11-5 | Verify with tests and MCP | Python suite reports `Ran 13 tests ... OK`; Godot MCP LSP diagnostics return `diagnostics: []`; MCP runtime output for `scenes/Main.tscn` returns `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M11 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M12-1 | Add explicit unsupported-feature report | Report lists Java constructs not yet converted with exact source path and line number |
| M12-2 | Add wave HUD details | HUD shows next source-derived unit group and generated wave version |
| M12-3 | Add source-derived sector/map wave rules | Wave timing and win conditions come from source rules or map metadata instead of local constants |
