extends Node
class_name GameManager

const cellSize := [64.0, 64.0]
const startPosition := [103.5, 100.5]
const fieldSize := [16, 8]
const speed := 16.0

@export var cookiesParent: Node
@export var firesParent: Node
@export var cursor: Cursor
@export var label: Label
@export var cookieScene: PackedScene
@export var fireScene: PackedScene
var cookies: Array[Obj]
@export var fires: Array[Obj]

var score: int:
	get():
		return score
	set(value):
		score = value
		updateScore()
var cookieNum: int:
	get():
		return cookieNum
	set(value):
		cookieNum = value
		updateScore()

func _ready() -> void:
	randomize()
	score = 0
	var cookiePos = generateCookies(10)
	cookieNum = cookiePos.size() - 1
	for i in range(1, cookiePos.size()):
		createCookie(cookiePos[i])

func cursorMoved(from: Vector2, to: Vector2):
	#print("Cursor moved from " + str(from) + " to " + str(to))
	for cookie in cookies:
		if cookie.pos == to:
			cookies.erase(cookie)
			cookie.queue_free()
			score += 1
	generateFires(3)

func createFire(pos: Vector2):
	var fire = fireScene.instantiate()
	fire.global_position = worldPos(pos)
	fires.append(fire)
	firesParent.add_child(fire)
	#print("Fire created: " + str(pos))

func generateFires(num: int):
	var fires_: Array[Vector2]
	var possiblePositions: Array[Vector2]
	var chosenPos: Vector2

	for x in range(0, fieldSize[0]):
		for y in range(0, fieldSize[1]):
			possiblePositions.append(Vector2(x, y))

	possiblePositions.erase(cursor.curPos)
	for cookie in cookies:
		possiblePositions.erase(cookie.pos)
	for fire in fires:
		possiblePositions.erase(fire.pos)
	
	for i in range(0, num):
		if possiblePositions.size() == 0:
			break
		
		chosenPos = possiblePositions[randi() % possiblePositions.size()]
		
		fires_.append(chosenPos)
		possiblePositions.erase(chosenPos)
		
	for fire_ in fires_:
		createFire(fire_)

func updateScore() -> void:
	label.text = str(score) + "/" + str(cookieNum) 
func createCookie(startPos: Vector2):
	var newCookie = cookieScene.instantiate()
	newCookie.init(startPos)
	newCookie.global_position = worldPos(startPos)
	cookies.append(newCookie)
	cookiesParent.add_child(newCookie)
func generateCookies(num: int) -> Array[Vector2]:
	var cookies_: Array[Vector2] = []
	var possiblePositions: Array[Vector2]
	var chosenPos: Vector2

	for x in range(0, fieldSize[0]):
		for y in range(0, fieldSize[1]):
			possiblePositions.append(Vector2(x, y))
	possiblePositions.erase(cursor.curPos)
	
	for i in range(1, num):
		if possiblePositions.size() == 0:
			break
		
		chosenPos = possiblePositions[randi() % possiblePositions.size()]
		cookies_.append(chosenPos)

		possiblePositions.erase(chosenPos)
		possiblePositions.erase(chosenPos + Vector2(1, 0))
		possiblePositions.erase(chosenPos + Vector2(-1, 0))
		possiblePositions.erase(chosenPos + Vector2(0, 1))
		possiblePositions.erase(chosenPos + Vector2(0, -1))
		possiblePositions.erase(chosenPos + Vector2(1, 1))
		possiblePositions.erase(chosenPos + Vector2(1, -1))
		possiblePositions.erase(chosenPos + Vector2(-1, -1))
		possiblePositions.erase(chosenPos + Vector2(-1, 1))
		
	return cookies_
func worldPos(cellPos: Vector2) -> Vector2:
	return Vector2(cellPos[0]*cellSize[0] + startPosition[0], cellPos[1]*cellSize[1] + startPosition[1])
