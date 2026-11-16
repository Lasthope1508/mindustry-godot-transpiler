# Handoff N2450 — ImpactReactor bar/stats rows

## What this slice did

Two pure-only pures (N2442 precedent, no tick wiring):
`source_impact_reactor_power_bar_state` (label Dict {key, amount}
+ Pal.powerBar + fraction RAW) +
`source_impact_reactor_stats_state` (production_time_seconds +
composed warmup_time_label). New helpers _strings_fixed /
_strings_auto_fixed. 5 files, commit `fadfdb37d` on
`slice/N2450-impact-reactor-bar-stats-rows`.

## Key facts for the next agent

- **Warmup label uses bundle values** "seconds" / "power
  equilibrium" (the brief said " s " + token — wrong). Label at
  def: "115.12 seconds ~ 21.16 seconds power equilibrium".
- **Def itemDuration 140f** (overrides class 60f). Net 6300.0,
  productionTime 2.3333333s, max 115.12s, equal 21.16s.
- **power_production is caller-supplied** getPowerProduction()
  — the producer fold is DEFERRED #71, still open.
- SSOT +5/+1/+2/+4 (exact est). DEFERRED #73 resolved (258→257).

## Godot debt (this slice)

- NEW proof `C07ImpactReactorBarStatsRowsProof` (6 keys) — never
  run.
