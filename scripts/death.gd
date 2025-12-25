extends State
class_name Death

# Drag your DeathScreen Control node here in the inspector
@export var death_screen: Control

# How long to wait before showing death screen (in seconds)
@export var death_delay: float = 1.5

# Internal timer
var timer := 0.0

# ===== RUNS ONCE WHEN PLAYER DIES =====
func enter(_prev_state: String) -> void:
	# Start the countdown timer
	timer = death_delay
	
	# Make player invincible and stop all movement
	if owner:
		owner.invincible = true
		owner.velocity = Vector2.ZERO
	
	# Turn off collision so player becomes a "ghost"
	if owner.has_node("CollisionShape2D"):
		owner.get_node("CollisionShape2D").disabled = true
	
	# Darken the ship sprite (FIXED: uses "main_body" instead of "Sprite2D")
	if owner.has_node("main_body"):
		owner.get_node("main_body").modulate = Color(0.3, 0.3, 0.3)
	
	# Play death animation if you have one
	if owner.has_node("AnimationPlayer"):
		owner.get_node("AnimationPlayer").play("death")
	
	# Make sure death screen is hidden initially
	if death_screen:
		death_screen.visible = false

# ===== RUNS EVERY FRAME WHILE DEAD =====
func update(delta: float) -> void:
	# Count down the timer
	timer -= delta
	
	# When timer reaches 0, show the death screen
	if timer <= 0:
		_on_death_finished()
	# Stay in death state (don't transition)
# ===== RUNS WHEN LEAVING DEATH STATE (when respawning) =====
func exit() -> void:
	# Re-enable collision
	if owner.has_node("CollisionShape2D"):
		owner.get_node("CollisionShape2D").disabled = false
	
	# Reset sprite color back to normal
	if owner.has_node("main_body"):
		owner.get_node("main_body").modulate = Color(1, 1, 1)
	
	# Hide death screen
	if death_screen:
		death_screen.visible = false

# ===== SHOWS THE DEATH SCREEN =====
func _on_death_finished() -> void:
	# Show the death panel
	if death_screen:
		death_screen.visible = true
		get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
		print("Death screen shown!")
	else:
		print("ERROR: No death_screen assigned in Death state inspector!")
	
	# The buttons will be connected in your DeathScreen script
	# or you can connect them here if needed
