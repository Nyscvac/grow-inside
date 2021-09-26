extends Area2D


var can_spawn = false
var enemy_counter = 0
var enemy_amount = 80
var Pool = -1
var done = false
var time_to_done = 60
var max_enemy_on_scn = 5

func _physics_process(delta):
	$ProgressBar.value = time_to_done - $time_scan.time_left
	for i in get_overlapping_bodies():
		if i.is_in_group("player"):
			if Input.is_action_just_pressed("E"):
				start_scanning(0, enemy_amount)


func _ready():
	$time_scan.wait_time = time_to_done
	$ProgressBar.max_value = time_to_done

func start_scanning(pool, amount):
	enemy_counter = amount
	Pool = pool
	$Timer.start()
	$time_scan.start()

func set_enemy_pos():
	var enemy_pos
	var rand_cast = randi() % $raycasts.get_child_count()
	for i in $raycasts.get_child_count():
		if i == rand_cast:
			enemy_pos = $raycasts.get_child(i).get_collision_point()
	var rand = int(rand_range(1, 15))
	for i in rand:
		enemy_pos = lerp(enemy_pos, global_position, 0.1)
	return enemy_pos
func spawn_enemy():
	var enemy_pos = set_enemy_pos()
	while enemy_pos.distance_to(get_tree().get_nodes_in_group("player")[0].global_position) < 10:
		#print(enemy_pos)
		enemy_pos = set_enemy_pos()
	var rand_en = randi() % DB.enemies[Pool].size()
	var enemy = load(DB.enemies[Pool][rand_en]["scene"]).instance()
	enemy.global_position = enemy_pos
	get_parent().add_child(enemy)


func _on_Timer_timeout():
	if !done:
		$AnimationPlayer.play("skaner_waves")
		if get_tree().get_nodes_in_group("enemy").size() < max_enemy_on_scn:
			spawn_enemy()
	else:
		$Sprite.hide()
		$Sprite2.show()
		$Timer.stop()
		get_parent().skaner_done()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "skaner_waves":
		if !done:
			$AnimationPlayer.play("skaner_waves")


func _on_time_scan_timeout():
	done = true
