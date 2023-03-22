class_name EndRoom
extends Room

#contains area that ends the current tower level, sometimes other things, depending on perks
#most important is the signal that the level will attach to to end the current tower
signal level_end_reached

func _on_exit_portal_entered(body):
	level_end_reached.emit()
