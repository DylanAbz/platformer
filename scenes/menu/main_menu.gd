extends Control

func _on_play_button_pressed() -> void:
	# à remplacer par scène de jeu
	get_tree().change_scene_to_file("res://scenes/player/Player.tscn")

func _on_quitt_button_pressed() -> void:
	get_tree().quit()
