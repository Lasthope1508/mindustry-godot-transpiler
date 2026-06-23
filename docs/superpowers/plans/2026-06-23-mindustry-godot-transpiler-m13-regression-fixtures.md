# M13 Regression Fixtures Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add checked expected generated output fixtures so generator drift is caught by tests.

**Architecture:** The test creates a small deterministic content registry in memory, calls the real `write_gdscript_registry` generator, and compares the generated `MindustryContentRegistry.gd` text exactly against a checked fixture. This keeps generated GDScript output stable while later work expands the emitter.

**Tech Stack:** Python 3.13, unittest, Godot 4.6.2 MCP diagnostics.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M13 tasks | 4 |
| Done | 4 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M13-1 | Add failing regression test | `test_regression_fixtures.py` initially failed because `expected_content_registry.gd` was missing |
| M13-2 | Add expected GDScript fixture | `tools/mindustry_godot_transpiler/tests/fixtures/expected_content_registry.gd` is checked in and compared exactly |
| M13-3 | Run Python verification | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 16 tests ... OK` |
| M13-4 | Run Godot MCP sanity | MCP LSP diagnostics for generated registry return `diagnostics: []`; MCP runtime debug output returns `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M13 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M14-1 | Start emitted GDScript classes | One Java class fixture emits one `.gd` class and passes exact fixture comparison plus Godot parse diagnostics |
| M14-2 | Add fixture update command | A guarded CLI command refreshes expected fixtures only when explicitly invoked |
| M14-3 | Add parse failure line numbers | `ast_manifest.json` failures include best-effort line numbers for parser errors |
