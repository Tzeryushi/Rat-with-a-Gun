extends Node2D

@export var acceleration : float = 500.0
@export var max_speed : float = 100.0

var velocity = Vector2.ZERO #this is simply where we start out when initializing


func _process(delta) -> void:
	var direction = sign(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	velocity.x = move_toward(velocity.x, max_speed*direction, acceleration*delta)
	global_position.x += velocity.x*delta
	
