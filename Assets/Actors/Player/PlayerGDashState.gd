class_name PlayerGDashState
extends PlayerState

@export var a_dash_node : NodePath
@export var jump_node : NodePath
@export var idle_node : NodePath
@export var move_node : NodePath
@export var shoot_node: NodePath

@onready var a_dash_state : BaseState = get_node(a_dash_node)
@onready var jump_state : BaseState = get_node(jump_node)
@onready var idle_state : BaseState = get_node(idle_node)
@onready var move_state : BaseState = get_node(move_node)
@onready var shoot_state : BaseState = get_node(shoot_node)

func on_enter() -> void:
	#switch to dash animation
	super()
	actor.switch_gun_held()

func input(_event:InputEvent) -> BaseState:
	#cycle to jump or shoot
	if Input.is_action_just_pressed("jump") and actor.has_jump_space():
		return jump_state
	if Input.is_action_just_pressed("shoot") and actor.is_shot_ready():
		return shoot_state
	
	return null

func process(_delta:float) -> BaseState:
	#Dash time calc
	if actor.is_dashing():
		return null
	
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		return move_state
	return idle_state

func physics_process(_delta:float) -> BaseState:
	#check if player is still grounded, switch to aerial dash if they are
	if !actor.is_grounded():
		return a_dash_state
	
	return null
