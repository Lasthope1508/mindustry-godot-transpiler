# Mindustry Godot M64 Mend Projector Booster Timer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source-backed `MendProjector` booster item storage/use timing so phase boost is not permanent after one transferred item.

**Architecture:** Keep the existing playable Godot surface in `PortGame.gd`, but split per-cell booster state from `optionalEfficiency`. `boost_mend_projector_at_cell()` transfers one source booster item from core inventory into a per-cell stock, and `simulate_mend_projectors()` derives optional efficiency from stock, lerps `phaseHeat` with source tick delta, then consumes stock on the source `useTime` timer so the following tick decays toward zero.

**Tech Stack:** Godot 4.6 GDScript, Python unittest parity tests, Godot MCP LSP/runtime verification.

---

## Source Facts

- `mindustry-upstream/core/src/mindustry/world/blocks/defense/MendProjector.java` updates `phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f)`.
- `MendProjector.updateTile()` consumes booster input only when `optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal`.
- `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets `mendProjector.useTime` default `400f` and `consumeItem(Items.phaseFabric).boost()` for `mend-projector`.
- `mindustry-upstream/core/src/mindustry/world/consumers/Consume.java` makes `.boost()` optional and booster.
- `mindustry-upstream/core/src/mindustry/world/consumers/ConsumeItems.java` returns efficiency `1f` when building item storage has the required item.
- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java` computes optional efficiency from optional consumers and calls `consume()` from block code.
- Arc `arc/util/Interval.java` at `f30acd23ec` fires when elapsed source time reaches the timer duration.

## Files

- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

## Task 1: RED Test For Booster Stock And Timer

- [x] **Step 1: Add failing test**

Add this test near existing MendProjector tests in `tools/mindustry_godot_transpiler/tests/test_playable.py`:

```python
    def test_port_game_consumes_mend_projector_booster_stock_on_source_timer(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("var mend_projector_booster_items: Dictionary = {}", source)
        self.assertIn("var mend_projector_booster_timers: Dictionary = {}", source)
        self.assertIn("mend_projector_booster_items[key] = int(mend_projector_booster_items.get(key, 0)) + 1", source)
        self.assertIn("mend_projector_optional_efficiency[key] = 1.0 if int(mend_projector_booster_items.get(key, 0)) > 0 else 0.0", source)
        self.assertIn("mend_projector_booster_timers[key] = float(mend_projector_booster_timers.get(key, 0.0)) + source_delta", source)
        self.assertIn("if float(mend_projector_booster_timers.get(key, 0.0)) >= float(block.properties.get(\"boosterUseTime\", 0.0)):", source)
        self.assertIn("mend_projector_booster_items[key] = max(0, int(mend_projector_booster_items.get(key, 0)) - 1)", source)
        self.assertIn("mend_projector_booster_timers[key] = 0.0", source)
```

- [x] **Step 2: Verify RED**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_consumes_mend_projector_booster_stock_on_source_timer -v
```

Expected: FAIL because `mend_projector_booster_items` and timer logic do not exist.

## Task 2: GREEN Implementation

- [x] **Step 1: Add per-cell booster state**

In `godot-mindustry/src/game/PortGame.gd`, near existing MendProjector dictionaries, add:

```gdscript
var mend_projector_booster_items: Dictionary = {}
var mend_projector_booster_timers: Dictionary = {}
```

- [x] **Step 2: Transfer booster item into per-cell stock**

Change `boost_mend_projector_at_cell()` so after core inventory decrements it stores one booster item:

```gdscript
mend_projector_booster_items[key] = int(mend_projector_booster_items.get(key, 0)) + 1
mend_projector_optional_efficiency[key] = 1.0
```

- [x] **Step 3: Consume booster stock on source timer**

In `simulate_mend_projectors(delta)`, derive optional efficiency from stock, lerp phase heat, then advance the booster timer and consume stock when generated `boosterUseTime` elapses:

```gdscript
mend_projector_optional_efficiency[key] = 1.0 if int(mend_projector_booster_items.get(key, 0)) > 0 else 0.0
mend_projector_phase_heat[key] = source_lerp_delta(float(mend_projector_phase_heat.get(key, 0.0)), float(mend_projector_optional_efficiency.get(key, 0.0)), 0.1, source_delta)
mend_projector_booster_timers[key] = float(mend_projector_booster_timers.get(key, 0.0)) + source_delta
if float(mend_projector_booster_timers.get(key, 0.0)) >= float(block.properties.get("boosterUseTime", 0.0)):
	mend_projector_booster_items[key] = max(0, int(mend_projector_booster_items.get(key, 0)) - 1)
	mend_projector_booster_timers[key] = 0.0
	mend_projector_optional_efficiency[key] = 1.0 if int(mend_projector_booster_items.get(key, 0)) > 0 else 0.0
```

- [x] **Step 4: Verify GREEN targeted**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_consumes_mend_projector_booster_stock_on_source_timer tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_lerps_mend_projector_phase_heat_like_source tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_simulates_source_mend_projector_phase_boost -v
```

Expected: OK.

## Task 3: Verification And Docs

- [x] **Step 1: Run full tests**

```powershell
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
```

Expected: all tests OK.

- [x] **Step 2: Run Godot MCP checks**

Use `mcp__godot.lsp_diagnostics` on `src/game/PortGame.gd`; expected `diagnostics: []`.

Use `mcp__godot.editor_run`, `mcp__godot.runtime_status`, and runtime addon calls to prove: one transferred `phase-fabric` gives `phaseHeat 0.0 -> 0.1` after one source tick, then after `400` source ticks booster stock is consumed and the next tick moves phase heat downward.

- [x] **Step 3: Update migration spec checklist**

In `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`, change totals to `67/67/0`, add `N65` done row, and add changelog row for M64.

- [x] **Step 4: Commit explicit files only**

```powershell
git add -- docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m64-mend-projector-booster-timer.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: time mend projector booster consumption"
```
