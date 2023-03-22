class_name StartRoom
extends Room

#start room will spawn certain perks and the like later on

#returns global spawn point for room
func get_spawn_point() -> Vector2:
	return entrance_pos.global_position
