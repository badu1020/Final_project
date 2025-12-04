extends Node
class_name State

var character
var state_machine

func enter(prev_state): pass
func exit(): pass
func handle_input(event): return null
func update(delta): return null
