extends Node

var characters_path = "res://Data/Critters.json"
var actions_path = "res://Data/Actions.json"

var characters_data : Dictionary = {}
var actions_data : Dictionary = {}

func open_characters():
	var f = File.new()
	f.open(characters_path, File.READ)
	
	characters_data = parse_json(f.get_as_text())

func close_characters():
	characters_data = {}

func open_actions():
	var f = File.new()
	f.open(actions_path, File.READ)
	
	actions_data = parse_json(f.get_as_text())

func close_actions():
	actions_data = {}

func get_character(character_id):
	if characters_data.has(character_id):
		return characters_data[character_id]

func get_action(action_id):
	if actions_data.has(action_id):
		return actions_data[action_id]

func get_dict_val(dict, key, def):
	if dict.has(key):
		return dict[key]
	return def

