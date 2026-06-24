# OverdriveProjector Range State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `OverdriveProjector` placement/select range state into Godot runtime helpers.

**Architecture:** Use generated `range`, `phaseRangeBoost`, and `baseColor` from M71. Expose non-phase place range and phase-heated select range as deterministic runtime summary values before building full overdrive block scanning.

**Tech Stack:** GDScript runtime in `godot-mindustry/src/game/PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof.

---

### Task 1: Overdrive Range State

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write the failing test**

Add a test requiring `source_overdrive_projector_range()`, place/select state helpers, and runtime summary keys.

- [x] **Step 2: Run RED test**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_overdrive_projector_range_state_like_source
```

Expected: FAIL because `source_overdrive_projector_range` does not exist.

- [x] **Step 3: Implement GDScript helpers**

Add helpers near existing Overdrive helper code in `PortGame.gd`:

```gdscript
func source_overdrive_projector_range(overdrive_projector, phase_heat := 0.0) -> float:
	if overdrive_projector == null:
		return 0.0
	var base_range := float(overdrive_projector.properties.get("range", 0.0))
	var phase_range_boost := float(overdrive_projector.properties.get("phaseRangeBoost", 0.0))
	return base_range + phase_heat * phase_range_boost
```

Expose place state at phase heat `0.0`, phase select state at phase heat `1.0`, and both summary keys.

- [x] **Step 4: Run tests**

Run targeted test, then full suite. Expected: full suite reports `86` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `src/game/PortGame.gd`. Run project, select `overdrive-projector`, call `get_runtime_summary()`, and verify place range `80`, phase select range `100`, color `feb380`, debug `errors: []`, and stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals from `75/75/0` to `76/76/0`, checklist from `N49-N73` to `N49-N74`, add row `N74`, and changelog `M73 source OverdriveProjector range state`. Run `git diff --check`, stage only related files, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m73-overdrive-range-state.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: expose overdrive range state"
```
