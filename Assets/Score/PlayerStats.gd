extends Resource

@export var gold : int = 0
@export var combo : int = 0

signal combo_up

#increment the combo value by one
func raise_combo() -> void:
	combo += 1
