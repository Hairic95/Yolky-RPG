extends Spatial

var combatant_reference = load("res://Src/Entities/3DCombatant.tscn")
var battlemenu_action_button_reference = load("res://Src/UIComponents/BattleMenuActionButton.tscn")

var players = []

func _ready():
	
	$Camera/Anim.play("CameraTest")
	
	AdventureHandler.connect("map_node_selected", self, "go_to_next_encounter")
	
	BattleTurnHandler.connect("action_selected", self, "set_selected_action")
	BattleTurnHandler.connect("combatant_selected", self, "set_selected_combatant")
	BattleTurnHandler.connect("combat_animation_ended", self, "combat_animation_ended")
	BattleTurnHandler.connect("damage_targets", self, "start_target_combatants_damage_animation")
	BattleTurnHandler.connect("combatant_died", self, "remove_combatant")
	
	BattleTurnHandler.connect("ai_chooses_action_and_combatant", self, "start_action")
	
	BattleTurnHandler.connect("create_popup_at", self, "create_combatant_popup_at")
	
	BattleTurnHandler.connect("battle_ended", self, "show_result")
	
	prepare_battle(
		{
			"type": Player.PlayerType.Player,
			"critters": [
				"potkin",
				"boevit",
				"slandle2"
			]
		},
		{
			"type": Player.PlayerType.AI,
			"critters": [
				"vhrab",
				"peakoli",
				"pandira2"
			]
		}
	)
	

func prepare_battle(player1_data, player2_data):
	
	DataHandler.open_characters()
	DataHandler.open_actions()
	
	var player1 = Player.new(player1_data.type)
	var player2 = Player.new(player2_data.type)
	
	players.append(player1)
	players.append(player2)
	
	var row_position_cont = 1
	for critter_id in player1_data.critters:
		prepare_critter(critter_id, row_position_cont, "left_side")
		row_position_cont += 1
	
	row_position_cont = 1
	for critter_id in player2_data.critters:
		prepare_critter(critter_id, row_position_cont, "right_side")
		row_position_cont += 1
	
	DataHandler.close_characters()
	DataHandler.close_actions()

func prepare_critter(critter_id, row_position, side):
	
	var critter_data = DataHandler.get_character(critter_id)
	
	var new_combatant : Combatant3D = combatant_reference.instance()
	new_combatant.player_owner = side
	var pos_path : NodePath = ""
	
	if side == "left_side":
		pos_path = str("Positions/PlayerPos", row_position)
		new_combatant.scale = Vector3(-1, 1, 1)
	elif side == "right_side":
		pos_path = str("Positions/EnemyPos", row_position)
	
	new_combatant.Combatant(critter_data, get_node(pos_path).translation)
	
	new_combatant.row_position = row_position
	new_combatant.fixed_translation = get_node(pos_path).translation
	
	$Combatants.add_child(new_combatant)

func start_round():
	pass

func start_turn(player : Player):
	if !player.can_start_turn():
		var next_player = get_next_player(player)
		if next_player == null:
			start_round()
		start_turn(next_player)
		return
	
	match player.type:
		Player.PlayerType.Player:
			show_player_ui()
		Player.PlayerType.AI:
			player.choose_action()
	

func get_next_player(player : Player):
	
	for p in players:
		if p == player:
			var index = players.find(p)
			if index == players.size() - 1:
				index = 0
			var next_player = players[index]
			if next_player.can_start_turn():
				return next_player
	return null

func show_player_ui():
	pass
