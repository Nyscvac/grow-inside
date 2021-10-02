extends Node

var Items
const Items_empty_ex = {
	"weapons" : {
		"slot1" : -1,
		"slot2" : -1
				},
	"inventory" : [],
	"vault" : [],
	"accessories" : {
	"slot1" : {"id" : -1, "working" : false},
	"slot2" : {"id" : -1, "working" : false}, 
	"slot3" : {"id" : -1, "working" : false}, 
	"slot4" : {"id" : -1, "working" : false}, 
	"slot5" : {"id" : -1, "working" : false},
	"slot6" : {"id" : -1, "working" : false},
}
}
const max_accessories = 6
func _ready():
	randomize()

func _process(delta):
	#print(Items)
	if Input.is_action_just_pressed("f11"):
		OS.window_fullscreen = !OS.window_fullscreen

func save_items():
	var file = ConfigFile.new()
	file.set_value("Items", "Items", Items)
	file.save("res://save1.data")

func load_items():
	var file = ConfigFile.new()
	var err = file.load("res://save1.data")
	var data
	if err == OK:
		data = file.get_value("Items", "Items")
		Items = data
