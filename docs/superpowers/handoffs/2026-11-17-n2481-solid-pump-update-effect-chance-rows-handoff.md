# Handoff N2481 — SolidPump updateEffect chance rows

## What this slice did

One pure-only chance row (no tick wiring):
`source_solid_pump_update_effect_chance_state` → {effect_call}
— {effect: <token>, x, y} when the pump-branch gate passes and
the roll hits, null otherwise. 5 files, +857/−3, commit
`97777de7b` on `slice/N2481-solid-pump-update-effect-chance-rows`.

## Key facts for the next agent

- **NO RNG in the pure** — chance + position rolls are
  caller-supplied, already-rolled (positions ALREADY-RANGED,
  the pure never sees the size).
- **Mathf.chance: `d >= 1f || rand.nextFloat() < d`** — the
  d >= 1f short-circuit fires unconditionally; the comparison
  is STRICT < (a roll exactly at threshold misses).
- Position rolls span [-size*2f, size*2f] = [-4f, 4f] for the
  size-2 water-extractor.
- **The water-extractor def overrides NEITHER updateEffect nor
  updateEffectChance** — the live call records the Fx.none
  token; token + chance are params so a def override passes
  through verbatim.
- Pump-branch gate is caller-evaluated (the N2220 advance owns
  it; no separate gate key).
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #90 resolved
  (234→233).

## Godot debt (this slice)

- NEW proof `C07SolidPumpUpdateEffectChanceProof` (6 keys) —
  never run.
