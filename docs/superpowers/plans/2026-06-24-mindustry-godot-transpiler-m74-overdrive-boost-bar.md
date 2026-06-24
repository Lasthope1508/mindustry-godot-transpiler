# OverdriveProjector Boost Bar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `OverdriveProjector.setBars()` boost fraction into Godot runtime helpers.

**Architecture:** Reuse `source_overdrive_projector_real_boost()` from M72 and generated `hasBoost`, `speedBoost`, and `speedBoostPhase`. Expose base and phase boost bar fractions in runtime summary for MCP proof before full UI bar rendering.

**Tech Stack:** GDScript runtime in `godot-mindustry/src/game/PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof.

---

### Task 1: Boost Bar Fraction

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write the failing test**

Add a test requiring `source_overdrive_projector_boost_bar_fraction()` and summary keys for base/phase bar fraction.

- [x] **Step 2: Run RED test**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_overdrive_projector_boost_bar_like_source
```

Expected: FAIL because `source_overdrive_projector_boost_bar_fraction` does not exist.

- [x] **Step 3: Implement GDScript helpers**

Add helpers near existing Overdrive helpers in `PortGame.gd`:

```gdscript
func source_overdrive_projector_boost_bar_fraction(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	if overdrive_projector == null:
		return 0.0
	var speed_boost := float(overdrive_projector.properties.get("speedBoost", 0.0))
	var speed_boost_phase := float(overdrive_projector.properties.get("speedBoostPhase", 0.0))
	var has_boost := bool(overdrive_projector.properties.get("hasBoost", false))
	var denominator := speed_boost + speed_boost_phase if has_boost else speed_boost
	if denominator <= 0.0:
		return 0.0
	return source_overdrive_projector_real_boost(overdrive_projector, phase_heat, efficiency) / denominator
```

Expose selected base and phase fractions in `get_runtime_summary()`.

- [x] **Step 4: Run tests**

Run targeted test, then full suite. Expected: full suite reports `87` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `src/game/PortGame.gd`. Run project, select `overdrive-projector`, call `get_runtime_summary()`, and verify base boost bar fraction `0.666666666666667`, phase boost bar fraction `1.0`, debug `errors: []`, and stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals from `76/76/0` to `77/77/0`, checklist from `N49-N74` to `N49-N75`, add row `N75`, and changelog `M74 source OverdriveProjector boost bar`. Run `git diff --check`, stage only related files, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m74-overdrive-boost-bar.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: expose overdrive boost bar"
```
