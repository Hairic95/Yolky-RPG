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

func choose_action():
	
	var chosen_critter = current_critters
	
