# C05 game rules state — N2098

Date: 2026-11-09. Batch: N2098 (single slice, fourth C05 batch). SSOT +2/+1/+1/+2 → 10826 / 1551 / 1439 / 2669; audit `totalSourceFunctions` stays 1335.

## What changed

The game held no rules state at all: the drill tick read `game.get("rules_state")` and fell back to an empty Dictionary, so `Rules.unitCost` always read the 1.0 defaults and no later slice (TeamRules cheating, per-team multipliers) could change anything live. In Java the rules object is live and mutable: `Vars.state` is the global `GameState` (Vars.java:271) and it holds `public Rules rules = new Rules()` (GameState.java:35).

- N2098 `SourceRulesRuntimeState.source_game_rules_state(rules_state)` — returns the live game rules: an existing non-empty rules state is returned as-is, the same Dictionary object, so mutations through it stay live on the game; a missing or empty state returns the Java `new Rules()` defaults (`unitCostMultiplier` 1.0, Rules.java:83; `teams` a fresh TeamRules, Rules.java:29).
- The game now holds the property (`SourcePortGameRootStatePortBridge.rules_state`, initialized from this function at construction), and the drill tick reads it through this function instead of falling back to `{}`.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_game_rules_state_binding.py` (registration + exact-evidence + Godot proof) — RED before the register script ran (2 errors), GREEN after: 3 tests OK.
- Godot proof `GameRulesStateProof` **9/9 true** on the real Main scene: empty/null rules return the defaults, an existing rules state is returned as the same object (a mutation through the result shows up on the input), the game holds the default rules, mutating the game's rules changes what `unitCost` reads (2.0), and the drill frame sees the mutation live (2.0, then 5.0 after a second mutation).
- Targeted gate: the game-rules-state + rules-unit-cost + cost-multiplier + content-registry + hydration + emitter + parity + symbols + playable tests — **4964 tests OK in 738.495s, exit=0** (log `~/workspace/logs/targeted-n2098.log`).
- Full Python suite: **5493 tests OK in 1389.536s, exit=0** (log `~/workspace/logs/full-suite-n2098.log`).

## SSOT delta

+2 symbols / +1 slice / +1 contract / +2 schemas → 10826 / 1551 / 1439 / 2669; audit `totalSourceFunctions` stays 1335. No module shard mirrors the owner (`core/GameState.java` matches no selection).

## Still open

- C05: live TeamRules cheating, and the descriptor/apply/adapter cache invalidation on Block reinit/reload. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
