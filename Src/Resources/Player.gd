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
	var possible_actions = []
	for action in chosen_critter.actions:
		if action.current_uses > 0:
			possible_actions.append(action)
	var chosen_action = possible_actions[randi()%possible_actions.size()]
	var possible_targets = []
	match chosen_action.target:
		"ally_single", "ally_all":
			for c in critters:
				if !c.is_ko:
					possible_targets.append(c)
		"enemy_single", "enemy_all":
			for c in opponent_critters:
				if !c.is_ko:
					possible_targets.append(c)
		"self":
			possible_targets.append(chosen_critter)
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	if chosen_action.target.ends_with("single"):
		var chosen_targets = [possible_targets[randi()%possible_targets.size()]]
		BattleTurnHandler.emit_signal("ai_action_chosen", chosen_critter, chosen_action, chosen_targets)
	else:
		BattleTurnHandler.emit_signal("ai_action_chosen", chosen_critter, chosen_action, possible_targets)
	
	

