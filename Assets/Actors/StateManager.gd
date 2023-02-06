extends Node

export var first_state : NodePath

var current_state : BaseState

#a generic state manager that should work with all inherited actors
#various states will be specialized for actors, but these functions should remain relevant

func swap_state(new_state:BaseState) -> void:
	#swaps in new state, unless it is the same state
	#cycle out of state as long as it exists
	if current_state:
		if current_state == new_state:
			assert(current_state == new_state, "ERROR: Actor state swapped to itself!") #this shouldn't ever happen
		current_state.on_exit()
	current_state = new_state
	current_state.on_enter()

func init_state(actor:Actor) -> void:
	#iterate through child nodes of StateManager to inject actor ref
	for state in get_children():
		if state is BaseState:
			state.actor = actor
	
	#start at predesignated first state
	swap_state(get_node(first_state))

func input(event:InputEvent) -> void:
	#called through actor process
	#if state interpretation changes state, swap to new state
	var new_state = current_state.input(event)
	if new_state:
		swap_state(new_state)

func process(delta:float) -> void:
	#called through actor process
	#if state interpretation changes state, swap to new state
	var new_state = current_state.process(delta)
	if new_state:
		swap_state(new_state)

func physics_process(delta:float) -> void:
	#called through actor physics process
	#if state interpretation changes state, swap to new state
	var new_state = current_state.physics_process(delta)
	if new_state:
		swap_state(new_state)
