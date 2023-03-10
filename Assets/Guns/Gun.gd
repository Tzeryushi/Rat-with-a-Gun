class_name Gun
extends Node2D

@export var _damage : int = 1
@export var _knockback : float = 100
@export var _firing_speed : float = 0.5
@export var _reload_time : float = 1
@export var _clip_size : int = 6
@export var _spread : float = 1.0
@export var _hold_length : float = 10
@export var _bullet_speed : float = 10
@export var _bullet_scene : PackedScene

@onready var gun_sprite := $GunSprite
@onready var back_position := $BackPosition
@onready var held_position := $HeldPosition
@onready var muzzle_position := $MuzzlePosition

var _held : bool = false

signal bullet_fired

#prototype to be inherited by other guns, structures are referenced by PlayerRat class
#initial internal data should be protected, effects and stat alterations will be returned with getter functions

#back position and held position are designated by the position nodes, and inform the sprite's position in various states

func _process(_delta):
#	if gun_sprite.rotation > PI/2 or gun_sprite.rotation < -PI/2:
#		gun_sprite.scale = Vector2(1,-1)
#	else:
#		gun_sprite.scale = Vector2(1,1)
	pass

func fire() -> Bullet:
	emit_signal("bullet_fired")
	var new_bullet = _bullet_scene.instantiate()
	#new_bullet.spawn(global_position+get_gun_rotation()*get_muzzle_reach(), _damage, _bullet_speed)
	new_bullet.spawn(global_position+get_gun_rotation()*get_muzzle_reach(), _damage, _bullet_speed)
	return new_bullet

func reload() -> void:
	pass

func switch_held() -> void:
	#switches to "hand" position in air
	_held = true
	#gun_sprite.scale = Vector2(1,1)
	gun_sprite.flip_v = false
	#set held gun distance and rotation point
	gun_sprite.offset = Vector2.ZERO - held_position.position/abs(gun_sprite.scale)
	gun_sprite.offset = (gun_sprite.offset+Vector2.RIGHT*_hold_length/abs(gun_sprite.scale))
	
func switch_back() -> void:
	#switches to back position on ground
	_held = false
	gun_sprite.flip_v = true
	gun_sprite.offset = Vector2.ZERO + back_position.position/abs(gun_sprite.scale)

func flip_gun_sprite_horizontal(value:bool) -> void:
	#flips the gun sprite if true, unflips if false
	#this is done through sprite scale as the sprite is flips around its offset, flipv simply flips the sprite in place
	if value:
		gun_sprite.scale.x = -abs(gun_sprite.scale.x)
	else:
		gun_sprite.scale.x = abs(gun_sprite.scale.x)

func flip_gun_sprite_vertical(value:bool) -> void:
	#flips the gun sprite if true, unflips if false
	#this is done through sprite scale as the sprite is flips around its offset, flipv simply flips the sprite in place
	if value:
		gun_sprite.scale.y = -abs(gun_sprite.scale.y)
	else:
		gun_sprite.scale.y = abs(gun_sprite.scale.y)

func get_knockback() -> float:
	#todo: factor in value changes from effects? should that be on the player?
	return _knockback

func get_muzzle_reach() -> float:
	#returns the distance between the current hold position and the muzzle
	return ((Vector2.RIGHT*_hold_length+muzzle_position.position-held_position.position)*scale).length()

func get_gun_rotation() -> Vector2:
	return Vector2(cos(gun_sprite.rotation), sin(gun_sprite.rotation))

func is_held() -> bool:
	return _held
