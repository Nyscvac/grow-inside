extends Node2D

var can_shoot = false
var damage = 5
var id = 0

func _ready():
	$shoot.start()

func _physics_process(delta):
	look_at(get_global_mouse_position())
	if global_rotation_degrees >= 90 or global_rotation_degrees <= -90:
		$shoot_eff.position.y = 3
		$shoot_pos.position.y = 3
		$Sprite.flip_v = true
	else:
		$shoot_eff.position.y = -3
		$shoot_pos.position.y = -3
		$Sprite.flip_v = false
		
	#print(global_rotation_degrees)
	if Input.is_mouse_button_pressed(1):
		if can_shoot:
			$shoot_eff.show()
			$AudioStreamPlayer2D.play()
			var bullet = load(DB.entities[0]["scene"])
			var bul = bullet.instance()
			bul.global_position = $shoot_pos.global_position
			bul.rotation = rotation
			bul.damage = damage
			get_parent().get_parent().add_child(bul)
			can_shoot = false
			$shoot.start()
			$Timer2.start()
			#print("shooted")


func _on_Timer_timeout():
	can_shoot = true
	


func _on_Timer2_timeout():
	$shoot_eff.hide()
