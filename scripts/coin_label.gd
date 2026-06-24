extends Label

func _process(delta):
	text = "Pièces : " + str(GameManager.coins)
