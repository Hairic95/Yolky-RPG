extends Sprite

var grid_pos : Vector2 = Vector2(0, 0)

var state : String = ""

func _ready():
	pass

func _on_TextureButton_pressed():
	
	AdventureHandler.emit_signal("grid_tile_clicked", self)
