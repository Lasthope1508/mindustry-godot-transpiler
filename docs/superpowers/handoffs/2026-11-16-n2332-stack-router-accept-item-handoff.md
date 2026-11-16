# Handoff N2332 — StackRouter acceptItem intake gate

## What this slice did

Wired the StackRouter acceptItem intake gate: a new pure ports the 4-term
StackRouter OVERRIDE (not the stricter parent DuctRouter gate). 5 files,
+827/−1, commit `a19a64f4` on `slice/N2332-stack-router-accept-item`.

## Key facts for the next agent

- Pure `source_stack_router_accept_item_state(unloading, current, item,
  items, item_capacity, facing_rel, rotation)` → `{accepts}`: exactly the 4
  terms of StackRouter.java:89-93. Item compare by name string (N2225
  precedent); total via shared `inventory.items_total`.
- `facing_rel` is a precomputed int frame input (N2324 precedent) — the port
  has no live tile geometry; Edges.getFacingEdge needs a world.tile lookup.
- **No call site:** acceptItem is a gate another building calls when
  dumping/offloading (BuildingComp.java:1001-1016); the tick has no intake
  path (verified by grep over the whole driver + N2240/N2324 tests).
- Scope corrections: `relativeTo` is **Tile.relativeTo** (Tile.java:82-84),
  NOT BuildingComp.java:530 (float-position, the one target() uses); Edges
  lives in **mindustry**, not arc (Edges.java:57-60).
- Nit (pre-existing, not fixed): driver :209 cites the facing term as
  "(StackRouter.java:90)" but the term is at :92.
- SSOT +1/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED net 0 (resolved
  #100 + 1 new live fill/caller + handleItem DuctRouter.java:179-184 defer).

## Godot debt (this slice)

- NEW proof `C07StackRouterAcceptItemProof` (6 keys) — never run.
