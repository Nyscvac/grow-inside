extends Area2D

var ripped = false
var hp = 4

func _physics_process(delta):
	if get_tree().get_nodes_in_group("player")[0] in get_overlapping_bodies():
		if Input.is_action_just_pressed("E"):
			if !ripped:
				rip_it_off()

func leaf_release(mode:int):
	if mode == 0:
		#$leafs.amount = randi() % 5 + 2
		$leafs.emitting = true
		
		#$leafs.emitting = false
	else:
		$leafs.one_shot = true
		$leafs.amount = randi() % 30 + 20
		$leafs.emitting = true
func rip_it_off():
	if !ripped:
		hp -= 1
		$anim.play("get_hit")
		leaf_release(0)
		if hp <= 0:
			var type
			var type_rand = randi() % 2
			var items = ["weapons", "accessories"]
			type = items[type_rand]
			var id = DB.get(type)[randi() % DB.get(type).size()]["id"]
			var item_drop = load(DB.entities[3]["scene"]).instance()
			item_drop.set_item(type, id, 1)
			item_drop.global_position = global_position
			get_parent().add_child(item_drop)
			$outline.show()
			$ripped.show()
			ripped = true
			leaf_release(1)
