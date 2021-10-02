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
var accessories = {
	"slot1" : {"id" : -1, "working" : false},
	"slot2" : {"id" : -1, "working" : false}, 
	"slot3" : {"id" : -1, "working" : false}, 
	"slot4" : {"id" : -1, "working" : false}, 
	"slot5" : {"id" : -1, "working" : false},
	"slot6" : {"id" : -1, "working" : false},
}
var weapon_slots = {
	"slot1" : -1,
	"slot2" : -1
}
var inventory = []
onready var tree = get_tree()


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
		if $Camera2D.zoom != Vector2(0.4, 0.4):
			$Camera2D.zoom = Vector2(0.4, 0.4)
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

func get_heal(value):
	hp += value
	hp = clamp(hp, 0, max_hp)

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

func apply_accessory(slot, mode:bool):
	call(DB.accessories[accessories[slot]["id"]]["effect"], mode)
	
func apply_accessories(mode:bool):
	for i in accessories:
		if accessories[i]["id"] != -1:
			if accessories[i]["working"] == false:
				call(DB.accessories[accessories[i]["id"]]["effect"], mode)
				accessories[i]["working"] = true

func clear_accessory(slot):
	call(DB.accessories[accessories[slot]["id"]]["effect"], false)

func use_consumable(id):
	call(DB.consumable[id]["effect"])

func equip(type, id, slot):
	if type == "weapons":
		if weapon_slots[slot] == -1:
			weapon_slots[slot] = id
			selected_slot = weapon_slots[slot]
			update_sel_slot()
		else:
			var inv = get_tree().get_nodes_in_group("inv")
			for i in inv:
				if i.place == "player":
					i.add_item2("weapons", weapon_slots[slot], 1)
					inventory = i.Inventory
			#get_add_item("weapons", weapon_slots[slot], 1)
			weapon_slots[slot] = id
			selected_slot = weapon_slots[slot]
			update_sel_slot()
	elif type == "accessories":
		#if accessories[slot]["id"] != id:
		if accessories[slot]["id"] == -1:
			accessories[slot]["id"] = id
			apply_accessory(slot, true)
		else:
			var inv = get_tree().get_nodes_in_group("inv")
			for i in inv:
				if i.place == "player":
					apply_accessory(slot, false)
					print("CHANGED")
					i.add_item2("accessories", accessories[slot]["id"], 1)
					print(i.Inventory)
					#inventory = i.Inventory
				#break
			
			#inventory = get_tree().get_nodes_in_group("inv")[0].Inventory
			accessories[slot]["id"] = id
			apply_accessory(slot, true)
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

#Accessories effects

func medkit_use():
	get_heal(50)

func bio_energy_core_eff(mode:bool):
	if mode:
		max_hp += 50
		hp += 50
	else:
		max_hp -= 50
		hp -= 50

func rebar_boots_eff(mode:bool):
	if mode:
		speed += 50
		acceleration += 50
	else:
		speed -= 50
		acceleration -= 50

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
