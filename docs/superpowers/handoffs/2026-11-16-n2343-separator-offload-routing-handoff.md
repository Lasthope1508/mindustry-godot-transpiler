# Handoff N2343 — Separator offload neighbor routing

## What this slice did

Routed Separator offload picks to the first accepting neighbour from the
cdump cursor (the proximity scan in offload()). 13 files, +1652/−10,
commit `208b72fd` on `slice/N2343-separator-offload-routing`.

## Key facts for the next agent

- Pure `source_separator_offload_routing_context_state(neighbour_accepts,
  neighbour_can_dump, dump_cursor)` → `{neighbors, dump_cursor}`. Cursor
  invariant (N2286): a routed pick leaves the cursor past the handler; a
  full refused scan returns it to the start.
- **Advance fix:** a context without dump_cursor now defaults it from
  frame cdump (the old default-{} path clobbered a nonzero frame cursor
  on every context-less craft).
- REUSED the N2281 dump frame inputs (`dump_neighbour_accepts` /
  `dump_neighbour_can_dump`) — Java has ONE proximity list; no synonym
  pair (AGENTS.md rule). Mismatched arrays → scan the longer array,
  missing = false.
- Cites: offload() is BuildingComp.java:1001-1015; `other.handleItem` is
  :1009 (not :1011).
- DEFERRED net 0 (resolve #154 + 1 new: offload neighbour write-back).
  SSOT +2/+1/+1/+2 (pure returns 2 keys).
- N2222 + N2281 test pins updated (7-arg → 8-arg advance call); NO re-run.

## Godot debt (this slice)

- NEW proof `C07SeparatorOffloadRoutingProof` (6 keys) — never run.
