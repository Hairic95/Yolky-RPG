extends Node2D
class_name Model

func play(anim_name):
	$Anim.play(anim_name)

func get_anim_length(anim_name) -> float:
	if $Anim.has_animation(anim_name):
		return $Anim.get_animation(anim_name).length
	return 0.1
