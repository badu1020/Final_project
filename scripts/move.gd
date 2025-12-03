extends Node
class_name move

@export var move_speed : float = 150.0

func update_state(character: CharacterBody2D, delta: float) -> Dictionary:
	# Forward/back control
	var forward := Input.get_action_strength("forward") - Input.get_action_strength("back")

	# No input? Switch to idle.
	if abs(forward) < 0.01:
		return {
			"state": "Idle",
			"playback": "Idle"
		}

	# Move based on character rotation
	var forward_vector := Vector2.UP.rotated(character.rotation)
	character.velocity = forward_vector * (forward * move_speed)
	character.move_and_slide()

	# Return movement state info
	return {
		"state": "Move",
		"playback": "move"
	}
