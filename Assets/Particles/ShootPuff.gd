extends ParticleAnimation

@onready var dust_1 := $Dust1

func _process(_delta) -> void:
	if !dust_1.emitting:
		finished.emit()

func play() -> void:
	dust_1.emitting = true

func stop() -> void:
	dust_1.emitting = false
