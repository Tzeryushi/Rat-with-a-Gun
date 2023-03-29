class_name Room
extends Node2D

#Rooms are the contained, crafted chunks that comprise each level
#Rooms are defined by their height and width, and location of their doorways
#Rooms are stacked at their doorways, creating a wavy, messy tower of rooms
#In the future, may allow for splitting and joining rooms

const PORTAL_LENGTH : int = 6

@onready var tilemap := $TileMap
@onready var entrance_pos := $TileMap/Entrance
@onready var exit_pos := $TileMap/Exit
@onready var spawn_point_container := $EnemySpawnPoints
@onready var tile_size : int = tilemap.tile_set.tile_size.x

#returns dimensions in scene pixel size
func get_map_space_dimensions() -> Vector2i:
	return tilemap.get_used_rect().size

func get_dimensions() -> Vector2:
	return tile_size*get_map_space_dimensions()

#returns tile-centered exit position relative to center of scene
func get_map_space_exit_position() -> Vector2:
	return Vector2(tilemap.local_to_map(exit_pos.position))

#returns tile-centered entrance position based on node
func get_entrance_position() -> Vector2:
	return tilemap.map_to_local(tilemap.local_to_map(entrance_pos.position))

#returns tile-centered exit position
func get_exit_position() -> Vector2:
	return tilemap.map_to_local(tilemap.local_to_map(exit_pos.position))

#gets spawn points from container node, EnemySpawnPoints
#spawn points must be of class SpawnPoint to be counted
func get_enemy_spawn_points() -> Array[SpawnPoint]:
	var spawn_array : Array[SpawnPoint]
	for spawn_point in spawn_point_container.get_children():
		if spawn_point is SpawnPoint:
			spawn_array.append(spawn_point)
	return spawn_array
