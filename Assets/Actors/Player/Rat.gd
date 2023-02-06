class_name PlayerRat

extends Actor

export var acceleration : float = 500.0
export var max_speed : float = 150.0
export var jump_power : float = 405.0
export var jump_cancel_power: float = 2500
export var jump_gravity : float = 680.0
export var gravity : float = 1000.0
export var terminal_velo : float = 500.0
export var dash_multiplier : float = 3.0
export var dash_time : float = 0.5
export var jump_buffer_tolerance : float = 0.1
export var coyote_time_tolerance : float = 0.15

var velocity := Vector2.ZERO #this is simply where we start out when initializing
var jump_held : bool = false #modified by states when jump is held or not, for jump buffering
var dash_completed : float = 0.0 #helps keeps track of how much dash time is left, checked by states
var jump_buffer_timer : float = 0.0 #checked by state to see if a jump has been buffered
var coyote_time : float = 0.0 #fall state checks this to see if coyote time is usable
var was_grounded : bool = false #keeps track of the grounded condition of the previous physics step

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
	
func _physics_process(_delta):
	state_manager.physics_process(_delta)
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
		velocity.y = move_toward(velocity.y, 0, jump_cancel_power*_delta)
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
		velocity.x = move_toward(velocity.x, max_speed*_direction, acceleration*_delta)
	velocity.x = move_and_slide(Vector2(velocity.x, 0.0), Vector2.UP).x
	#global_position.x += velocity.x*_delta

func dash(_direction, _delta:float) -> void:
	#dashes in direction, will continue to do so until dash_completed is up
	#dash should preserve any prior velocity and then return to it after completion
	pass

func shoot(_delta:float) -> void:
	#shoot utilizes gun system to provide acceleration to player
	pass
	
func idle(_delta:float) -> void:
	#anything that needs to happen when idle
	velocity.x = move_toward(velocity.x, max_speed*0, acceleration*_delta)
	velocity.x = move_and_slide(Vector2(velocity.x, 0.0), Vector2.UP).x
	#global_position.x += velocity.x*_delta
	pass

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
