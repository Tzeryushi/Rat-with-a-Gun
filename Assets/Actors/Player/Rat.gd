class_name PlayerRat

extends Actor

@export var first_gun : NodePath

@export var acceleration : float = 30.0
@export var max_speed : float = 600.0
@export var jump_power : float = 1400.0
@export var jump_cancel_power: float = 2000
@export var jump_gravity : float = 40
@export var stomp_power : float = 1500
@export var gravity : float = 50.0
@export var terminal_velo : float = 1500.0
@export var dash_multiplier : float = 3.0
@export var dash_time : float = 0.5
@export var jump_buffer_tolerance : float = 0.1
@export var coyote_time_tolerance : float = 0.15
@export var hurt_time : float = 0.5
@export var hurt_bounceback_force : float = 800
@export var default_invincible_time : float = 0.2
@export var landing_dust_puff_scene : PackedScene
@export var jumping_dust_puff_scene : PackedScene

@onready var current_gun : Gun = get_node(first_gun)
@onready var ground_collider := $GroundPhysicsCollider
@onready var jump_collider := $JumpPhysicsCollider
@onready var ground_hurtbox := $Hurtbox/GroundHurtbox
@onready var jump_hurtbox := $Hurtbox/JumpHurtbox
@onready var bounce_casts := $UnderCasts
@onready var jump_space_casts := $OverCasts
@onready var debug_line := $DebugLine
@onready var center_point := $Center
@onready var back_point := $Back

#var velocity := Vector2.ZERO #this is simply where we start out when initializing
var move_direction : int = 0 #keeps track of the last direction from move() input
var jump_held : bool = false #modified by states when jump is held or not, for jump buffering
var dash_completed : float = 0.0 #helps keeps track of how much dash time is left, checked by states
var jump_buffer_timer : float = 0.0 #checked by state to see if a jump has been buffered
var coyote_time : float = 0.0 #fall state checks this to see if coyote time is usable
var was_grounded : bool = false #keeps track of the grounded condition of the previous physics step
var stomped_node_reference : Node #a reference to the last entity bounced upon - will often be a null 'pointer'
var invincible : bool = false #to help future proof this, only interact using the setter/getter function
var invincible_timer : float = 0.0
var is_hurt : bool = false
var last_hurt_direction : Vector2 = Vector2.ZERO #impulse direction from last painful collision
var last_player_state : Globals.PLAYERSTATE #holds the last state type, set when exiting from a state

#player signals
signal health_changed(new_value:int, old_value:int)
signal invincibility_started
signal invincibility_finished
signal jumped

#gun signals (passed through)
signal bullet_fired(bullet:Bullet)
signal bullets_in_clip_updated(bullets:int)
signal clip_emptied
signal firing_started(time:float)
signal firing_finished
signal reload_started(time:float)
signal reload_finished

#player node accepts input, sends to state manager to get result
#states will decide if player defined functions for actions will be triggered
#basically,
#states decide what will happen with input, sends commands to player class
#player class values and methods are altered by Effects nodes
#player class executes functionality

#we do not define functionality in classes as it further erodes the ability to
#augment the player with Effects nodes, or at best makes code more obtuse

func _ready() -> void:
	state_manager.init_state(self)
	health_changed.emit(health, health)

func _unhandled_input(_event) -> void:
	state_manager.input(_event)
	
func _process(_delta) -> void:
	state_manager.process(_delta)
	
	#temporary invincible timer check
	if invincible_timer > 0.0:
		invincible_timer -= _delta
		if invincible_timer <= 0.0:
			set_invincible(false)
			
	sprite_rotations()
	
func _physics_process(_delta):
	state_manager.physics_process(_delta)
	move_and_slide()
	
	#coyote and jump buffer countdowns
	if coyote_time > 0.0:
		coyote_time -= _delta
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= _delta
	
	
#player functions

