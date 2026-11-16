# Handoff N2388 — Separator sense rows (sense-only)

## What this slice did

New pure `source_separator_sense_state` — progress as-is, NO clamp;
other sensors delegate via caller-supplied `super_value`. Pure-only.
**canDump does NOT land** (no Separator itemFilter modeled). 5
files, +897/−1, commit `aefb3fd60` on
`slice/N2388-separator-sense-rows`.

## Key facts for the next agent

- **Progress as-is, NO clamp** — 1.5 stays 1.5 (unlike
  MendProjector).
- **canDump waits for an itemFilter model:** `consumesItem(item)` =
  `itemFilter[item.id]` (Block.java:774-776); the port has only the
  generic `consumes_item_state` (caller-supplied filter); the
  separator def has no `consumeItem` (Blocks.java:1231-1246).
- SSOT +2/+1/+1/+2. DEFERRED #38 REWRITTEN IN PLACE (canDump-only
  remains) — count stays 306.
- Future slice: model the Separator itemFilter (separator:
  all-false; disassembler: scrap-only), then canDump can land.

## Godot debt (this slice)

- NEW proof `C07SeparatorSenseRowsProof` (6 keys) — never run.
