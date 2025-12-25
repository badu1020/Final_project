extends Node2D

@export var max_range: float = 1000.0
@export var base_damage: float = 50.0

@onready var ray_cast = $RayCast2D
@onready var line_2d = $Line2D
@onready var impact_sprite = $ImpactSprite # The sprite at the hit point

func _ready():
	# Set the laser's max reach
	ray_cast.target_position = Vector2(max_range, 0)
	
	# Initialize Line2D with 2 points (start and end)
	line_2d.points = [Vector2.ZERO, Vector2(max_range, 0)]
	# Set the laser's max reach
	ray_cast.target_position = Vector2(max_range, 0)

func _physics_process(delta: float) -> void:
	if ray_cast.is_colliding():
		# 1. Get the collision point
		var hit_point = to_local(ray_cast.get_collision_point())
		
		# 2. Position the Visuals
		line_2d.points[1] = hit_point
		impact_sprite.visible = true
		impact_sprite.position = hit_point
		
		# 3. Calculate Intensity (Falloff)
		var distance = global_position.distance_to(ray_cast.get_collision_point())
		var intensity = clamp(1.0 - (distance / max_range), 0.0, 1.0)
		
		# Adjust visuals based on intensity
		line_2d.width = 15.0 * intensity
		impact_sprite.scale = Vector2.ONE * intensity
		
		# 4. Damage the "Victim"
		var victim = ray_cast.get_collider()
		if victim and victim.has_method("take_damage"):
			# This triggers the victim's logic
			victim.take_damage(base_damage * intensity * delta)
	else:
		# If hitting nothing, extend to max range but make it look "off"
		line_2d.points[1] = ray_cast.target_position
		impact_sprite.visible = false
		line_2d.width = 2.0 # Thin "idle" beam
