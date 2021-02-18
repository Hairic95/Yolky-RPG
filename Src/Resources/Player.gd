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

func _init(player_type):
	type = player_type


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
