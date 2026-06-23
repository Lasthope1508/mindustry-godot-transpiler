# M22 All Generated Script Instances Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Load and instantiate every generated Mindustry class skeleton in the playable Godot scene, not only the selected smoke-test classes.

**Architecture:** Keep generated files read-only. `PortGame.gd` walks `GeneratedClassRegistry.all_classes()`, loads each `gdscript_path`, creates a `RefCounted` instance, stores instances by `java_package.java_name`, and records load/instance failures for MCP runtime inspection. The selected class HUD remains as a readable subset while `get_runtime_summary()` exposes full counts.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M22 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M22-1 | Add failing all-generated instance regression test | Targeted unittest failed because `PortGame.gd` did not walk `GeneratedClassRegistry.all_classes()` yet |
| M22-2 | Implement full generated script loading and instancing | `PortGame.gd` now walks `GeneratedClassRegistry.all_classes()`, stores `all_generated_scripts` and `all_generated_instances`, and records load/instance failure arrays; targeted unittest passes |
| M22-3 | Expose full generated counts in HUD/runtime summary | HUD includes `All generated script instances: %d / %d`; `get_runtime_summary()` returns all-generated script/instance counts and failure arrays; targeted unittest passes; MCP LSP diagnostics return `diagnostics: []` |
| M22-4 | Verify Python and Godot diagnostics | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 29 tests ... OK`; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []` |
| M22-5 | Verify runtime MCP reports 801 instances | Restarted `scenes/Main.tscn` through MCP; runtime `get_runtime_summary()` returns `generated_class_count=801`, `all_generated_script_count=801`, `all_generated_instance_count=801`, and empty load/instance failure arrays; MCP debug output returns `errors: []` |
| M22-6 | Update ledger and commit | Design spec now includes N23 for all generated script instances; this plan records all M22 tasks done; checkpoint is committed with message `feat: instantiate all generated scripts` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M22 task | N/A |
