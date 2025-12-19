extends Node  # Or whatever node is the child of the Area2D

@export var move_speed: float = 200.0
@export var arena_radius: float = 2500.0
@export var arena_center: Vector2 = Vector2.ZERO  # center of the arena

var velocity: Vector2 = Vector2.ZERO

func _ready():
	# Give a random initial direction
	var angle = randf() * TAU
	velocity = Vector2(cos(angle), sin(angle)) * move_speed

func _process(delta):
	# Move the parent asteroid (Area2D)
	var asteroid = get_parent()  # assumes this node is child of the Area2D
	asteroid.position += velocity * delta

	# Calculate distance from arena center
	var to_center = asteroid.position - arena_center
	var distance = to_center.length()

	# Bounce if outside circular arena
	if distance > arena_radius:
		var normal = to_center.normalized()
		velocity = velocity - 2 * velocity.dot(normal) * normal
		asteroid.position = arena_center + normal * arena_radius
