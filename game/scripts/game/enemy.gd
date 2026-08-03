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

var enemy_id := ""
var max_health := 48.0
var health := 48.0


func set_enemy_id(next_enemy_id: String) -> void:
	enemy_id = next_enemy_id


func set_enemy_health(next_max_health: float) -> void:
	max_health = max(next_max_health, 1.0)
	health = max_health


func apply_damage(amount: float) -> bool:
	health = max(health - max(amount, 0.0), 0.0)

	if health <= 0.0:
		destroy()
		return true

	return false


func set_enemy_index(enemy_index: int) -> void:
	var color: Color = ENEMY_COLORS[enemy_index % ENEMY_COLORS.size()]
	dome.color = Color(color.r, color.g, color.b, 0.72)
	body.color = color
	core.color = Color(0.00784314, 0.00392157, 0.027451, 1.0)


func destroy() -> void:
	queue_free()
