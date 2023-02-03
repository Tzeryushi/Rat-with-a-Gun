class_name Actor
extends KinematicBody2D #can be changed later

export var animation_node : NodePath
export var state_manager_node : NodePath

onready var animations : AnimatedSprite = get_node(animation_node)
onready var state_manager = get_node(state_manager_node)

func _ready() -> void:
	#inject actor ref to states
	pass
	
func _unhandled_input(event) -> void:
	#send input to states
	pass

func _physics_process(delta) -> void:
	#send request to states, handled in inheriting actors
	pass

func _process(delta) -> void:
	#will send request to states, handled in inheriting actors
	pass
