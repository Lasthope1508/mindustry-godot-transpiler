# Mindustry Godot Content Model M5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert generated content registry entries into live Godot content objects.

**Architecture:** Add hand-written Godot content base classes under `src/mindustry/content`. `MindustryContentCatalog` preloads generated registry data, instantiates `MindustryItem`, `MindustryLiquid`, and `MindustryBlock`, and exposes lookup/count APIs. `PortGame.gd` uses the catalog for HUD and validates generated counts against loaded objects.

**Tech Stack:** Godot 4.6.2 GDScript, MCP LSP diagnostics, MCP runtime verification, Python 3.13 `unittest` regression suite.

---

### Task 1: Base content classes
- [x] Add `Content.gd` with id, field, type, implementation, properties, texture path, and dictionary conversion.
- [x] Add `UnlockableContent.gd` with `always_unlocked` and `hidden` behavior.
- [x] Add `Item.gd`, `Liquid.gd`, and `Block.gd` typed wrappers around extracted registry properties.

### Task 2: Content catalog loader
- [x] Add `ContentCatalog.gd` that preloads generated registry and creates object arrays/maps.
- [x] Use path-based inheritance and script preloads so runtime parsing does not depend on stale Godot global class cache.

### Task 3: Game wiring
- [x] Load `MindustryContentCatalog` in `PortGame.gd`.
- [x] Validate catalog counts against generated registry counts.
- [x] Show loaded object counts and object-derived copper display name in HUD.

### Task 4: Verification
- [x] Run Python unittest suite.
- [x] Run MCP LSP diagnostics on every new content script and `PortGame.gd`.
- [x] Run scene through MCP and confirm `editor_debug_output` has `errors=[]`.
