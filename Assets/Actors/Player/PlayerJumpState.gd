class_name PlayerJumpState
extends PlayerState

export var a_dash_node : NodePath
export var fall_node : NodePath
export var idle_node : NodePath
export var move_node : NodePath
export var shoot_node: NodePath

onready var a_dash_state : BaseState = get_node(a_dash_node)
onready var fall_state : BaseState = get_node(fall_node)
onready var idle_state : BaseState = get_node(idle_node)
onready var move_state : BaseState = get_node(move_node)
onready var shoot_state : BaseState = get_node(shoot_node)

#implementation can scale over time

func on_enter() -> void:
	#switch to jump animation
	.on_enter()
	#reset jump button held flag
	actor.jump_held = true
	actor.jump()
	#where should we call the jump?

func on_exit() -> void:
	.on_exit()
	actor.jump_held = false

func input(_event:InputEvent) -> BaseState:
	#cycle to aerial dash
	if Input.is_action_just_pressed("dash"):
		return a_dash_state
	if Input.is_action_just_pressed("shoot"):
		return shoot_state
	#if jump is released, flag to cut jump height
	if Input.is_action_just_released("jump"):
		actor.jump_held = false
	#in unhandled case, returns null to keep same state
	return null

func physics_process(_delta:float) -> BaseState:
	#check if player is still grounded, switch to fall_state if not
	#TODO: Get floor calc
	
	actor.jump_process(_delta)
	#send directional data to be handled in player class
	var direction = get_move_direction()
	actor.move(direction, _delta)
	
	if actor.velocity.y >= 0:
		return fall_state
	
	#TODO: check if player is grounded, switch state accordingly
	if actor.is_grounded() and !actor.is_moving_up():
		if direction == 0:
			return idle_state
		return move_state
	
	return null
