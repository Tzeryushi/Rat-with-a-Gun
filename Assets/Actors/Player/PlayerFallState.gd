class_name PlayerFallState
extends PlayerState

@export var a_dash_node : NodePath
@export var jump_node : NodePath
@export var idle_node : NodePath
@export var move_node : NodePath
@export var shoot_node : NodePath
@export var bounce_node : NodePath
@export var hurt_node : NodePath

@onready var a_dash_state : BaseState = get_node(a_dash_node)
@onready var jump_state : BaseState = get_node(jump_node)
@onready var idle_state : BaseState = get_node(idle_node)
@onready var move_state : BaseState = get_node(move_node)
@onready var shoot_state : BaseState = get_node(shoot_node)
@onready var bounce_state : BaseState = get_node(bounce_node)
@onready var hurt_state : BaseState = get_node(hurt_node)

#implementation can scale over time

func on_enter() -> void:
	#switch to jump animation
	super()
	actor.switch_gun_held()

func input(_event:InputEvent) -> BaseState:
	#check if reloading
	check_reload()
	
	#cycle to aerial dash
	if Input.is_action_just_pressed("jump"):
		if actor.can_coyote_jump():
			return jump_state
		actor.start_jump_buffer_timer()
	
	if Input.is_action_just_pressed("dash"): return a_dash_state
	elif Input.is_action_just_pressed("shoot") and actor.is_shot_ready():
		return shoot_state
	#in unhandled case, returns null to keep same state
	return null

func physics_process(_delta:float) -> BaseState:	
	#send directional data to be handled in player class
	if actor.is_hurt:
		return hurt_state
	
	var direction = get_move_direction()
	
	#check if the player stomped this tick
	if actor.check_stomp(_delta):
		actor.fall(_delta) #must be called here to move the player to the connection point
		actor.move(direction, _delta)
		return bounce_state
	actor.fall(_delta)
	actor.move(direction, _delta)
	
	#check if player is grounded, switch state accordingly
	#can switch to move or idle
	if actor.is_grounded():
		if actor.is_jump_buffered():
			return jump_state
		if direction == 0:
			return idle_state
		return move_state
	
	return null
