# Handoff — N2132: Wire the payload efficiency into the shouldConsume gate

Date: 2026-11-12. Batch: N2132 (single slice). Status: **GREEN + gate verified clean except Godot — commit/push in the 12:00 cron run.** Targeted tests 12/12 OK (N2132 4/4 + N2129 4/4 + N2124 4/4); Godot proof GREEN (43 keys, all true); full gate Ran 5625, failures=83, skipped=5, 0 errors — all 83 Godot-proof failures.

## RED progress (11:00 cron run, 2026-11-12 ~11:00-11:15 +07)

- State at RED time: main at 62799b7 (N2131 done + pushed to the fork 2026-11-12 ~10:50); working tree clean except untracked `*.gd.uid` files (never stage), untracked gate logs, and the Windows queue doc `docs/superpowers/reports/2026-11-12-c06-godot-test-queue.md` (another thread — never stage).
- javalang 0.13.0 present, Godot 4.6.2 present (`~/workspace/godot-bin/godot` symlink; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c06_unit_assembler_payload_should_consume.py` (4 tests). RED run: **Ran 4 tests in 13.9s, FAILED (failures=1, errors=7)** — all expected:
  - registration `KeyError: 'N2132'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: the gate does not yet call `source_unit_factory_assembler_payload_state(frame, plan)`;
  - proof: 5 subTest `KeyError`s, one per new key (`should_consume_assembler_default_false`, `should_consume_assembler_full_blocks_true`, `should_consume_assembler_short_blocks_false`, `should_consume_live_assembler_efficiency_zero`, `should_consume_live_assembler_unoccupied_zero`) — the old proof scene itself still runs green (returncode 0, no ERROR, its 42 old keys match), the new keys are simply not emitted yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module).

## What this batch is

The wiring half of the assembler payload work, the next item on the N2131 "Next" list: the `shouldConsume` gate's assembler branch stops reading the frame's `payload_efficiency` default (1.0, N2124) and reads `consPayload.efficiency` live from the payload module through the N2129 function `source_unit_factory_assembler_payload_state(frame, plan)`. A blocks-less assembler reads 0.0 once the gate is live, which is the Java behavior. The N2124 proof's assembler keys update with it.

## Exact upstream evidence (all 7 exprs verified verbatim in this VM)

- `UnitAssemblerBuild.shouldConsume()` (UnitAssembler.java:389-391): `return enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories();` — the `consPayload.efficiency(this) > 0` conjunct is the one this slice wires.
- `consPayload` declaration (UnitAssembler.java:158): `consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements));`
- `ConsumePayloadDynamic.efficiency` (ConsumePayloadDynamic.java:20-29): `public float efficiency(Building build){` / `for(PayloadStack stack : payloads.get(build)){` / `if(!build.getPayloads().contains(stack.item, Math.round(stack.amount * mult))){` / `return 0f;` / `return 1f;` — 1.0 only when every requirement stack is held at `Math.round(amount * mult)`.
- The module the gate now reads (UnitAssembler.java:323, 717-719): `public PayloadSeq blocks = new PayloadSeq();` / `public PayloadSeq getPayloads(){` / `return blocks;`.
- Plan requirements (Blocks.java:6526-6527): tank-assembler tier 0 vanquish = stell 4 + tungsten-wall-large 10; tier 1 conquer = locus 6 + carbide-wall-large 20 (already in the port via N2124/N2129; the proof uses content names `stell` / `tungsten-wall-large`).

## Design (decided in RED, implement in GREEN)

