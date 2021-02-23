extends Spatial

var combatant_reference = load("res://Src/Entities/BattleCritter.tscn")
var battlemenu_action_button_reference = load("res://Src/UIComponents/BattleMenuActionButton.tscn")

var first_player = null
var current_player = null
var players = []

func _ready():
	
	BattleTurnHandler.connect("ai_action_chosen", self, "execute_action")
	BattleTurnHandler.connect("create_popup_at", self, "create_combatant_popup_at")
	
	randomize()
	
	$Camera/Anim.play("CameraTest")
	
	
	prepare_battle(
		{
			"id": "1",
			"type": Player.PlayerType.Player,
			"critters": [
				"pandira2",
				"boevit",
				"slandle2"
			]
		},
		{
			"id": "2",
			"type": Player.PlayerType.AI,
			"critters": [
				"vhrab",
				"potkin",
				"peakoli"
			]
		}
	)
	first_player = players[randi()%players.size()]
	start_round(first_player)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		go_to_next_turn()

func prepare_battle(player1_data, player2_data):
	
	DataHandler.open_characters()
	DataHandler.open_actions()
	
	var player1 = Player.new(player1_data.id, player1_data.type, "left")
	var player2 = Player.new(player2_data.id, player2_data.type, "right")
	
	players.append(player1)
	players.append(player2)
	
	$Players.add_child(player1)
	$Players.add_child(player2)
	
	if player1.type == Player.PlayerType.Player:
		current_player = player1
	
	if player2.type == Player.PlayerType.AI:
		player2.opponent_critters = player1.critters
	
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
	
	var new_critter = combatant_reference.instance()
	var pos_path : NodePath = ""
	
	if player.side == "left":
		pos_path = str("Positions/PlayerPos", row_position)
		new_critter.scale = Vector3(-1, 1, 1)
	elif player.side == "right":
		pos_path = str("Positions/EnemyPos", row_position)
		new_critter.set_enemy_target()
	
	new_critter.init(critter_data, player, get_node(pos_path).translation)
	
	new_critter.row_position = row_position
	new_critter.fixed_translation = get_node(pos_path).translation
	
	$Critters.add_child(new_critter)
	
	player.critters.append(new_critter)

func start_round(first_player):
	for critter in $Critters.get_children():
		if !critter.is_ko:
			critter.can_act = true
	
	current_player = first_player
	
	start_turn()

func start_turn():
	hide_player_ui()
	match current_player.type:
		Player.PlayerType.Player:
			$UI/MessageBox/Message.text = "Your Turn: choose your action!"
			show_player_ui()
		Player.PlayerType.AI:
			$UI/MessageBox/Message.text = "Waiting for opponent..."
			current_player.choose_action()

func go_to_next_turn():
	current_player = get_next_player()
	
	if !current_player.can_start_turn():
		var next_player = get_next_player()
		if next_player.can_start_turn():
			current_player = next_player
			start_turn()
		else:
			start_round(first_player)
		# tie result
	else:
		start_turn()

func get_next_player():
	for p in players:
		if p == current_player:
			var index = players.find(p)
			if index == players.size() - 1:
				index = 0
			else:
				index += 1
			var next_player = players[index]
			return next_player
	return current_player

func show_player_ui():
	for critter in current_player.critters:
		var new_critter_button = Button.new()
		new_critter_button.text = critter.critter_name
		new_critter_button.connect("pressed", self, "show_critter_actions", [critter])
		if !critter.can_act:
			new_critter_button.disabled = true
		$UI/ActionMenu/Critters.add_child(new_critter_button)

func hide_player_ui():
	for btn in $UI/ActionMenu/Critters.get_children():
		btn.queue_free()
	for btn in $UI/ActionMenu/Actions.get_children():
		btn.queue_free()
	for btn in $UI/ActionMenu/Targets.get_children():
		btn.queue_free()
	yield(get_tree().create_timer(.01), "timeout")

func show_critter_actions(critter):
	for old_button in $UI/ActionMenu/Actions.get_children():
		old_button.queue_free()
	for old_button in $UI/ActionMenu/Targets.get_children():
		old_button.queue_free()
	for c in $Critters.get_children():
		c.set_select_sprite_visible(false)
	yield(get_tree().create_timer(0.01), "timeout")
	for action in critter.actions:
		var new_action_button = Button.new()
		new_action_button.text = str(action.action_name, " ", action.current_uses, "/", action.max_uses)
		new_action_button.connect("pressed", self, "show_action_targets", [critter, action])
		if action.current_uses < 1:
			new_action_button.disabled = true
		$UI/ActionMenu/Actions.add_child(new_action_button)
		critter.set_select_sprite_visible(true)

