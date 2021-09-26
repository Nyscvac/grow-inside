extends RigidBody2D


var acc = 1
var damage = 15
var dashing = false
var hp = 35
var appeared = false

func _ready():
	appear()
func _physics_process(delta):
	var sped = global_position.direction_to(get_tree().get_nodes_in_group("player")[0].global_position) / 2 * acc
	if appeared:
		if !dashing:
			global_position += sped
		else:
			if global_position.distance_to($RayCast2D.get_collision_point()) > 10:
				global_position = global_position.linear_interpolate($RayCast2D.get_collision_point(), delta / 1.5)
	if sped.x > 0:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
	rotation = lerp(rotation, 0, 0.04)


func dash():
	$RayCast2D.cast_to = global_position.direction_to(get_tree().get_nodes_in_group("player")[0].global_position) * 10000
	$RayCast2D.enabled = true
	dashing = true
	$AnimatedSprite.play("attack")
	$AnimatedSprite.speed_scale = 5
	$Timer.start()


func dead():
	$CollisionShape2D.call_deferred("set_disabled", true)
	$AnimatedSprite.hide()
	$Particles2D.emitting = true
	var boom = DB.sound.instance()
	boom.setup(load("res://audio/sfx/boom.wav"), 1, -15)
	get_parent().add_child(boom)
	yield(get_tree().create_timer(1), "timeout")
	$Particles2D.emitting = false
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
func get_hit(value:int):
	hp -= value
	if hp <= 0:
		dead()
	var sfx = DB.sound.instance()
	sfx.setup(load("res://audio/sfx/456309__cynical2207__short-hits-with-metal-stick-on-a-steel-wheel.wav"), rand_range(0.9, 1.2), -25)
	get_parent().add_child(sfx)
	$anim.play("get_hit")


func appear():
	$appear_par.emitting = true
	yield(get_tree().create_timer(0.55), "timeout")
	$appear_par.emitting = false
	appeared = true

func _on_Timer_timeout():
	dashing = false
	$AnimatedSprite.speed_scale = 1
	$AnimatedSprite.play("default")


func _on_Timer2_timeout():
	dash()


func _on_enemy_3_body_entered(body):
	if body.is_in_group("player"):
		body.get_hit(damage)