#jump
func jump() -> void:
	#simple jump, is called on multiple frames
	#velocity applied until max is reached
	velocity.y = -jump_power
	emit_signal("jumped")
	animate_jump_puff()
	
func jump_process(_delta:float) -> void:
	#quickly decreases upwards velocity until it is 0
	#velocity.y = move_toward(velocity.y, terminal_velo, gravity*_delta)
	if !jump_held:
		#velocity.y = move_toward(velocity.y, 0, jump_cancel_power*_delta)
		velocity.y = velocity.y/2
		jump_held = true
	else:
		velocity.y = move_toward(velocity.y, terminal_velo, jump_gravity)

#fall
func fall(_delta:float) -> void:
	#accelerates downwards, no jumps allowed unless there is coyote time
	velocity.y = move_toward(velocity.y, terminal_velo, gravity)

#move (used by many states)
func move(_direction, _delta:float) -> void:
	#move accelerates the player towards input direction up to max speed
	move_direction = _direction
	#flipping our player sprite
	#this might require some changes if animations are standardized, until then we utilize sprite scale
	if (_direction >= 1 or _direction <= -1) and is_grounded():
		animations.scale.x = sign(_direction)*abs(animations.scale.x)
	
	if is_grounded() and sign(_direction)!=sign(velocity.x):
		#simulated friction for grounded movement
		velocity.x = move_toward(velocity.x, max_speed*_direction, acceleration*2)
	else:
		#less reverse movement in air
		if _direction == 0:
			velocity.x = move_toward(velocity.x, max_speed*_direction, acceleration*.1)
		else:
			velocity.x = move_toward(velocity.x, max_speed*_direction, acceleration*2)
	
	#set_velocity(Vector2(velocity.x, 0.0))
	#set_up_direction(Vector2.UP)
	#move_and_slide()
	#velocity.x = velocity.x
	#global_position.x += velocity.x*_delta

#dash
func dash(_direction, _delta:float) -> void:
	#dashes in direction, will continue to do so until dash_completed is up
	#dash should preserve any prior velocity and then return to it after completion
	pass

#shoot
func shoot() -> void:
	#shoot utilizes gun system to provide acceleration to player
	#if is_grounded():
		#return
	if current_gun.get_bullets_in_clip() <= 0 and !current_gun.is_reloading():
		current_gun.reload()
		return
	#getting the vector from the center of the player
	var shot_direction_vector = get_mouse_direction()
	var shot_power = shot_direction_vector*current_gun.get_knockback()
	#resetting upward velocities to prevent rocketing and provide proper impulse when falling
	if shot_power.y > 0:
		velocity.y = -(shot_direction_vector*current_gun.get_knockback()).y
	elif shot_power.y < 0:
		velocity.y -= (shot_direction_vector*current_gun.get_knockback()).y
	velocity.x -= (shot_direction_vector*current_gun.get_knockback()).x
	
	#getting the bullet and storing it in the scene, outside of the player
	#todo: store this in a specialized container node!
	#todo: set up bullet lifetime calculations
	var bullet = current_gun.fire()
	#bullet.set_position(center_point.global_position+current_gun.get_gun_rotation()*current_gun.get_muzzle_reach())
	bullet.set_direction(shot_direction_vector.normalized())
	bullet.set_lifetime(2.0)
	get_parent().add_child(bullet)
func switch_gun_back() -> void:
	current_gun.switch_back()
	current_gun.position = back_point.position
func switch_gun_held() -> void:
	current_gun.switch_held()
	current_gun.position = center_point.position
	
#idle
func idle(_delta:float) -> void:
	#anything that needs to happen when idle
	velocity.x = move_toward(velocity.x, max_speed*0, acceleration)
#	set_velocity(Vector2(velocity.x, 0.0))
#	set_up_direction(Vector2.UP)
#	move_and_slide()
#	velocity.x = velocity.x
	#global_position.x += velocity.x*_delta

