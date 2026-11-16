# Handoff N2325 — RegenProjector mendMap flush

## What this slice did

Ported the RegenProjector mendMap flush: the advance reports
heal_applications + clears the map + stamps last_update_frame when the
frame last_update_frame differs from update_id. 6 files, +1032/−45,
commit `7cd2d224` on `slice/N2325-regen-projector-update-tile`.

## Key facts for the next agent

- ⚠️ **SCOPE PREMISE WAS WRONG** — the RegenProjector updateTile advance
  already existed from N2228 (741652ea) and consume was live from N2260;
  the scope asked for a "full advance" that was already there. N2325 is
  only the flush. **Lesson: scope must verify the real driver, not trust
  DEFERRED blindly.**
- Flush Java: `if(lastUpdateFrame != state.updateId){ ... build.heal(
  entry.value); ... mendMap.clear(); }` (RegenProjector.java:166–177);
  lastUpdateFrame static −1 (:24), updateId incremented once per logic
  update (Logic.java:512).
- The flush sits OUTSIDE the efficiency gate — it fires even at efficiency
  0; a suppressed tick does not flush.
- The tick write-backs the flushed amounts on the frame and applies
  NOTHING to the target buildings yet — the live heal application still
  defers.
- Schema/contract N2228 extended in place 9→11 keys (flush keys ride the
  existing advance contract — no new contract). SSOT +2/+1/+0/+0 (NOT the
  +8 SCOPE estimate).
- **The N2228 proof was updated in this slice** (follow-through): 7
  accumulation calls seed last_update_frame 0 / update_id 0; the live-tick
  key was REWRITTEN with a damaged copper-wall neighbour + hydrogen 1.0 +
  1 phaseFabric — that key was ALREADY stale before N2325.
- The N2228 proof header ("consume() defers") was still wrong since N2260
  — the coordinator fixed it at integration (ded46b85, comment-only).
- DEFERRED 325→327 (+2: #163 rewritten in place + 2 new entries).

## Godot debt (this slice)

- NEW proof `C07RegenProjectorMendMapFlushProof` (5 keys) — never run.
- RE-RUN of N2228 proof `C07RegenProjectorUpdateTileProof` (live-tick key
  rewritten + accumulation seeds changed) — never run.
