class_name PlayerMoveState
extends PlayerState

#references to possible states
#grounded_dash
#aerial_dash
#jump
#fall
#idle
#shoot

@export var g_dash_node : NodePath
#export var a_dash_node : NodePath
@export var jump_node : NodePath
@export var fall_node : NodePath
@export var idle_node : NodePath
@export var shoot_node: NodePath
@export var hurt_node : NodePath

@onready var g_dash_state : BaseState = get_node(g_dash_node)
@onready var jump_state : BaseState = get_node(jump_node)
@onready var fall_state : BaseState = get_node(fall_node)
@onready var idle_state : BaseState = get_node(idle_node)
@onready var shoot_state : BaseState = get_node(shoot_node)
@onready var hurt_state : BaseState = get_node(hurt_node)

#implementation can scale over time

func on_enter() -> void:
	#switch to move animation
	super()
	actor.switch_gun_back()

func input(_event:InputEvent) -> BaseState:
	#check if reloading
	check_reload()
	
	#cycle to jump or dash
	if Input.is_action_just_pressed("jump"): return jump_state
	elif Input.is_action_just_pressed("dash"): return g_dash_state
	#elif Input.is_action_just_pressed("shoot"): return shoot_state
	#in unhandled case
	return null

func physics_process(_delta:float) -> BaseState:
	if actor.is_hurt:
		return hurt_state
	
	#check if player is still grounded, switch to fall_state if not
	if !actor.is_grounded():
		return fall_state
	
	#send directional data to be handled in player class
	var direction = get_move_direction()
	actor.move(direction, _delta)
	actor.fall(_delta)
	if direction == 0 :
		return idle_state
	
	return null
