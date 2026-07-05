extends Area2D

@onready var ufo: StaticBody2D = $"../UFO"
@onready var ufo_area: Area2D = $"../UFO/Area2D"

func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	if ufo_area in get_overlapping_areas() and ufo.state == ufo.states.FLYING:
		if ufo.global_position.distance_to(global_position) < 7:
			ufo.global_position = global_position
			ufo.start_floating()
		else:
			var angle = ufo.global_position.angle_to_point(global_position)
			ufo.velocity /= 8
			ufo.velocity += 4 * Vector2.RIGHT.rotated(angle)
