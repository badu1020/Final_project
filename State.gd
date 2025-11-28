extends Node
class_name State

var state_machine
var character : CharacterBody2D

func enter(prev_state: State) -> void:
	pass

func exit() -> void:
	pass

func handle_input(event: InputEvent) -> State:
	return null

func update(delta: float) -> State:
	return null
