extends Control



func _ready():
	g.load_items()
	$anim.play("logo2_noise")




func _on_play_pressed():
	get_tree().change_scene("res://scenes/other/hub_menu.tscn")


func _on_exit_pressed():
	g.save_items()
	get_tree().quit()
