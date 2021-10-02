extends Control


var items = g.Items_empty_ex

var vault_inventory = []
var player_inventory = []

func _ready():
	if g.Items != null:
		print("SEt")
		items = g.Items
		set_player_inventory(items["inventory"])
		set_vault(items["vault"])
		set_weapon("slot1", items["weapons"]["slot1"])
		set_weapon("slot2", items["weapons"]["slot2"])
	update_inventories()
	$background_loc.show()
	$tab_menu.hide()
	$black_intro.play(1, "showed")
	#yield($black_intro, "appeared")
	

func set_player_inventory(inventory):
	player_inventory = inventory
	update_inventories()

func update_weapons():
	if items["weapons"]["slot1"] != -1:
		$tab_menu/wep_slot1/icon1.texture = load(DB.weapons[items["weapons"]["slot1"]]["icon"])
	else:
		$tab_menu/wep_slot1/icon1.texture = null
	if items["weapons"]["slot2"] != -1:
		$tab_menu/wep_slot2/icon2.texture = load(DB.weapons[items["weapons"]["slot2"]]["icon"])
	else:
		$tab_menu/wep_slot2/icon2.texture = null

func update_accessories():
	var c = 1
	for i in items["accessories"].keys():
		if items["accessories"][i]["id"] != -1:
			get_node("tab_menu/acc_" + i + "/icon"+ str(c)+"c").texture = load(DB.accessories[items["accessories"][i]["id"]]["icon"])
		c += 1
	#print("F")
func update_inventories():
	#print("FF")
	$tab_menu/inventory.clear()
	$tab_menu/vault.clear()
	$tab_menu/inventory.update_inventory(player_inventory)
	$tab_menu/vault.update_inventory(vault_inventory)
	update_weapons()
	update_accessories()
	g.save_items()
func set_vault(inventory):
	vault_inventory = inventory
	update_inventories()

func set_weapon(slot, weapon):
	items["weapons"][slot] = weapon

func set_accessory(slot, acc):
	items["accessories"][slot]["id"] = acc

func start_mission(location_id):
	var level = load(DB.locations[location_id]["scene"])
	g.Items = items
	get_tree().change_scene_to(level)


func _on_loc_jun_b_pressed():
	$black_intro.play(1, "hided")
	yield($black_intro, "hided")
	start_mission(0)


func _on_tab_menu_b_pressed():
	$black_intro.play(3, "hided")
	yield($black_intro, "hided")
	$background_loc.hide()
	$black_intro.play(3, "showed")
	$tab_menu.show()


func _on_back_b_pressed():
	$black_intro.play(3, "hided")
	yield($black_intro, "hided")
	$tab_menu.hide()
	$black_intro.play(3, "showed")
	$background_loc.show()


func _on_back_b2_pressed():
	g.save_items()
	get_tree().change_scene("res://scenes/other/main_menu.tscn")


func _on_swap_pressed():
	var slot1 = items["weapons"]["slot1"]
	var slot2 = items["weapons"]["slot2"]
	items["weapons"]["slot1"] = slot2
	items["weapons"]["slot2"] = slot1
	update_inventories()



