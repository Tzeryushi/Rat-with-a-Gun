class_name DebugContainer
extends VBoxContainer

var player : PlayerRat
var _player_connected : bool = false

func _ready():
	Events.combo_changed.connect(_combo_change)
	Events.gold_changed.connect(_gold_change)
	
func _process(_delta):
	if !$ReloadTime/Timer.is_stopped():
		$ReloadTime.text = "[color=red]Reloading: " + str(snapped($ReloadTime/Timer.time_left, 0.001))
	if !$FireTime/Timer.is_stopped():
		$FireTime.text = "[color=red]Not Fireable: " + str(snapped($FireTime/Timer.time_left, 0.001))
	if !$ComboTimer/Timer.is_stopped():
		$ComboTimer.text = "[color=green]Combo Time Left: [/color][color=blue]" + str(snapped($ComboTimer/Timer.time_left, 0.001))
	$FrameRate.text = "[color=purple]Frame Rate: " + str(Engine.get_frames_per_second())

func connect_to_player(_player:PlayerRat) -> void:
	player = _player
	player.bullets_in_clip_updated.connect(_on_player_bullets_in_clip_updated)
	player.firing_finished.connect(_on_player_firing_finished)
	player.firing_started.connect(_on_player_firing_started)
	player.health_changed.connect(_on_player_health_changed)
	player.invincibility_started.connect(_on_player_invincibility_started)
	player.invincibility_finished.connect(_on_player_invincibility_finished)
	player.reload_finished.connect(_on_player_reload_finished)
	player.reload_started.connect(_on_player_reload_started)
	_player_connected = true

func disconnect_player() -> void:
	player.bullets_in_clip_updated.disconnect(_on_player_bullets_in_clip_updated)
	player.firing_finished.disconnect(_on_player_firing_finished)
	player.firing_started.disconnect(_on_player_firing_started)
	player.health_changed.disconnect(_on_player_health_changed)
	player.invincibility_started.disconnect(_on_player_invincibility_started)
	player.invincibility_finished.disconnect(_on_player_invincibility_finished)
	player.reload_finished.disconnect(_on_player_reload_finished)
	player.reload_started.disconnect(_on_player_reload_started)
	_player_connected = false

func _on_player_health_changed(new_value, _old_value):
	$Health.text = "Health: [color=green]" + str(new_value)

func _on_player_bullets_in_clip_updated(bullets):
	$Clip.text = "Clip: [color=blue]" + str(bullets)

func _on_player_invincibility_started():
	$Invincible.text = "[color=green]Invincible: YES"

func _on_player_invincibility_finished():
	$Invincible.text = "[color=red]Invincible: NO"

func _on_player_reload_started(time):
	$ReloadTime.text = "[color=red]Reloading: " + str(time)
	$ReloadTime/Timer.wait_time = time
	$ReloadTime/Timer.start()
func _on_player_reload_finished():
	$ReloadTime.text = "[color=green]Loaded"

func _on_player_firing_started(time):
	$FireTime.text = "[color=red]Not Fireable: " + str(time)
	$FireTime/Timer.wait_time = time
	$FireTime/Timer.start()
func _on_player_firing_finished():
	$FireTime.text = "[color=green]Fireable"

func _combo_change(new_value, timer_value) -> void:
	$Combo.text = "Combo: " + str(new_value)
	$ComboTimer.text = "Combo Time Left: [color=blue]" + str(snapped(timer_value, 0.001))
	if timer_value > 0:
		$ComboTimer/Timer.wait_time = timer_value
		$ComboTimer/Timer.start()

func _gold_change(new_value) -> void:
	$Gold.text = "Gold: [color=orange]" + str(new_value)
