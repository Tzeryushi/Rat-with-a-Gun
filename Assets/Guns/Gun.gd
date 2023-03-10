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
var _reloading : bool = false
var _fire_restricted : bool = false
var _bullets_in_clip : int = _clip_size

signal reload_started(time:float)
signal reload_finished
signal bullet_fired
signal clip_emptied

#prototype to be inherited by other guns, structures are referenced by PlayerRat class
#initial internal data should be protected, effects and stat alterations will be returned with getter functions

#back position and held position are designated by the position nodes, and inform the sprite's position in various states

func _process(_delta):
	#will potentially handle gun rotation here in the future
	pass

func fire() -> Bullet:
	#instantiates loaded bullet, returns ref
	#this will remove a bullet from the clip and start the firing speed timer
	_fire_rate_timer()
	#TODO: update conditional with clip check
	_bullets_in_clip += -1
	if (_bullets_in_clip < 1):
		clip_emptied.emit()
		reload()
	bullet_fired.emit()
	var new_bullet = _bullet_scene.instantiate()
	#new_bullet.spawn(global_position+get_gun_rotation()*get_muzzle_reach(), _damage, _bullet_speed)
	new_bullet.spawn(global_position+get_gun_rotation()*get_muzzle_reach(), _damage, _bullet_speed)
	return new_bullet

func reload() -> void:
	#begins reload, yields until reload time passes
	#emits signal upon beginning and end to interface with UI
	#by design this does not directly interact with checks to shoot, but does affect is_shot_ready
	
	#TODO: update to not use base variables
	reload_started.emit(_reload_time)
	_reloading = true
	print("reloading...")
	await get_tree().create_timer(_reload_time).timeout
	_reloading = false
	print("done!")
	_bullets_in_clip = _clip_size
	reload_finished.emit()

func _fire_rate_timer() -> void:
	_fire_restricted = true
	await get_tree().create_timer(_firing_speed).timeout
	_fire_restricted = false

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

func is_shot_ready() -> bool:
	#returns true when gun can shoot
	#this is limited by reload, loaded bullets, and firing speed
	return !(_fire_restricted or _reloading)