- **No new symbols, no new contracts, no new schemas.** The wiring adds no new function, registry const, or return key: `source_unit_factory_should_consume_state` (N2124) and `source_unit_factory_assembler_payload_state` (N2129) already exist, and `payload_efficiency` is already a shouldConsume return key. The ledger entry N2132 therefore lists the ONE symbol this slice makes live — `source_unit_factory_should_consume_state_result.payload_efficiency` — which already exists in the registry (N2124). This is allowed: `validate_source_slice_ledger` requires `source_symbols` non-empty (an empty list would fail the global gate), and precedent exists for symbols shared across slices (N1084/N1085 share 5 symbols). Expected SSOT after GREEN: **11256 / 1583 / 1504 / 2799** (symbols unchanged, slices +1, contracts/schemas unchanged); audit stays 1335.
- Ledger N2132 entry: `status: done`, `java_source: core/src/mindustry/world/blocks/units/UnitAssembler.java`, `java_class: mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild`, `java_method: UnitAssemblerBuild.shouldConsume()`, `godot_owner: SourceUnitFactoryBuildState.source_unit_factory_should_consume_state`, `exact_exprs`: the 7 exprs above, `source_symbols`: the 1 reused symbol, `tests`: the 4 test names of the new module, `runtime_proof: /root/C06UnitFactoryShouldConsumeProof`, `deferred_exprs`: checkTier, live production wiring, unit-factory power-stamp wiring, battery live `enabled` stamp, disabled-belt efficiency half, C06–C12 open.
- Register script `register_c06_unit_assembler_payload_should_consume.py` (GREEN): writes the ledger N2132 entry and updates the registry symbol `source_unit_factory_should_consume_state_result.payload_efficiency` — its `rule` currently says "the port has no payload module yet, so the frame input defaults 1.0" (stale after wiring) → reword to the live read via `source_unit_factory_assembler_payload_state` (N2132); append the 4 N2132 test names to its `tests`. Verify SSOT totals 11256 / 1583 / 1504 / 2799, audit 1335.
- Gate wiring in `SourceUnitFactoryBuildState.gd`, assembler branch of `source_unit_factory_should_consume_state`:
  - Replace `result["payload_efficiency"] = float(frame.get("payload_efficiency", 1.0))` with a call to `source_unit_factory_assembler_payload_state(frame, plan)` and read its `payload_efficiency` (same pattern as the `item_eff` call directly above it; `plan` is already computed in the branch).
  - Update the deferred-conjuncts comment above the dispatcher: `consPayload.efficiency` is now live (N2132); only `Units.canCreate` (frame `can_create`, default true, needs C07 live unit counts) stays deferred.
  - Update the comment in `source_unit_factory_assembler_payload_state` ("It is not wired into the shouldConsume gate yet — the gate keeps reading the frame's payload_efficiency default (1.0, N2124) until the wiring slice lands it...") to say it IS wired (N2132).
