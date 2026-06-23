# Mindustry Godot Content Registry M4 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate a Godot-readable content registry from Mindustry Java source for items, liquids, and block constructor declarations.

**Architecture:** `content_registry.py` extracts data from `Items.java`, `Liquids.java`, and `Blocks.java`, writes `content_registry.json`, and emits `MindustryContentRegistry.gd`. `PortGame.gd` reads the generated GDScript registry so runtime UI reports source-derived totals instead of only hardcoded playable data.

**Tech Stack:** Python 3.13 `unittest`, `javalang==0.13.0`, Godot 4.6.2 GDScript, Godot MCP verification.

---

### Task 1: Registry extractor

**Files:**
- Create: `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- Test: `tools/mindustry_godot_transpiler/tests/test_content_registry.py`

- [ ] Extract `Item` and `Liquid` assignments with `javalang` from fixture Java source.
- [ ] Extract block assignments from `Blocks.java` source with a constrained constructor declaration scanner.
- [ ] Resolve copied asset paths for item and liquid icons when matching files exist.

### Task 2: CLI and generated outputs

**Files:**
- Modify: `tools/mindustry_godot_transpiler/transpile.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_cli.py`
- Generate: `godot-mindustry/src/generated/content_registry.json`
- Generate: `godot-mindustry/src/generated/MindustryContentRegistry.gd`

- [ ] Add `content` command.
- [ ] Write JSON and GDScript registry outputs.
- [ ] Verify CLI writes both files from fixtures.

### Task 3: Godot wiring and verification

**Files:**
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [ ] Preload generated registry in `PortGame.gd`.
- [ ] Show registry counts in HUD.
- [ ] Run `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`.
- [ ] Run `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry`.
- [ ] Use MCP `lsp_diagnostics` and `editor_debug_output` before marking done.
