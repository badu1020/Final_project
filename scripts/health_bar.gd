extends ProgressBar

func _ready():
	# Style the health bar
	add_theme_stylebox_override("background", create_background())
	add_theme_stylebox_override("fill", create_fill())

func create_background() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)  # Dark gray background
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color.BLACK
	return style

func create_fill() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color.GREEN  # Will be overridden by modulate
	return style
