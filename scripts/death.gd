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
	
	# Turn off collision so player becomes a "ghost" (use deferred to avoid physics errors)
	if owner.has_node("CollisionShape2D"):
		owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	# Darken the ship sprite
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

# ===== RUNS WHEN LEAVING DEATH STATE (when respawning) =====
func exit() -> void:
	# Re-enable collision (use deferred to avoid physics errors)
	if owner.has_node("CollisionShape2D"):
		owner.get_node("CollisionShape2D").set_deferred("disabled", false)
	
	# Reset sprite color back to normal
	if owner.has_node("main_body"):
		owner.get_node("main_body").modulate = Color(1, 1, 1)
	
	# Hide death screen
	if death_screen:
		death_screen.visible = false

# ===== SHOWS THE DEATH SCREEN =====
func _on_death_finished() -> void:
	if death_screen:
		death_screen.visible = true
		print("Death screen shown!")
		
		# Find buttons inside VBoxContainer
		var vbox = death_screen.get_node_or_null("VBoxContainer")
		if vbox:
			# Connect Respawn button
			var respawn_btn = vbox.get_node_or_null("RespawnButton")
			if respawn_btn and not respawn_btn.pressed.is_connected(_on_respawn_pressed):
				respawn_btn.pressed.connect(_on_respawn_pressed)
				print("Respawn button connected!")
			
			# Connect Leave button
			var leave_btn = vbox.get_node_or_null("LeaveButton")
			if leave_btn and not leave_btn.pressed.is_connected(_on_leave_pressed):
				leave_btn.pressed.connect(_on_leave_pressed)
				print("Leave button connected!")
		else:
			print("ERROR: VBoxContainer not found!")
	else:
		print("ERROR: No death_screen assigned!")

# ===== BUTTON FUNCTIONS =====

# Called when Respawn button is pressed
func _on_respawn_pressed() -> void:
	print("Respawn button pressed!")
	
	# Hide death screen immediately
	if death_screen:
		death_screen.visible = false
	
	# Reset health to full
	owner.health = owner.max_health
	owner.set_health()
	
	# Reset invincibility
	owner.invincible = false
	
	# Move player back to arena center
	owner.global_position = owner.arena_center
	owner.rotation_degrees = 0
	
	# Switch back to Idle state
	owner._switch_state(state_machine.get_node("Idle"))

# Called when Leave button is pressed
func _on_leave_pressed() -> void:
	print("Leave button pressed!")
	
	# Disconnect from multiplayer
	if NetworkHandler.is_server:
		# If host, shut down the server
		NetworkHandler.connection = null
		NetworkHandler.is_server = false
		print("Server shut down")
	else:
		# If client, disconnect from server
		NetworkHandler.disconnect_client()
		print("Disconnected from server")
	
	# Clear player references
	NetworkHandler.connected_peer_ids.clear()
	NetworkHandler.client_peers.clear()
	ClientNetworkGlobals.id = -1
	
	# Go back to main menu or quit
	# Option 1: Main menu (update the path!)
	# get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
	# Option 2: Just quit the game
	get_tree().quit()
