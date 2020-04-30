extends Control

var overworldgridtile_reference = load("res://Src/UIComponents/OverworldGridTile.tscn")

var current_grid_tile = null

func _ready():
	
	AdventureHandler.connect("grid_tile_clicked", self, "go_to_new_grid_tile")
	
	generate()

func generate():
	
	$Grid.position = get_viewport_rect().size / 2
	
	var texture_grid_dimension = 50
	
	for x in range(10):
		for y in range(10):
			var new_grid_tile = overworldgridtile_reference.instance()
			
			new_grid_tile.texture = load("res://Assets/Textures/Overworld/grid_far.png")
			
			new_grid_tile.grid_pos = Vector2(x, y)
			
			if x == 5 and y == 5:
				current_grid_tile = new_grid_tile
			
			new_grid_tile.position = Vector2(x * texture_grid_dimension, y * texture_grid_dimension) - Vector2(1, 1) * texture_grid_dimension * 10 / 2
			
			$Grid/Offset.add_child(new_grid_tile)
	
	set_up_current_grid_tile()
	

func set_up_current_grid_tile():
	
	for tile in $Grid/Offset.get_children():
		tile.texture = load("res://Assets/Textures/Overworld/grid_far.png")
	
	current_grid_tile.texture = load("res://Assets/Textures/Overworld/grid_current.png")
	
	
	var possible_positions = [
		current_grid_tile.grid_pos + Vector2.UP,
		current_grid_tile.grid_pos + Vector2.LEFT,
		current_grid_tile.grid_pos + Vector2.RIGHT,
		current_grid_tile.grid_pos + Vector2.DOWN
	]
	
	for tile in $Grid/Offset.get_children():
		if possible_positions.has(tile.grid_pos):
			tile.texture = load("res://Assets/Textures/Overworld/grid_moving.png")
			if tile.grid_pos == possible_positions[0]:
				tile.rotation = 0
			elif tile.grid_pos == possible_positions[1]:
				tile.rotation = -PI / 2
			elif tile.grid_pos == possible_positions[2]:
				tile.rotation = PI / 2
			elif tile.grid_pos == possible_positions[3]:
				tile.rotation = PI

func go_to_new_grid_tile(new_current_grid_tile):
	
	
	for child in $Yolkies.get_children():
		child.play("Moving")
		if current_grid_tile.grid_pos.x > new_current_grid_tile.grid_pos.x:
			child.scale = Vector2(-1, 1)
		elif current_grid_tile.grid_pos.x < new_current_grid_tile.grid_pos.x:
			child.scale = Vector2(1, 1)
	
	current_grid_tile = new_current_grid_tile
	
	$Grid/OverworldMover.interpolate_property($Grid/Offset, "position", $Grid/Offset.position, -current_grid_tile.position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	
	
	$Grid/OverworldMover.start()
	
	yield($Grid/OverworldMover, "tween_all_completed")
	
	set_up_current_grid_tile()
	
