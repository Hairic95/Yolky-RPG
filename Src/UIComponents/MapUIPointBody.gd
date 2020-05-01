extends RigidBody2D

var left_connections = []

var right_connections = []

var id = 0

func _ready():
	randomize()

func set_body(value):
	$CollisionShape2D.shape = CircleShape2D.new()
	var shape = $CollisionShape2D.shape
	shape.radius = value
	$Area2D/AreaShape.shape = CircleShape2D.new()
	var area_shape = $Area2D/AreaShape.shape
	area_shape.radius = value + 1
	
	applied_force = Vector2(randf(), randf()).normalized() * 10

func _on_Area2D_body_entered(body):
	if body.is_in_group("point") and body.id != id:
		if body.position.x > position.x:
			right_connections.append(body)
		else:
			left_connections.append(body)

func _on_Area2D_body_exited(body):
	if right_connections.has(body):
		right_connections.erase(body)
	if left_connections.has(body):
		left_connections.erase(body)
