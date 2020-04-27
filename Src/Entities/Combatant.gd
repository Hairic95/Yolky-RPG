extends Node2D
class_name Combatant

# Combat Logic

var current_hp : int = 1

var stats : Dictionary = {
	"attack" : 1,
	"maxhp" : 1,
	"speed" : 1
}

var moves : Array = []

var data_tag : String = ""

var is_under_player_control : bool = false

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
			add_child(new_model)
	if dict_data.has("moves"):
		moves = dict_data.moves
	
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
		# Todo create and emit signal
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

func attack_to_position(attack_position : Vector2):
	if !is_playing_animation:
		add_new_animation(attack_position + Vector2(-20, 0), "Moving")
		add_new_animation(attack_position + Vector2(-15, 0), "Attacking")
		add_new_animation(Vector2.ZERO, "Idle")
		play_first_animation()
		z_index = 1
