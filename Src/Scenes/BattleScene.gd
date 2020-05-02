extends Control

var combatant_reference = load("res://Src/Entities/Combatant.tscn")
var battlemenu_action_button_reference = load("res://Src/UIComponents/BattleMenuActionButton.tscn")

func _ready():
	
	randomize()
	
	AdventureHandler.connect("map_node_selected", self, "go_to_next_encounter")
	
	BattleTurnHandler.connect("action_selected", self, "set_selected_action")
	BattleTurnHandler.connect("combatant_selected", self, "set_selected_combatant")
	BattleTurnHandler.connect("combat_animation_ended", self, "combat_animation_ended")
	BattleTurnHandler.connect("damage_targets", self, "start_target_combatants_damage_animation")
	BattleTurnHandler.connect("combatant_died", self, "remove_combatant")
	
	BattleTurnHandler.connect("ai_chooses_action_and_combatant", self, "start_action")
	
	BattleTurnHandler.connect("create_popup_at", self, "create_combatant_popup_at")
	
	BattleTurnHandler.connect("battle_ended", self, "show_result")
	
	DataHandler.open_characters()
	DataHandler.open_actions()
	
	$MapUI.connect("map_loaded", self, "show_map")
	
	# map test
	test_map()
	
	#battleTest
	#test()
	
	#start_turn()
	
	DataHandler.close_characters()
	DataHandler.close_actions()

# Generation : TODO

# _Test

func _input(ev):
	if ev is InputEventKey:
		if ev.scancode == KEY_SPACE and ev.pressed and !$MapUI.is_generating:
			hide_map()

