extends ColorRect

signal showed
signal hided

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func play(speed, anim):
	var sped = $anim.playback_speed
	$anim.playback_speed = speed
	$anim.play(anim)
	yield($anim, "animation_finished")
	$anim.playback_speed = sped
	if anim == "hided":
		emit_signal("hided")
	if anim == "showed":
		emit_signal("showed")

