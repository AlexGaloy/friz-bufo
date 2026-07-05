extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var sprite: Sprite2D = $"Sprite2D"
@onready var container: Control = $"../UI/Container"
var start_y: float

func _ready() -> void:
	start_y = position.y

func _process(delta: float) -> void:
	position.y = start_y + 5*sin(Time.get_ticks_msec()/300.0)

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		for child in container.get_children():
			if child.name == name:
				child.show()
				queue_free()
