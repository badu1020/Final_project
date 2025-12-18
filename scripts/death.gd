extends State
class_name Death

@export var death_delay: float = 1.5
var timer := 0.0
func enter(_prev_state: String) -> void:
	timer = death_delay

	if owner:
		owner.invincible = true
		owner.velocity = Vector2.ZERO

	# Disable collisions
	if owner.has_node("CollisionShape2D"):
		owner.get_node("CollisionShape2D").disabled = true

	# Death visual
	if owner.has_node("Sprite2D"):
		owner.get_node("Sprite2D").modulate = Color(0.3, 0.3, 0.3)

	# Optional: play animation
	if owner.has_node("AnimationPlayer"):
		owner.get_node("AnimationPlayer").play("death")
func update(delta: float) -> void:
	timer -= delta

	if timer <= 0:
		_on_death_finished()
func exit() -> void:
	pass
func _on_death_finished() -> void:
	pass
