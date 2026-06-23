# M14 Class Emitter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Emit parseable GDScript class skeletons from parseable Mindustry Java AST metadata.

**Architecture:** `java_ast.py` remains the source parser. `emitter.py` converts parsed class/enum metadata into GDScript files under `src/generated/classes` without `class_name` collisions. `transpile.py emit` writes the generated files plus `emitted_classes.json` so skipped parser failures remain visible.

**Tech Stack:** Python 3.13, `javalang`, unittest, Godot 4.6.2 MCP diagnostics.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M14 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M14-1 | Add emitter unit test | `test_emitter.py` verifies a Java class fixture emits exact GDScript metadata constants |
| M14-2 | Add CLI emit test | `test_cli.py` verifies `transpile.py emit` writes a class file and `emitted_classes.json` |
| M14-3 | Implement emitter | `mindustry_port/emitter.py` emits parseable GDScript skeletons with package, kind, fields, constructors, methods, and enum constants |
| M14-4 | Generate upstream classes | `python tools/mindustry_godot_transpiler/transpile.py emit --upstream mindustry-upstream --godot godot-mindustry` prints `emitted classes=612 failures=189` |
| M14-5 | Verify with tests and MCP | Python suite reports `Ran 18 tests ... OK`; Godot MCP project scan sees `638` scripts; representative generated class LSP diagnostics return `diagnostics: []`; MCP runtime output returns `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M14 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M15-1 | Reduce parser failures | `emitted_classes.json` skipped failure count decreases from `189` with fixtures for each parser feature added |
| M15-2 | Generate method stubs | Emitted classes include parseable GDScript method signatures for simple Java methods and exact fixture tests |
| M15-3 | Link emitted classes to runtime | Selected generated skeletons are instantiated or preloaded by a Godot registry scene with MCP runtime verification |
