extends Area2D

var speed = 35

var dir = Vector2(0, 1)

func _process(delta):
	position += dir * speed * delta
