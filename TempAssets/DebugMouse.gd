extends Polygon2D


func _physics_process(delta):
	global_position = get_viewport().get_mouse_position()/4
