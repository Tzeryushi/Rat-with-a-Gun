class_name PlayerFallState
extends PlayerState

export var a_dash_node : NodePath
export var idle_node : NodePath
export var move_node : NodePath
export var shoot_node: NodePath

onready var a_dash_state : BaseState = get_node(a_dash_node)
onready var idle_state : BaseState = get_node(idle_node)
onready var move_state : BaseState = get_node(move_node)
onready var shoot_state : BaseState = get_node(shoot_node)

#implementation can scale over time

func on_enter() -> void:
	#switch to jump animation
	.on_enter()

func input(_event:InputEvent) -> BaseState:
	#cycle to aerial dash
	if Input.is_action_just_pressed("dash"): return a_dash_state
	elif Input.is_action_just_pressed("shoot"): return shoot_state
	#in unhandled case, returns null to keep same state
	return null

func physics_process(_delta:float) -> BaseState:	
	actor.fall(_delta)
	#send directional data to be handled in player class
	var direction = get_move_direction()
	actor.move(direction, _delta)
	
	#check if player is grounded, switch state accordingly
	#can switch to move or idle
	if actor.is_grounded():
		if direction == 0:
			return idle_state
		return move_state
	
	return null
