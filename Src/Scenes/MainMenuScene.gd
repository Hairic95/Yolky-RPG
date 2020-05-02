extends Control

var mainmenuface_reference = load("res://Src/UIComponents/MainMenu/MainMenuFace.tscn")

func _ready():
	pass
	$Tween.interpolate_property($Title, "rect_position", Vector2(0, -80), Vector2(0, 0), 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.interpolate_property($LeftScroller, "rect_position", Vector2(-40, 0), Vector2(4, 0), 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.interpolate_property($RightScroller, "rect_position", Vector2(280, 0), Vector2(214, 0), 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.interpolate_property($PlayButton, "rect_position", Vector2(120 - $PlayButton.rect_size.x / 2, 184), Vector2(120 - $PlayButton.rect_size.x / 2, 100), 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()
	#spawn_face(Vector2.DOWN)

func spawn_face(dir):
	var new_face = mainmenuface_reference.instance()
	new_face.dir = dir
	if dir == Vector2.DOWN:
		$LeftScroller/Spawn.add_child(new_face)

func _on_End_area_entered(area):
	area.queue_free()

func _on_Enter_area_entered(area):
	spawn_face(Vector2.DOWN)


func _on_PlayButton_pressed():
	play_animation()

func play_animation():
	$PlayButton.disabled = true
	$Tween.interpolate_property($Title, "rect_position", $Title.rect_position, Vector2(0, -244), 1.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property($LeftScroller, "rect_position", $LeftScroller.rect_position, Vector2(4, -244), 1.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property($RightScroller, "rect_position", $RightScroller.rect_position, Vector2(214, -244), 1.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property($PlayButton, "rect_position", $PlayButton.rect_position, Vector2(120 - $PlayButton.rect_size.x / 2, -244), 1.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	
	get_tree().change_scene("res://Src/Scenes/BattleScene.tscn")

