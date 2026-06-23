# M56 Source Turret Recoil Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract source duo turret recoil values and apply them to playable turret recoil state after firing.

**Architecture:** `source_parity.py` reads duo `recoil = 0.5f` and `recoils = 2` directly from `Blocks.java` and compares generated registry data against it. `content_registry.py` emits both values into generated block properties. `PortGame.gd` tracks per-turret recoil, sets it to `1.0` when a shot fires, decays it by source `recoilTime` defaulting to turret `reload`, computes a source-style recoil offset with source `recoilPow = 1.8`, applies that offset to the turret sprite, and reports recoil values through MCP runtime summary.

**Source facts:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets duo `recoils = 2` and `recoil = 0.5f`. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` defines default `recoil = 1f`, `recoils = -1`, `recoilTime = -1f`, and `recoilPow = 1.8f`; `init()` sets `recoilTime = reload` when negative; each update moves `curRecoil` toward `0` by `1 / recoilTime`; each shot sets `curRecoil = 1f`; `recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil)`.

**Tech Stack:** Python source-parity tests, Python content generator, GDScript runtime, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M56 tasks | 9 |
| Done | 9 |
| Not done | 0 |
| Blocked | 0 |

## Execution Checklist

- [x] M56-1 Add failing source-parity test for `recoil` and `recoils`.
- [x] M56-2 Add failing generator test for `recoil` and `recoils`.
- [x] M56-3 Add failing playable runtime test for recoil state, decay, offset, and summary.
- [x] M56-4 Extract source recoil values.
- [x] M56-5 Regenerate Godot content registry.
- [x] M56-6 Apply source recoil state and sprite offset in playable turret fire.
- [x] M56-7 Verify targeted and full tests.
- [x] M56-8 Verify MCP LSP/runtime behavior.
- [x] M56-9 Update docs total/done/not done and commit.

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M56-1 | Add failing source-parity test for `recoil` and `recoils` | Targeted source-parity test failed before implementation with `None != 0.5` for `recoil`. |
| M56-2 | Add failing generator test for `recoil` and `recoils` | Targeted content registry test failed before implementation because generated duo properties omitted `recoil` and `recoils`. |
| M56-3 | Add failing playable runtime test for recoil state, decay, offset, and summary | Targeted playable test failed before implementation because `PortGame.gd` lacked `SOURCE_RECOIL_POW` and recoil state/helpers. |
| M56-4 | Extract source recoil values | `source_parity.py` now reads duo `recoil` and `recoils`; `content_registry.py` now emits numeric `recoil` and integer `recoils` block properties. |
| M56-5 | Regenerate Godot content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` reported `content items=22 liquids=11 blocks=417 units=56`. |
| M56-6 | Apply source recoil state and sprite offset in playable turret fire | Targeted playable test passed with recoil dictionary, source helpers, decay by source reload default, sprite offset application, and runtime summary fields. |
| M56-7 | Verify targeted and full tests | Targeted 3-test command passed; full `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran 63 tests with `OK`. |
| M56-8 | Verify MCP LSP/runtime behavior | MCP LSP diagnostics returned `[]`; MCP runtime reported `selected_turret_recoil=0.5`, `selected_turret_recoils=2`, `last_turret_cur_recoil=1` after firing, `last_turret_cur_recoil=0.7` after `0.1s`, recoil offset magnitude decreased, and debug output errors `[]`. |
| M56-9 | Update docs total/done/not done and commit | Spec now records N57 and status `59/59`; this plan records M56 `9/9`; explicit-file stage and commit follow fresh verification. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M56 item | Add next source-backed migration item after reading upstream Java and writing RED tests. |
