class_name PlayerStompState
extends PlayerState

@export var a_dash_node : NodePath
@export var fall_node : NodePath
@export var idle_node : NodePath
@export var move_node : NodePath
@export var shoot_node: NodePath
@export var hurt_node : NodePath

@onready var a_dash_state : BaseState = get_node(a_dash_node)
@onready var fall_state : BaseState = get_node(fall_node)
@onready var idle_state : BaseState = get_node(idle_node)
@onready var move_state : BaseState = get_node(move_node)
@onready var shoot_state : BaseState = get_node(shoot_node)
@onready var hurt_state : BaseState = get_node(hurt_node)

func on_enter() -> void:
	#switch to stomp animation
	super()
	#introduce stomp velocity
	actor.stomp()
	actor.switch_gun_held()

func input(_event:InputEvent) -> BaseState:
	#cycle to aerial dash
	if Input.is_action_just_pressed("dash"):
		return a_dash_state
	if Input.is_action_just_pressed("shoot") and actor.is_shot_ready():
		return shoot_state
	#in unhandled case, returns null to keep same state
	return null

func physics_process(_delta:float) -> BaseState:
	if actor.is_hurt:
		return hurt_state
	
	actor.stomp_process(_delta)
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
