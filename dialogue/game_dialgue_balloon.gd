extends BaseGameDialogueBalloon

@onready var avatar_panel: Panel = $Balloon/DialogueBox/PanelContainer/MarginContainer/HBoxContainer/AvatarPanel

func set_avatar(character: String) -> void:
	if character == "none":
		avatar_panel.hide()
	else:
		avatar_panel.show() 
		avatar_panel.set_avatar(character)
