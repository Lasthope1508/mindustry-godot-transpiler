# Handoff N2452 — Accelerator getCursor rows

## What this slice did

One pure-only pure `source_accelerator_get_cursor_state` (no tick
wiring): can_launch (existing N2271 gate + env half) + cursor
(hand / super-hand / arrow). The gate is caller-supplied from the
existing can_launch pure — not recomputed. 5 files, commit
`4847a6b24` on `slice/N2452-accelerator-get-cursor-rows`.

## Key facts for the next agent

- **configurable = true confirmed** (Accelerator.java:77) — the
  super-hand branch is live for this def when interactable.
- **Cite correction:** getCursor is :243-246 (the #251 entry's
  ":242-244" is off by one; :242 is blank).
- SSOT +2/+1/+1/+2 (exact est). DEFERRED #251 resolved (258→257).

## Godot debt (this slice)

- NEW proof `C07AcceleratorGetCursorRowsProof` (6 keys) — never
  run.
