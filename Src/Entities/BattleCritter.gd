extends Spatial
class_name BattleCritter

var critter_name : String = "Missing String"

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

func init(dict_data : Dictionary, player : Player, starting_translation : Vector3):
	player_owner = player.id
	# Data setting
	critter_name = DataHandler.get_dict_val(dict_data, "name", critter_name)
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

func get_damaged():
	if current_hp > 0:
		model.play("Damaged")
	else:
		model.play("Dying")

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
