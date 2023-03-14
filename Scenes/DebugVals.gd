extends VBoxContainer


func _ready():
	pass
	
func _process(_delta):
	if !$ReloadTime/Timer.is_stopped():
		$ReloadTime.text = "[color=red]Reloading: " + str(snapped($ReloadTime/Timer.time_left, 0.001))
	if !$FireTime/Timer.is_stopped():
		$FireTime.text = "[color=red]Not Fireable: " + str(snapped($FireTime/Timer.time_left, 0.001))

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
