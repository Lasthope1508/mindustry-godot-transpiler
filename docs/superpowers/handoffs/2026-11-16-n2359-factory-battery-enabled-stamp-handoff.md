# Handoff N2359 — N2134 enabled stamp wired into factory runtime path

## What this slice did

Wired the N2134 battery enabled stamp pure into the factory live-loop
power update: grouped batteries are stamped BEFORE `update_state`, so
distribute + drain + stored-total all see live enabled. 5 files, +771,
commit `1463f85a0` on `slice/N2359-factory-battery-enabled-stamp`.

## Key facts for the next agent

- Placement BEFORE `update_state` (not after `updated_batteries:1087`)
  — the pre-update stamp flows into distribute + drain:1122 +
  stored:1172 and covers the cheat branch (proof pins it with
  cheat-branch keys).
- Java-exact side effect: distribute now gates on live enabled
  (PowerGraph.java:163/:180).
- SSOT +0/+1/+0/+0 (reuses 4 N2134 symbols — the validator only
  requires a NON-EMPTY `source_symbols` list). DEFERRED net 0.
- Standing limitation: in the real game `block_from_sprite` returns a
  catalog entry (no live enabled), so the stamp keeps the static
  value; live enabled for real battery buildings is a separate slice.

## Godot debt (this slice)

- NEW proof `C07FactoryBatteryEnabledStampProof` (9 keys) — never run.
