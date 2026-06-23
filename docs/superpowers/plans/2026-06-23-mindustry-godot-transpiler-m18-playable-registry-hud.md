# M18 Playable Registry HUD Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect generated Java class registry data to the playable Godot scene so source conversion progress is visible in-game.

**Architecture:** `PortGame.gd` preloads `src/generated/GeneratedClassRegistry.gd`, reads `MindustryGeneratedClassRegistry.count()` during content registry load, stores it in `generated_class_count`, and includes the count in the HUD. This is intentionally read-only and does not change gameplay simulation yet.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP diagnostics/runtime.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M18 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M18-1 | Add HUD registry regression test | `test_playable.py` asserts `PortGame.gd` preloads `GeneratedClassRegistry.gd`, assigns `generated_class_count = GeneratedClassRegistry.count()`, and contains `Generated Java classes: %d` |
| M18-2 | Verify TDD red | Targeted test failed before implementation because `PortGame.gd` did not read the generated class registry |
| M18-3 | Implement HUD registry connection | `PortGame.gd` preloads `GeneratedClassRegistry.gd`, stores `generated_class_count`, and adds generated class count to HUD text |
| M18-4 | Verify Python tests and LSP | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 23 tests ... OK`; MCP LSP diagnostics for `src/game/PortGame.gd` return `diagnostics: []` |
| M18-5 | Verify MCP runtime launch | MCP stopped stale runtime, launched `scenes/Main.tscn`, and `editor_debug_output` returned `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M18 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M19-1 | Preload selected generated class scripts from registry | Runtime loads selected `gdscript_path` entries and reports loaded names in HUD/debug output with MCP runtime verification |
| M19-2 | Add generated package summary | Registry exposes package counts, and playable HUD/debug data shows top packages without runtime errors |
| M19-3 | Translate simple method bodies | Fixture tests convert basic Java `return` literals and field assignments into GDScript stub bodies |
