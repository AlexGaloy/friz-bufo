extends StaticBody2D

enum states {
	HELD,
	FLYING,
	FLOATING,
	RETURNING
}
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var player: CharacterBody2D = $"../Player"
@onready var tile: TileMapLayer = $"../TileMapLayer"
@onready var area_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var feet: Area2D = $"../Player/feet"
@onready var beam: RayCast2D = $beam
@onready var beam_sprite: Sprite2D = $beam/Sprite2D
@onready var area: Area2D = $Area2D
@onready var spikes: TileMapLayer = $"../spikes"
var start_pos: Vector2 = Vector2.ZERO
var state: states = states.FLOATING
var velocity: Vector2 = Vector2(0,0)
var ground_pos: Vector2


func _ready() -> void:
	start_floating()

func start_holding():
	state = states.HELD
	#reset appearance and orientation and beam collision
	area.monitoring = false
	beam.enabled = false
	beam.hide()
	sprite.play("idle")
	sprite.flip_v = false
	rotation = 0

func start_flying():
	state = states.FLYING
	start_pos = position
	sprite.play("spin")
	var angle: float = player.global_position.angle_to_point(get_global_mouse_position())
	velocity = 2 * Vector2.RIGHT.rotated(angle)
	rotation = angle
	if rotation_degrees > 90 or rotation_degrees < -90:
		sprite.flip_v = true
	sprite.play("spin")
	area.monitoring = true

func start_floating():
	position = tile.map_to_local(tile.local_to_map(position))
	if tile.get_cell_source_id(tile.local_to_map(tile.to_local(global_position))) != -1:
		start_returning()
		return
	state = states.FLOATING
	ground_pos = tile.local_to_map(tile.to_local(global_position))
	#creating the beam visually
	#the postition of the ufo in respect to the tilemap
	var tile_pos: Vector2i = tile.local_to_map(tile.to_local(global_position))
	if Vector2i(ground_pos) == tile_pos:
		#check all tiles going down from ufo position until a tile is found
		var check_pos: Vector2i = tile_pos
		while tile.get_cell_source_id(check_pos) == -1 and check_pos.y < 100:
			check_pos.y += 1
		ground_pos = check_pos
		#set the size and position of the beam based on the distance
		beam_sprite.scale.y = abs(ground_pos.y-tile_pos.y) - 1
		beam_sprite.position.y = (beam_sprite.scale.y * 8) + 2
		beam.target_position.y = (2*beam_sprite.position.y) + 4
	#reset UFO orientation, appearance, and collision
	beam.enabled = true
	beam.show()
	sprite.flip_v = false
	rotation = 0 
	sprite.play("float")

func start_returning():
	state = states.RETURNING
	#disable collsion check
	beam.enabled = false
	beam.hide()
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	sprite.play("spin")

func _process(_delta: float) -> void:
	if  state == states.FLOATING or state == states.HELD:
		sprite_2.animation = sprite.animation
		sprite_2.frame = sprite.frame
		sprite_2.show()
	else:
		sprite_2.hide()
	match state:
		states.HELD:
			#always stay at player pos
			position = player.position + Vector2(0,4)
			#if thrown, fly towards mouse
			if Input.is_action_just_pressed("throw"):
				start_flying()
		states.FLYING:
			#move towards mouse
			position += velocity
			#if its too far return
			if start_pos.distance_to(position) > 80:
				start_returning()
		states.RETURNING:
			#move towards player always and rotate to face player
			var angle: float = global_position.angle_to_point(player.global_position)
			velocity = 2 * Vector2.RIGHT.rotated(angle)
			rotation = angle + PI
			#if close enough, change state to held
			if position.distance_to(player.position) < 5:
				start_holding()
			position += velocity
		states.FLOATING:
			#if player is standing on it, collide
			if $"." in feet.get_overlapping_bodies():
				set_collision_layer_value(1,true)
				set_collision_mask_value(1,true)
			else:
				set_collision_layer_value(1,false)
				set_collision_mask_value(1,false)
			#bring back to hand if clicked
			if Input.is_action_just_pressed("throw"):
				start_returning()

#check for collision with tilemap and snap to tilemap grid
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == tile and state == states.FLYING:
		start_floating()
	if body == spikes:
		start_returning()
	if body.name.contains("checkpoint"):
		position.y -= 16
		position.x = body.position.x
		start_floating()
