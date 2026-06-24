# Time Scale Decay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `BuildingComp.update()` time-scale duration decay for boosted placed blocks.

**Architecture:** Read `BuildingComp.java` for `(timeScaleDuration -= Time.delta) <= 0f` and `timeScale = 1f`. Add a source helper returning the decayed `time_scale` and `time_scale_duration`, apply it to placed block sprite metadata, and expose a deterministic MCP step for verification.

**Tech Stack:** Python source parity/playable tests, GDScript runtime in `PortGame.gd`, Godot MCP LSP/runtime proof.

---

### Task 1: Source Time Scale Duration Decay

**Files:**
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing tests**

Add source parity for the exact `BuildingComp.update()` time-scale decay lines and playable runtime tests for helper/accessor methods.

- [x] **Step 2: Run RED tests**

Run targeted tests. Expected: FAIL because parity/runtime helpers do not exist.

- [x] **Step 3: Implement helpers**

Add `verify_building_time_scale_decay_source()`. Add `source_building_time_scale_decay_state()`, `decay_block_time_scale_sprite()`, `simulate_block_time_scales()`, and `step_block_time_scales()`; call decay from `_process()`.

- [x] **Step 4: Run tests**

Run targeted tests, then full suite. Expected: full suite reports `97` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `PortGame.gd`. Run project, apply overdrive boost to a conveyor, verify `time_scale=1.5` and duration `61`, step block time scales by `61 / 60.0` seconds, and verify duration `0` and `time_scale=1`; debug `errors: []`, stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals/checklist, add row/changelog, run `git diff --check`, stage only related files, and commit `feat: decay building time scale boosts`.
