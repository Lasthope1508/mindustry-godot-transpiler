extends RefCounted
class_name SourceTurretAccuracyState

const SOURCE_TURRET_TOTAL_INACCURACY_EXPR := "inaccuracy + type.inaccuracy"

static func total_inaccuracy(turret_inaccuracy: float, bullet_inaccuracy: float) -> float:
	return turret_inaccuracy + bullet_inaccuracy
