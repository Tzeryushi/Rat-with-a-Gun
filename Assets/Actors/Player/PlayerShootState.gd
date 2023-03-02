class_name PlayerShootState
extends PlayerState

export var a_dash_node : NodePath
export var jump_node : NodePath
export var fall_node : NodePath
export var idle_node : NodePath
export var move_node : NodePath
export var shoot_node: NodePath

onready var a_dash_state : BaseState = get_node(a_dash_node)
onready var jump_state : BaseState = get_node(jump_node)
onready var fall_state : BaseState = get_node(fall_node)
onready var idle_state : BaseState = get_node(idle_node)
onready var move_state : BaseState = get_node(idle_node)
onready var shoot_state : BaseState = get_node(shoot_node)

func on_enter() -> void:
	#switch to shoot animation
	#todo: flag so that animation doesn't reset coming from a gdash
	.on_enter()
	actor.switch_gun_held()

func input(_event:InputEvent) -> BaseState:
	#cycle to jump or shoot
	if actor.is_grounded():
		if Input.is_action_just_pressed("jump"): return jump_state
	if actor.is_shot_ready():
		if Input.is_action_just_pressed("shoot"): return shoot_state
	if Input.is_action_just_pressed("dash"): return a_dash_state
	
	return null

func process(_delta:float) -> BaseState:
	return null

func physics_process(_delta:float) -> BaseState:
	actor.shoot(_delta)
	
	var direction = get_move_direction()
	actor.move(direction, _delta)
	
	if actor.is_grounded() and !actor.is_moving_up():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			return move_state
		return idle_state
	
	#if actor.velocity.y > 0:
	return fall_state
