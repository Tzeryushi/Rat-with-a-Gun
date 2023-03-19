extends Line2D

@export var limited := false
@export var trail_length = 15

var hit : bool = false

func _process(delta) -> void:
	global_position = Vector2.ZERO
	global_rotation = 0
	if hit:
		if get_point_count() != 0:
			remove_point(0)
	else:
		var point : Vector2 = get_parent().global_position
		add_point(point)
		while get_point_count() > trail_length:
			remove_point(0)
