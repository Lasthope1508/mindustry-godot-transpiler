# Drill Warmup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `DrillBuild.updateTile()` warmup progression into the Godot playable runtime.

**Architecture:** Read `Drill.java` for `warmup = Mathf.approachDelta(warmup, speed, warmupSpeed);` and `warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);`. Read Arc `Mathf.java` at Mindustry `archash=f30acd23ec` for `approachDelta(from, to, speed) = approach(from, to, Time.delta * speed)` and `approach(from, to, speed) = from + clamp(to - from, -speed, speed)`. Add Godot helpers for approach/approachDelta, track drill warmup by cell, and multiply drill output delta by current warmup.

**Tech Stack:** Python source parity/playable tests, GDScript runtime in `PortGame.gd`, Godot MCP LSP/runtime proof.

---

### Task 1: Drill Warmup Wiring

**Files:**
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing tests**

Add source parity for drill warmup approachDelta lines. Add playable tests requiring `source_approach()`, `source_approach_delta()`, drill warmup state, and production delta multiplied by warmup.

- [x] **Step 2: Run RED tests**

Run targeted tests. Expected: FAIL because parity/runtime helpers do not exist yet.

- [x] **Step 3: Implement helpers and wiring**

Add `verify_drill_warmup_source()`. Add `source_approach()`, `source_approach_delta()`, `source_drill_warmup_state()`, `step_drill_warmup_cell()`, and warmup-aware production delta.

- [x] **Step 4: Run tests**

Run targeted tests, then full suite. Expected: full suite reports `103` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `PortGame.gd`. Run project and call helpers proving approachDelta, drill warmup, and warmup-scaled drill output. Debug `errors: []`, stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals/checklist, add row/changelog, run `git diff --check`, stage only related files, and commit `feat: apply drill warmup progression`.
