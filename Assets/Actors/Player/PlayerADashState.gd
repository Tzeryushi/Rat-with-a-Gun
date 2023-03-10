class_name PlayerADashState
extends PlayerState

@export var g_dash_node : NodePath
@export var fall_node : NodePath
@export var jump_node : NodePath
@export var idle_node : NodePath
@export var move_node : NodePath
@export var shoot_node: NodePath

@onready var g_dash_state : BaseState = get_node(g_dash_node)
@onready var fall_state : BaseState = get_node(fall_node)
@onready var jump_state : BaseState = get_node(jump_node)
@onready var idle_state : BaseState = get_node(idle_node)
@onready var move_state : BaseState = get_node(idle_node)
@onready var shoot_state : BaseState = get_node(shoot_node)

func on_enter() -> void:
	#switch to dash animation
	super()
	actor.switch_gun_held()

func input(_event:InputEvent) -> BaseState:
	#cycle to jump or shoot
	if Input.is_action_just_pressed("shoot") and actor.is_shot_ready():
		return shoot_state
	
	return null

func process(_delta:float) -> BaseState:
	#Dash time calc
	if actor.is_dashing():
		if actor.is_grounded():
			return g_dash_state
		return null
	
	if actor.is_grounded():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			return move_state
		return idle_state
	return fall_state

func physics_process(_delta:float) -> BaseState:
	#calculate air fall rate
	
	return null
