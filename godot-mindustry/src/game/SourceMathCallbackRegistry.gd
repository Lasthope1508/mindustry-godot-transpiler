extends RefCounted
class_name SourceMathCallbackRegistry

# Canonical callback identifiers for shared Arc/Mathf helpers.
const APPROACH_DELTA_KEY := "approach_delta"
const MATHF_APPROACH_DELTA_FALLBACK := "source_mathf_approach_delta"
const LERP_DELTA_KEY := "lerp_delta"
const MATHF_LERP_DELTA_FALLBACK := "source_mathf_lerp_delta"
const ARC_LERP_DELTA_FALLBACK := "source_arc_lerp_delta"
const MATHF_DST_KEY := "mathf_dst"
const MATHF_DST_FALLBACK := "source_mathf_dst"

# These callbacks use different argument contracts, so their fallback aliases stay distinct.
const VEC2_LIMIT_KEY := "vec2_limit"
const ARC_VEC2_LIMIT_FALLBACK := "source_arc_vec2_limit"
const VECTOR_STATE_LIMIT_FALLBACK := "source_vec2_limit"
