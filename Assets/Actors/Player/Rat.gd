class_name PlayerRat

extends Actor

export var acceleration : float = 500.0
export var max_speed : float = 100.0
export var gravity : float = 4.0
export var dash_multiplier : float = 3.0
export var dash_time : float = 0.5
export var jump_buffer_tolerance : float = 0.3
export var coyote_time_tolerance : float = 0.1

var velocity := Vector2.ZERO #this is simply where we start out when initializing
var jump_held : bool = false
var dash_completed : float = 0.0 #helps keeps track of how much dash time is left, checked by states
var jump_buffered : bool = false #checked by state to see if a jump has been buffered
var time_since_grounded : float = 0.0 #fall state checks this to see if coyote time is usable


#player node accepts input, sends to state manager to get result
#states will decide if player defined functions for actions will be triggered
#basically,
#states decide what will happen with input, sends commands to player class
#player class values and methods are altered by Effects nodes
#player class executes functionality

#we do not define functionality in classes as it further erodes the ability to
#augment the player with Effects nodes, or at best makes code more obtuse

#player functions
func jump(_delta:float) -> void:
	#simple jump, is called on multiple frames
	#velocity applied until max is reached
	pass

func jump_cut(_delta:float) -> void:
	#quickly decreases upwards velocity until it is 0
	pass

func fall(_delta:float) -> void:
	#accelerates downwards, no jumps allowed unless there is coyote time
	pass
	
func move(_direction, _delta:float) -> void:
	#accelerates in input direction up to max speed
	velocity.x = move_toward(velocity.x, max_speed*_direction, acceleration*_delta)
	global_position.x += velocity.x*_delta

func dash(_direction, _delta:float) -> void:
	#dashes in direction, will continue to do so until dash_completed is up
	#dash should preserve any prior velocity and then return to it after completion
	pass

func shoot(_delta:float) -> void:
	#shoot utilizes gun system to provide acceleration to player
	pass
	
func idle(_delta:float) -> void:
	#anything that needs to happen when idle
	pass

func is_grounded() -> bool:
	#TODO: grounded check
	return true

func is_dashing() -> bool:
	if dash_completed <= 0.0:
		return false
	return true

func is_shot_ready() -> bool:
	#TODO: update this with reload time
	return true
