extends StaticBody2D

var sprites = ["res://sprites/ship_fragm2.png", "res://sprites/space_ship_fragm.png"]

func _ready():
	$Sprite.texture = load(sprites[randi() % sprites.size()])
