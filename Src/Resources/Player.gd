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

var opponent_critters = []

var side : String = "left"

func _init(player_id, player_type, field_side):
	id = player_id
	type = player_type
	side = field_side

func can_start_turn():
	for critter in critters:
		if critter.can_act:
			return true
	return false

func choose_action():
	var possible_attackers = []
	for critter in critters:
		if critter.can_act:
			possible_attackers.append(critter)
	var chosen_critter = possible_attackers[randi()%possible_attackers.size()]
	var choose_action = chosen_critter.actions[randi()%chosen_critter.actions.size()]
	var possible_targets = []
	for critter in opponent_critters:
		if !critter.is_ko:
			possible_targets.append(critter)
	var chosen_targets = [possible_targets[randi()%possible_targets.size()]]
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	BattleTurnHandler.emit_signal("ai_action_chosen", chosen_critter, choose_action, chosen_targets)
	

