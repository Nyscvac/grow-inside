extends Node2D


var skaners_done = 0
onready var max_skaners = get_tree().get_nodes_in_group("scaner").size()
var enemy_pool = 0
var level_cleared = false
var Items = {
	"weapons" : {
		"slot1" : -1,
		"slot2" : -1
				},
	"inventory" : [],
	"vault" : []
}




func _ready():
	if g.Items != g.Items_empty_ex:
		Items = g.Items 
		g.Items = g.Items_empty_ex
	spawn_player(Items) 

func end_mission(items):
	get_node("UI/control/black_intro").play(1, "hided")
	yield(get_node("UI/control/black_intro"), "hided")
	var player = get_tree().get_nodes_in_group("player")[0]
	items["inventory"] = player.inventory
	items["weapons"]["slot1"] = player.weapon_slots["slot1"]
	items["weapons"]["slot2"] = player.weapon_slots["slot2"]
	g.Items = items
	print(items)
	get_tree().change_scene("res://scenes/other/hub_menu.tscn")

func spawn_player(items):
	var player = load(DB.entities[4]["scene"]).instance()
	if items != {}:
		player.weapon_slots["slot1"] = items["weapons"]["slot1"]
		player.weapon_slots["slot2"] = items["weapons"]["slot2"]
		player.inventory = items["inventory"]
	player.global_position = $player_spawn_pos.global_position
	add_child(player)

func skaner_done():
	skaners_done += 1
	if skaners_done >= max_skaners:
		level_cleared = true

func _physics_process(delta):
	#print(Items["inventory"])
	if Input.is_action_just_pressed("ui_home"):
		end_mission(Items)
	if level_cleared:
		if get_tree().get_nodes_in_group("enemy").size() == 0:
			end_mission(Items)
