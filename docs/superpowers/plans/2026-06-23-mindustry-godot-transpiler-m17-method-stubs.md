# M17 Method Stubs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose parsed Java methods as parseable, collision-safe GDScript stubs in generated class skeletons.

**Architecture:** Extend `mindustry_port.emitter` so each parsed Java method produces a placeholder method named `java_method_<sanitized_java_name>_<index>`. The numeric suffix preserves overload traceability and avoids GDScript duplicate function names. Stubs accept `_args: Array = []` to avoid source parameter keyword collisions until full statement translation exists.

**Tech Stack:** Python 3.13, unittest, Godot 4.6.2 MCP diagnostics.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M17 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M17-1 | Add method stub fixture | `test_emitter.py` fixture includes overloaded Java methods and expects `java_method_enabled_0` plus `java_method_enabled_1` |
| M17-2 | Verify TDD red | `python -m unittest tools.mindustry_godot_transpiler.tests.test_emitter -v` failed before implementation because emitted method stubs were missing |
| M17-3 | Implement collision-safe stub emission | `emitter.py` sanitizes method names and emits `func java_method_<name>_<index>(_args: Array = []) -> Variant` |
| M17-4 | Regenerate upstream skeletons | `python tools/mindustry_godot_transpiler/transpile.py emit --upstream mindustry-upstream --godot godot-mindustry` prints `emitted classes=801 failures=0`; `Items.gd` contains `java_method_load_0`; `Damage.gd` contains `35` method stubs |
| M17-5 | Verify Python tests | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 22 tests ... OK` |
| M17-6 | Verify Godot MCP diagnostics | LSP diagnostics for `src/generated/classes/mindustry/content/Items.gd` and `src/generated/classes/mindustry/entities/Damage.gd` return `diagnostics: []`; MCP debug output returns `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M17 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M18-1 | Attach generated class registry to playable scene debug data | Playable scene reads `MindustryGeneratedClassRegistry.count()` and exposes it in debug/HUD without runtime errors |
| M18-2 | Preload selected generated class scripts from registry | Runtime loads selected scripts by `gdscript_path` with MCP runtime verification |
| M18-3 | Start translating simple method bodies | Fixture tests convert basic `return` literals and field assignments into GDScript method bodies |