- N2129 test module update (required, else the full gate fails): `tools/mindustry_godot_transpiler/tests/test_c06_unit_assembler_payload.py`, `test_assembler_payload_reads_blocks_not_the_gate_default` — the gate assertion flips from `assertNotIn('source_unit_factory_assembler_payload_state(', gate)` to `assertIn`, and the comment above it updates to the wired state. (The N2131 test's `assertNotIn(...payload_intake_state..., gate)` is unaffected — the intake is still not called by the gate.)
- Proof updates in `godot-mindustry/tools/runtime_proofs/C06UnitFactoryShouldConsumeProof.gd` (same scene, no new `.tscn`; proof JSON is gitignored, never stage it). Proof keys 42 → 43:
  - `should_consume_assembler_default_true` → `should_consume_assembler_default_false`: frame `{"block_implementation": "UnitAssembler", "current_tier": 0}` (no `blocks`) → `should_consume == false`, `payload_efficiency == 0.0`, `plan_unit == "vanquish"`, `item_efficiency == 1.0`.
  - `should_consume_assembler_no_payload_eff_false` → `should_consume_assembler_short_blocks_false`: frame + `"blocks": {"stell": 3, "tungsten-wall-large": 10}` (one stell short of the vanquish plan) → `should_consume == false`, `payload_efficiency == 0.0`. (The old frame-key form would still pass by coincidence — empty blocks also read 0.0 — but its intent is dead once the gate ignores the frame key, so re-express it with blocks.)
  - NEW `should_consume_assembler_full_blocks_true`: frame + `"blocks": {"stell": 4, "tungsten-wall-large": 10}` (plan met) → `should_consume == true`, `payload_efficiency == 1.0`.
  - `should_consume_live_assembler_efficiency_one` → `should_consume_live_assembler_efficiency_zero`: the live assembler frame carries no `blocks`, so its live efficiency reads 0.0 once the gate is live (per the N2129 handoff: a blocks-less assembler reads 0.0).
  - `should_consume_live_assembler_unoccupied_one` → `should_consume_live_assembler_unoccupied_zero`: same reason — clearing `was_occupied` no longer restores efficiency while the module is empty.
  - The N2124 test module needs NO change: its proof test asserts returncode 0, no `ERROR:`, one proof line, `matches` true — all still hold. Its registration test asserts N2124's own symbols/contracts, unchanged by this slice.
- The gate's `should_consume` formula itself is unchanged (`enabled and not was_occupied and activate and item_efficiency > 0 and can_create and payload_efficiency > 0`) — only the `payload_efficiency` input changes source.

## Files changed (RED only)

- `tools/mindustry_godot_transpiler/tests/test_c06_unit_assembler_payload_should_consume.py` (new, 4 tests): registration (ledger N2132, 1 reused symbol, runtime proof, test names, deferred_exprs), exact-evidence (1 reused symbol + 7 exprs over UnitAssembler.java + ConsumePayloadDynamic.java), source-text (gate calls `source_unit_factory_assembler_payload_state(frame, plan)`; no `frame.get("payload_efficiency", 1.0)`; no "It is not wired into the shouldConsume" comment; proof has the 5 new keys and none of the 4 old ones), Godot proof (`C06UnitFactoryShouldConsumeProof.tscn`, prefix `C_06_UNIT_FACTORY_SHOULD_CONSUME_PROOF `, the 5 new keys true).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests, 1 failure + 7 errors, all expected** — registration `KeyError: 'N2132'`, evidence errors on the missing ledger entry, source-text `AssertionError` (gate does not call the payload state yet), proof 5 subTest `KeyError`s (new keys not emitted yet; the old scene still runs green on its 42 keys).
- Exact-expr pre-check: **7/7 exprs found verbatim** in the 2 slice sources (UnitAssembler.java, ConsumePayloadDynamic.java).
- `git diff --check` clean.
- State at RED time: main at 62799b7 (N2131 merged + pushed to the fork 2026-11-12 ~10:50); SSOT 11256 / 1582 / 1504 / 2799; audit 1335.

## GREEN progress (11:15 cron run, 2026-11-12 ~11:15-11:30 +07)

- javalang was missing again (VM restart wiped the system-wide install) — reinstalled 0.13.0 first (`pip install --break-system-packages javalang==0.13.0`), per the standing rule.
- Register script written + run: `tools/mindustry_godot_transpiler/register_c06_unit_assembler_payload_should_consume.py`. Ledger N2132 written; symbol `source_unit_factory_should_consume_state_result.payload_efficiency` rule reworded to the live read + tests extended to 8 (4 N2124 + 4 N2132). **SSOT verified: 11256 / 1583 / 1504 / 2799, audit 1335** — exactly as expected.
- Gate wiring implemented in `SourceUnitFactoryBuildState.gd`: assembler branch now calls `source_unit_factory_assembler_payload_state(frame, plan)` and reads its `payload_efficiency` (same pattern as `item_eff`); the two comments updated (deferred-conjuncts comment: only `Units.canCreate` stays deferred; payload-state comment: wired since N2132).
- N2129 test module flipped (`assertNotIn` → `assertIn` on the gate call) + comment updated.
- Proof keys updated in `C06UnitFactoryShouldConsumeProof.gd`: 4 renames + 1 new key (42 → 43 keys).
- **Targeted tests GREEN 12/12 in 73.1s** (N2132 4/4 + N2129 4/4 + N2124 4/4, Godot on PATH). First attempt 11/12: the N2132 proof test failed only on the `ERROR:` assert — a concurrent C06DefenseProofDebug scene from another thread held port 7777 at that moment (that thread has since PROVEN the defense flake cause: per-shot random inaccuracy ±2°, see MEMORY.md). The proof JSON itself was already `matches: true` with all 43 keys true, including the 5 new keys; re-run with the port free passed clean.
- `git diff --check` clean.
- **Full gate STARTED ~11:22 +07, detached via `setsid nohup python3 -m unittest discover -s tests`, PID 3079 (own session SID 3079), log `tools/mindustry_godot_transpiler/full-suite-n2132-gate.log`, no Godot on PATH.** Expected ~16 min → done ~11:38 +07; expected **Ran 5625, FAILED (failures=83, skipped=5), 0 errors** — all 83 `assertIsNotNone(godot)` (82 inherited + the new N2132 proof test). Progress dots + F markers already in the expected shape at ~11:23. **Do NOT start another gate while PID 3079 is running; verify its result in the next run(s) before commit/push.**

## Gate attempt 1 DIED (11:30 cron run, 2026-11-12 ~11:30 +07)

- PID 3079 is gone; log froze at 04:22:50 UTC (11:22:50 +07), **3410 chars: 3346 dots + 59 F + 5 skipped, no summary** — died ~50 s after start. VM did NOT restart after the gate started (uptime 22 min at 11:30 → booted ~11:08 +07, before the 11:15 run; javalang 0.13.0 still present). No OOM in dmesg. Death point matches N2131 attempt 2 almost exactly (3407 tests, 58 F, 5 skipped) — same signature as "killed when the spawning cron session ended". The setsid detach evidently did not protect it this time (or the 11:15 run's setsid did not take effect as recorded).
- Dead-attempt log preserved as `tools/mindustry_godot_transpiler/full-suite-n2132-gate-attempt1.log`.
- **Gate RESTARTED ~11:31 +07 (attempt 2): `setsid nohup python3 -m unittest discover -s tests`, fresh log `full-suite-n2132-gate.log`, no Godot on PATH. Verified detached: PID 4326, PPID 1, SID 4326 (own session leader), log growing (178 → 564 bytes in ~40 s).** Expected done ~11:47 +07; expected Ran 5625, failures=83, skipped=5, 0 errors, all `assertIsNotNone(godot)`. **Do NOT start another gate while PID 4326 is running; verify its result in the next run(s) before commit/push.**

## Gate attempt 2 VERIFIED CLEAN (12:00 cron run, 2026-11-12 ~12:00-12:01 +07)

- PID 4326 finished ~12:01 +07 (log `tools/mindustry_godot_transpiler/full-suite-n2132-gate.log`): **Ran 5625 tests in 1767.821s, FAILED (failures=83, skipped=5), 0 errors** — exactly as expected. All 83 failures verified individually as Godot-absent asserts: 82 × plain `assertIsNotNone(godot)` + 1 × `assertIsNotNone(godot, 'Godot required for hydration proof')` (the pre-existing hydration test). Zero non-Godot failures, zero errors. The N2132 module contributes only its proof test (`test_reference_graph_and_actual_c06_unit_assembler_payload_should_consume`); its 3 non-proof tests pass, as do the flipped N2129 module's non-proof tests.
- Attempt 2 ran 29.5 min (vs ~16 min for earlier gates) — slower, not stuck; it was still at 5337/5625 tests at 12:00 and finished ~1 min later. No action needed.
- Gate clean except Godot → step 7 below (report + spec + commit/push) proceeds in this run.

## GREEN work remaining (next run)

1. ~~Write + run the register script: ledger N2132 entry + registry symbol rule/tests update; SSOT 11256 / **1583** / 1504 / 2799, audit 1335.~~ **Done 11:15 run.**
2. ~~Implement the gate wiring + the two comment updates in `SourceUnitFactoryBuildState.gd`.~~ **Done 11:15 run.**
3. ~~Flip the N2129 test module's gate assertion (`assertNotIn` → `assertIn`) + comment.~~ **Done 11:15 run.**
4. ~~Update the proof keys in `C06UnitFactoryShouldConsumeProof.gd` (4 renames + 1 new key; 42 → 43 keys).~~ **Done 11:15 run.**
5. ~~Targeted tests GREEN 4/4 (Godot on PATH).~~ **Done 11:15 run — 12/12 across N2132+N2129+N2124.**
6. Full Python gate (210 modules) — **ATTEMPT 1 (PID 3079) DIED ~11:22:50 +07, ~50 s after start, log froze at 3410 chars (3346 dots + 59 F + 5 skipped), no summary; VM did not restart, no OOM. ATTEMPT 2 (PID 4326, ~11:31) FINISHED ~12:01 +07: Ran 5625 in 1767.821s, FAILED (failures=83, skipped=5), 0 errors — all 83 verified Godot-proof asserts (82 plain + 1 hydration variant), zero real failures. Gate clean except Godot.** Verified in the 12:00 run.
7. ~~When the gate is verified clean except Godot: report + design-spec N2132 row + Status Summary 1582→1583 + changelog row + this handoff, then commit + push to the fork (origin main) only when the slice is fully done.~~ **Done in the 12:00 run — see reports/2026-11-12-c06-unit-assembler-payload-should-consume.md; commit + push below.** Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`, gate logs, or the Windows queue doc).

## Next (after N2132 lands)

- `checkTier` from the module tiers (UnitAssembler.java:360-376) — next in the C06 order.
- Then: battery live `enabled` stamp, disabled-belt efficiency half, unit-factory shouldConsume wiring to the power stamp, live production wiring (progress + call at completion).

## Deferred (not this slice)

- `checkTier` from the module tiers (UnitAssembler.java:360-376).
- Live production wiring: progress advance + the call at completion (UnitFactory.java:401-403, Reconstructor.java:330-348, UnitAssembler.spawned()), plus the intake call site (`moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- Unit-factory frames' per-class shouldConsume wiring to the power stamp; battery live `enabled` stamp; disabled-belt efficiency half.
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Commit

Committed + pushed to origin main (fork Lasthope1508) in the 12:00 cron run — see the commit for the hash. Gate verified clean except Godot (Ran 5625, failures=83, skipped=5, 0 errors, all Godot-proof).
