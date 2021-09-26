extends AudioStreamPlayer


func setup(strm, pitch, vol):
	stream = strm
	pitch_scale = pitch
	volume_db = vol

func _ready():
	play()
	yield(self, "finished")
	queue_free()
