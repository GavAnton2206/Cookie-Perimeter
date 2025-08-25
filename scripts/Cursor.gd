extends Sprite2D
class_name Cursor

@export var gameManager: GameManager

signal moved(from: Vector2, to: Vector2)

var curPos := Vector2(0, 0)
var tween: Tween

func _ready() -> void:
	moved.connect(gameManager.cursorMoved)
	tween = get_tree().create_tween()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right"):
		move(Vector2(1, 0))
	elif event.is_action_pressed("left"):
		move(Vector2(-1, 0))
	elif event.is_action_pressed("up"):
		move(Vector2(0, -1))
	elif event.is_action_pressed("down"):
		move(Vector2(0, 1))

func move(direction: Vector2):
	var lastPos = Vector2(curPos.x, curPos.y)
	curPos += direction
	curPos.x = clamp(curPos.x, 0, gameManager.fieldSize[0] - 1)
	curPos.y = clamp(curPos.y, 0, gameManager.fieldSize[1] - 1)
	
	if curPos.x == lastPos.x and curPos.y == lastPos.y:
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "global_position", gameManager.worldPos(curPos), 1.0/gameManager.speed).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(Callable.create(moved, "emit").bind(lastPos, curPos))
