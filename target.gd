extends Sprite2D

@onready var tile: TileMapLayer = $"../TileMapLayer"
@onready var player: CharacterBody2D = $"../Player"
@onready var ray: RayCast2D = $"../Player/RayCast2D"
@onready var ufo: StaticBody2D = $"../UFO"
var speed: int = 1

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	#visible = ufo.state == ufo.states.HELD
	var angle: float = player.global_position.angle_to_point(get_global_mouse_position())
	ray.rotation = angle - PI/2
	if ray.is_colliding():
		ray.target_position.y -= speed
		ray.force_raycast_update()
		speed += 1
	elif ray.target_position.y < 80:
		speed = 1
		ray.target_position.y += speed
		ray.force_raycast_update()
	var loose_pos: Vector2
	if ray.target_position.y > 80:
		if player.global_position.distance_to(get_global_mouse_position()) < 80:
			loose_pos = get_global_mouse_position()
		else:
			loose_pos = player.global_position + Vector2.RIGHT.rotated(angle) * 80
	else:
		loose_pos = player.global_position + (ray.target_position+Vector2(0,-9)).rotated(ray.rotation)
	global_position = tile.to_global(tile.map_to_local(tile.local_to_map(tile.to_local(loose_pos))))
