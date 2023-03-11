class_name Bullet
extends Node2D

var _damage : int = 0
var _speed : float = 0.0
var _direction : Vector2 = Vector2.ZERO
var _lifetime : float = 0.0

#array to hold refs to pertinent Effects - cannot be statically typed in 3.x, inherently dangerous!
var effects : Array

#standard bullet behavior, can be overridden

func _process(_delta) -> void:
	#countdown to lifetime.
	_lifetime -= _delta
	if _lifetime <= 0.0:
		destroy()

func _physics_process(_delta) -> void:
	#typical behavior sends the bullet towards its current direction at speed
	
	#todo: run functions from player Effects here
	
	global_position += _direction * _speed * _delta
	rotation = _direction.angle()
	pass

func spawn(new_position:Vector2, damage:int=0, speed:float=1.0, life:float=1.0) -> void:
	#the position argument must be global!
	self.position = new_position
	_damage = damage
	_speed = speed
	_lifetime = life
	#todo: load in references to player Effects here
	#todo: onload effects here
	pass

func destroy() -> void:
	#under most circumstances, this should be called in lieu of queue_free
	queue_free()
	pass

#setters
#func set_position(position) -> void:
#	self.position = position
func set_direction(direction:Vector2) -> void:
	_direction = direction
func set_lifetime(lifetime:float) -> void:
	_lifetime = lifetime
func set_damage(damage:int) -> void:
	_damage = damage
func set_velocity(speed:float) -> void:
	_speed = speed


func _on_Bullet_body_entered(_body):
	if _body is Actor and _body.is_in_group("enemy"):
		_body.health = _body.health - _damage
	destroy()
