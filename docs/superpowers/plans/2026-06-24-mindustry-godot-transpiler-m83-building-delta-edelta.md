# Building Delta Edelta Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `BuildingComp.delta()` and `BuildingComp.edelta()` as reusable Godot runtime helpers.

**Architecture:** Read `BuildingComp.java` for `delta() = Time.delta * timeScale` and `edelta() = efficiency * delta()`. Expose pure helper functions first, without wiring gameplay systems yet, so later Drill/Conveyor migration can reuse source-proven tick math.

**Tech Stack:** Python source parity/playable tests, GDScript runtime in `PortGame.gd`, Godot MCP LSP/runtime proof.

---

### Task 1: Source Delta Helpers

**Files:**
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing tests**

Add source parity for `return Time.delta * timeScale;` and `return efficiency * delta();`. Add playable tests requiring `source_building_delta()` and `source_building_edelta()` helpers.

- [x] **Step 2: Run RED tests**

Run targeted tests. Expected: FAIL because parity/runtime helpers do not exist.

- [x] **Step 3: Implement helpers**

Add `verify_building_delta_edelta_source()`. Add `source_building_delta(source_delta, time_scale)` and `source_building_edelta(source_delta, time_scale, efficiency)` in `PortGame.gd`.

- [x] **Step 4: Run tests**

Run targeted tests, then full suite. Expected: full suite reports `99` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `PortGame.gd`. Run project and call helpers: `source_building_delta(60, 1.5)` expects `90`; `source_building_edelta(60, 1.5, 0.5)` expects `45`; debug `errors: []`, stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals/checklist, add row/changelog, run `git diff --check`, stage only related files, and commit `feat: expose building delta helpers`.
