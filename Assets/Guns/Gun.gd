class_name Gun
extends Node2D

export var _damage : int = 1
export var _knockback : float = 100
export var _firing_speed : float = 0.5
export var _reload_time : float = 1
export var _clip_size : int = 6
export var _bullet_speed : float = 10
export var _bullet_scene : PackedScene

onready var gun_sprite := $GunSprite
onready var back_position := $BackPosition
onready var held_position := $HeldPosition
onready var muzzle_position := $MuzzlePosition

signal bullet_fired

#prototype to be inherited by other guns, structures are referenced by PlayerRat class
#initial internal data should be protected, effects and stat alterations will be returned with getter functions

#back position and held position are designated by the position nodes, and inform the sprite's position in various states

func fire() -> Bullet:
	emit_signal("bullet_fired")
	var new_bullet = _bullet_scene.instance()
	new_bullet.spawn(muzzle_position.global_position, _damage, _bullet_speed)
	return new_bullet

func reload() -> void:
	pass

func switch_held() -> void:
	#switches to "hand" position in air
	gun_sprite.scale = Vector2(1,1)
	gun_sprite.position = Vector2.ZERO - held_position.position
	
func switch_back() -> void:
	#switches to back position on ground
	gun_sprite.scale = Vector2(1,-1)
	gun_sprite.position = Vector2.ZERO + back_position.position
	pass

func get_knockback() -> float:
	#todo: factor in value changes from effects? should that be on the player?
	return _knockback

func get_muzzle_reach() -> float:
	#returns the distance between the current hold position and the muzzle
	return (muzzle_position - gun_sprite.position).length()
