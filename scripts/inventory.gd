extends ItemList


var selected_slot
var selected_slot_acc
var can_set_slot = false
var can_set_slot_acc = false
var Action
var Id
var Id2
var Type
var fast_put = false
var Inventory = []
var setted = false
export(String, "inventory", "vault", "none") var itself:String 
export(String, "player", "hub", "none") var place:String


func _physics_process(delta):
	if !setted:
		if place == "player":
			if get_tree().get_nodes_in_group("player").size() != 0:
				Inventory = get_tree().get_nodes_in_group("player")[0].inventory
				setted = true
				print("SSSSSSSS", Inventory)

	if Input.is_action_just_pressed("ui_end"):
		update_inventory(Inventory)
		print("Inventory updated")
	if Input.is_action_pressed("ctrl"):
		fast_put = true
	else:
		fast_put = false
func set_menu(type:String):
	if place == "player":
		for i in DB.item_actions[type]:
			$PopupMenu.add_item(i)
	elif place == "hub":
		for i in DB.item_actions_hub[type]:
			$PopupMenu.add_item(i)
func is_id2_valid(id2):
	var id = find(id2)
	if id != null:
		return false
	else:
		return true
func generate_item_id2(nm:String):
	var id2 = nm + str(randi() % 999999)
	while is_id2_valid(id2) == false:
		id2 = nm + str(randi() % 999999)
	return id2
func add_item2(type, id, amount):
	if type == "resources" or type == "consumable":
		if Inventory.size() > 0:
			for i in Inventory.size():
				if Inventory[i]["id"] == id:
					if Inventory[i]["type"] == type:
						if Inventory[i]["amount"] < DB.resources[id]["stack_size"]:
							if Inventory[i]["amount"] + amount <= DB.resources[id]["stack_size"]:
								Inventory[i]["amount"] += amount
							else:
								var was = Inventory[i]["amount"]
								Inventory[i]["amount"] += DB.resources[id]["stack_size"] - Inventory[i]["amount"]
								var id2 = generate_item_id2(DB.get(type)[id]["name"])
								Inventory.append({
									"id" : id,
									"amount" : was + amount - DB.resources[id]["stack_size"],
									"name" : DB.get(type)[id]["name"],
									"type" : type,
									"id2" : id2
									})
							update_inventory(Inventory)
							return
						else:
							if i < Inventory.size() - 1:
								continue
							var id2 = generate_item_id2(DB.get(type)[id]["name"])
							Inventory.append({
								"id" : id,
								"amount" : amount, 
								"name" : DB.get(type)[id]["name"],
								"type" : type,
								"id2" : id2
							})
							update_inventory(Inventory)
							return
				if i < Inventory.size() - 1:
					continue
				var id2 = generate_item_id2(DB.get(type)[id]["name"])
				Inventory.append({
					"id" : id,
					"amount" : amount, 
					"name" : DB.get(type)[id]["name"],
					"type" : type,
					"id2" : id2
							})
				update_inventory(Inventory)
		else:
			var id2 = generate_item_id2(DB.get(type)[id]["name"])
			Inventory.append({
				"id" : id,
				"amount" : amount, 
				"name" : DB.get(type)[id]["name"],
				"type" : type,
				"id2" : id2
						})
			update_inventory(Inventory)
			return
	else:
		var id2 = generate_item_id2(DB.get(type)[id]["name"])
		Inventory.append({
			"id" : id,
			"amount" : amount,
			"name" : DB.get(type)[id]["name"],
			"type" : type,
			"id2" : id2
		})
		update_inventory(Inventory)
		#print("ItemList: ", items)

func update_inventory(inventory):
	Inventory = inventory
	clear()
	var c = 0
	for i in inventory:
		if i["type"] == "resources" or i["type"] == "consumable":
			add_item(i["name"] + " " + str(i["amount"]), load(DB.get(i["type"])[i["id"]]["icon"]))
			set_item_metadata(c, {"type" : i["type"], "id" : i["id"], "id2" : i["id2"]})
		else:
			add_item(i["name"], load(DB.get(i["type"])[i["id"]]["icon"]))
			set_item_metadata(c, {"type" : i["type"], "id" : i["id"], "id2" : i["id2"]})
		c += 1