func hide_map():
	$MapUI/MapTween.interpolate_property($MapUI, "rect_position", $MapUI.rect_position, Vector2(0, -50), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$MapUI/MapTween.interpolate_property($Menu, "rect_position", $Menu.rect_position, Vector2(0, 144 - $Menu.rect_size.y), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	$MapUI/MapTween.start()

func test_map():
	
	var i = 1
	start_adventure()
	
	$MapUI.generate_map()

func show_map():
	$MapUI/MapTween.interpolate_property($MapUI, "rect_position", $MapUI.rect_position, Vector2(0, 0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$MapUI/MapTween.interpolate_property($Menu, "rect_position", $Menu.rect_position, Vector2(0, 144), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	$MapUI/MapTween.start()

func start_adventure():
	DataHandler.open_characters()
	DataHandler.open_actions()
	
	var i = 1
	for team_member in TeamHandler.current_team_data:
		
		var team_member_data = DataHandler.get_character(team_member)
		
		create_character_outside(team_member_data, "player", i)
		i += 1
	
	
	DataHandler.close_characters()
	DataHandler.close_actions()

func create_character_outside(character_dict : Dictionary, side : String, pos : int):
	
	var new_combatant : Combatant = combatant_reference.instance()
	new_combatant.player_owner = side
	var start_pos_path : NodePath = ""
	var final_pos_path : NodePath = ""
	
	if side == "player":
		start_pos_path = "Combatants/Positions/PlayerSpawn"
		final_pos_path = str("Combatants/Positions/PlayerPos", pos)
	elif side == "enemy":
		start_pos_path = "Combatants/Positions/EnemySpawn"
		final_pos_path = str("Combatants/Positions/EnemyPos", pos)
		new_combatant.scale = Vector2(-1, 1)
	
	new_combatant.Combatant(character_dict, get_node(start_pos_path).position)
	
	new_combatant.row_position = pos
	new_combatant.fixed_position = get_node(final_pos_path).position
	
	$Combatants/Entities.add_child(new_combatant)
	
	new_combatant.play_non_combat_animation("Moving", get_node(final_pos_path).position)
	
	return new_combatant

# Turn Order

var turn_queue : Array = []

var current_combatant : Combatant = null

func start_turn():
	
	turn_queue =  $Combatants/Entities.get_children()
	#turn_queue.sort_custom(self, "order_combatants")
	
	new_combatant_round()

func new_combatant_round():
	
	if check_victory_condition():
		return
	
	if turn_queue.size() == 0:
		start_turn()
		return
	
	turn_queue.sort_custom(self, "order_combatants")
	current_combatant = turn_queue.pop_front()
	
	for entity in $Combatants/Entities.get_children():
		entity.disable_button(true)
	
	if current_combatant.player_owner == "enemy":
		current_combatant.act($Combatants/Entities.get_children())
	else:
		$Menu/MenuHBox/MoveDetails.show()
		$Menu/MenuHBox/MoveEffect.show()
		reset_action_menu()
		# Set up action button
		for action in current_combatant.actions:
			var new_action_button = battlemenu_action_button_reference.instance()
			new_action_button.text = action.action_name
			new_action_button.action = action
			$Menu/MenuHBox/Moves.add_child(new_action_button)

func order_combatants(comb_1, comb_2) -> bool :
	if comb_1.get_speed() > comb_2.get_speed():
		return true
	elif comb_1.get_speed() == comb_2.get_speed():
		if randi()%2 == 0:
			return true
	return false

func remove_combatant(combatant : Combatant):
	turn_queue.erase(combatant)
	combatant.queue_free()

func check_victory_condition():
	var is_player_remaining = false
	var is_enemy_remaining = false
	
	for cmb in $Combatants/Entities.get_children():
		if cmb.player_owner == "player":
			is_player_remaining = true
		if cmb.player_owner == "enemy":
			is_enemy_remaining = true
	
	if !is_player_remaining:
		BattleTurnHandler.emit_signal("battle_ended", false)
		return true
	if !is_enemy_remaining:
		BattleTurnHandler.emit_signal("battle_ended", true)
		return true
	
	return false

# Current Action

var selected_action

func set_selected_action(action : Action):
	
	selected_action = action
	
	$Menu/MenuHBox/MoveDetails/DmgIndicator/DmgValue.text = str(action.damage)
	
	var target_cont = 1
	
	for t in action.target:
		var target_sprite = get_node(str("Menu/MenuHBox/MoveDetails/TargetIndicator/ReachPos", target_cont))
		var enemy_combatant = get_enemy_in_position(target_cont)
		if enemy_combatant != null:
			if t == "#":
				target_sprite.texture = load("res://Assets/Textures/UI/Target_full.png")
				enemy_combatant.disable_button(false)
			elif t == ".":
				target_sprite.texture = load("res://Assets/Textures/UI/Target_empty.png")
				enemy_combatant.disable_button(true)
		target_cont += 1
	
	$Menu/MenuHBox/MoveDetails/TypeIndicator/TypeValue.text = action.type
	
	# TODO : Effects

var target_combatants : Array = []

func set_selected_combatant(combatant : Combatant):
	
	target_combatants.append(combatant)
	
	for action_button in $Menu/MenuHBox/Moves.get_children():
		action_button.queue_free()
	for entity in $Combatants/Entities.get_children():
		entity.disable_button(false)
	
	$Menu/MenuHBox/MoveDetails.hide()
	$Menu/MenuHBox/MoveEffect.hide()
	
	start_action(current_combatant, selected_action, target_combatants)

# Call this to execute the action
func start_action(attacker : Combatant, action_to_execute : Action, targets : Array):
	
	match(action_to_execute.action_type):
		"attack":
			for target in targets:
				target.get_hurt(action_to_execute.damage)
			
			
			if (attacker.player_owner == "enemy"):
				var new_popup = popup_reference.instance()
				new_popup.position = Vector2(260, 40)
				new_popup.set_popup(action_to_execute.action_name, "LeftRightPopup")
				$Writings.add_child(new_popup)
				yield(new_popup.get_node("Anim"), "animation_finished")
			if targets.size() > 0:
				current_combatant.attack_to_position(targets[0].position)
			target_combatants = targets
		"pass":
			var new_popup = popup_reference.instance()
			new_popup.position = attacker.position + Vector2(0, -32)
			new_popup.set_popup("Pass", "UpDownPopup")
			$Writings.add_child(new_popup)
			yield(new_popup.get_node("Anim"), "animation_finished")
			new_combatant_round()

func combat_animation_ended():
	
	new_combatant_round()

func get_enemy_in_position(index):
	for entity in $Combatants/Entities.get_children():
		if entity.player_owner == "enemy" and entity.row_position == index:
			return entity
	return null

func get_all_players():
	var players = []
	for entity in $Combatants/Entities.get_children():
		if entity.player_owner == "player":
			players.append(entity)
	return players

func start_target_combatants_damage_animation():
	for combatant in target_combatants:
		combatant.get_damaged()
	target_combatants = []

# UI

func reset_action_menu():
	selected_action = null
	
	$Menu/MenuHBox/MoveDetails/DmgIndicator/DmgValue.text = ""
	
	var target_cont = 1
	
	for t in range(3):
		var target_sprite = get_node(str("Menu/MenuHBox/MoveDetails/TargetIndicator/ReachPos", target_cont))
		var enemy_combatant = get_enemy_in_position(target_cont)
		if enemy_combatant != null:
			target_sprite.texture = load("res://Assets/Textures/UI/Target_empty.png")
			enemy_combatant.disable_button(true)
			target_cont += 1
	
	$Menu/MenuHBox/MoveDetails/TypeIndicator/TypeValue.text = ""

var popup_reference = load("res://Src/UIComponents/Popup.tscn")

func create_combatant_popup_at(type, text, start_pos):
	var new_combatant_popup = popup_reference.instance()
	new_combatant_popup.position = start_pos
	new_combatant_popup.set_popup(text, "UpDownPopup")
	$Writings.add_child(new_combatant_popup)

# true is victory
func show_result(value : bool):
	if value:
		show_battle_headline("You win the fight!")
	else:
		show_battle_headline("You lose...")
	yield(get_tree().create_timer(1.7), "timeout")
	show_map()

# Map navigation

func go_to_next_encounter(map_node):
	
	hide_map()
	
	match(map_node.encounter_type):
		"battle":
			
			DataHandler.open_characters()
			DataHandler.open_actions()
			
			var bg_start_pos = $BG.rect_position
			
			$BG/MovementTween.interpolate_property($BG, "rect_position", bg_start_pos, bg_start_pos - Vector2($BG.rect_size.x, 0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			$BG/MovementTween.start()
			
			for team_member in $Combatants/Entities.get_children():
				team_member.play_non_combat_animation("Moving")
			yield($BG/MovementTween, "tween_all_completed")
			
			var i = 1
			for enemy_tag in map_node.encounter_data.enemies:
				var enemy_data = DataHandler.get_character(enemy_tag)
				var new_enemy = create_character_outside(enemy_data, "enemy", i)
				i += 1
			
			$BG/MovementTween.interpolate_property($BG, "rect_position", bg_start_pos + Vector2($BG.rect_size.x, 0), bg_start_pos, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			$BG/MovementTween.start()
			
			yield($BG/MovementTween, "tween_all_completed")
			
			DataHandler.close_characters()
			DataHandler.close_actions()
			
			show_battle_headline("Start Battle")
			yield(get_tree().create_timer(1.8), "timeout")
			
			start_turn()

func show_battle_headline(text_to_display):
	$BattleHeadline/Text.text = text_to_display
	$BattleHeadline/Tween.interpolate_property($BattleHeadline/Text, "rect_position", $BattleHeadline/Text.rect_position, Vector2(0, 25), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$BattleHeadline/Tween.start()
	yield($BattleHeadline/Tween, "tween_all_completed")
	
	yield(get_tree().create_timer(0.8), "timeout")
	
	$BattleHeadline/Tween.interpolate_property($BattleHeadline/Text, "rect_position", $BattleHeadline/Text.rect_position, Vector2(0, -25), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$BattleHeadline/Tween.start()
	yield($BattleHeadline/Tween, "tween_all_completed")
