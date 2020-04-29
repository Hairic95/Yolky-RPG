extends Node2D

var type = "damage"

func set_popup(text : String, anim_name : String, type : String = ""):
	$Text.text = text
	$Anim.play(anim_name)
	if type != "":
		self.type = type

func _on_Anim_animation_finished(anim_name):
	queue_free()
