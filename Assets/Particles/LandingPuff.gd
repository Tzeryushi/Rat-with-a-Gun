extends ParticleAnimation

@onready var dust_1 := $Dust1
@onready var dust_2 := $Dust2

func _process(_delta) -> void:
	if !dust_1.emitting and !dust_2.emitting:
		finished.emit()

func play() -> void:
	dust_1.emitting = true
	dust_2.emitting = true

func stop() -> void:
	dust_1.emitting = false
	dust_2.emitting = false
