# Handoff N2299 — UnitAssemblerModule acceptPayload + link Assembler gate

## What this slice did

Ported the module gate (UnitAssemblerModule.java:110-111) and the link Assembler gate
(UnitAssembler.java:722-727) as 2 pures:
`source_unit_assembler_module_accept_payload_state` → 4 outputs and
`source_unit_assembler_accept_payload_state` → 5 outputs. The tick exposes
`frame["accepts_payload"]` / `frame["link_accepts_payload"]` AFTER the advance, even
when disabled. Commit `48d2bd72`
(`slice/N2299-unit-assembler-module-accept-payload`).

## Key facts for the next agent

- DEFERRED entry 51's cite was WRONG twice: the file is in `world/blocks/units/`
  (not `payloads/`), and the gate is :110-111 (:125-127 is inside `onRemoved`).
- The quota rounds via arc `Mathf.round` (BIG_ENOUGH trick = floor(x+0.5)), NOT
  `java.lang.Math.round` — same on the non-negative domain, so `roundi` is correct.
- Java accepts when ANY matching plan requirement passes the count check
  (any-match verdict); the `quota` key reports the FIRST matching requirement's quota
  (agrees in practice: 1 stack/content per def).
- `source_is_module` is always true (the module calls `link.acceptPayload(this,
  payload)`). The −1 adjustment applies when the source is a module AND the assembler
  already holds an equal payload.
- The N2248 handoff gate is NOT fed by the new verdicts yet (new DEFERRED entry).
- Pre-existing drift (flagged, not fixed): driver header cites `acceptsPayload =
  true;` at :27, real line :28.
- DEFERRED entry 51 resolved; the updateTile live fill entry reworded. SSOT
  +9/+1/+2/+4 → 11897/1744/1679/3150.

## Godot debt (this slice)

Proof `C07UnitAssemblerModuleAcceptPayloadProof` (6 keys) — written, NEVER run on
this VM. See GOAL.md §5. Run targeted test
`tests.test_c07_unit_assembler_module_accept_payload` with Godot 4.6.2 on PATH, port
7777 free.
