extends CanvasLayer

@onready var gem_m: TextureRect = $"Container/gem m"
@onready var gem_t: TextureRect = $"Container/gem t"
@onready var gem_c: TextureRect = $"Container/gem c"
@onready var label: Label = $Container/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gem_m.visible and gem_t.visible:
		label.show()
