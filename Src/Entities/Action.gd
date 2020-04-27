extends Reference
class_name Action

var action_name : String = ""
var damage : int = 0
var target : Array = []
var type : String = ""
var effects : Array = []

func _init(dict_data : Dictionary):
	
	if dict_data.has("name"):
		action_name = dict_data.name
	if dict_data.has("damage"):
		damage = dict_data.damage
	if dict_data.has("target"):
		target = dict_data.target
	if dict_data.has("type"):
		type = dict_data.type
	if dict_data.has("effects"):
		effects = dict_data.effects

