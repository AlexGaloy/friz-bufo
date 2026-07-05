extends StaticBody2D

@onready var area: Area2D = $Area2D
@onready var ufo: StaticBody2D = $"../UFO"
@onready var player: CharacterBody2D = $"../Player"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if player.checkpoint == $".":
		sprite.animation = "active"
	else:
		sprite.animation = "inactive"


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() == ufo and ufo.state == ufo.states.FLOATING:
		player.spawnpoint = position + Vector2(0,-16)
		player.checkpoint = $"."
