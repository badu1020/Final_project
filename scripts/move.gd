extends State
class_name Move

@onready var eng = $"../../thrusters"

var arena_center := Vector2.ZERO
var arena_radius := 2500.0
var idle_timer := 0.1
var time_in_state := 0.0
var animation

func _ready() -> void:
	match ConfigHandler.load_ship_size():
		0:
			animation = "frig_engine_move"
		1:
			animation = "cruiser_engine_move"
		2:
			animation = "destroyer_engine_move"
		_:
			animation = "frig_engine_move"

func enter(_prev_state):
	time_in_state = 0.0

func update(delta):
	eng.play(animation)
	time_in_state += delta

	# ✅ Declare inputs FIRST so they exist in full scope
	var move_input := 0.0
	var turn_input := 0.0

	if owner.is_authority:
		# --- Forward / back ---
		move_input = Input.get_action_strength("forward") \
			- Input.get_action_strength("back")

		# --- Turn ---
		turn_input = Input.get_action_strength("turn_right") \
			- Input.get_action_strength("turn_left")



	# --- Idle transition check ---
	if time_in_state > idle_timer and move_input == 0.0 and abs(turn_input) < 0.01:
		if state_machine.has_method("set_state"):
			state_machine.set_state("Idle")

	return null
