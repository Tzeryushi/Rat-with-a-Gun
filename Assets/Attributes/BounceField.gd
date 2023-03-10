extends Area2D

@onready var parent_actor : Actor = get_parent()

#when added to an actor, will add a field that can be bounced on by the player
#while this generally will only interact directly with the PlayerRat class,
#it could be expanded in the future if need be 

@export var stomp_strength : float = 1.0

func get_stomp_strength() -> float:
	return stomp_strength

func bounce_parent() -> void:
	parent_actor.be_bounced_on()
