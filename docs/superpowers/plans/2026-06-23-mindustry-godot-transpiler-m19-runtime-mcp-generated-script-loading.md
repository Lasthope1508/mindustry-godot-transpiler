# M19 Runtime MCP and Generated Script Loading Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Godot runtime reachable through MCP while the playable scene loads selected generated Java class scripts from the generated registry.

**Architecture:** Enable `godot_mcp_runtime` as a project addon/autoload so running scenes expose TCP port `7777` to the MCP server. Keep generated class loading in handwritten `PortGame.gd`: it asks `GeneratedClassRegistry.gd` for selected Java class metadata, loads each `gdscript_path` with `ResourceLoader`, records loaded names, shows them in HUD text, and exposes `get_runtime_summary()` for live MCP verification.

**Tech Stack:** Godot 4.6.2, GDScript, Python unittest, Godot MCP editor/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M19 tasks | 7 |
| Done | 7 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M19-1 | Install runtime MCP addon | `godot-mindustry/addons/godot_mcp_runtime/` contains `plugin.cfg`, `godot_mcp_runtime.gd`, and `mcp_runtime_autoload.gd` |
| M19-2 | Enable runtime MCP in project config | `project.godot` enables `res://addons/godot_mcp_runtime/plugin.cfg` and autoloads `MCPRuntime` |
| M19-3 | Add runtime addon regression test | `test_godot_mcp_runtime.py` asserts runtime addon files exist and plugin config is enabled |
| M19-4 | Load selected generated scripts from registry | `PortGame.gd` defines `SELECTED_GENERATED_CLASS_NAMES := ["Items", "Blocks", "UnitTypes", "Damage"]`, calls `GeneratedClassRegistry.find_by_java_name()`, loads `gdscript_path` with `ResourceLoader.load()`, and records loaded names |
| M19-5 | Show loaded generated scripts in HUD | HUD text includes `Loaded generated scripts: %d (%s)` from `loaded_generated_class_names` |
| M19-6 | Expose MCP runtime summary method | `PortGame.gd` has `get_runtime_summary()` returning generated class count, loaded generated names, content counts, palette size, and live gameplay counters |
| M19-7 | Verify through MCP runtime | MCP `runtime_status` returns `connected=true` and `runtimeAddon=connected`; runtime `call_method /root/Main get_runtime_summary` returns `generated_class_count=801`, loaded generated names `[Items, Blocks, UnitTypes, Damage]`, and content counts `items=22`, `liquids=11`, `blocks=417`, `units=56`; `editor_debug_output` returns `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M19 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M20-1 | Instantiate generated class scripts safely | Runtime summary reports successful script instance creation for selected generated classes without Godot errors |
| M20-2 | Translate simple Java method bodies | Fixture tests convert simple returns/assignments into GDScript method bodies and representative generated scripts pass MCP LSP diagnostics |
| M20-3 | Drive source-derived block placement through runtime summary | MCP input injection places a block, and `get_runtime_summary()` reports changed placed block/core inventory state without errors |
