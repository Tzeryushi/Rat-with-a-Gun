extends BaseScene

@export var total_rooms : int = 3 #decides how tall a level is, may elect for height instead
@export var room_scenes : Array[PackedScene]
@export var end_room_scene : PackedScene
@export var start_room_scene : PackedScene

@export var test_enemy_scene : PackedScene

@export var player_node : NodePath
@export var debug_node : NodePath

@onready var map_container := $MapContainer
@onready var enemy_container := $EnemyContainer
@onready var player : PlayerRat = get_node(player_node)
@onready var debug : DebugContainer = get_node(debug_node)

var is_swapping_level : bool = false #used to prevent double catches on win interactions
var end_room : EndRoom

signal level_cleared
signal level_loaded

func _ready() -> void:
	debug.connect_to_player(player)
	#debug.visible = false
	populate_level()
	Shake.set_camera($Player/Camera2D) #camera must be set!

#temp input stuff for debug and level cycling
func _input(_event) -> void:
	if Input.is_action_just_pressed("debug"):
		debug.visible = !debug.visible
	if Input.is_action_just_pressed("move_up"):
		end_room.call_deferred("start_monitoring")

#win should be called upon reaching the end of a level
func _win() -> void:
	clear_level()
	call_deferred("populate_level")
	await self.level_loaded

#lose should be called upon giving up a run or health depletion
func _lose() -> void:
	pass

#loads in rooms randomly and slots their exits together to build the level
#there is some redundant code here, needs another pass
func populate_level() -> void:
	#TODO: populate from the level end first
	#inheriting levels can override this implementation if specific changes are warranted
	
	var current_tower_position := Vector2.ZERO
	var last_entrance := Vector2.ZERO
	
	#load in the ending room first, work down
	end_room = end_room_scene.instantiate()
	map_container.add_child(end_room)
	end_room.position.y = end_room.position.y - end_room.tile_size*end_room.get_map_space_exit_position().y
	last_entrance = end_room.get_entrance_position()
	current_tower_position.y = end_room.get_dimensions().y
	#we connect the ending zone to our win function
	end_room.level_end_reached.connect(_win)
	
	#for each room we set the location based on the entrance of the last placed room
	#the room position is shifted and accounts for dimensions outside of positive xy values
	for i in total_rooms:
		var room : Room = room_scenes[randi()%room_scenes.size()].instantiate()
		map_container.add_child(room)
		var shift_position : Vector2 = Vector2(room.get_exit_position().x-last_entrance.x, room.get_map_space_exit_position().y*room.tile_size)
		room.position = current_tower_position - shift_position
		current_tower_position = room.position + Vector2(0,room.get_dimensions().y+shift_position.y)
		last_entrance = room.get_entrance_position()
	
	#finally, load in the start scene
	var start_room : StartRoom = start_room_scene.instantiate()
	map_container.add_child(start_room)
	var shift_position : Vector2 = Vector2(start_room.get_exit_position().x-last_entrance.x, start_room.get_map_space_exit_position().y*start_room.tile_size)
	start_room.position = current_tower_position - shift_position
	
	#now move player spawn (temporary)
	$Player.global_position = start_room.get_spawn_point()
	
	#link spawn signals to level
	#I may decide to do this on a per-room basis in the future
	for room in map_container.get_children():
		if room is Room:
			for point in room.get_enemy_spawn_points():
				point.spawn_triggered.connect(on_spawn_point_triggered)

	level_loaded.emit()

#wipes the loaded level scenes, careful of player position!
func clear_level() -> void:
	player.position.y = -20000
	for room in map_container.get_children():
		if room is Room:
			for point in room.get_enemy_spawn_points():
				point.spawn_triggered.disconnect(on_spawn_point_triggered)
			room.queue_free()
	for enemy in enemy_container.get_children():
		enemy.queue_free()
	level_cleared.emit()

#spawn an enemy when a point calls for it
#TODO: update with randomized enemies, spawn types, hitbox activations after position setting
func on_spawn_point_triggered(point:SpawnPoint) -> void:
	var new_enemy : BaseEnemy = test_enemy_scene.instantiate()
	enemy_container.call_deferred("add_child",new_enemy)
	new_enemy.global_position = point.global_position
	