#stomp functions
func stomp() -> void:
	#when an enemy actor is stomped upon, execute
	if (move_direction >= 1 or move_direction <= -1):
		animations.scale.x = sign(move_direction)*abs(animations.scale.x)
	var stomp_multiplier = stomped_node_reference.get_stomp_strength()
	velocity.y = -stomp_power*stomp_multiplier
	
	stomped_node_reference.bounce_parent()
	add_to_gun_clip()
func stomp_process(_delta) -> void:
	#carries and reduces y velocity similarly to jump process
	velocity.y = move_toward(velocity.y, terminal_velo, jump_gravity)

func check_stomp(_delta) -> bool:
	#as long as the player is falling, they will stomp on a stompable field; rays are extended to the player velocity
	#the player body will move to the cast intersection in the physics tick
	#TODO: Add some invicibility and remove velocity truncation
	if velocity.y > 0:
		for cast in bounce_casts.get_children():
			cast.target_position = Vector2.DOWN*(velocity*_delta)
			cast.force_raycast_update()
			if cast.is_colliding() && cast.get_collision_normal() == Vector2.UP:
				#velocity.y = (cast.get_collision_point() - cast.global_position - Vector2.DOWN).y
				stomped_node_reference = cast.get_collider()
				return true
	return false

func switch_hitboxes(value:Globals.PLAYERSTATE) -> void:
	#switches which hitboxes player uses, basis of animation
	if Globals.is_aerial_state(value):
		print("val")
		#aerial hitbox active
		ground_collider.disabled = true
		jump_collider.disabled = false
		ground_hurtbox.disabled = true
		jump_hurtbox.disabled = false
	else:
		#ground hitbox active
		ground_collider.disabled = false
		jump_collider.disabled = true
		ground_hurtbox.disabled = false
		jump_hurtbox.disabled = true
			

func hurt() -> void:
	#uses vector from the last collision to determine direction bounce when hurt
	velocity = Vector2(sign(last_hurt_direction.x)*.71, -.71)*hurt_bounceback_force
	animations.scale.x = -sign(velocity.x)*abs(animations.scale.x)
	set_invincible_time(default_invincible_time)
	is_hurt = false
func hurt_process(_delta:float) -> void:
	#simulates fall and move while in hurt state (no inputs)
	velocity.x = move_toward(velocity.x, max_speed*0, acceleration/2)
	if !is_grounded():
		velocity.y = move_toward(velocity.y, terminal_velo, gravity)

func is_grounded() -> bool:
	#uses kinematicbody function to determine ground contact
	#this might merit change in the future...raycasts? unsure
	var value = is_on_floor()
	if !value and was_grounded:
		coyote_time = coyote_time_tolerance
	was_grounded = value
	return value
func is_moving_up() -> bool:
	#returns true if player velocity is moving them upwards, to prevent false landings
	if velocity.y < 0:
		return true
	return false
func is_dashing() -> bool:
	return dash_completed > 0.0
func is_shot_ready() -> bool:
	#TODO: update this with reload time
	return current_gun.is_shot_ready()

func start_jump_buffer_timer() -> void:
	jump_buffer_timer = jump_buffer_tolerance
func is_jump_buffered() -> bool:
	return jump_buffer_timer > 0.0
	
func can_coyote_jump() -> bool:
	return coyote_time > 0.0
func has_jump_space() -> bool:
	#if there is space to jump, true
	for cast in jump_space_casts.get_children():
		if cast.is_colliding() and cast.get_collision_normal() == Vector2.DOWN:
			return false
	return true

#invincibility functions
func set_invincible(state:bool=true) -> void:
	invincible = state
	if invincible:
		invincibility_started.emit()
	else:
		invincibility_finished.emit()
func set_invincible_time(time:float) -> void:
	if !invincible_timer > 0.0:
		set_invincible(true)
	invincible_timer = time
func is_invincible() -> bool:
	return invincible
func start_default_invincible() -> void:
	set_invincible_time(default_invincible_time)
func get_hurt_time() -> float:
	return hurt_time

