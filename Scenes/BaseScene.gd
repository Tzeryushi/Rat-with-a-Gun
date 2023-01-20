extends Node2D

class_name BaseScene

#BaseScene is inherited by all major scenes
#It contains basic architecture that can be generically referenced by the Main node
#Each scene that inherits BaseScene can specify its own behavior

#while some of this behavior could be accomplished in a _ready function, it will not
#function correctly for scenes that are preloaded. Custom functions for these scenes
#are a must.

func start_up() -> void:
	#start_up is to be called by the main layer when a scene is first loaded.
	pass
	
func on_reveal() -> void:
	#on_reveal is meant to be called each time a scene is transitioned in and become visible to the player.
	pass

func clean_up() -> void:
	#clean_up is to be called BEFORE a scene node is removed.
	pass
