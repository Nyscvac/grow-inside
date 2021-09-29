extends Control

func _ready():
	#$tab_menu.show()
	$tab_menu.hide()
	$black_intro.show()
	$black_intro.play(1, "showed")
	$tab_menu.hide()


func update_slots():
	var player = get_tree().get_nodes_in_group("player")[0]
	if player.weapon_slots["slot1"] != -1:
		$tab_menu/wep_slot1/icon1.texture = load(DB.weapons[player.weapon_slots["slot1"]]["icon"])
	else:
		$tab_menu/wep_slot1/icon1.texture = null
	if player.weapon_slots["slot2"] != -1:
		$tab_menu/wep_slot2/icon2.texture = load(DB.weapons[player.weapon_slots["slot2"]]["icon"])
	else:
		$tab_menu/wep_slot2/icon2.texture = null

func _process(delta):
	if get_tree().get_nodes_in_group("player").size() != 0:
		var p_hp = get_tree().get_nodes_in_group("player")[0].hp
		var p_mx_hp = get_tree().get_nodes_in_group("player")[0].max_hp
#		$ProgressBar.value = p_hp
#		$ProgressBar.max_value = p_mx_hp
#		$ProgressBar
#		print($ProgressBar.value, $ProgressBar.max_value)
		$Label2.text =  str(p_hp) + "/" + str(p_mx_hp)
	$Label.text = str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("tab"):
		if !$tab_menu.visible:
			$tab_menu.visible = true
			#$tab_menu/inventory.update_inventory(get_tree().get_nodes_in_group("player")[0].inventory)
			update_slots()
		else:
			$tab_menu.visible = false



func _on_swap_pressed():
	var player = get_tree().get_nodes_in_group("player")[0]
	var slot1 = player.weapon_slots["slot1"]
	var slot2 = player.weapon_slots["slot2"]
	player.weapon_slots["slot1"] = slot2
	player.weapon_slots["slot2"] = slot1
	if player.selected_slot == slot1:
		player.selected_slot = slot2
	else:
		player.selected_slot = slot1
	update_slots()
	player.update_sel_slot()
