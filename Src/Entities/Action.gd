extends Reference
class_name Action

var id : String = "tackle"
var action_name : String = "Missing string"
var action_type : String = "damage"
var power : int = 0
var stat : String = "adaptable"
var max_uses : int = 1
var current_uses : int = 1
var target : String = "enemy_single"
var effects : Array = []
var self_effects : Array = []

func _init(action_id: String, dict_data : Dictionary):
	id = action_id
	action_name = DataHandler.get_dict_val(dict_data, "name", action_name)
	action_type = DataHandler.get_dict_val(dict_data, "action_type", action_type)
	power = DataHandler.get_dict_val(dict_data, "power", power)
	stat = DataHandler.get_dict_val(dict_data, "stat", stat)
	target = DataHandler.get_dict_val(dict_data, "target", target)
	effects = DataHandler.get_dict_val(dict_data, "effects", effects)
	self_effects = DataHandler.get_dict_val(dict_data, "self_effects", self_effects)
	max_uses = DataHandler.get_dict_val(dict_data, "uses", max_uses)
	current_uses = max_uses
