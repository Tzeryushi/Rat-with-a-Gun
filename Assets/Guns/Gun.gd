class_name Gun
extends Node2D

export var _damage : int = 10
export var _knockback : float = 100
export var _firing_speed : float = 0.5
export var _reload_time : float = 1
export var _clip_size : int = 6

#prototype to be inherited by other guns, structures are referenced by PlayerRat class
#initial internal data should be protected, effects and stat alterations will be returned with getter functions

func get_knockback() -> float:
	#todo: factor in value changes from effects? should that be on the player?
	return _knockback