func find(id2):
	for i in Inventory:
		if i["id2"] == id2:
			return i
func _on_inventory_item_selected(index):
	#var type = get_item_metadata(get_selected_items()[0])["type"]
	var type = find(get_item_metadata(get_selected_items()[0])["id2"])["type"]
	#var id = get_item_metadata(get_selected_items()[0])["id"]
	var id = find(get_item_metadata(get_selected_items()[0])["id2"])["id"]
	#var id2 = get_item_metadata(get_selected_items()[0])["id2"]
	var id2 = find(get_item_metadata(get_selected_items()[0])["id2"])["id2"]
	print(get_item_metadata(get_selected_items()[0]),"F")
	var amount = find(get_item_metadata(get_selected_items()[0])["id2"])["amount"]
	if !fast_put:
		$PopupMenu.clear()
		set_menu(get_item_metadata(index)["type"])
		$PopupMenu.popup()
		$PopupMenu.rect_global_position = get_global_mouse_position()
	else:
		if place == "hub":
			if itself == "inventory":
				print(str(id2) + " from inventory to vault")
				get_parent().get_node("vault").add_item2(type, id, amount)
				#print(get_parent().get_node("vault").Inventory, "G")
				for i in Inventory:
					if i["id2"] == id2:
						Inventory.remove(Inventory.find(i))
				get_parent().get_parent().update_inventories()
			elif itself == "vault":
				print(str(id2) + " from vault to inventory")
				get_parent().get_node("inventory").add_item2(type, id , amount)
				for i in Inventory:
					if i["id2"] == id2:
						Inventory.remove(Inventory.find(i))
				get_parent().get_parent().update_inventories()

func _on_PopupMenu_popup_hide():
	for i in get_selected_items():
		unselect(i)

func equip_weapon():
	if place == "player":
		var player = get_tree().get_nodes_in_group("player")[0]
		player.call("equip", Type, Id, selected_slot)
		Type = null 
		Id = null
		can_set_slot = false
		for i in Inventory:
			if i["id2"] == Id2:
				Inventory.remove(Inventory.find(i))
		Id2 = null
		update_inventory(Inventory)
		get_parent().get_parent().update_slots()
		get_parent().get_parent().get_node("anim").stop()
	elif place == "hub":
		#player.call("equip", Type, Id, selected_slot)
		if get_parent().get_parent().items["weapons"][selected_slot] == -1:
			get_parent().get_parent().set_weapon(selected_slot, Id)
		else:
			add_item2("weapons", DB.weapons[get_parent().get_parent().items["weapons"][selected_slot]]["id"], 1)
			get_parent().get_parent().set_weapon(selected_slot, Id)
			#print("G")
		Type = null 
		Id = null
		can_set_slot = false
		for i in Inventory:
			if i["id2"] == Id2:
				Inventory.remove(Inventory.find(i))
				break
		Id2 = null
		get_parent().get_parent().update_inventories()
		update_inventory(Inventory)
		#get_parent().get_parent().update_slots()
		get_parent().get_node("anim").stop()

func equip_accessory():
	if place == "player":
		for i in get_tree().get_nodes_in_group("player")[0].accessories.values():
			if i["id"] == Id:
				return
		var player = get_tree().get_nodes_in_group("player")[0]
		player.call("equip", Type, Id, selected_slot_acc)
		Type = null 
		Id = null
		can_set_slot_acc = false
		for i in Inventory:
			if i["id2"] == Id2:
				Inventory.remove(Inventory.find(i))
				break
		Id2 = null
		update_inventory(Inventory)
		get_parent().get_parent().update_slots()
		get_parent().get_parent().get_node("anim").stop()
	elif place == "hub":
		for i in get_parent().get_parent().items["accessories"].values():
			if i["id"] == Id:
				return
		if get_parent().get_parent().items["accessories"][selected_slot_acc]["id"] == -1:
			get_parent().get_parent().set_accessory(selected_slot_acc, Id)
		else:
			#apply_accessory(selected_slot_acc, false)
			add_item2("accessories", get_parent().get_parent().items["accessories"][selected_slot_acc]["id"], 1)
			get_parent().get_parent().set_accessory(selected_slot_acc, Id)
			print("CHANGED")
			
		Type = null 
		Id = null
		can_set_slot_acc = false
		for i in Inventory:
			if i["id2"] == Id2:
				Inventory.remove(Inventory.find(i))
				break
		Id2 = null
		get_parent().get_parent().update_inventories()
		update_inventory(Inventory)
		#get_parent().get_parent().update_slots()
		#yield(get_parent().get_node("anim"), "animation_finished")
		get_parent().get_node("anim").stop()
