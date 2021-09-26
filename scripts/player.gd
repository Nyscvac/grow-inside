extends KinematicBody2D



var speed = 100
var max_speed = 3000
var normal_speed = 100
var acceleration = 1000
var motion = Vector2()
var max_hp = 150
var hp = 150
var can_dash = true
var can_get_hit = true
var selected_slot = -1
var weapon_slots = {
	"slot1" : -1,
	"slot2" : -1
}
var inventory = []
onready var tree = get_tree()
var acc_slots = []

func dead():
	queue_free()
	get_tree().quit()

func _ready():
	selected_slot = weapon_slots["slot1"]
	update_sel_slot()
	print("F", weapon_slots)

func get_hit(damage:int):
	if can_get_hit == true:
		hp -= damage
		can_get_hit = false
		$anim.play("get_hit")
		yield($anim, "animation_finished")
		$anim.play("imframes")
		$imframes.start()


func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed('d')) - int(Input.is_action_pressed('a'))
	axis.y = int(Input.is_action_pressed('s')) - int(Input.is_action_pressed('w'))
	return axis.normalized()
func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO

func add_item(type, id, amount):
	if type == "resources":
		if inventory.size() > 0:
			var has = false
			for i in inventory.size():
				if inventory[i]["id"] == id:
					if inventory[i]["type"] == type:
						if inventory[i]["amount"] < DB.resources[id]["stack_size"]:
							if inventory[i]["amount"] + amount <= DB.resources[id]["stack_size"]:
								inventory[i]["amount"] += amount
							else:
								var was = inventory[i]["amount"]
								inventory[i]["amount"] += DB.resources[id]["stack_size"] - inventory[i]["amount"]
								inventory.append({
									"id" : id,
									"amount" : was + amount - DB.resources[id]["stack_size"],
									"name" : DB.get(type)[id]["name"],
									"type" : type,
									"id2" : DB.get(type)[id]["name"] + str(randi() % 999999)
									})
							return
						else:
							if i < inventory.size() - 1:
								continue
							inventory.append({
								"id" : id,
								"amount" : amount, 
								"name" : DB.get(type)[id]["name"],
								"type" : type,
								"id2" : DB.get(type)[id]["name"] + str(randi() % 999999)
							})
							return
		else:
			inventory.append({
				"id" : id,
				"amount" : amount, 
				"name" : DB.get(type)[id]["name"],
				"type" : type,
				"id2" : DB.get(type)[id]["name"] + str(randi() % 999999)
						})
			return
	else:
		inventory.append({
			"id" : id,
			"name" : DB.get(type)[id]["name"],
			"type" : type,
			"id2" : DB.get(type)[id]["name"] + str(randi() % 999999)
		})

func remove_item(id2):
	for i in inventory:
		if i["id2"] == id2:
			inventory.remove(inventory.find(i)) 

func get_knocked(knockback, r):
	pass
	
func apply_movement(aceleration):
	motion += aceleration
	motion = motion.clamped(speed)


func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.empty():
		return
	var distances = []
	for i in enemies:
		var distance = position.distance_squared_to(i.position)
		distances.append(distance)
	var closest_enemy = distances.min()
	var enemy_idx = distances.find(closest_enemy)
	return enemies[enemy_idx]
func get_position():
	return position

#func _input(event):
#	if event is InputEventMouseButton:
#		if event.button_index == 2:
#			if selected_slot == slot1:
#				selected_slot = slot2
#				#print("G")
#				update_sel_slot()
#			else: 
#				selected_slot = slot1
#				update_sel_slot()

func _physics_process(delta):
	#print(slot1, slot2, selected_slot)
		
	if Input.is_action_just_pressed("1"):
		selected_slot = weapon_slots["slot1"]
		update_sel_slot()
	if Input.is_action_just_pressed("2"):
		selected_slot = weapon_slots["slot2"]
		update_sel_slot()
	#print(slot1, slot2)
	if hp <= 0:
		dead()
	if Input.is_action_pressed("v"):
		if $Camera2D.zoom != Vector2(1.5, 1.5):
			$Camera2D.zoom = Vector2(1.5, 1.5)
	else:
		if $Camera2D.zoom != Vector2(0.3, 0.3):
			$Camera2D.zoom = Vector2(0.3, 0.3)
	if Input.is_action_pressed("d"):
	
			$Sprite.flip_h = false
			$Sprite.play("walk_right")
			#print("s")
	elif Input.is_action_pressed("a"):

			$Sprite.flip_h = true
			$Sprite.play("walk_right")
	elif Input.is_action_pressed("s"):

			#$Sprite.flip_h = true
			$Sprite.play("walk_right")
	elif Input.is_action_pressed("w"):

			#$Sprite.flip_h = true
			$Sprite.play("walk_right")
	else:
		$Sprite.play("stand")
	
	if Input.is_action_just_pressed("shift"):
		dash()



	var axis = get_input_axis()
	if axis == Vector2.ZERO:
		apply_friction(acceleration * delta)
	else:
		apply_movement(axis * acceleration * delta)
		move_and_slide(motion)

func update_sel_slot():
	clear_weapon()
	if selected_slot != -1:
		var wep = load(DB.get("weapons")[selected_slot]["scene"]).instance()
		wep.position = $wep_pos.position
		add_child(wep)

func clear_weapon():
	for i in get_children():
		if i.is_in_group("weapon"):
			i.queue_free()


func drop_selected_weapon():
	var drop = load(DB.entities[3]["scene"]).instance()
	drop.set_item("weapons", selected_slot)
	drop.global_position = global_position
	get_parent().add_child(drop)
	if weapon_slots["slot1"] == selected_slot:
		weapon_slots["slot1"] = -1
		selected_slot = -1
		update_sel_slot()
	if weapon_slots["slot2"] == selected_slot:
		weapon_slots["slot2"] = -1
		selected_slot = -1
		update_sel_slot()
func take_weapon(slot):
	clear_weapon()
	var wep = load(DB.get("weapons")[slot]["scene"]).instance()
	wep.position = $wep_pos.position
	add_child(wep)
	selected_slot = slot

func equip(type, id, slot):
	if type == "weapons":
		if weapon_slots[slot] == -1:
			weapon_slots[slot] = id
			selected_slot = weapon_slots[slot]
			update_sel_slot()
		else:
			add_item("weapons", weapon_slots[slot], 1)
			weapon_slots[slot] = id
			selected_slot = weapon_slots[slot]
			update_sel_slot()


func give_item(type, id, amount):
	var inv = get_tree().get_nodes_in_group("inv")
	for i in inv:
		if i.place == "player":
			i.add_item2(type, id, amount)
			inventory = i.Inventory
			print("Inventory: ", i.Inventory)
			return
			
func dash():
	if can_dash:
		$Particles2D.emitting = true
		$Sprite.modulate = Color(1, 1, 1, 0.352941)
		$CollisionShape2D.disabled = true
		speed = 7000
		acceleration = 7000
		$Timer.start()
		$dash.start()
		can_dash = false


func _on_Timer_timeout():
	$Sprite.modulate = Color(1, 1, 1, 1)
	$CollisionShape2D.disabled = false
	speed = 100
	acceleration = 1000
	$Particles2D.emitting = false


func _on_dash_timeout():
	can_dash = true
	$anim.play("dash_ready")


func _on_imframes_timeout():
	can_get_hit = true
