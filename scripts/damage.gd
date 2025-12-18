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
func update(delta: float) -> void:
	timer -= delta

	if timer <= 0:
		state_machine.change_state("Idle")
func exit() -> void:
	if owner:
		owner.invincible = false

		if owner.has_node("Sprite2D"):
			owner.get_node("Sprite2D").modulate = Color.WHITE
