extends Node
class_name Player

var id : String = ""

enum PlayerType {
	Player = 0,
	AI = 1
	NetPlayer = 2
}

var type = PlayerType.Player

var current_critters = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
