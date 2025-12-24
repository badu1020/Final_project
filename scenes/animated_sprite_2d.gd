extends AnimatedSprite2D


@export var max_health: int = 50
@onready var current_health: int = max_health

@onready var anim_player = $AnimationPlayer # Make sure you have this node
@onready var sprite = $Sprite2D

var is_dead: bool = false

func take_damage(amount: int):
	if is_dead:
		return
		
	current_health -= amount
	print("Hit! Health remaining: ", current_health)
	
	# Optional: Play a "hit" or "flash" animation here
	
	if current_health <= 0:
		die()

func die():
	is_dead = true
	# Replace "explode" with the exact name of your animation in the AnimationPlayer
	if anim_player.has_animation("explode"):
		anim_player.play("explode")
		# Wait for the animation to finish before deleting the object
		await anim_player.animation_finished
	
	queue_free()