func _on_PopupMenu_index_pressed(index):
	var f = $PopupMenu.get_item_text(index)
	#var type = get_item_metadata(get_selected_items()[0])["type"]
	var type = find(get_item_metadata(get_selected_items()[0])["id2"])["type"]
	#var id = get_item_metadata(get_selected_items()[0])["id"]
	var id = find(get_item_metadata(get_selected_items()[0])["id2"])["id"]
	#var id2 = get_item_metadata(get_selected_items()[0])["id2"]
	var id2 = find(get_item_metadata(get_selected_items()[0])["id2"])["id2"]
	#print(get_item_metadata(get_selected_items()[0]),"F")
	var amount = find(get_item_metadata(get_selected_items()[0])["id2"])["amount"]
	if f == "equip":
		if type == "weapons":
			can_set_slot = true
			Type = type 
			Id = id
			Id2 = id2
			if place == "player":
				get_parent().get_parent().get_node("anim").play("slots_light_up")
			else:
				get_parent().get_node("anim").play("slots_light_up")
		elif type == "accessories":
			can_set_slot_acc = true
			Type = type 
			Id = id
			Id2 = id2
			if place == "player":
				get_parent().get_parent().get_node("anim").play("slots_light_up_acc")
			else:
				get_parent().get_node("anim").play("slots_light_up_acc")
		print("equip")
	elif f == "info":
		print("info")
	elif f == "delete":
		for i in Inventory:
			if i["id2"] == id2:
				Inventory.remove(Inventory.find(i))
		update_inventory(Inventory)
		print("delete")
	elif f == "put":
		if itself == "inventory":
			print(str(id2) + " from inventory to vault")
			get_parent().get_node("vault").add_item2(type, id, amount)
			for i in Inventory:
				if i["id2"] == id2:
					Inventory.remove(Inventory.find(i))
			get_parent().get_parent().update_inventories()
		elif itself == "vault":
			print(str(id2) + " from vault to inventory")
			get_parent().get_node("inventory").add_item2(type, id , amount)
			for i in Inventory:
				if i["id2"] == id2:
					Inventory.remove(Inventory.find(i))
			get_parent().get_parent().update_inventories()
	
	elif f == "use":
		if place == "player":
			get_tree().get_nodes_in_group("player")[0].use_consumable(id)
			for i in Inventory:
				if i["id2"] == id2:
					i["amount"] -= 1
					if i["amount"] <= 0:
						Inventory.remove(Inventory.find(i))
			update_inventory(Inventory)
func _on_icon1_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot == true:
			selected_slot = "slot1"
			equip_weapon()
func _on_icon2_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot == true:
			selected_slot = "slot2"
			equip_weapon()



func _on_icon1c_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot_acc == true:
			selected_slot_acc = "slot1"
			equip_accessory()
			print("LOX1")


func _on_icon2c_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot_acc == true:
			selected_slot_acc = "slot2"
			equip_accessory()
			print("LOX2")


func _on_icon3c_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot_acc == true:
			selected_slot_acc = "slot3"
			equip_accessory()
			print("LOX3")


func _on_icon4c_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot_acc == true:
			selected_slot_acc = "slot4"
			equip_accessory()
			print("LOX4")


func _on_icon5c_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot_acc == true:
			selected_slot_acc = "slot5"
			equip_accessory()
			print("LOX5")


func _on_icon6c_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot_acc == true:
			selected_slot_acc = "slot6"
			equip_accessory()
			print("LOX6")
