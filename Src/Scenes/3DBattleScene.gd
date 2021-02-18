extends Spatial

var combatant_reference = load("res://Src/Entities/3DCombatant.tscn")
var battlemenu_action_button_reference = load("res://Src/UIComponents/BattleMenuActionButton.tscn")

var players = []

func _ready():
	
	$Camera/Anim.play("CameraTest")
	
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
	
	#battleTest
	prepare_player_critters()
	prepare_enemies_critter()
	

func prepare_players():
	
	var player_1 = Player.new()
	var player_2 = Player.new()
	

func prepare_player_critters():
	DataHandler.open_characters()
	DataHandler.open_actions()
	
	var i = 1
	for team_member in TeamHandler.current_team_data:
		
		var team_member_data = DataHandler.get_character(team_member)
		
		create_critter(team_member_data, "player", i)
		i += 1
	
	
	DataHandler.close_characters()
	DataHandler.close_actions()

func prepare_enemies_critter():
	
	
	var encounter_data = [
		"vhrab",
		"peakoli",
		"pandira2"
	]
	
	DataHandler.open_characters()
	DataHandler.open_actions()
	
	
	
	var i = 1
	for enemy_tag in encounter_data:
		var enemy_data = DataHandler.get_character(enemy_tag)
		var new_enemy = create_critter(enemy_data, "enemy", i)
		i += 1
	
	
	DataHandler.close_characters()
	DataHandler.close_actions()
	
	# show_battle_headline("Start Battle")
	yield(get_tree().create_timer(1.8), "timeout")
	
	# start_turn()

func create_critter(character_dict : Dictionary, side : String, pos : int):
	
	var new_combatant : Combatant3D = combatant_reference.instance()
	new_combatant.player_owner = side
	var pos_path : NodePath = ""
	
	if side == "player":
		pos_path = str("Positions/PlayerPos", pos)
		new_combatant.scale = Vector3(-1, 1, 1)
	elif side == "enemy":
		pos_path = str("Positions/EnemyPos", pos)
	
	new_combatant.Combatant(character_dict, get_node(pos_path).translation)
	
	new_combatant.row_position = pos
	new_combatant.fixed_translation = get_node(pos_path).translation
	
	$Combatants.add_child(new_combatant)
	
	return new_combatant

var camera_target = null

func _on_CreatureButton_pressed(creature_pos):
	pass

func _on_CreatureButton_mouse_entered(creature_pos):
	for critter in $Combatants.get_children():
		if critter.player_owner == "player" and critter.row_position == creature_pos:
			critter.set_select_sprite_visible(true)
			if camera_target != critter:
				fix_camera_to_critter(critter.translation)
			camera_target = critter
			break
	$Camera/CameraReset.stop()

func _on_CreatureButton_mouse_exited(creature_pos):
	for critter in $Combatants.get_children():
		if critter.player_owner == "player" and critter.row_position == creature_pos:
			critter.set_select_sprite_visible(false)
			break
	$Camera/CameraReset.start()

func _on_TargetButton_pressed(target_pos):
	pass # Replace with function body.

func _on_TargetButton_mouse_entered(target_pos):
	# TODO: controlla che l'azione selezionata selezioni tutti i bersagli nel caso
	#       l'azione colpisca tutti o un alleato
	if true:
		for critter in $Combatants.get_children():
			if critter.player_owner == "enemy" and critter.row_position == target_pos:
				critter.set_select_sprite_visible(true)
				if camera_target != critter:
					fix_camera_to_critter(critter.translation)
				camera_target = critter
				break
	$Camera/CameraReset.stop()

func _on_TargetButton_mouse_exited(target_pos):
	# TODO: controlla che l'azione selezionata selezioni tutti i bersagli nel caso
	#       l'azione colpisca tutti o un alleato
	if true:
		for critter in $Combatants.get_children():
			if critter.player_owner == "enemy" and critter.row_position == target_pos:
				critter.set_select_sprite_visible(false)
				break
	$Camera/CameraReset.start()

func fix_camera_to_critter(creature_translation: Vector3):
	$Camera/Anim.stop()
	$Camera/CameraReset.stop()
	
	$Camera/CameraTween.interpolate_property($Camera, "translation", $Camera.translation, Vector3(creature_translation.x, 2, -5), 0.8)
	$Camera/CameraTween.interpolate_property($Camera, "rotation_degrees", $Camera.rotation_degrees, Vector3(-20, 180, 0),  0.8)
	$Camera/CameraTween.start()

func _on_CameraReset_timeout():
	$Camera/CameraTween.interpolate_property($Camera, "translation", $Camera.translation, Vector3(0, 2, -7), 0.5)
	$Camera/CameraTween.interpolate_property($Camera, "rotation_degrees", $Camera.rotation_degrees, Vector3(-15, 180, 0), 0.5)
	$Camera/CameraTween.start()
	camera_target = null
	yield($Camera/CameraTween, "tween_all_completed")
	
	if camera_target == null:
		$Camera/Anim.play("CameraTest")
