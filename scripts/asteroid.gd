extends Area2D
class_name ASteroid

var size_array = [1, 2, 3, 4]
@export var speed = 100
var direction: Vector2
var is_networked: bool = false  # Flag to prevent random direction generation

func _ready() -> void:
	# Only generate random direction if not set by network
	if !is_networked:
		var x = randf_range(-1, 1)
		var y = randf_range(-1, 1)
		direction = Vector2(x, y).normalized()

func _process(delta: float) -> void:
	position += direction * speed * delta

# Called by spawner when creating from network data
func setup_from_network(dir: Vector2, scale_val: float) -> void:
	is_networked = true
	direction = dir.normalized()
	scale = Vector2(scale_val, scale_val)
