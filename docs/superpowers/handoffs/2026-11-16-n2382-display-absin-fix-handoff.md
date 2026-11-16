# Handoff N2382 — Display-path absin fix (Mend + Overdrive)

## What this slice did

Fix slice: `50.0/PI2` → `100.0/PI2` in
`SourceMendProjectorDisplayState.gd:86` +
`SourceOverdriveProjectorDisplayState.gd:69`, 2 pins updated in
`test_playable.py`, + 1 arithmetic pin test. 3 files, +34/−4,
commit `0bc32f127` on `slice/N2382-display-absin-fix`.

## Key facts for the next agent

- **Java absin doubles the scale:** `absin(in,scl,mag) =
  (sin(in, scl*2f, mag)+mag)/2f` (Mathf.java:78-80), so the port
  helper needs the DOUBLED scale: helper(v, 100/PI2) ≡ Java
  absin(v, 50/PI2).
- Overdrive Java:145 verified to use the SAME 50f/PI2 scale as
  Mend Java:152 — both files fixed.
- SSOT +0, no proof, no re-run (the only `top_alpha` proof hit
  pins the hidden branch only).
- Closes the N2372 follow-through item.

## Godot debt (this slice)

- None.
