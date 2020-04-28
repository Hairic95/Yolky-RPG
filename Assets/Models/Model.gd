extends Node2D
class_name Model

func _ready():
	$Anim.play("Idle")

func play(anim_name):
	$Anim.play(anim_name)

func get_anim_length(anim_name) -> float:
	if $Anim.has_animation(anim_name):
		return $Anim.get_animation(anim_name).length
	return 0.1

signal attack()
signal create_popup(type)
signal dead()

func attack():
	emit_signal("attack")

func create_damage_number():
	emit_signal("create_popup", "damage")

func _on_Anim_animation_finished(anim_name):
	if anim_name == "Dying":
		emit_signal("dead")
