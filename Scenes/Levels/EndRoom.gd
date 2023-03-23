class_name EndRoom
extends Room

#contains area that ends the current tower level, sometimes other things, depending on perks
#most important is the signal that the level will attach to to end the current tower
@onready var exit_portal_area := $ExitPortal

var _check : bool = false

signal level_end_reached

#func _ready() -> void:
#	exit_portal_area.set_deferred("monitoring", false)

func start_monitoring() -> void:
	exit_portal_area.set_deferred("monitoring", true)
	await get_tree().create_timer(0.2).timeout
	exit_portal_area.set_deferred("monitoring", false)

func _on_exit_portal_entered(body):
	if body is PlayerRat:
		exit_portal_area.set_deferred("monitoring", false)
		level_end_reached.emit()
