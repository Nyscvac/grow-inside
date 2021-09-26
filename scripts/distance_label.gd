extends Label


export var meters:int 


func _ready():
	text = str(meters) + " m from ship crash"
	$anim.play("appear")
	yield($anim, "animation_finished")
	queue_free()
