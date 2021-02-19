extends Spatial
class_name Combatant3D

var critter_name : String = ""

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

var can_act = false

var is_ko = false

# Animation

var fixed_translation : Vector3 = Vector3.ZERO
var animation_stack : Array = []
var model : Model = null

var is_playing_animation : bool = false

func _ready():
	$AnimationPlayer.play("Idle")
	$MovementTween.connect("tween_all_completed", self, "on_movement_tween_completed")

func Combatant(dict_data : Dictionary, starting_translation : Vector3):
	# Data setting
	if dict_data.has("name"):
		critter_name = dict_data.name
	if dict_data.has("stats"):
		if dict_data.stats.has("attack") and dict_data.stats.has("maxhp") and dict_data.stats.has("speed"):
			stats = dict_data.stats
			current_hp = stats.maxhp
	if dict_data.has("texture"):
			$Image.texture = load(str("res://Assets/Textures/Characters/", dict_data.texture, ".png"))
			set_sprite()
	if dict_data.has("actions"):
		for action_data in dict_data.actions:
			var new_action = Action.new(DataHandler.get_action(action_data))
			actions.append(new_action)
	
	# Position setting
	fixed_translation = starting_translation
	translation = starting_translation

func add_new_animation(translation : Vector3, anim_name : String):
	if translation == Vector3.ZERO:
		translation = fixed_translation
	
	var new_animation = {
		"pos" : translation,
		"anim_name" : anim_name
	}
	
	animation_stack.append(new_animation)

func get_damaged():
	if current_hp > 0:
		model.play("Damaged")
	else:
		model.play("Dying")
	
	create_popup("damage")

# Stats handling

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
	BattleTurnHandler.emit_signal("create_popup_at", type, latest_damage_taken, translation + Vector3(0, -32, 0))

func delete_on_death():
	BattleTurnHandler.emit_signal("combatant_died", self)

# AI 

func act(possible_targets : Array):
	
	# check the target position to determinate which action are possible
	var targetable_index = []
	for t in possible_targets:
		if t.player_owner == "player":
			targetable_index.append(t.row_position - 1)
	
	var choosable_actions = []
	for action in actions:
		for i in targetable_index:
			if action.target[i] != ".":
				choosable_actions.append(action)
				break
	
	# if no action is choosable pass turn
	if choosable_actions.size() == 0:
		pass_turn()
		return
	
	# choose one action at random
	var action_selected = choosable_actions[randi()%choosable_actions.size()]
	
	var choosable_targets = []
	for target in possible_targets:
		if action_selected.target[target.row_position - 1] == "#" and target.player_owner == "player":
			choosable_targets.append(target)
	
	var actual_targets = []
	actual_targets.append(choosable_targets[randi()%choosable_targets.size()])
	
	BattleTurnHandler.emit_signal("ai_chooses_action_and_combatant", self, action_selected, actual_targets)

func pass_turn():
	var pass_action = Action.new({"action_type" : "pass"})
	BattleTurnHandler.emit_signal("ai_chooses_action_and_combatant", self, pass_action, [])

func set_sprite():
	$Image.offset.y = $Image.texture.get_size().y / 2
	$SelectSprite.translation.y = 2.5

func set_select_sprite_visible(value):
	$SelectSprite.visible = value
