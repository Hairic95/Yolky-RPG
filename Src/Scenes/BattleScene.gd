extends Control

var combatant_reference = load("res://Src/Entities/Player.tscn")

func _ready():
	test()

func test():
	var character_file = File.new()
	
	character_file.open("res://Data/characters.json", File.READ)
	
	var characters = parse_json(character_file.get_as_text())
	
	var i = 1
	for chr in characters.values():
		
		var new_combatant : Combatant = combatant_reference.instance()
		var pos_path : NodePath = "."
		if i < 4:
			pos_path = str("Combatants/Positions/PlayerPos", i)
		else:
			pos_path = str("Combatants/Positions/EnemyPos", i - 3)
			new_combatant.scale = Vector2(-1, 1)
		
		new_combatant.Combatant(chr, get_node(pos_path).position)
		
		$Combatants/Entities.add_child(new_combatant)
		
		i += 1

func test_attack1():
	$Combatants/Entities.get_child(0).attack_to_position($Combatants/Positions/EnemyPos1.position)
func test_attack2():
	$Combatants/Entities.get_child(2).attack_to_position($Combatants/Positions/EnemyPos2.position)
func test_attack3():
	$Combatants/Entities.get_child(1).attack_to_position($Combatants/Positions/EnemyPos3.position)
