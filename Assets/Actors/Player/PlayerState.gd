class_name PlayerState
extends BaseState

export var animation_type : String #this is used when entering a state

var actor: PlayerRat

func on_enter() -> void:
	#execute when state is entered
	#this will be overwritten by inheritors, will need to be referenced if needed
	actor.animations.play(animation_type)
	pass

func on_exit() -> void:
	#execute when when is exited into another state
	pass

func input(_event:InputEvent) -> BaseState:
	#execute when actor receives input
	#returns the state of the actor, which may have changed
	return null

func process(_delta:float) -> BaseState:
	#execute to define process loop functionality in state
	#returns the state of the actor, which may have changed
	return null

func physics_process(_delta:float) -> BaseState:
	#execute to define physics process loop functionality in state
	#returns the state of the actor, which may have changed
	return null
