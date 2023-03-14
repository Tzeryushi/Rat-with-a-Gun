extends ParticleAnimation

@onready var flare := $MuzzleFlare

func _process(_delta) -> void:
	if !flare.emitting:
		finished.emit()

func play() -> void:
	flare.emitting = true

func stop() -> void:
	flare.emitting = false
