extends Panel

@onready var sree: Sprite2D = $Avatar/Sree
@onready var ramen_paglu: Sprite2D = $Avatar/RamenPaglu
@onready var pork_paglu: Sprite2D = $Avatar/PorkPaglu
@onready var omma: Sprite2D = $Avatar/Omma
@onready var appa: Sprite2D = $Avatar/Appa
@onready var upasana: Sprite2D = $Avatar/Upasana

@onready var avatars = {
	"sree": sree,
	"ramenpaglu": ramen_paglu,
	"porkpaglu": pork_paglu,
	"omma": omma,
	"appa": appa,
	"upasana": upasana,
}


func _ready() -> void:
	sree.show()
	ramen_paglu.hide()
	pork_paglu.hide()
	omma.hide()
	appa.hide()
	upasana.hide()


func set_avatar(character_name: String) -> void:
	for key in avatars:
		if key == character_name:
			avatars[key].show()
		else:
			avatars[key].hide()
