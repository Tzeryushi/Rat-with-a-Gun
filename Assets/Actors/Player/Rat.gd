class_name PlayerRat

extends Actor

export var first_gun : NodePath

export var acceleration : float = 500.0
export var max_speed : float = 150.0
export var jump_power : float = 210.0
export var jump_cancel_power: float = 2500
export var jump_gravity : float = 380.0
export var stomp_power : float = 300
export var gravity : float = 600.0
export var terminal_velo : float = 500.0
export var dash_multiplier : float = 3.0
export var dash_time : float = 0.5
export var jump_buffer_tolerance : float = 0.1
export var coyote_time_tolerance : float = 0.15

onready var current_gun : Gun = get_node(first_gun)
onready var bounce_casts := $UnderCasts

var velocity := Vector2.ZERO #this is simply where we start out when initializing
var jump_held : bool = false #modified by states when jump is held or not, for jump buffering
var dash_completed : float = 0.0 #helps keeps track of how much dash time is left, checked by states
var jump_buffer_timer : float = 0.0 #checked by state to see if a jump has been buffered
var coyote_time : float = 0.0 #fall state checks this to see if coyote time is usable
var was_grounded : bool = false #keeps track of the grounded condition of the previous physics step
var stomped_node_reference : Node #a reference to the last entity bounced upon - will often be a null 'pointer'
var invincible : bool = false #to help future proof this, only interact using the setter/getter function
var invincible_timer : float = 0.0

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

func _unhandled_input(_event) -> void:
	state_manager.input(_event)
	
func _process(_delta) -> void:
	state_manager.process(_delta)
	
	#temporary invincible timer check
	if invincible_timer > 0.0:
		invincible_timer -= _delta
		if invincible_timer >= 0.0:
			set_invincible(false)
	
func _physics_process(_delta):
	state_manager.physics_process(_delta)
	
	#coyote and jump buffer countdowns
	if coyote_time > 0.0:
		coyote_time -= _delta
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= _delta
	#if global_position.y >= 304:
	#	global_position.y = 304
	
#player functions
func jump() -> void:
	#simple jump, is called on multiple frames
	#velocity applied until max is reached
	velocity.y = -jump_power

func jump_process(_delta:float) -> void:
	#quickly decreases upwards velocity until it is 0
	#velocity.y = move_toward(velocity.y, terminal_velo, gravity*_delta)
	if !jump_held:
		#velocity.y = move_toward(velocity.y, 0, jump_cancel_power*_delta)
		velocity.y = velocity.y/2
		jump_held = true
	else:
		velocity.y = move_toward(velocity.y, terminal_velo, jump_gravity*_delta)
	velocity.y = move_and_slide(Vector2(0.0, velocity.y), Vector2.UP).y
	#global_position.y += (velocity.y*_delta)
	pass

func fall(_delta:float) -> void:
	#accelerates downwards, no jumps allowed unless there is coyote time
	velocity.y = move_toward(velocity.y, terminal_velo, gravity*_delta)
	velocity.y = move_and_slide(Vector2(0.0, velocity.y), Vector2.UP).y
	#global_position.y += (velocity.y*_delta)
	pass
	
func move(_direction, _delta:float) -> void:
	#accelerates in input direction up to max speed
	if _direction < 0:
		animations.flip_h = false
	if _direction > 0:
		animations.flip_h = true
	if is_grounded() and sign(_direction)!=sign(velocity.x):
		#simulated friction for grounded movement
		velocity.x = move_toward(velocity.x, max_speed*_direction, acceleration*2*_delta)
	else:
		#less reverse movement in air
		if _direction == 0:
			velocity.x = move_toward(velocity.x, max_speed*_direction, acceleration*_delta*.2)
		else:
			velocity.x = move_toward(velocity.x, max_speed*_direction, acceleration*2*_delta)
	velocity.x = move_and_slide(Vector2(velocity.x, 0.0), Vector2.UP).x
	#global_position.x += velocity.x*_delta

func dash(_direction, _delta:float) -> void:
	#dashes in direction, will continue to do so until dash_completed is up
	#dash should preserve any prior velocity and then return to it after completion
	pass

func shoot(_delta:float) -> void:
	#shoot utilizes gun system to provide acceleration to player
	if is_grounded():
		return
	var mouse_pos = get_global_mouse_position()/4
	
	var shot_direction_vector = (mouse_pos - get_global_position())
	shot_direction_vector = shot_direction_vector/shot_direction_vector.length()
	var shot_power = shot_direction_vector*current_gun.get_knockback()
	if shot_power.y > 0:
		velocity.y = -(shot_direction_vector*current_gun.get_knockback()).y
	elif shot_power.y < 0:
		velocity.y -= (shot_direction_vector*current_gun.get_knockback()).y
	velocity.x -= (shot_direction_vector*current_gun.get_knockback()).x/2.5
	
func idle(_delta:float) -> void:
	#anything that needs to happen when idle
	velocity.x = move_toward(velocity.x, max_speed*0, acceleration*_delta)
	velocity.x = move_and_slide(Vector2(velocity.x, 0.0), Vector2.UP).x
	#global_position.x += velocity.x*_delta
	pass

func stomp() -> void:
	#when an enemy actor is stomped upon, execute
	var stomp_multiplier = stomped_node_reference.get_stomp_strength()
	velocity.y = -stomp_power*stomp_multiplier
	
	stomped_node_reference.bounce_parent()
	
func stomp_process(_delta) -> void:
	velocity.y = move_toward(velocity.y, terminal_velo, jump_gravity*_delta)
	velocity.y = move_and_slide(Vector2(0.0, velocity.y), Vector2.UP).y

func is_grounded() -> bool:
	#TODO: grounded check
	#if global_position.y >= 304:
	var value = is_on_floor()
	if !value and was_grounded:
		coyote_time = coyote_time_tolerance
	was_grounded = value
	return value

func is_dashing() -> bool:
	return dash_completed > 0.0

func is_shot_ready() -> bool:
	#TODO: update this with reload time
	return true

func start_jump_buffer_timer() -> void:
	jump_buffer_timer = jump_buffer_tolerance

func is_jump_buffered() -> bool:
	return jump_buffer_timer > 0.0
	
func can_coyote_jump() -> bool:
	return coyote_time > 0.0

func set_invincible(state:bool=true) -> void:
	invincible = state

func set_invincible_time(time:float) -> void:
	invincible_timer = time
	if invincible_timer > 0.0:
		set_invincible(true)

func is_invincible() -> bool:
	return invincible

func check_stomp(_delta) -> bool:
	#as long as the player is falling, they will stomp on a stompable field; rays are extended to the player velocity
	#the player body will move to the cast intersection in the physics tick
	#TODO: Add some invicibility and remove velocity truncation
	if velocity.y > 0:
		for cast in bounce_casts.get_children():
			cast.cast_to = Vector2.DOWN*velocity*_delta+Vector2.DOWN
			cast.force_raycast_update()
			if cast.is_colliding() && cast.get_collision_normal() == Vector2.UP:
				#velocity.y = (cast.get_collision_point() - cast.global_position - Vector2.DOWN).y
				stomped_node_reference = cast.get_collider()
				return true
	return false
