# Mindustry Godot Build Placement M7 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the playable slice use source-derived block build data and allow placing real Mindustry blocks in Godot.

**Architecture:** Extend the content registry generator to extract block `requirements(Category...)`, `size`, and `health` from `Blocks.java` initializers. `PortGame.gd` builds a small placement palette from live `MindustryContentCatalog` block objects and places selected blocks into `World/BlockLayer` using copied texture paths.

**Tech Stack:** Python 3.13 `unittest`, generated Godot registry, Godot 4.6.2 GDScript, Godot MCP LSP/runtime verification.

---

### Task 1: Source data extraction
- [x] Add failing registry test for `requirements(Category.distribution, ...)`, `size`, and `health`.
- [x] Extract `category`, `size`, and `health` from block initializer bodies.
- [x] Regenerate `content_registry.json` and `MindustryContentRegistry.gd`.

### Task 2: Interactive placement
- [x] Add build palette ids from source-derived block catalog.
- [x] Add keyboard selection for slots `1` through `6`.
- [x] Add left-click placement on the world grid under `World/BlockLayer`.
- [x] Cache placed block textures loaded from generated block texture paths.

### Task 3: Verification
- [x] Run full Python unittest suite.
- [x] Run MCP LSP diagnostics on `PortGame.gd` and generated registry.
- [x] Run scene through MCP and confirm `editor_debug_output` has `errors=[]`.
