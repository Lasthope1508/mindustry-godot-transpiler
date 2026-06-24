# OverdriveProjector Draw State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `OverdriveBuild.draw()` visual state into Godot runtime helpers.

**Architecture:** Reuse `source_absin()` and generated `baseColor`, `phaseColor`, and block size. Keep `heat`, `phase_heat`, source time, and LOD inputs explicit so MCP can prove formulas before live Overdrive update state exists.

**Tech Stack:** GDScript runtime in `godot-mindustry/src/game/PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof.

---

### Task 1: Draw State

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write the failing test**

Add a test requiring `source_overdrive_projector_draw_state()` and selected helper with explicit heat/phase/time args.

- [x] **Step 2: Run RED test**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_overdrive_projector_draw_state_like_source
```

Expected: FAIL because `source_overdrive_projector_draw_state` does not exist.

- [x] **Step 3: Implement GDScript helpers**

Add helpers near existing Overdrive helpers in `PortGame.gd`:

```gdscript
func source_overdrive_projector_draw_state(overdrive_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	var f := 1.0 - fmod(source_time_ticks / 100.0, 1.0)
	if overdrive_projector == null or not lod_l2:
		return {"visible": false, "f": f, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "stroke": 0.0, "line_r": 0.0, "line_w": 0.0}
	var line_r: float = max(0.0, clamp(2.0 - f * 2.0, 0.0, 1.0) * float(block_size(overdrive_projector)) * float(tile_size) / 2.0 - f - 0.2)
	var line_w: float = clamp(0.5 - f, 0.0, 1.0) * float(block_size(overdrive_projector)) * float(tile_size)
	return {
		"visible": true,
		"f": f,
		"base_color": str(overdrive_projector.properties.get("baseColor", "")),
		"phase_color": str(overdrive_projector.properties.get("phaseColor", overdrive_projector.properties.get("baseColor", ""))),
		"phase_heat": phase_heat,
		"top_alpha": heat * source_absin(source_time_ticks, 50.0 / SOURCE_PI2, 1.0) * 0.5 * lod_alpha2,
		"stroke": (2.0 * f + 0.1) * heat,
		"line_r": line_r,
		"line_w": line_w,
	}
```

Expose selected helper for MCP runtime calls.

- [x] **Step 4: Run tests**

Run targeted test, then full suite. Expected: full suite reports `89` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `src/game/PortGame.gd`. Run project, select `overdrive-projector`, call `selected_build_overdrive_draw_state_for_inputs(0.08, 0.1, 0.0)`, and verify `visible=true`, `f=1`, `top_alpha=0.02`, `stroke=0.168`, `line_r=0`, `line_w=0`, colors `feb380/ffd59e`, debug `errors: []`, and stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals from `78/78/0` to `79/79/0`, checklist from `N49-N76` to `N49-N77`, add row `N77`, and changelog `M76 source OverdriveProjector draw state`. Run `git diff --check`, stage only related files, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m76-overdrive-draw-state.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: expose overdrive draw state"
```
