# OverdriveProjector DrawLight Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `OverdriveBuild.drawLight()` light state into Godot runtime helpers.

**Architecture:** Use generated `emitLight`, `lightRadius`, and `baseColor` from M71. Keep `smooth_efficiency` as an explicit method parameter so MCP can prove the exact Java formula without inventing live Overdrive build state before update simulation is ported.

**Tech Stack:** GDScript runtime in `godot-mindustry/src/game/PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof.

---

### Task 1: DrawLight State

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write the failing test**

Add a test requiring `source_overdrive_projector_light_state()` and `selected_build_overdrive_light_state_for_smooth_efficiency()`.

- [x] **Step 2: Run RED test**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_overdrive_projector_draw_light_like_source
```

Expected: FAIL because `source_overdrive_projector_light_state` does not exist.

- [x] **Step 3: Implement GDScript helpers**

Add helpers near existing Overdrive helpers in `PortGame.gd`:

```gdscript
func source_overdrive_projector_light_state(overdrive_projector, smooth_efficiency: float) -> Dictionary:
	if overdrive_projector == null or not bool(overdrive_projector.properties.get("emitLight", false)):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return {
		"color": str(overdrive_projector.properties.get("baseColor", "")),
		"radius": float(overdrive_projector.properties.get("lightRadius", 0.0)) * smooth_efficiency,
		"alpha": 0.7 * smooth_efficiency,
	}
```

Expose selected helper with explicit `smooth_efficiency` arg for MCP runtime calls.

- [x] **Step 4: Run tests**

Run targeted test, then full suite. Expected: full suite reports `88` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `src/game/PortGame.gd`. Run project, select `overdrive-projector`, call `selected_build_overdrive_light_state_for_smooth_efficiency(0.08)`, and verify `color="feb380"`, `radius=4.0`, `alpha=0.056`, debug `errors: []`, and stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals from `77/77/0` to `78/78/0`, checklist from `N49-N75` to `N49-N76`, add row `N76`, and changelog `M75 source OverdriveProjector drawLight`. Run `git diff --check`, stage only related files, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m75-overdrive-draw-light.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: expose overdrive draw light"
```
