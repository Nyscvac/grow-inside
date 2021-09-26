extends Area2D



export var Id = -1
export var Type = ""
export var Amount = 0

func _ready():
	set_item(Type, Id, Amount) 

	
func set_item(type, id, amount):
	$Sprite.texture = load(DB.get(type)[id]["icon"])
	Id = DB.get(type)[id]["id"]
	Type = type
	Amount = amount
func _physics_process(delta):
	if get_tree().get_nodes_in_group("player")[0] in get_overlapping_bodies():
		if Input.is_action_just_pressed("E"):
			get_tree().get_nodes_in_group("player")[0].give_item(Type, Id, Amount)
			queue_free()
