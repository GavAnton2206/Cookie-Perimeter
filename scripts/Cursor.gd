extends Sprite2D
class_name Cursor

@export var gameManager: GameManager

signal moved(from: Vector2, to: Vector2)
signal left()

var curPos := Vector2(0, 0)
var tween: Tween
var movedNum: int = 0

func _ready() -> void:
	moved.connect(gameManager.cursorMoved)
	left.connect(gameManager.cursorLeft)
	tween = get_tree().create_tween()

func _input(event: InputEvent) -> void:
	if gameManager.gameEnded:
		return

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
		left.emit()
		return

	movedNum += 1
	
	if tween:
		tween.kill()
	
	gameManager.cursorStartedMovement(lastPos, curPos)
	tween = create_tween()
	tween.tween_property(self, "global_position", gameManager.worldPos(curPos), 1.0/gameManager.speed).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(Callable.create(moved, "emit").bind(lastPos, curPos))
