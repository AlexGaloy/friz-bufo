extends CanvasLayer

@onready var gem_m: TextureRect = $"Container/gem m"
@onready var gem_t: TextureRect = $"Container/gem t"
@onready var gem_c: TextureRect = $"Container/gem c"
@onready var label: Label = $Container/Label
@onready var mini_map: TileMapLayer = $"Container/map/mini map"
@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"
@onready var background: TileMapLayer = $"../background"
@onready var mini_background: TileMapLayer = $"Container/map/mini background"
@onready var mini_cover: TileMapLayer = $"Container/map/mini cover"
@onready var player: CharacterBody2D = $"../Player"
@onready var mini_player: Sprite2D = $"Container/map/mini map/mini player"
@onready var color_rect: ColorRect = $Container/map/ColorRect
@onready var timer: Label = $Container/timer
var start_time: float = 0.0

func _ready() -> void:
	mini_map.tile_map_data = tile_map_layer.tile_map_data
	mini_background.tile_map_data = background.tile_map_data
	var rect = mini_map.get_used_rect().grow(4)
	for x in range(rect.position.x/4, rect.end.x/4):
		for y in range(rect.position.y/4, rect.end.y/4):
			mini_cover.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
	color_rect.size = rect.size
	color_rect.position = rect.position
	start_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
	var elapsed_time = (Time.get_ticks_msec() - start_time)/1000
	if gem_m.visible and gem_t.visible:
		label.show()
	else:
		timer.text = str(int(elapsed_time)/60)+":"
		if fmod(elapsed_time,60) < 10:
			timer.text += "0"
		timer.text += str(roundf(fmod(elapsed_time,60)*100)/100)
	var player_tile_pos: Vector2i = tile_map_layer.local_to_map(tile_map_layer.to_local(player.global_position))
	mini_player.position = mini_map.map_to_local(player_tile_pos) + Vector2(0,1)
	for tile in mini_cover.get_used_cells():
		if mini_cover.local_to_map(mini_cover.to_local(mini_player.global_position)).distance_to(tile) < 5:
			mini_cover.set_cell(tile,-1)
