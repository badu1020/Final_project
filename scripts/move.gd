extends State
class_name Move

@onready var eng = $"../../thrusters"

var arena_center := Vector2.ZERO
var arena_radius := 2500
var idle_timer = 0.1
var time_in_state = 0.0

func enter(prev_state):
	pass

func update(delta):
	eng.play("frig_engine_move")
	time_in_state += delta
	# --- Forward/back input ---
	var move_input = Input.get_action_strength("forward") - Input.get_action_strength("back")
	
	if time_in_state > idle_timer and (move_input) == 0:
		# Idle check
		var turn_input = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
		if abs(turn_input) < 0.01:
			return state_machine.get_node("Idle")
		return null

	var direction = Vector2.UP.rotated(deg_to_rad(character.rotation_degrees))
	var desired_move = direction * move_input * character.move_speed * delta

	# --- Clamp to circle ---
	var new_pos = character.global_position + desired_move
	var offset = new_pos - arena_center
	if offset.length() > arena_radius:
		# Keep the player inside: move along the edge if necessary
		var edge_pos = arena_center + offset.normalized() * arena_radius
		new_pos = edge_pos

	character.global_position = new_pos

	return null
