class_name ParticleAnimation
extends Node

signal finished

func play() -> void:
	emit_signal("finished")
	pass

func stop() -> void:
	emit_signal("finished")
	pass
