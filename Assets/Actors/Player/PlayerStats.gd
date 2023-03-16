extends Node

@export var resources : RatResource
@export var combo_gold_multiplier : int = 1

@onready var combo_timer := $ComboTimer

var player_gold_multiplier : int = 1
var player_combo_time_addition : float = 0.0

func _ready() -> void:
	Events.combo_up.connect(increase_combo)

#increases the combo by 1, sends a global signal
func increase_combo() -> void:
	if resources.combo == 0:
		start_combo()
	resources.combo += 1
	Events.combo_changed.emit(resources.combo, combo_timer.time_left)

#triggers when a combo starts from scratch
func start_combo() -> void:
	combo_timer.wait_time = resources.default_combo_time_limit + player_combo_time_addition
	combo_timer.start()

#pauses the combo timer, currently does not pause increasing combo
func pause_combo_timer(state:bool) -> void:
	combo_timer.paused = state

#resets combo and distributes gold based on total
func end_combo() -> void:
	#for each 5 in the combo, get 50 gold + an additional 10 gold for each 5 past 5 (10, 30, 60, 100, 150)
	resources.gold += int((resources.combo/5 + pow(5*(resources.combo/5-1),2) + 5*(resources.combo/5-1))
		*player_gold_multiplier*combo_gold_multiplier)
	Events.gold_changed.emit(resources.gold)
	resources.combo = 0
	Events.combo_changed.emit(resources.combo)

func get_combo() -> int:
	return resources.combo

func set_combo(value:int) -> void:
	if value > 0:
		resources.combo = value
	elif value == 0:
		end_combo()
