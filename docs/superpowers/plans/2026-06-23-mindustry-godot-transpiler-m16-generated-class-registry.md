# M16 Generated Class Registry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make emitted Mindustry Java class skeletons discoverable from Godot through a generated registry script.

**Architecture:** Extend `mindustry_port.emitter` so `emit_gdscript_classes` writes both per-class skeletons under `src/generated/classes` and a root `src/generated/GeneratedClassRegistry.gd`. The registry contains source-linked metadata entries and small lookup helpers, while `emitted_classes.json` records the registry file name for pipeline traceability.

**Tech Stack:** Python 3.13, unittest, Godot 4.6.2 MCP diagnostics.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M16 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M16-1 | Add emitter regression test for generated registry | `test_emitter.py` asserts `GeneratedClassRegistry.gd` exact output for a one-class fixture and manifest `registry` field |
| M16-2 | Add CLI regression coverage | `test_cli.py` asserts `transpile.py emit` writes `src/generated/GeneratedClassRegistry.gd` |
| M16-3 | Implement registry generation | `emitter.py` writes `MindustryGeneratedClassRegistry` with `CLASS_COUNT`, `CLASSES`, `count`, `all_classes`, and `find_by_java_name` |
| M16-4 | Regenerate upstream registry | `python tools/mindustry_godot_transpiler/transpile.py emit --upstream mindustry-upstream --godot godot-mindustry` prints `emitted classes=801 failures=0` and `emitted_classes.json` records `registry: GeneratedClassRegistry.gd` |
| M16-5 | Verify Python tests | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 22 tests ... OK` |
| M16-6 | Verify Godot MCP diagnostics | `mcp__godot.project_info` sees `828` scripts; LSP diagnostics for `src/generated/GeneratedClassRegistry.gd` return `diagnostics: []`; MCP debug output returns `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M16 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M17-1 | Add simple generated method stubs | Per-class generated files expose parseable method stubs for source method metadata with collision-safe names and fixture tests |
| M17-2 | Preload selected generated classes from registry | Runtime can load selected generated class scripts through `GeneratedClassRegistry.gd`; MCP runtime verifies no errors |
| M17-3 | Feed generated class metadata into playable HUD/debug view | Playable scene can show source class counts/package counts from registry while remaining playable under MCP runtime |
