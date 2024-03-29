class_name PlayerState
extends BaseState

@export var animation_type : String #this is used when entering a state
@export var state_type : Globals.PLAYERSTATE

var actor: PlayerRat
var move_last : int = 0

func on_enter() -> void:
	#execute when state is entered
	#this will be overwritten by inheritors, will need to be referenced if needed
	#print(self)
	actor.animations.play(animation_type)
	actor.switch_hitboxes(state_type)
	pass

func on_exit() -> void:
	#execute when when is exited into another state
	actor.last_player_state = state_type
	pass

func input(_event:InputEvent) -> BaseState:
	#execute when actor receives input
	#returns the state of the actor, which may have changed
	return null

func process(_delta:float) -> BaseState:
	#execute to define process loop functionality in state
	#returns the state of the actor, which may have changed
	return null

func physics_process(_delta:float) -> BaseState:
	#execute to define physics process loop functionality in state
	#returns the state of the actor, which may have changed
	return null

func get_move_direction() -> int:
	#gets a direction from input
	#the last direction pressed gets priority
	var value = sign(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		#code here cannot be collapsed due to priority rules
		if Input.is_action_just_pressed("move_left"):
			value = -1
		elif Input.is_action_just_pressed("move_right"):
			value = 1
		elif move_last == -1:
			value = -1
		elif move_last == 1:
			value = 1
	move_last = value
	return value

func check_reload() -> void:
	if Input.is_action_just_pressed("reload"):
		actor.current_gun.reload()
