extends Node2D
class_name Combatant

# Combat Logic

var current_hp : int = 1

var stats : Dictionary = {
	"attack" : 1,
	"maxhp" : 1,
	"speed" : 1
}

var row_position : int = 1

var actions : Array = []

var data_tag : String = ""

var is_under_player_control : bool = false

var player_owner = "enemy"

# Animation

var fixed_position : Vector2 = Vector2(0, 0)
var animation_stack : Array = []
var model : Model = null

var is_playing_animation : bool = false

func _ready():
	$MovementTween.connect("tween_all_completed", self, "on_movement_tween_completed")

func Combatant(dict_data : Dictionary, starting_position : Vector2):
	# Data setting
	if dict_data.has("stats"):
		if dict_data.stats.has("attack") and dict_data.stats.has("maxhp") and dict_data.stats.has("speed"):
			stats = dict_data.stats
			current_hp = stats.maxhp
	if dict_data.has("model"):
		var new_model = load(str("res://Assets/Models/",dict_data.model,".tscn")).instance()
		if new_model is Model:
			model = new_model
			
			# animation signal connection
			model.connect("create_popup", self, "create_popup")
			model.connect("dead", self, "delete_on_death")
			model.connect("attack", self, "attack_enemy")
			
			add_child(new_model)
	if dict_data.has("actions"):
		for action_data in dict_data.actions:
			var new_action = Action.new(DataHandler.get_action(action_data))
			actions.append(new_action)
	
	# Position setting
	fixed_position = starting_position
	position = starting_position

func add_new_animation(position : Vector2, anim_name : String):
	if position == Vector2.ZERO:
		position = fixed_position
	
	var new_animation = {
		"pos" : position,
		"anim_name" : anim_name
	}
	
	animation_stack.append(new_animation)

func play_first_animation():
	if animation_stack.size() == 0:
		is_playing_animation = false
		BattleTurnHandler.emit_signal("combat_animation_ended")
		z_index = 0
		return
	
	
	is_playing_animation = true
	
	var anim_to_execute = animation_stack.pop_front()
	
	$MovementTween.interpolate_property(self, "position", position, anim_to_execute.pos, 
										model.get_anim_length(anim_to_execute.anim_name), 
										Tween.TRANS_LINEAR, Tween.EASE_IN)
	$MovementTween.start()
	
	model.play(anim_to_execute.anim_name)

func on_movement_tween_completed():
	play_first_animation()

func attack_enemy():
	BattleTurnHandler.emit_signal("damage_targets")

func attack_to_position(attack_position : Vector2):
	if !is_playing_animation:
		add_new_animation(attack_position + Vector2(-20, 0), "Moving")
		add_new_animation(attack_position + Vector2(-15, 0), "Attacking")
		add_new_animation(Vector2.ZERO, "Idle")
		play_first_animation()
		z_index = 2

func get_damaged():
	if current_hp > 0:
		model.play("Damaged")
	else:
		model.play("Dying")
	
	create_popup("damage")
	
	z_index = 1

# Stats handling

func get_speed():
	if stats.has("speed"):
		return stats.speed

func _on_CharacterButton_pressed():
	BattleTurnHandler.emit_signal("combatant_selected", self)

func get_hurt(damage):
	current_hp = max(current_hp - damage, 0)
	if current_hp == 0:
		latest_damage_taken = "Dead"
	else:
		latest_damage_taken = str(damage)

# Button

func disable_button(value : bool):
	$CharacterButton.disabled = value

# Popup

var latest_damage_taken : String = ""

func create_popup(type):
	BattleTurnHandler.emit_signal("create_popup_at", type, latest_damage_taken, position + Vector2(0, -32))

func delete_on_death():
	BattleTurnHandler.emit_signal("combatant_died", self)
