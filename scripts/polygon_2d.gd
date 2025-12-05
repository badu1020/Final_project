extends Polygon2D

func _ready():
	var radius = 2500
	var points = []
	var segments = 64  # higher = smoother
	for i in range(segments):
		var angle = i * (TAU / segments)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	polygon = points
