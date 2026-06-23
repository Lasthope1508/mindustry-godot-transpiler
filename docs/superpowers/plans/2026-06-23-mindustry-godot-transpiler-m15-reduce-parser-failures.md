# M15 Reduce Parser Failures Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce Mindustry Java parser failures blocking generated GDScript class skeleton emission.

**Architecture:** Keep `javalang` as metadata parser, but preprocess Java source before parsing because class skeleton emission only needs declarations, fields, constructors, methods, imports, and inheritance. Strip executable callable bodies, replace text blocks, and normalize pattern `instanceof` after bodies are removed so comments cannot corrupt brace matching.

**Tech Stack:** Python 3.13, `javalang`, unittest, Godot 4.6.2 MCP diagnostics.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M15 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M15-1 | Reproduce modern Java parser blockers | Added Java AST tests for switch-arrow method bodies, pattern `instanceof`, text blocks, and `instanceof` text in method comments; regression test failed before implementation |
| M15-2 | Strip executable callable bodies before parsing | `java_ast.py` now replaces method/constructor/lambda-like callable bodies with `{}` while preserving surrounding type declarations |
| M15-3 | Tolerate text blocks and pattern `instanceof` | `_preprocess_modern_java` replaces Java text blocks and normalizes pattern `instanceof` after body stripping |
| M15-4 | Regenerate generated class skeletons | `python tools/mindustry_godot_transpiler/transpile.py emit --upstream mindustry-upstream --godot godot-mindustry` prints `emitted classes=801 failures=0` |
| M15-5 | Verify Python tests | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 22 tests ... OK` |
| M15-6 | Verify Godot MCP diagnostics | `mcp__godot.project_info` sees `827` scripts; LSP diagnostics return `diagnostics: []` for `Renderer.gd`, `BaseBuilderAI.gd`, and `Damage.gd`; MCP debug output returns `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M15 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M16-1 | Generate simple method stubs | Emitted classes include parseable GDScript method declarations for simple Java methods and exact fixture tests |
| M16-2 | Link generated skeletons into a source registry | Selected generated classes are preloaded or indexed by a Godot registry scene with MCP runtime verification |
| M16-3 | Expand gameplay simulation from generated source data | World block behavior uses source-derived conveyor/drill/core models and MCP runtime verifies playable interaction |
