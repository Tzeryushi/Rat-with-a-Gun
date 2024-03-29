class_name Actor
extends CharacterBody2D #can be changed later

@export var animation_node : NodePath
@export var state_manager_node : NodePath

#actor attributes
@export var health : int = 2: get = get_health, set = set_health
@export var base_power : int = 1
@export var defense : int = 0
@export var enemy : bool = false

@onready var animations : AnimatedSprite2D = get_node(animation_node)
@onready var state_manager = get_node(state_manager_node)

func _ready() -> void:
	#inject actor ref to states
	pass
	
func _unhandled_input(_event) -> void:
	#send input to states
	pass

func _physics_process(_delta) -> void:
	#send request to states, handled in inheriting actors
	pass

func _process(_delta) -> void:
	#will send request to states, handled in inheriting actors
	pass

func be_bounced_on() -> void:
	#will contain logic that occurs to an actor when bounced on
	pass

func get_actor_damage() -> int:
	#will be overridden
	return base_power

func get_health() -> int:
	return health

func set_health(value:int) -> void:
	health = value
