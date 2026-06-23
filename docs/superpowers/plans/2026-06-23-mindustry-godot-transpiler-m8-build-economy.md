# Mindustry Godot Build Economy M8 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make placed blocks consume source-derived item requirements from the core inventory.

**Architecture:** Extend `content_registry.py` to parse `with(Items.x, n)` requirements from `Blocks.java` initializer bodies. `PortGame.gd` reads requirements from live `MindustryBlock` objects, shows selected block cost in HUD, and blocks/deducts placement using the copper inventory already produced by the playable drill/conveyor/core loop.

**Tech Stack:** Python 3.13 `unittest`, generated Godot registry, Godot 4.6.2 GDScript, Godot MCP diagnostics/runtime verification.

---

### Task 1: Source requirements extraction
- [x] Add failing test for `requirements(Category.distribution, with(Items.copper, 3))`.
- [x] Parse requirements into `properties.requirements` as `[{"item":"copper","amount":3}]`.
- [x] Regenerate `content_registry.json` and `MindustryContentRegistry.gd`.

### Task 2: Build economy wiring
- [x] Add `can_afford`, `spend_requirements`, and `requirements_text` in `PortGame.gd`.
- [x] Prevent placement when core lacks required copper.
- [x] Deduct copper when placement succeeds.
- [x] Show selected block cost in HUD.

### Task 3: Verification
- [x] Run full Python unittest suite.
- [x] Run MCP LSP diagnostics on `PortGame.gd` and generated registry.
- [x] Run scene through MCP and confirm `editor_debug_output` has `errors=[]`.
