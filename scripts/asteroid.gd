extends Area2D
class_name ASteroid

var size_array = [1, 2, 3, 4]
@export var speed = 100
var direction: Vector2
var is_networked: bool = false
var random_generator: RandomNumberGenerator  # NEW

func _ready() -> void:
	if !is_networked:
		var x = randf_range(-1, 1)
		var y = randf_range(-1, 1)
		direction = Vector2(x, y).normalized()

func _process(delta: float) -> void:
	position += direction * speed * delta

func setup_from_network(dir: Vector2, scale_val: float) -> void:
	is_networked = true
	direction = dir.normalized()
	scale = Vector2(scale_val, scale_val)
	
