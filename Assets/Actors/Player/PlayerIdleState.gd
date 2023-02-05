class_name PlayerIdleState
extends PlayerState

#references to possible states
#grounded_dash
#aerial_dash
#jump
#fall
#idle
#shoot

export var g_dash_node : NodePath
export var jump_node : NodePath
export var fall_node : NodePath
export var move_node : NodePath
export var shoot_node: NodePath

onready var g_dash_state : BaseState = get_node(g_dash_node)
onready var jump_state : BaseState = get_node(jump_node)
onready var fall_state : BaseState = get_node(fall_node)
onready var move_state : BaseState = get_node(move_node)
onready var shoot_state : BaseState = get_node(shoot_node)

#implementation can scale over time

func on_enter() -> void:
	#switch to move animation
	.on_enter()

func input(_event:InputEvent) -> BaseState:
	#cycle to other states
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		return move_state
	elif Input.is_action_just_pressed("jump"): return jump_state
	elif Input.is_action_just_pressed("dash"): return g_dash_state
	elif Input.is_action_just_pressed("shoot"): return shoot_state
	return null

func physics_process(_delta:float) -> BaseState:
	
	actor.idle(_delta)
	
	#check if grounded, fall if not
	if !actor.is_grounded():
		return fall_state
	
	return null
