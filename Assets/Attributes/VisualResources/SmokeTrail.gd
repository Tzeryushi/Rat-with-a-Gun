extends Line2D

@export var limited := false
@export var trail_length = 15

#@onready var decay_tween : Tween = get_tree().create_tween()

var lifetime := [1.0, 2.0]

var hit : bool = false

func _ready() -> void:
#	if limited:
#		start_tween()
	pass

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

#func start_tween() -> void:
#	decay_tween.tween_property(self, "modulate:a", 0.0, randf_range(lifetime[0], lifetime[1])).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
#	await decay_tween.finished
#	queue_free()
