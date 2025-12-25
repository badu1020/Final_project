extends State
class_name AvtoFireState

# --- Configuration ---
@export var projectile_scene: PackedScene
@export var fire_rate: float = 0.2  # Time between bursts
@export var detection_range: float = 800.0
@export var aim_cone_angle: float = 120.0

# --- Internal Variables ---
var fire_timer: float = 0.0
var firing_markers: Array[Marker2D] = []

func enter(_prev_state: String) -> void:
	fire_timer = 0.0 # Fire immediately upon entering state
	
	# Find all markers (Marker2D to Marker2D6) on the owner
	firing_markers.clear()
	var marker_names = ["Marker2D", "Marker2D2", "Marker2D3", "Marker2D4", "Marker2D5"]
	
	for m_name in marker_names:
		var m = owner.get_node_or_null(m_name)
		if m is Marker2D:
			firing_markers.append(m)
			
	if firing_markers.is_empty():
		print("Warning: FireState found no Marker2Ds on ", owner.name)

func physics_update(delta: float) -> void:
	# If no markers exist, we can't fire, so go back to Idle
	if firing_markers.is_empty():
		state_machine.transition_to("Idle")
		return

	fire_timer -= delta
	
	# Logic: Find a target. If found and timer is ready, fire.
	var target = find_nearest_target()
	
	if target:
		if fire_timer <= 0:
			fire_at_target(target)
			fire_timer = fire_rate
	else:
		# If no target is in range, return to Idle or Move state
		state_machine.transition_to("Idle")

func find_nearest_target() -> Node2D:
	# Use the first marker as the eye/pivot for detection
	var ref_marker = firing_markers[0]
	
	var space_state = owner.get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	
	var shape = CircleShape2D.new()
	shape.radius = detection_range
	query.shape = shape
	query.transform = owner.global_transform
	query.collision_mask = 2 # Target Layer (Enemies)
	
	var results = space_state.intersect_shape(query)
	if results.is_empty(): return null
	
	var nearest_target = null
	var nearest_distance = INF
	# Ship's forward direction (usually -transform.y for top-down)
	var forward_dir = -owner.global_transform.y 
	
	for result in results:
		var target = result.collider
		if target == owner: continue
		
		var to_target = (target.global_position - ref_marker.global_position).normalized()
		var angle_to_target = rad_to_deg(forward_dir.angle_to(to_target))
		
		if abs(angle_to_target) <= aim_cone_angle / 2.0:
			var dist = ref_marker.global_position.distance_to(target.global_position)
			if dist < nearest_distance:
				nearest_distance = dist
				nearest_target = target
				
	return nearest_target

func fire_at_target(target: Node2D) -> void:
	for marker in firing_markers:
		var p = projectile_scene.instantiate()
		# Add to the scene tree root or main world so projectiles don't move with the player
		owner.get_parent().add_child(p)
		
		p.global_position = marker.global_position
		
		# Set direction for the projectile
		var dir = (target.global_position - marker.global_position).normalized()
		if p.has_method("set_direction"):
			p.set_direction(dir)
		else:
			# Fallback if your projectile uses rotation
			p.rotation = dir.angle()

func exit() -> void:
	# Reset timer when leaving the state
	fire_timer = 0.0
