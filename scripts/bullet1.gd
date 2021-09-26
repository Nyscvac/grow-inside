extends Area2D

var speed = Vector2(5, 0)
var damage:int
var touched = false

func _physics_process(delta):
	if $Sprite.visible:
		position += speed.rotated(rotation)
	

func _on_bullet1_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("get_hit"):
			body.call("get_hit", damage)
	#$Particles2D.rotation = rotation
	touched = true
	$Particles2D.emitting = true
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Sprite.hide()
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()


func _on_range_timeout():
	if !touched:
		queue_free()
