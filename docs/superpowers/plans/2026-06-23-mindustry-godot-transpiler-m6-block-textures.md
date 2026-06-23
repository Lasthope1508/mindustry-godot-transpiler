# Mindustry Godot Block Texture Registry M6 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Attach copied Mindustry sprite paths to generated block registry entries.

**Architecture:** Extend `content_registry.py` with a block texture resolver that scans copied `assets/core/assets-raw/sprites/blocks`. The resolver prefers exact canonical block sprite names, handles animated suffixes, and keeps non-rendered `air` textureless to avoid false positives.

**Tech Stack:** Python 3.13 `unittest`, generated Godot GDScript registry, Godot MCP diagnostics/runtime verification.

---

### Task 1: Tests
- [x] Add fixture coverage for `conveyor` mapping to `conveyor-0-0.png`.
- [x] Add fixture coverage that `air` remains textureless.

### Task 2: Generator
- [x] Add `_block_texture_path` resolver.
- [x] Include `texture` on every generated block entry.
- [x] Regenerate `content_registry.json` and `MindustryContentRegistry.gd`.

### Task 3: Verification
- [x] Confirm generated block texture coverage is `416/417`, with only `air` intentionally empty.
- [x] Run full Python unittest suite.
- [x] Run MCP LSP diagnostics and MCP scene runtime check with `errors=[]`.
