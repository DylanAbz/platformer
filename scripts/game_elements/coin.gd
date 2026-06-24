extends Area3D

@export var rotation_speed := 180.0

func _process(delta):
	rotate_y(deg_to_rad(rotation_speed * delta))


func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.coins += 1
		queue_free()
