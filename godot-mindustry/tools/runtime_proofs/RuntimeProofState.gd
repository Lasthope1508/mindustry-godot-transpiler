class_name RuntimeProofState

static func proof_path(proof_name: String) -> String:
	return ProjectSettings.globalize_path("res://tools/runtime_proofs/" + proof_name + ".json")

static func proof_label(proof_name: String) -> String:
	return proof_name.to_snake_case().to_upper()

static func write_proof(proof_name: String, proof: Dictionary) -> String:
	var proof_json := JSON.stringify(proof)
	print(proof_label(proof_name) + " " + proof_json)
	var proof_file := FileAccess.open(proof_path(proof_name), FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
		proof_file.close()
	return proof_json

static func exit_code(proof: Dictionary) -> int:
	return 0 if bool(proof.get("matches", false)) else 1
