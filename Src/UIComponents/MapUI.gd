extends Control

func _ready():
	randomize()
	
	AdventureHandler.connect("map_node_selected", self, "set_enabled_map_points")

var is_generating = false

var astar = AStar2D.new()

var body_points = []
var node_points = []

var mapline_reference = load("res://Src/UIComponents/MapLine.tscn")
var mapnode_reference = load("res://Src/UIComponents/MapNode.tscn")
var MapUIPointBody_reference = load("res://Src/UIComponents/MapUIPointBody.tscn")

signal map_loaded()

func generate_map():
	
	randomize()
	
	is_generating = true
	
	body_points.clear()
	node_points.clear()
	astar.clear()
	for child in $MapElements.get_children():
		child.queue_free()
	
	for i in range(15):
		var new_point = MapUIPointBody_reference.instance()
		new_point.set_body(randi()%7 + 9)
		new_point.position = Vector2($TextureRect.rect_size.x / 6 * ((randi()%3 + 1) - 2), 0)
		new_point.id = i
		body_points.append(new_point)
		$TextureRect/NodeContainer.add_child(new_point)
	
	var rightmost_point = null
	var leftmost_point = null
	
	yield(get_tree().create_timer(0.4), "timeout")
	for body in body_points:
		node_points.append(body.position)
		astar.add_point(body.id, body.position)
		
		for other_body in body.right_connections:
			if astar.has_point(other_body.id):
				astar.connect_points(body.id, other_body.id, false)
				other_body.left_connections.append(body)
		for other_body in body.left_connections:
			if astar.has_point(other_body.id):
				astar.connect_points(other_body.id, body.id, false)
				body.right_connections.append(other_body)
	
	add_sprites()
	
	for child in $TextureRect/NodeContainer.get_children():
		if !child is CollisionPolygon2D:
			child.queue_free()
	
	is_generating = false
	
	emit_signal("map_loaded")


# TODO Handle connections in order to go from left to right
func add_sprites():	
	for astar_id in astar.get_points():
		var new_mapnode = mapnode_reference.instance()
		new_mapnode.position = astar.get_point_position(astar_id)
		$MapElements.add_child(new_mapnode)
		new_mapnode.id = astar_id
	for astar_id in astar.get_points():
		
		for c in astar.get_point_connections(astar_id):
			var new_line = mapline_reference.instance()
			var start = astar.get_point_position(astar_id)
			var end = astar.get_point_position(c)
			new_line.add_point(start + 7 * (end - start).normalized())
			new_line.add_point(end + 7 * (start - end).normalized())
			$MapElements.add_child(new_line)
			get_map_node_by_id(astar_id).connections.append(get_map_node_by_id(c))
			get_map_node_by_id(c).connections.append(get_map_node_by_id(astar_id))
	
	var starting_node = get_map_node_by_id(astar.get_points()[randi()%astar.get_points().size()])
	
	set_enabled_map_points(starting_node)
	

func set_enabled_map_points(current_map_point):
	var map_node = get_map_node_by_id(current_map_point.id)
	for map_point in $MapElements.get_children():
		if map_point is MapNode:
			map_point.set_disabled(true)
	for next_map_point in map_node.connections:
		next_map_point.set_disabled(false)

func get_map_node_by_id(id):
	for child in $MapElements.get_children():
		if child is MapNode:
			if child.id == id:
				return child
