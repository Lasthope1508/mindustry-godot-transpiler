extends RefCounted
class_name SourceStatusDefaults

const STATUS_EFFECT_NONE := "StatusEffects.none"
const STATUS_FIELD_EXPR := "public StatusEffect status = StatusEffects.none;"
const STATUS_DURATION_FIELD_EXPR := "public float statusDuration = 300;"
const STATUS_APPLY_METHOD := "public void apply(StatusEffect effect, float duration){\n        if(effect == StatusEffects.none || effect == null || isImmune(effect)) return; //don't apply empty or immune effects\n    }"
const STATUS_APPLY_RESULT_METHOD := "public void apply(StatusEffect effect, float duration){"
const STATUS_APPLY_RESULT_GUARD := "if(effect == StatusEffects.none || effect == null || isImmune(effect)) return;"
const STATUS_APPLY_RESULT_WEAPON_SHOOT_STATUS_FIELD := "public StatusEffect shootStatus = StatusEffects.none;"
const STATUS_APPLY_RESULT_WEAPON_DURATION_FIELD := "public float shootStatusDuration = 60f * 5f;"
const STATUS_APPLY_RESULT_WEAPON_CALL := "unit.apply(shootStatus, shootStatusDuration);"
