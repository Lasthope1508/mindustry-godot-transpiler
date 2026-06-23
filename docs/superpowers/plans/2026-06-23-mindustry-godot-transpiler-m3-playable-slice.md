# Mindustry Godot Transpiler M3 Playable Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `godot-mindustry` open to a playable source-asset slice: camera, tiled world, ore, drill, conveyors, core inventory, and skin path registry.

**Architecture:** Python generates `playable_content.json` from copied Mindustry assets. Godot `PortGame.gd` loads that JSON, instantiates nodes under existing MCP-created scene layers, simulates copper production and conveyor delivery to core.

**Tech Stack:** Python 3.13 `unittest`, Godot 4.6.2 GDScript, Mindustry copied PNG assets, MCP Godot project verification.

---

### Task 1: Playable content manifest
- Test required asset ids and paths exist.
- Generate `godot-mindustry/src/generated/playable_content.json`.

### Task 2: Godot playable script
- Add `godot-mindustry/src/game/PortGame.gd`.
- Attach to `Main.tscn` root.
- Build world nodes at runtime under `World/*` layers.
- Add camera movement and zoom.
- Add core inventory HUD.

### Task 3: Verification
- Run Python tests.
- Run pipeline `playable` command.
- Use `mcp__godot.project_info` and `mcp__godot.project_setting_get`.
- Confirm zero Godot GUI processes.
- Update spec ledger and commit.
