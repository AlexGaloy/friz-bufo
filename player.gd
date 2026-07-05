extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var beam: RayCast2D = $"../UFO/beam"
@onready var tile: TileMapLayer = $"../TileMapLayer"
@onready var ufo: StaticBody2D = $"../UFO"
@onready var spikes: TileMapLayer = $"../spikes"
@onready var coyote_timer: Timer = $"coyote timer"
@onready var jump_timer: Timer = $"jump timer"
var timing: bool = false
var spawnpoint: Vector2 = Vector2(0,-40)
var checkpoint: StaticBody2D = null

func _ready() -> void:
	pass # Replace with function body.

func respawn():
	ufo.start_holding()
	global_position = spawnpoint

func _process(delta: float) -> void:
	#move left and right based on keys otherwise stop
	if Input.is_action_pressed("left"):
		velocity.x = -100
		sprite.flip_h = false
	elif Input.is_action_pressed("right"):
		velocity.x = 100
		sprite.flip_h = true
	else:
		velocity.x = 0
	#jump if possible and fall if not on the ground
	if beam.get_collider() == $"." and beam.visible:
		if is_equal_approx(velocity.y,0):
			velocity.y = -300
		elif velocity.y < -200:
			velocity.y += 5
		else:
			velocity.y = -200
	else:
		if is_on_floor():
			timing = false
		else:
			if Input.is_action_just_pressed("jump"):
				jump_timer.start(.1)
			if velocity.y < 0:
				timing = true
			if timing == false:
				timing = true
				coyote_timer.start(.175)
			velocity.y += 5 + 1.5*(sign(velocity.y)+1)
		if is_on_floor() or !coyote_timer.is_stopped():
			if Input.is_action_just_pressed("jump") or !jump_timer.is_stopped():
				velocity.y = -250
				coyote_timer.stop()
				jump_timer.stop()
	move_and_slide()

func _on_feet_body_entered(body: Node2D) -> void:
	if body == spikes:
		var tile_pos: Vector2i = spikes.local_to_map(spikes.to_local(global_position))
		var check_pos: Vector2i = tile_pos
		while spikes.get_cell_source_id(check_pos) == -1 and check_pos.y - tile_pos.y < 3 and tile.get_cell_source_id(tile.local_to_map(tile.to_local(spikes.to_global(spikes.map_to_local(check_pos))))) == -1 and spikes.to_global(spikes.map_to_local(check_pos)) != ufo.global_position:
			check_pos.y += 1
		if spikes.get_cell_source_id(check_pos) != -1:
			respawn()

func _on_head_body_entered(body: Node2D) -> void:
	if body == spikes:
		respawn()
