# Handoff N2478 — BeamDrill canPlaceOn / drawPlace rows

## What this slice did

TWO pure-only pures (no tick wiring): `source_beam_drill_can_
place_on_state` → {can_place_on} + `source_beam_drill_draw_
place_state` → {dash_lines, speed_text, icon, tier_req_text}
(call records; bundle KEYS, not rendered values). 5 files,
+1344/−3, commit `2b301e11f` on
`slice/N2478-beam-drill-can-place-on-draw-place-rows`.

## Key facts for the next agent

- **invalidItem is the LAST unmineable drop** (overwrites every
  time — the brief said first, wrong).
- **item is the LAST found across lasers, NOT nulled when
  multiple** (unlike updateFacing :408-410) — speed text keeps
  the full count, only the icon is suppressed.
- **Dash length has NO off-by-one** (j is the solid tile's own
  index); **the walk is a WHILE loop** (GDScript for leaves j
  = n−1, Java leaves j == range).
- Dash endpoints: raw tile coords × tilesize (no offset); icon
  dx/dy use the Block offset (4.0 size-2, 0.0 size-3).
  tilesize Java 8; iconSmall/4f = 6.0. Tier-req text carries
  valid=false HARDCODED.
- Origins from the N2346 laser-origins pure (no second copy).
- SSOT +5/+1/+2/+4 (symbols +2 over est). DEFERRED #234
  resolved + 1 new entry (live placement call site, 234→234).

## Godot debt (this slice)

- NEW proof `C07BeamDrillCanPlaceOnDrawPlaceProof` (6 keys) —
  never run.
