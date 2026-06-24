# Drill TimeDrilled Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `DrillBuild.updateTile()` `timeDrilled` progression into the Godot playable runtime.

**Architecture:** Read `Drill.java` for `timeDrilled += warmup * delta();`. Track `timeDrilled` by drill cell and expose deterministic helpers so later source draw/rotator migration can use source-backed drill animation time.

**Tech Stack:** Python source parity/playable tests, GDScript runtime in `PortGame.gd`, Godot MCP LSP/runtime proof.

---

### Task 1: Drill TimeDrilled State

**Files:**
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing tests**

Add source parity for `timeDrilled += warmup * delta();`. Add playable tests requiring `drill_time_drilled` state and helper functions.

- [x] **Step 2: Run RED tests**

Run targeted tests. Expected: FAIL because parity/runtime helpers do not exist yet.

- [x] **Step 3: Implement helpers and wiring**

Add `verify_drill_time_drilled_source()`. Add `source_drill_time_drilled_delta()`, `drill_time_drilled_at_cell()`, `set_drill_time_drilled_at_cell()`, `step_drill_time_drilled_cell()`, and wire it before warmup update in `simulate_factory()`.

- [x] **Step 4: Run tests**

Run targeted tests, then full suite. Expected: full suite reports `105` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `PortGame.gd`. Run project and call helpers proving `warmup * delta()` time progression. Debug `errors: []`, stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals/checklist, add row/changelog, run `git diff --check`, stage only related files, and commit `feat: track drill time drilled`.
