# Handoff N2371 — Liquid neighbour write-back helper + Fracker dumpLiquid wiring

## What this slice did

The shared liquid neighbour write-back helper (mirror of the N2353
item helper), the shared routing reporting `handled_index`, and the
Fracker dumpLiquid wiring. 10 files, +1375/−15, commit `c10447a62` on
`slice/N2371-liquid-neighbour-write-back`.

## Key facts for the next agent

- **Conduit has NO queue** — the belt analogy is wrong. Conduit never
  overrides handleLiquid; the default `liquids.add` lands in its
  LiquidModule on the sprite meta. Conduit path writes the meta store.
- **FOUR Conduit-class defs** (conduit / pulse-conduit / plated-conduit
  / reinforced-conduit, Blocks.java:2322/2329/2337/2410). Detection is
  frame-meta OR block id.
- **handled_index needs handle AND flow** (flow is computed before the
  accept guard :915-917; a full neighbour handles a zero flow).
- **Multi-recipient deviation:** a dump reaching several neighbours
  reports only the FIRST handled index — the write-back lands the
  total there; the per-neighbour split is deferred.
- Preload cycles: frame-key list from runtime `load()`, conduit key a
  local const.
- SSOT +6/+1/+1/+2 (exactly as estimated). DEFERRED 319→319 (−1
  Fracker write-back + 1 liquid follow-ups entry; stale N2363 base —
  merge by entry TEXT).
- The Fracker schema/contract fold landed in N2376 (the routing fold
  was done in this slice's owning-register update).

## Godot debt (this slice)

- NEW proof `C07LiquidNeighbourWriteBackProof` (7 keys) — never run.
- Follow-through: Pump #257, SolidPump #260, LiquidBridge #263,
  PayloadUnloader #276 wirings (next wave — the routing already
  reports `handled_index` for all of them); multi-recipient split;
  core store mapping.
