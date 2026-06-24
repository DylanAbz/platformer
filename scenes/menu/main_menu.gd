extends Control

func _on_play_button_pressed() -> void:
	# à remplacer par scène de jeu
	get_tree().change_scene_to_file("res://scenes/test/playerTest.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
