class_name SpawnPoint
extends Node2D

#stores information like spawn radius, which allows/disallows enemies of certain sizes to spawn

@export var spawn_radius : float = 50.0
@export var spawn_detection_radius : float = 1250.0

@onready var detection_node := $SpawnDetection/SpawnDetectionRadius

var already_spawned : bool = true

signal spawn_triggered(spawn_point:SpawnPoint)

func _ready() -> void:
	detection_node.shape.radius = spawn_detection_radius
	already_spawned = false

#when player enters spawn territory, alert parent scene to spawning
func _on_spawn_detection_body_entered(body):
	if !already_spawned:
		spawn_triggered.emit(self)
		already_spawned = true
	
