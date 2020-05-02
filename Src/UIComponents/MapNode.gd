extends Node2D
class_name MapNode

var id

var encounter_type = "battle"

var encounter_data = {
	"enemies" : [
		"bomborolo",
		"bomborolo"
	]
}

var connections = []

func _ready():
	randomize()
	
	#if randi()% 4 == 0:
	#	$TextureButton.texture_normal = load("res://Assets/Textures/Map/unknown_encounter.png")

func _on_TextureButton_pressed():
	AdventureHandler.emit_signal("map_node_selected", self)

func set_disabled(value):
	$TextureButton.disabled = value
