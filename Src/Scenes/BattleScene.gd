extends Control

var combatant_reference = load("res://Src/Entities/Combatant.tscn")
var battlemenu_action_button_reference = load("res://Src/UIComponents/BattleMenuActionButton.tscn")

func _ready():
	
	randomize()
	
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
	
	test()
	start_turn()
	
	
	DataHandler.close_characters()
	DataHandler.close_actions()

# Generation : TODO

# _Test

func test():
	
	var i = 1
	for chr in DataHandler.characters_data.values():
		
		var new_combatant : Combatant = combatant_reference.instance()
		var pos_path : NodePath = "."
		if i < 4:
			pos_path = str("Combatants/Positions/PlayerPos", i)
			new_combatant.player_owner = "player"
			new_combatant.row_position = 4 - i
		else:
			pos_path = str("Combatants/Positions/EnemyPos", i - 3)
			new_combatant.scale = Vector2(-1, 1)
			new_combatant.row_position = i - 3
		
		new_combatant.Combatant(chr, get_node(pos_path).position)
		
		$Combatants/Entities.add_child(new_combatant)
		
		i += 1

# Turn Order

var turn_queue : Array = []

var current_combatant : Combatant = null

func start_turn():
	
	turn_queue =  $Combatants/Entities.get_children()
	#turn_queue.sort_custom(self, "order_combatants")
	
	new_combatant_round()

func new_combatant_round():
	
	check_victory_condition()
	
	if turn_queue.size() == 0:
		start_turn()
		return
	
	current_combatant = turn_queue.pop_front()
	
	if current_combatant.player_owner == "enemy":
		
		# TODO Implement enemy logic and action selectio
		
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
	if !is_enemy_remaining:
		BattleTurnHandler.emit_signal("battle_ended", true)
	

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
	
	for target in targets:
		target.get_hurt(selected_action.damage)
	
	if targets.size() > 0:
		current_combatant.attack_to_position(targets[0].position)
	
	target_combatants = targets

func combat_animation_ended():
	
	new_combatant_round()

func get_enemy_in_position(index):
	for entity in $Combatants/Entities.get_children():
		if entity.player_owner == "enemy" and entity.row_position == index:
			return entity
	return null

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

var combatant_popup_reference = load("res://Src/UIComponents/CombatantPopup.tscn")

func create_combatant_popup_at(type, text, start_pos):
	var new_combatant_popup = combatant_popup_reference.instance()
	new_combatant_popup.position = start_pos
	new_combatant_popup.set_text(text)
	$Popups.add_child(new_combatant_popup)

# true is victory
func show_result(value : bool):
	if value:
		$BattleResult.text = "You win the fight!"
	else:
		$BattleResult.text = "You lose..."
	$BattleResult.visible = true
