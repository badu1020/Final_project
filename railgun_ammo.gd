extends Area2D
class_name RailgunAmmo

# Railgun stats - FAST projectile
@export var speed: float = 1200.0  # Very fast
@export var damage: float = 35.0
@export var lifetime: float = 3.0  # Destroys after 3 seconds

# Movement direction (set when spawned)
var direction: Vector2 = Vector2.RIGHT

# Internal timer
var time_alive: float = 0.0

func _ready() -> void:
	# Connect collision signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Play animation if available
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	# Move in straight line (not affected by player movement)
	position += direction * speed * delta
	
	# Count lifetime and auto-destroy
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

# Hit a body (player, enemy, wall)
func _on_body_entered(body: Node2D) -> void:
	print("Railgun hit:", body.name)
	
	# Deal damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Destroy projectile
	queue_free()

# Hit another area (shields, other projectiles)
func _on_area_entered(area: Area2D) -> void:
	print("Railgun hit area:", area.name)
	
	# Deal damage
	if area.has_method("take_damage"):
		area.take_damage(damage)
	
	# Destroy projectile
	queue_free()

# Called by Fire state to set direction
func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()
