extends RefCounted
class_name SourceGameWaveState


static func source_game_wave_run_state(wave: int, wave_spacing: float, is_campaign: bool, wave_time_multiplier: float) -> Dictionary:
	# Logic.runWave() (Logic.java:319-325): the 4 body exprs
	# only. The wavetime formula in play()
	# (Logic.java:272, with initialWaveSpacing + `* 2`)
	# is NOT in this slice, nor is skipWave()
	# (Logic.java:315-317, a later 1-expr slice once
	# runWave lands) nor `state.stats.wavesLasted =
	# state.wave;` from gameOver() (Logic.java:434, a
	# different method).
	# `spawner.spawnEnemies();` -- WaveSpawner is not
	# ported on either line (WaveSpawner.java unscanned,
	# method WaveSpawner 0-hit both ledgers); recorded
	# as spawn_enemies data until a WaveSpawner slice
	# lands.
	# `state.wave++;`
	# `state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);`
	# `Events.fire(new WaveEvent());` -- no event bus in
	# the port (method Events.on 0-hit both ledgers);
	# recorded as fired_event data; event-bus design is
	# a separate main-thread decision.
	var next_wave: int = wave + 1
	var wavetime: float = wave_spacing * (wave_time_multiplier if is_campaign else 1.0)
	return {"wave": next_wave, "wavetime": wavetime, "spawn_enemies": true, "fired_event": "WaveEvent"}


static func source_game_wave_skip_state(wave: int, wave_spacing: float, is_campaign: bool, wave_time_multiplier: float) -> Dictionary:
	# Logic.skipWave() (Logic.java:315-317): the 1 body expr
	# only -- `runWave();` (:316). skipWave forwards to
	# runWave() (Logic.java:319-325, owned N2437); the
	# envelope adds skipped_wave: true to runWave's 4
	# result keys. The forward precedent is N2422
	# (LaserTurretBuild.placed() forwarding to
	# super.placed()).
	var result: Dictionary = source_game_wave_run_state(wave, wave_spacing, is_campaign, wave_time_multiplier)
	return {"skipped_wave": true, "wave": result["wave"], "wavetime": result["wavetime"], "spawn_enemies": result["spawn_enemies"], "fired_event": result["fired_event"]}
