extends KinematicBody2D


var alive = true
var speed = Vector2(5.5, 0)
var acc = 1
var hp = 40
var damage = 15
var appeared = false
var can_shoot = true

func appear():
	$appear_par.emitting = true
	yield(get_tree().create_timer(1), "timeout")
	$appear_par.emitting = false
	appeared = true

func _ready():
	appear()


func dead():
	alive = false
	$CollisionShape2D.call_deferred("set_disabled", true)
	$AnimatedSprite.hide()
	var boom = DB.sound.instance()
	boom.setup(load("res://audio/sfx/boom.wav"), 1, -15)
	get_parent().add_child(boom)
	$Particles2D2.emitting = false
	$Particles2D3.emitting = false
	$Particles2D.emitting = true
	yield(get_tree().create_timer(1), "timeout")
	queue_free()


func get_hit(value:int):
	hp -= value
	if hp <= 0:
		dead()
	var hit_sound = DB.sound.instance()
	hit_sound.setup(load("res://audio/sfx/456309__cynical2207__short-hits-with-metal-stick-on-a-steel-wheel.wav"), rand_range(0.9, 1.2), -25)
	get_parent().add_child(hit_sound)
	$anim.play("get_hit")

func _physics_process(delta):
	if get_tree().get_nodes_in_group("player")[0] in $hitbox.get_overlapping_bodies():
		get_tree().get_nodes_in_group("player")[0].get_hit(damage)
	if alive:
		if appeared:
			var sped = global_position.direction_to(get_tree().get_nodes_in_group("player")[0].global_position) * acc
			global_position += sped
			move_and_slide(sped)

func shoot():
	$shoot_pos.look_at(get_tree().get_nodes_in_group("player")[0].position)
	var shoot = load(DB.entities[1]["scene"]).instance()
	shoot.global_position = $shoot_pos.global_position
	shoot.rotation = $shoot_pos.rotation
	$Sprite.show()
	var shot_sound = DB.sound.instance()
	shot_sound.setup(load("res://audio/sfx/348163__djfroyd__laser-one-shot-2.wav"), 1, -20)
	get_parent().add_child(shot_sound)
	get_parent().add_child(shoot)
	yield(get_tree().create_timer(0.02), "timeout")
	$Sprite.hide()

func _on_Timer_timeout():
	if alive:
		acc = 0.5
		yield(get_tree().create_timer(0.5), "timeout")
		shoot()
		acc = 1
