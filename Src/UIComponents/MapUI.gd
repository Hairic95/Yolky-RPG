extends Control

func _ready():
	randomize()

var is_generating = false

var astar = AStar2D.new()

var body_points = []
var node_points = []

var mapline_reference = load("res://Src/UIComponents/MapLine.tscn")
var mapnode_reference = load("res://Src/UIComponents/MapNode.tscn")
var MapUIPointBody_reference = load("res://Src/UIComponents/MapUIPointBody.tscn")

signal map_loaded()

func generate_map():
	
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
		for other_body in body.left_connections:
			if astar.has_point(other_body.id):
				astar.connect_points(other_body.id, body.id, false)
	
	add_sprites()
	
	for child in $TextureRect/NodeContainer.get_children():
		if !child is CollisionPolygon2D:
			child.queue_free()
	
	is_generating = false
	
	emit_signal("map_loaded")

func add_sprites():
	for p in node_points:
		var new_mapnode = mapnode_reference.instance()
		new_mapnode.position = p
		$MapElements.add_child(new_mapnode)
	for body in body_points:
		if astar.has_point(body.id):
			for c in astar.get_point_connections(body.id):
				var new_line = mapline_reference.instance()
				var start = astar.get_point_position(body.id)
				var end = astar.get_point_position(c)
				new_line.add_point(start + 7 * (end - start).normalized())
				new_line.add_point(end + 7 * (start - end).normalized())
				$MapElements.add_child(new_line)
