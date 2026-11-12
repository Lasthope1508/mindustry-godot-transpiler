# Report — N2132: Wire the payload efficiency into the shouldConsume gate

Date: 2026-11-12. Batch: N2132 (single slice). Status: GREEN done in this VM, targeted tests **12/12 OK** (N2132 4/4 + N2129 4/4 + N2124 4/4). **Godot proof GREEN 2026-11-12 ~11:15 +07: Godot 4.6.2-stable Linux (build 71f334935, identical to the Windows 4.6.2 build) ran `C06UnitFactoryShouldConsumeProof.tscn` headless in this VM — 43 keys, all true, `matches: true`. Inclusive full gate finished ~12:01 +07 (Ran 5625 in 1767.821s, failures=83, skipped=5, 0 errors — all 83 Godot-proof failures, no Godot binary on PATH). Committed + pushed to origin main (fork Lasthope1508) in the 12:00 cron run.**

## What changed

N2129 built the assembler's payload module (`blocks: PayloadSeq`) and its efficiency function, but the `shouldConsume` gate still read the frame's `payload_efficiency` default (1.0, N2124) — so a blocks-less assembler looked fully supplied. Java reads the live module: `UnitAssemblerBuild.shouldConsume()` (UnitAssembler.java:389-391) requires `consPayload.efficiency(this) > 0`, where `consPayload` is `ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements)` (UnitAssembler.java:158) and `ConsumePayloadDynamic.efficiency` (ConsumePayloadDynamic.java:20-29) returns 1.0 only when every requirement stack is held at `Math.round(amount * mult)`, else 0.0.

N2132 wires the gate's assembler branch to `SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_state(frame, plan)` (N2129) and reads its `payload_efficiency` — the same pattern as the `item_eff` call directly above it; `plan` is already computed in the branch. A blocks-less assembler now reads 0.0, which is the Java behavior. No new symbols, contracts, or schemas: the wiring reuses the existing `source_unit_factory_should_consume_state_result.payload_efficiency` symbol (N2124) and the existing N2129 function; the ledger N2132 entry lists that one reused symbol (precedent: N1084/N1085 share symbols). The `should_consume` formula itself is unchanged (`enabled and not was_occupied and activate and item_efficiency > 0 and can_create and payload_efficiency > 0`) — only the `payload_efficiency` input changes source. The registry symbol's `rule` is reworded from "the port has no payload module yet, so the frame input defaults 1.0" to the live read, and its `tests` grow to 8 (4 N2124 + 4 N2132).

## Proof keys (42 → 43, same scene, no new .tscn)

- `should_consume_assembler_default_true` → `should_consume_assembler_default_false`: frame `{"block_implementation": "UnitAssembler", "current_tier": 0}` (no `blocks`) → `should_consume == false`, `payload_efficiency == 0.0`, `plan_unit == "vanquish"`, `item_efficiency == 1.0`.
- `should_consume_assembler_no_payload_eff_false` → `should_consume_assembler_short_blocks_false`: frame + `"blocks": {"stell": 3, "tungsten-wall-large": 10}` (one stell short of the vanquish plan) → `should_consume == false`, `payload_efficiency == 0.0`.
- NEW `should_consume_assembler_full_blocks_true`: frame + `"blocks": {"stell": 4, "tungsten-wall-large": 10}` (plan met) → `should_consume == true`, `payload_efficiency == 1.0`.
- `should_consume_live_assembler_efficiency_one` → `should_consume_live_assembler_efficiency_zero`: the live assembler frame carries no `blocks`, so its live efficiency reads 0.0 once the gate is live.
- `should_consume_live_assembler_unoccupied_one` → `should_consume_live_assembler_unoccupied_zero`: same reason — clearing `was_occupied` no longer restores efficiency while the module is empty.
- The N2124 test module needs NO change: its proof test asserts returncode 0, no `ERROR:`, one proof line, `matches` true — all still hold.

## Verified numbers (measured in this VM)

- Test module `test_c06_unit_assembler_payload_should_consume.py`: **4/4 OK** — registration (ledger N2132, 1 reused symbol, runtime proof, test names, deferred_exprs), exact-evidence (1 reused symbol + 7 exprs over UnitAssembler.java + ConsumePayloadDynamic.java, all found verbatim), source-text (gate calls `source_unit_factory_assembler_payload_state(frame, plan)`; no `frame.get("payload_efficiency", 1.0)`; no "It is not wired into the shouldConsume" comment; proof has the 5 new keys and none of the 4 old ones), and the Godot proof test (43 keys, all true, `matches: true`).
- Targeted run with Godot on PATH: **12/12 OK in 73.1s** (N2132 4/4 + N2129 4/4 + N2124 4/4). First attempt 11/12: the N2132 proof test failed only on the `ERROR:` assert — a concurrent C06DefenseProofDebug scene from another thread held port 7777 at that moment; the proof JSON itself was already `matches: true` with all 43 keys true, including the 5 new keys; re-run with the port free passed clean. (Lesson, already in MEMORY.md: never run standalone proof scenes while a gate runs — a busy port 7777 puts `ERROR:` in the scene output.)
- The N2129 test module's gate assertion flipped (`assertNotIn` → `assertIn` on the gate call) + comment updated to the wired state; the N2131 test's `assertNotIn(...payload_intake_state..., gate)` is unaffected — the intake is still not called by the gate.
- `git diff --check` clean.
- SSOT +0/+1/+0/+0 → **11256 / 1583 / 1504 / 2799**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2132 4/4, N2129 4/4, N2124 4/4 (proof green, see above).
- Godot proof: **GREEN 2026-11-12 ~11:15 +07** — 43 keys all true, `matches: true`, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- Full Python suite, inclusive gate with the N2132 module (log `tools/mindustry_godot_transpiler/full-suite-n2132-gate.log`, 210 modules): the first attempt (PID 3079, started ~11:22) died ~11:22:50 when its spawning cron session ended — log froze at 3410 chars (3346 dots + 59 F + 5 skipped), no summary, unverifiable; the VM did not restart and there was no OOM. The second attempt started detached with `setsid` ~11:31 (PID 4326, PPID 1, SID 4326) and **finished ~12:01 +07: Ran 5625 in 1767.821s, FAILED (failures=83, skipped=5), 0 errors** — all 83 verified individually as Godot-proof failures (82 plain `assertIsNotNone(godot)` + 1 `Godot required for hydration proof` variant); the N2132 module contributes only its proof test, its 3 non-proof tests pass. Zero errors, zero non-Godot failures: the gate is clean except Godot. Attempt 2 ran 29.5 min (vs ~16 min for earlier gates) — slower, not stuck. Lesson (recorded in the handoff): start long gates with `setsid` so they survive the spawning session.
- The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green.

## Deferred

- `checkTier` from the module tiers (UnitAssembler.java:360-376) — next in the C06 order.
- Battery live `enabled` stamp; disabled-belt efficiency half; unit-factory shouldConsume wiring to the power stamp; live production wiring (progress advance + the call at completion, including the intake call site `moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

See `handoffs/2026-11-12-c06-unit-assembler-payload-should-consume-handoff.md` for the full detail.
