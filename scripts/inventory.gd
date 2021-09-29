extends ItemList


var selected_slot
var can_set_slot = false
var Action
var Id
var Id2
var Type
var fast_put = false
var Inventory = []
export(String, "inventory", "vault", "none") var itself:String 
export(String, "player", "hub", "none") var place:String
func _physics_process(delta):
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
func add_item2(type, id, amount):
	if type == "resources":
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
								Inventory.append({
									"id" : id,
									"amount" : was + amount - DB.resources[id]["stack_size"],
									"name" : DB.get(type)[id]["name"],
									"type" : type,
									"id2" : DB.get(type)[id]["name"] + str(randi() % 999999)
									})
							update_inventory(Inventory)
							return
						else:
							if i < Inventory.size() - 1:
								continue
							Inventory.append({
								"id" : id,
								"amount" : amount, 
								"name" : DB.get(type)[id]["name"],
								"type" : type,
								"id2" : DB.get(type)[id]["name"] + str(randi() % 999999)
							})
							update_inventory(Inventory)
							return
				if i < Inventory.size() - 1:
					continue
				Inventory.append({
					"id" : id,
					"amount" : amount, 
					"name" : DB.get(type)[id]["name"],
					"type" : type,
					"id2" : DB.get(type)[id]["name"] + str(randi() % 999999)
							})
				update_inventory(Inventory)
		else:
			Inventory.append({
				"id" : id,
				"amount" : amount, 
				"name" : DB.get(type)[id]["name"],
				"type" : type,
				"id2" : DB.get(type)[id]["name"] + str(randi() % 999999)
						})
			update_inventory(Inventory)
			return
	else:
		Inventory.append({
			"id" : id,
			"amount" : amount,
			"name" : DB.get(type)[id]["name"],
			"type" : type,
			"id2" : DB.get(type)[id]["name"] + str(randi() % 999999)
		})
		update_inventory(Inventory)
		#print("ItemList: ", items)

func update_inventory(inventory):
	Inventory = inventory
	#var inventory = player.inventory
	clear()
	var c = 0
	for i in inventory:
		if i["type"] == "resources":
			add_item(i["name"] + " " + str(i["amount"]), load(DB.resources[i["id"]]["icon"]))
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
		player.remove_item(Id2)
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
		can_set_slot = true
		Type = type 
		Id = id
		Id2 = id2
		if place == "player":
			get_parent().get_parent().get_node("anim").play("slots_light_up")
		else:
			get_parent().get_node("anim").play("slots_light_up")
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

func _on_icon1_gui_input(event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot == true:
			selected_slot = "slot1"
			equip_weapon()
func _on_icon2_gui_input(event):
	if Input.is_mouse_button_pressed(1):
		if can_set_slot == true:
			selected_slot = "slot2"
			equip_weapon()
