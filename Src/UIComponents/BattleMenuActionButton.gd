extends Button

var action = null

func _ready():
	pass

func _on_ActionButton_pressed():
	BattleTurnHandler.emit_signal("action_selected", action)
