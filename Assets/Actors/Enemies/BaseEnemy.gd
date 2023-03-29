class_name BaseEnemy
extends Actor

@export var _gravity : float = 50
@export var _terminal_velo : float = 800
@export var _bob_impulse : float = 20

@onready var starting_position : Vector2 = global_position

func be_bounced_on() -> void:
	super()
	destruct()

func destruct() -> void:
	Events.combo_up.emit()
	queue_free()

func set_health(value:int) -> void:
	health = value
	if health <= 0:
		destruct()
