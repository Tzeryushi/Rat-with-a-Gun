class_name Gun
extends Node2D

@export var _damage : int = 1
@export var _knockback : float = 1200
@export var _firing_speed : float = 0.5
@export var _reload_time : float = 1
@export var _clip_size : int = 6
@export var _spread : float = 1.0
@export var _shake_strength : float = 4.0
@export var _shake_length : float = 0.2
@export var _hold_length : float = 10
@export var _bullet_speed : float = 1000
@export var _bullet_scene : PackedScene
@export var _flare_scene : PackedScene
@export var _smoke_scene : PackedScene

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
signal firing_started(time:float)
signal firing_finished
signal bullets_in_clip_updated(bullets:int)
signal bullet_fired(bullet:Bullet)
signal clip_emptied
signal flare_fired
signal reloaded_when_clip_full

#prototype to be inherited by other guns, structures are referenced by PlayerRat class
#initial internal data should be protected, effects and stat alterations will be returned with getter functions

#back position and held position are designated by the position nodes, and inform the sprite's position in various states

func _ready():
	bullets_in_clip_updated.emit(_bullets_in_clip)

func _process(_delta):
	#will potentially handle gun rotation here in the future
	pass

func fire() -> Bullet:
	#instantiates loaded bullet, returns ref
	#this will remove a bullet from the clip and start the firing speed timer
	_fire_rate_timer()
	#TODO: update conditional with clip check
	set_bullets_in_clip(_bullets_in_clip-1)
	if (_bullets_in_clip < 1):
		clip_emptied.emit()
	var new_bullet : Bullet = _bullet_scene.instantiate()
	#new_bullet.spawn(global_position+get_gun_rotation()*get_muzzle_reach(), _damage, _bullet_speed)
	new_bullet.spawn(global_position+get_gun_rotation()*get_muzzle_reach(), _damage, _bullet_speed)
	
	#firing particles
	_emit_flare()
	_emit_dust()
	Shake.shake(_shake_strength, _shake_length)
	
	#emit signal and return bullet ref
	bullet_fired.emit(new_bullet)
	return new_bullet

func reload() -> void:
	#begins reload, yields until reload time passes
	#emits signal upon beginning and end to interface with UI
	#by design this does not directly interact with checks to shoot, but does affect is_shot_ready
	if _reloading:
		return
	if is_clip_full():
		reloaded_when_clip_full.emit()
	#TODO: update to not use base variables
	_reloading = true
	reload_started.emit(_reload_time)
	await get_tree().create_timer(_reload_time).timeout
	_reloading = false
	set_bullets_in_clip(_clip_size)
	reload_finished.emit()

func _fire_rate_timer() -> void:
	_fire_restricted = true
	firing_started.emit(_firing_speed)
	await get_tree().create_timer(_firing_speed).timeout
	_fire_restricted = false
	firing_finished.emit()

func _emit_flare() -> void:
	var flare_particles : ParticleAnimation = _flare_scene.instantiate()
	add_child(flare_particles)
	flare_particles.position = Vector2.RIGHT*get_muzzle_reach()
	flare_particles.play()
	await flare_particles.finished
	flare_particles.queue_free()

func _emit_dust() -> void:
	var smoke_particles : ParticleAnimation = _smoke_scene.instantiate()
	add_child(smoke_particles)
	smoke_particles.position = Vector2.RIGHT*get_muzzle_reach()
	smoke_particles.play()
	await smoke_particles.finished
	smoke_particles.queue_free()

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
	return Vector2(cos(rotation), sin(rotation))

func get_bullets_in_clip() -> int:
	return _bullets_in_clip
func set_bullets_in_clip(value:int) -> void:
	if value > 0:
		_bullets_in_clip = value
	elif !_reloading:
		_bullets_in_clip = 0
	bullets_in_clip_updated.emit(value)
func add_bullet_to_clip() -> void:
	if get_bullets_in_clip() < _clip_size:
		set_bullets_in_clip(get_bullets_in_clip()+1)

func is_held() -> bool:
	return _held

func is_reloading() -> bool:
	return _reloading

func is_shot_ready() -> bool:
	#returns true when gun can shoot
	#this is limited by reload, loaded bullets, and firing speed
	return !(_fire_restricted or _reloading)

#returns if the clip is full, should be total clip size
func is_clip_full() -> bool:
	#this will need updating when clip size can change
	return _clip_size == get_bullets_in_clip()
