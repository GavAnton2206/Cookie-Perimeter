extends TextureRect

@export var time: float
var tween: Tween

func _ready() -> void:
	tween = create_tween().set_loops()
	tween.tween_property(self, "rotation", 2*PI, time).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation", 0, time).set_trans(Tween.TRANS_SINE)