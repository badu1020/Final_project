extends Node
class_name StateMachine

@export var initial_state : State
@export var Move : State
@export var damage : State
var current_state : State
var character : CharacterBody2D
var state_machine


func _ready() -> void:
	character = get_parent()
	
	# Pass references to all child states
	for child in get_children():
		if child is State:
			child.state_machine = self
			child.character = character

	current_state = initial_state
	current_state.enter(null)

func _process(delta: float) -> void:
	if current_state == null:
		return

	var new_state = current_state.update(delta)
	if new_state:
		current_state.enter(new_state)

func _input(event: InputEvent) -> void:
	if current_state == null:
		return
		
	var new_state = current_state.handle_input(event)
	if new_state:
		current_state.enter(new_state)

#func transition_to(new_state: State) -> void:
	#current_state.exit()
	#new_state.enter(current_state)
	#current_state = new_state
