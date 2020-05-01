extends Node2D

func _ready():
	randomize()
	
	if randi()% 4 == 0:
		$TextureButton.texture_normal = load("res://Assets/Textures/Map/unknown_encounter.png")
