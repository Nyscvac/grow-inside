extends KinematicBody2D



var showed = false
signal ready_actions
var attacking = false
var hp = 35
var alive = true

var actions = {
	0 : {
		"order" : ["appear", "shoot", "disappear"],
		"delay_btwn" : [1, 1, 1]
		}
}

func dead():
	alive = false
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

func _ready():
	$attack_timer.start()
	$AnimatedSprite.hide()
	#shoot()
	#play_action(0)
	#yield(get_tree().create_timer(3), "timeout")
	#_wait(2)


func disappear():
	$CollisionShape2D.call_deferred("set_disabled", true)
	$AnimatedSprite.play("disappear")
	yield($AnimatedSprite, "animation_finished")
	$AnimatedSprite.hide()
	

func appear():
	var player_pos = get_tree().get_nodes_in_group("player")[0].global_position
	var rand_pos = Vector2(rand_range(-150, 150), rand_range(-90, 90))
	global_position = player_pos + rand_pos
	$AnimatedSprite.show()
	$CollisionShape2D.call_deferred("set_disabled", false)
	$AnimatedSprite.play("appear")
	showed = true

func play_action(action_id:int):
	attacking = true
	for i in actions[action_id]["order"].size():
		yield(get_tree().create_timer(actions[action_id]["delay_btwn"][i]), "timeout")
		call(actions[action_id]["order"][i])
	attacking = false


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


func _on_attack_timer_timeout():
	if !attacking:
		if alive:
			play_action(0)
