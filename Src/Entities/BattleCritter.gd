extends Spatial
class_name BattleCritter

var critter_name : String = "Missing String"

# Combat Logic
var current_hp : int = 100
var max_hp : int = 100

var stats : Dictionary = {
	"attack" : 1,
	"defense": 1,
	"special_attack": 1,
	"special_defense": 1,
}

var row_position : int = 1
var actions : Array = []
var data_tag : String = ""
var is_under_player_control : bool = false
var player_owner = "1"

var can_act = false

var is_ko = false

var current_status = []

# Animation

var fixed_translation : Vector3 = Vector3.ZERO
var animation_stack : Array = []
var model : Model = null

var is_playing_animation : bool = false

func _ready():
	$AnimationTree.active = true

func init(dict_data : Dictionary, player : Player, starting_translation : Vector3):
	player_owner = player.id
	# Data setting
	critter_name = DataHandler.get_dict_val(dict_data, "name", critter_name)
	stats = DataHandler.get_dict_val(dict_data, "stats", stats)
	current_hp = max_hp
	# TODO: Make animated models for complex animations
	if dict_data.has("texture"):
			$Image.texture = load(str("res://Assets/Textures/Characters/", dict_data.texture, ".png"))
			set_sprite()
	for action_data in DataHandler.get_dict_val(dict_data, "actions", ["tackle"]):
		var new_action = Action.new(action_data, DataHandler.get_action(action_data))
		actions.append(new_action)
	
	# Position setting
	fixed_translation = starting_translation
	translation = starting_translation

func get_hurt(damage):
	current_hp = max(0, current_hp - damage)
	if current_hp > 0:
		pass
		#model.play("Damaged")
	else:
		$AnimationTree.active = false
		$Image.modulate = Color(0.3, 0.3, 0.3)
		can_act = false
		is_ko = true
		#model.play("Dying")
	$HealthBar/HealthTween.interpolate_property($HealthBar/CurrentHealth, "scale",
			$HealthBar/CurrentHealth.scale, Vector3(float(current_hp) / float(max_hp), 1, 1), 0.3)
	$HealthBar/HealthTween.start()
	yield($HealthBar/HealthTween, "tween_all_completed")

func heal(amount):
	current_hp = min(max_hp, current_hp + amount)
	$HealthBar/HealthTween.interpolate_property($HealthBar/CurrentHealth, "scale",
			$HealthBar/CurrentHealth.scale, Vector3(float(current_hp) / float(max_hp), 1, 1), 0.3)
	$HealthBar/HealthTween.start()

func set_sprite():
	$Image.offset.y = $Image.texture.get_size().y / 2
	$SelectSprite.translation.y = 2.5
	$HealthBar.translation.y = 2.0

func set_enemy_target():
	$Target.texture = load("res://Assets/Textures/UI/TargetEnemy.png")

func set_select_sprite_visible(value):
	$SelectSprite.visible = value

func set_target_sprite_visible(value):
	$Target.visible = value

func add_stasus(status, turn_amount):
	current_status.append({
		"status": status,
		"turn_amount": turn_amount
	})

func get_attack():
	var multiplier = 1.0
	if is_burned():
		multiplier /= 2.0
	return float(DataHandler.get_dict_val(stats, "attack", 1)) * multiplier
func get_defense():
	return float(DataHandler.get_dict_val(stats, "defense", 1))
func get_special_attack():
	return float(DataHandler.get_dict_val(stats, "special_attack", 1))
func get_special_defense():
	return float(DataHandler.get_dict_val(stats, "special_defense", 1))

func is_burned():
	for status in current_status:
		if status.status == "burn":
			return true
	return false
