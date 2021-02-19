extends Spatial

var combatant_reference = load("res://Src/Entities/3DCombatant.tscn")
var battlemenu_action_button_reference = load("res://Src/UIComponents/BattleMenuActionButton.tscn")

var current_player = null
var players = []

func _ready():
	
	randomize()
	
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
			"id": "1",
			"type": Player.PlayerType.Player,
			"critters": [
				"potkin",
				"boevit",
				"slandle2"
			]
		},
		{
			"id": "2",
			"type": Player.PlayerType.AI,
			"critters": [
				"vhrab",
				"peakoli",
				"pandira2"
			]
		}
	)
	
	start_round()

func prepare_battle(player1_data, player2_data):
	
	DataHandler.open_characters()
	DataHandler.open_actions()
	
	var player1 = Player.new(player1_data.id, player1_data.type, "left")
	var player2 = Player.new(player2_data.id, player2_data.type, "right")
	
	players.append(player1)
	players.append(player2)
	
	if player1.type == Player.PlayerType.Player:
		current_player = player1
	
	var row_position_cont = 1
	for critter_id in player1_data.critters:
		prepare_critter(critter_id, row_position_cont, player1)
		row_position_cont += 1
	
	row_position_cont = 1
	for critter_id in player2_data.critters:
		prepare_critter(critter_id, row_position_cont, player2)
		row_position_cont += 1
	
	DataHandler.close_characters()
	DataHandler.close_actions()

func prepare_critter(critter_id, row_position, player):
	
	var critter_data = DataHandler.get_character(critter_id)
	
	var new_critter : Combatant3D = combatant_reference.instance()
	new_critter.player_owner = player.id
	var pos_path : NodePath = ""
	
	if player.side == "left":
		pos_path = str("Positions/PlayerPos", row_position)
		new_critter.scale = Vector3(-1, 1, 1)
	elif player.side == "right":
		pos_path = str("Positions/EnemyPos", row_position)
	
	new_critter.Combatant(critter_data, get_node(pos_path).translation)
	
	new_critter.row_position = row_position
	new_critter.fixed_translation = get_node(pos_path).translation
	
	$Critters.add_child(new_critter)
	
	player.critters.append(new_critter)

func start_round():
	for critter in $Critters.get_children():
		if !critter.is_ko:
			critter.can_act = true
	
	start_turn(players[randi()%players.size()])

func start_turn(player : Player):
	if !player.can_start_turn():
		var next_player = get_next_player(player)
		if next_player == null:
			start_round()
		if next_player.can_start_turn():
			start_turn(next_player)
			return
		# tie result
	
	match player.type:
		Player.PlayerType.Player:
			$UI/TestTurn.text = "Your Turn"
			show_player_ui()
		Player.PlayerType.AI:
			$UI/TestTurn.text = "Opponent Turn"
			player.choose_action()

func get_next_player(player : Player):
	for p in players:
		if p == player:
			var index = players.find(p)
			if index == players.size() - 1:
				index = 0
			var next_player = players[index]
			return next_player
	return null

func show_player_ui():
	for critter in current_player.critters:
		var new_critter_button = Button.new()
		new_critter_button.text = critter.critter_name
		
		new_critter_button.connect("pressed", self, "show_critter_actions", [critter])
		
		$UI/Critters.add_child(new_critter_button)

func show_critter_actions(critter):
	
	for old_button in $UI/Actions.get_children():
		old_button.queue_free()
	
	for action in critter.actions:
		var new_action_button = Button.new()
		new_action_button.text = action.action_name
		
		new_action_button.connect("pressed", self, "show_critter_actions", [critter])
		
		$UI/Actions.add_child(new_action_button)
