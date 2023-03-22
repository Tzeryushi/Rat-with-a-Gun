extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Shake.set_camera($Player/Camera2D)
	print($TileMap.map_to_local($TileMap.local_to_map($TileMap/Entrance.position)))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
