extends Area2D
class_name Enemy

const ENEMY_COLORS := [
	Color(0.86, 1.0, 0.18, 1.0),
	Color(1.0, 0.28, 0.72, 1.0),
	Color(0.1, 0.94, 1.0, 1.0),
]

@onready var dome: Polygon2D = %Dome
@onready var body: Polygon2D = %Body
@onready var core: Polygon2D = %Core


func set_enemy_index(enemy_index: int) -> void:
	var color: Color = ENEMY_COLORS[enemy_index % ENEMY_COLORS.size()]
	dome.color = Color(color.r, color.g, color.b, 0.72)
	body.color = color
	core.color = Color(0.00784314, 0.00392157, 0.027451, 1.0)


func destroy() -> void:
	queue_free()
