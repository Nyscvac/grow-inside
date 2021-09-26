extends KinematicBody2D

var dash_weights = {

	"few" : {
		"it" : 5,
		"chance" : 50
			},
	"long" : {
		"it" : 10,
		"chance" : 10
			},
	"to_player" : {
		"it" : -1,
		"chance" : 40
			},

}
var p_pos
var move_to_player = false
var dashing = false
var move_to_point = false
var point
var alive = true
var hp = 35
var damage = 15
var appeared = false

func _ready():
	appear()

func get_hit(value:int):
	hp -= value
	if hp <= 0:
		dead()
	var hit_sound = DB.sound.instance()
	hit_sound.setup(load("res://audio/sfx/456309__cynical2207__short-hits-with-metal-stick-on-a-steel-wheel.wav"), rand_range(0.9, 1.2), -25)
	get_parent().add_child(hit_sound)
	$anim.play("get_hit")

func dead():
	alive = false
	$CollisionShape2D.call_deferred("set_disabled", true)
	$AnimatedSprite.hide()
	var boom = DB.sound.instance()
	boom.setup(load("res://audio/sfx/boom.wav"), 1, -15)
	get_parent().add_child(boom)
	$Particles2D4.emitting = false
	$Particles2D3.emitting = false
	$Particles2D.emitting = true
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
func appear():
	$appear_par.emitting = true
	yield(get_tree().create_timer(1), "timeout")
	$appear_par.emitting = false
	appeared = true
func _physics_process(delta):
	if move_to_player:
		if global_position.distance_to(p_pos) > 10:
			global_position = global_position.linear_interpolate(p_pos, delta * 3)
			print(p_pos)
		else:
			$Particles2D3.emitting = false
			$Particles2D4.emitting = false
			move_to_player = false
			dashing = false
			p_pos = null
			$AnimatedSprite.play("fall")
			yield($AnimatedSprite, "animation_finished")
	if move_to_point:
		if global_position.distance_to(point) > 10:
			global_position = global_position.linear_interpolate(point, delta * 3)
		else:
			$Particles2D3.emitting = false
			$Particles2D4.emitting = false
			move_to_point = false
			dashing = false
			point = null
			$AnimatedSprite.play("fall")
			yield($AnimatedSprite, "animation_finished")
			
func dash(rand):
	dashing = true
	#choosing dash type
	var total = 0
	var it
	for i in dash_weights.values():
		total += i["chance"]
	var ran = rand * total
	for i in dash_weights.values():
		if ran < i["chance"]:
			it = i["it"]
			break
		ran -= i["chance"]
	if it != -1:
		var r = randi() % 360
		for i in 360:
			if i == r:
				r = i
				break
		$RayCast2D.rotation_degrees = r
		var pos = global_position
		for i in it:
			pos = lerp(pos, $RayCast2D.get_collision_point(), 0.1)
		point = pos
		$AnimatedSprite.play("start")
		yield($AnimatedSprite, "animation_finished")
		$Particles2D3.emitting = true
		$Particles2D4.emitting = true
		move_to_point = true
	else:
		p_pos = get_tree().get_nodes_in_group("player")[0].global_position
		$AnimatedSprite.play("start")
		yield($AnimatedSprite, "animation_finished")
		$Particles2D3.emitting = true
		$Particles2D4.emitting = true
		move_to_player = true


func _on_Timer_timeout():
	if !dashing:
		dash(rand_range(0,1))
