extends Node2D

var grid_pos : Vector2 = Vector2(0, 0)

var state : String = ""

var has_been_visited = false

func _ready():
	pass

func _on_TextureButton_pressed():
	AdventureHandler.emit_signal("grid_tile_clicked", self)

func set_texture(texture):
	$BG.texture = texture

func set_disabled(value):
	$Click.disabled = value

func is_enabled():
	return !$Click.disabled
