extends Area2D
class_name ASteroid

var size_array =[1,2,3,4]

@export var speed = 100

var direction: Vector2

func _ready() -> void:
	var x = randf_range(-1,1)
	var y = randf_range(-1,1)
	direction = Vector2(x,y)

func _process(delta: float) -> void:
	position+=direction*speed*delta