func show_action_targets(critter : BattleCritter, action : Action):
	for old_button in $UI/ActionMenu/Targets.get_children():
		old_button.queue_free()
	yield(get_tree().create_timer(0.01), "timeout")
	var targets = []
	# Selectable targets
	match action.target:
		"ally_single":
			for c in $Critters.get_children():
				if c.player_owner == critter.player_owner:
					targets.append(c)
		"enemy_single":
			for c in $Critters.get_children():
				if c.player_owner != critter.player_owner:
					targets.append(c)
		"self":
			targets.append(critter)
		"ally_all":
			for c in $Critters.get_children():
				if c.player_owner == critter.player_owner:
					if !c.is_ko:
						targets.append(c)
		"enemy_all":
			for c in $Critters.get_children():
				if c.player_owner != critter.player_owner:
					if !c.is_ko:
						targets.append(c)
	# single target
	if action.target.ends_with("single") || action.target == "self":
		for target in targets:
			var new_target_button = Button.new()
			new_target_button.text = target.critter_name
			new_target_button.connect("pressed", self, "execute_action", [critter, action, [target]])
			if target.is_ko:
				new_target_button.disabled = true
			else:
				new_target_button.connect("mouse_entered", self, "show_target_selected", [[target]])
				new_target_button.connect("mouse_exited", self, "hide_target_selected", [[target]])
			$UI/ActionMenu/Targets.add_child(new_target_button)
	elif action.target.ends_with("all"):
		var new_target_button = Button.new()
		if action.target.begins_with("enemy"):
			new_target_button.text =  "All Enemies"
		else:
			new_target_button.text = "All Allies"
		new_target_button.connect("pressed", self, "execute_action", [critter, action, targets])
		new_target_button.connect("mouse_entered", self, "show_target_selected", [targets])
		new_target_button.connect("mouse_exited", self, "hide_target_selected", [targets])
		$UI/ActionMenu/Targets.add_child(new_target_button)

func execute_action(critter : BattleCritter, action : Action, targets : Array):
	for c in $Critters.get_children():
		c.set_select_sprite_visible(false)
	hide_player_ui()
	hide_target_selected($Critters.get_children())
	$UI/MessageBox/Message.text = critter.critter_name + " uses " +  action.action_name + "!"
	$Camera/Anim.stop()
	# Move camera towards target
	if targets.size() == 1:
		var destination = Vector3(targets[0].translation.x, $Camera.translation.y, $Camera.translation.z)
		$Camera/CameraTween.interpolate_property($Camera, "translation", 
				$Camera.translation, 
				destination, 
				0.4)
		$Camera/CameraTween.start()
		yield($Camera/CameraTween, "tween_all_completed")
	else:
		var final_camera_x = 0
		for target in targets:
			final_camera_x += target.translation.x
		var destination = Vector3(final_camera_x / targets.size(), $Camera.translation.y, $Camera.translation.z)
		$Camera/CameraTween.interpolate_property($Camera, "translation", 
				$Camera.translation, 
				destination, 
				0.4)
		$Camera/CameraTween.start()
		yield($Camera/CameraTween, "tween_all_completed")
	# Execute the action
	match action.action_type:
		Constants.ActionTypeDamage:
			for target in targets:
				var damage = 1
				var stat_type = action.stat
				if action.stat == "adaptable":
					if critter.get_attack() >= critter.get_special_attack():
						stat_type = "physical"
					else:
						stat_type = "special"
				if stat_type == "physical":
					damage = int(float(action.power) * (critter.get_attack() / target.get_defense()))
				elif stat_type == "special":
					damage = int(float(action.power) * (critter.get_special_attack() / target.get_special_defense()))
				target.get_hurt(max(1, damage))
		Constants.ActionTypeEffect:
			print("effects: " + to_json(action.effects))
	# Apply Action effects
	for effect in action.effects:
		for target in targets:
			apply_effect(effect, target)
	for effect in action.self_effects:
		apply_effect(effect, critter)
	
	# remove one use of the move
	action.current_uses -= 1
	# check if the user has any uses of their moves left, if no uses are left give only tackle.
	# if the only move if tackle, ko the creature
	var out_of_moves = true
	for a in critter.actions:
		if a.current_uses > 0:
			out_of_moves = false
			break
	if out_of_moves:
		if critter.actions.size() == 1 and critter.actions[0].id == "tackle":
			critter.get_hurt(1000)
		else:
			DataHandler.open_actions()
			critter.actions = []
			critter.actions.append(Action.new("tackle", DataHandler.get_action("tackle")))
			DataHandler.close_actions()
	# the critter cannot act until next round
	critter.can_act = false
	yield(get_tree().create_timer(1), "timeout")
	$Camera/Anim.play("CameraTest")
	# go to next action
	if !is_game_over():
		go_to_next_turn()

func apply_effect(effect, target):
	match effect.code:
		"heal":
			target.heal(effect.amount)

func show_target_selected(targets : Array):
	for target in targets:
		target.set_target_sprite_visible(true)

func hide_target_selected(targets : Array):
	for target in targets:
		target.set_target_sprite_visible(false)

func is_game_over() -> bool:
	
	var player1_critters = []
	var player2_critters = []
	
	for critter in $Critters.get_children():
		if critter.player_owner == players[0].id && !critter.is_ko:
			player1_critters.append(critter)
		if critter.player_owner == players[1].id && !critter.is_ko:
			player2_critters.append(critter)
	
	if player1_critters.empty():
		$UI/MessageBox/Message.text = "You have lost!"
		return true
	if player2_critters.empty():
		$UI/MessageBox/Message.text = "You have won!"
		return true
	
	return false
