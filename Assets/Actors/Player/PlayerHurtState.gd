class_name PlayerHurtState
extends PlayerState

@export var g_dash_node : NodePath
@export var a_dash_node : NodePath
@export var fall_node : NodePath
@export var jump_node : NodePath
@export var idle_node : NodePath
@export var move_node : NodePath
@export var shoot_node: NodePath
@export var stomp_node: NodePath

@onready var g_dash_state : BaseState = get_node(g_dash_node)
@onready var a_dash_state : BaseState = get_node(a_dash_node)
@onready var fall_state : BaseState = get_node(fall_node)
@onready var jump_state : BaseState = get_node(jump_node)
@onready var idle_state : BaseState = get_node(idle_node)
@onready var move_state : BaseState = get_node(move_node)
@onready var shoot_state : BaseState = get_node(shoot_node)
@onready var stomp_state : BaseState = get_node(stomp_node)

var hurt_time : float = 0.5

#the hurt state can transition to most every other state!
#invincibility is applied on entry
#state gets input lockout time from the player class

func on_enter() -> void:
	#switch to hurt animation
	super()
	#start invincibility, grab hurt timer from player, call impulse from hurt
	hurt_time = actor.get_hurt_time()
	actor.hurt()

func process(_delta:float) -> BaseState:
	#countdown for hurt
	hurt_time -= _delta
	if hurt_time <= 0.0:
		#ideally we would implement an input hierarchy in some resource somewhere, but 
		#that's kinda out of the scope of this project
		if !actor.is_grounded() or actor.is_moving_up():
			#check for aerial states, dash->shoot->fall
			if Input.is_action_pressed("dash"):
				return a_dash_state
			if Input.is_action_pressed("shoot"):
				return shoot_state
			return fall_state
		else:
			#check for ground states, dash->jump->move->idle
			if Input.is_action_pressed("dash"):
				return g_dash_state
			if Input.is_action_pressed("jump"):
				return jump_state
			if get_move_direction() != 0:
				return move_state
			return idle_state
		
	return null

func physics_process(_delta:float) -> BaseState:
	actor.hurt_process(_delta)
	return null
