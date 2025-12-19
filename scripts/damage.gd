extends State
class_name DamageState

@export var invincibility_duration: float = 1.0
@export var knockback_force: float = 200.0

var timer := 0.0

func enter(_prev_state: String) -> void:
	timer = invincibility_duration

	if owner:
		owner.invincible = true

		if owner.has_node("Sprite2D"):
			owner.get_node("Sprite2D").modulate = Color(1, 0.5, 0.5)

func update(delta: float):
	timer -= delta

	if timer <= 0:
		if owner:
			# Check movement input to decide next state
			if Input.is_action_pressed("forward") or Input.is_action_pressed("back"):
				return state_machine.get_node("Move")
			else:
				return state_machine.get_node("Idle")
	
	return null

func exit() -> void:
	if owner:
		owner.invincible = false

		if owner.has_node("Sprite2D"):
			owner.get_node("Sprite2D").modulate = Color.WHITE
