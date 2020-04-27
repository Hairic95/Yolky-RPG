extends Node2D

func _ready():
	$Anim.play("Popup")

func set_text(value):
	$Text.text = value

func _on_Anim_animation_finished(anim_name):
	queue_free()
