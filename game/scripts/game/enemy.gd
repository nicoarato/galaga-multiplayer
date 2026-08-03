extends Area2D
class_name Enemy

@onready var dome: Polygon2D = %Dome
@onready var body: Polygon2D = %Body
@onready var core: Polygon2D = %Core
@onready var left_light: Polygon2D = %LeftLight
@onready var right_light: Polygon2D = %RightLight

var enemy_id := ""
var enemy_type_id := "drone"
var max_health := 48.0
var health := 48.0


func set_enemy_id(next_enemy_id: String) -> void:
	enemy_id = next_enemy_id


func set_enemy_health(next_max_health: float) -> void:
	max_health = max(next_max_health, 1.0)
	health = max_health


func set_enemy_type(next_enemy_type_id: String, stats: Dictionary) -> void:
	enemy_type_id = next_enemy_type_id
	set_enemy_health(float(stats.get("health", 48.0)))

	var color: Color = stats.get("color", Color(0.86, 1.0, 0.18, 1.0))
	var visual_scale := float(stats.get("scale", 1.0))
	scale = Vector2.ONE * visual_scale
	dome.color = Color(color.r, color.g, color.b, 0.72)
	body.color = color
	left_light.color = Color(1.0, color.g, color.b, 1.0)
	right_light.color = Color(color.r, 0.2, 1.0, 1.0)
	core.color = Color(0.00784314, 0.00392157, 0.027451, 1.0)


func apply_damage(amount: float) -> bool:
	health = max(health - max(amount, 0.0), 0.0)

	if health <= 0.0:
		destroy()
		return true

	return false


func destroy() -> void:
	queue_free()
