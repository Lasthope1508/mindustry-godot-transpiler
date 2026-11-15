# N2230 TractorBeamTurret updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-3, coordinator lượt 4).

## What this slice did

- TractorBeamTurret activation/retarget/coolant/look-at/strength/damage/impulse as a pure advance in `SourceTractorBeamTurretBuildState.gd` (TractorBeamTurret.java:78-139 + Units.closestEnemy :296-313). ClosestEnemy priority rules ported faithfully (higher priority wins even if farther; equal priority needs strictly closer; dst2 minus hitSize²).
- 11 result symbols; driver passes `retarget_tick=false`, `candidates=[]` live (no timer helper, no live query — cadence + scan deferred).

## Key facts for the next agent

- **Eff ordering trap**: eff/edelta are computed at :84 BEFORE the coolant branch (:92-106) — this tick uses the OLD multiplier; the proof pins it.
- **coolantMultiplier has NO reset** — the build field is only written at :75 (init 1f) and :105; the block-level field (BaseTurret :32/:46) is a DIFFERENT field read only by ReloadTurret.
- **Coolant is null for parallax — confirmed** (no ConsumeCoolant consumer; the `:3638` coolant line belongs to the block before parallax).
- Def parallax constants beat class defaults: force 16f, scaledForce 9f, damage 0.5f, rotateSpeed 12 (Blocks.java:3640-3653). targetAir=true, targetGround=false → flying only.
- **The 17 `SourceTractorBeamTurretBuildUpdateTile*State.gd` files are DEAD for live gameplay** (only linked to each other; PortGame has 0 "tractor" matches; driver preloads none). NOT modified. Do NOT delete without user approval.
- Register: 102 exact exprs, 0 missing. DEFERRED: 260 (260 − 1 + 1 new merged live-fill entry).
- Slice commit `57ec6873` (branch `slice/N2230-tractor-beam-update-tile`, đã push 17:42); integration cherry-pick `1b785fdb`; SSOT gộp `b5129382` (11568/1675/1598/2987).

## Godot debt (this slice)

- `C07TractorBeamUpdateTileProof` — 8 keys (6 scope + live_tick + coolant). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