func sprite_rotations() -> void:
	#calculations for player and gun sprite rotations and flips
	#this is a little iffy and has a dependency with checking the player sprite scale value
	#I'd like to revisit this, potentially by setting up a member variable(s) that tracks
	#movement direction or mouse direction
	#the current behavior is split between here and the move function...beware!
	
	#calculation rotations when gun is held (midair)
	if current_gun.is_held():
		var current_angle = get_mouse_direction().angle()
		current_gun.rotation = current_angle
		if sign(animations.scale.x) > 0:
			animations.rotation = current_angle
		else:
			animations.rotation = current_angle - PI
	else:
		current_gun.rotation = Vector2.RIGHT.angle()
		animations.rotation = Vector2.RIGHT.angle()
	
	#gross gunsprite flipping solution that requires checking player sprite data
	#gun sprite changes should probably be inside the gun class, this is a hacky temp solution
	#that does require me to pass in move direction data to the gun
	#if that becomes a neccessity, this will absolutely be changed
	if is_grounded() and !current_gun.is_held():
		current_gun.flip_gun_sprite_vertical(false)
		current_gun.flip_gun_sprite_horizontal(sign(animations.scale.x)<0)
	if !is_grounded() and current_gun.is_held():
		current_gun.flip_gun_sprite_vertical(sign(animations.scale.x)<0)
		current_gun.flip_gun_sprite_horizontal(false)
	
	debug_line.clear_points()
	debug_line.add_point(center_point.position)
	debug_line.add_point(get_viewport().get_mouse_position() - get_global_transform_with_canvas().origin)
func get_mouse_direction() -> Vector2:
	#these specific transforms to get mouse screen position due to the viewport altering worldspace resolution
	#this is a pain point! consider revision or connect it to the viewport!
	var mouse_pos = get_viewport().get_mouse_position() - get_global_transform_with_canvas().origin
	#getting the vector to the center of the player
	var shot_direction_vector = (mouse_pos - center_point.position)
	shot_direction_vector = shot_direction_vector/shot_direction_vector.length()
	return shot_direction_vector.normalized()

func add_to_gun_clip() -> void:
	#adds to clip and updates clip graphic
	current_gun.add_bullet_to_clip()

func change_health(value:int) -> void:
	#in the future, this will send out signals to update GUI and visual functions
	set_health(health + value)
func set_health(value:int) -> void:
	emit_signal("health_changed", value, health)
	health = value

#visual functions
func animate_land_puff() -> void:
	var dust_particles : ParticleAnimation = landing_dust_puff_scene.instantiate()
	add_child(dust_particles)
	dust_particles.play()
	await dust_particles.finished
	dust_particles.queue_free()
func animate_jump_puff() -> void:
	var dust_particles : ParticleAnimation = jumping_dust_puff_scene.instantiate()
	add_child(dust_particles)
	dust_particles.play()
	await dust_particles.finished
	dust_particles.queue_free()

#incoming signals

#hurtbox signals
func _on_Hurtbox_body_entered(body):
	if body is Actor and !is_invincible():
		change_health(-body.get_actor_damage()+defense)
		last_hurt_direction = (center_point.global_position - body.global_position).normalized()
		is_hurt = true
func _on_Hurtbox_area_entered(area):
	if area is Actor:
		change_health(-area.get_actor_damage()+defense)
		last_hurt_direction = (center_point.global_position - area.global_position).normalized()
		is_hurt = true

#gun signals
func _on_gun_bullet_fired(bullet):
	bullet_fired.emit(bullet)
func _on_gun_bullets_in_clip_updated(bullets):
	bullets_in_clip_updated.emit(bullets)
func _on_gun_clip_emptied():
	clip_emptied.emit()
func _on_gun_firing_started(time):
	firing_started.emit(time)
func _on_gun_firing_finished():
	firing_finished.emit()
func _on_gun_reload_started(time):
	reload_started.emit(time)
func _on_gun_reload_finished():
	reload_finished.emit()
