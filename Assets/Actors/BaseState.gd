class_name BaseState
extends Node

#States should return null if they do not change!
#This is some moderate coupling, but it allows state managers to know whether to change or not

func on_enter() -> void:
	#execute when state is entered
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
