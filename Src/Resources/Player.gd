extends Node
class_name Player

var id : String = ""

enum PlayerType {
	Player = 0,
	AI = 1
	NetPlayer = 2
}

var type = PlayerType.Player

var critters = []

var side : String = "left"

func _init(id, player_type, field_side):
	id = id
	type = player_type
	side = field_side

func can_start_turn():
	for critter in critters:
		if critter.can_act:
			return true
	return false

func choose_action():
	
	var chosen_critter = critters
	

