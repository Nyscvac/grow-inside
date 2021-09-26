extends Area2D

var damage = 13

var speed = Vector2(3.3, 0)

func _physics_process(delta):
	position += speed.rotated(rotation)

func _on_enemy_shot_body_entered(body):
	if body.is_in_group("player"):
		body.get_hit(damage)
		queue_free()
