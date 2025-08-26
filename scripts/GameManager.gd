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
@export var winLabel: Label
@export var winButton: Button
@export var winUI: Panel
@export var loseUI: Panel
@export var sounds: SoundManager

@export var cookieScene: PackedScene
@export var fireScene: PackedScene
var cookies: Array[Obj]
var fires: Array[Obj]
var gameEnded := false

var cookiesToFree: Array[Object]
var firesToFree: Array[Object]

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
	var cookiePos = generateCookies(15)
	cookieNum = cookiePos.size() - 1
	for i in range(1, cookiePos.size()):
		createCookie(cookiePos[i])

func cursorStartedMovement(from: Vector2, to: Vector2):
	for i in range(0, cookiesToFree.size()):
		score += 1
		cookiesToFree[i].queue_free()

	cookiesToFree = []

	if firesToFree.size() >= 1:
		lose()
		return

	var eaten = false
	for cookie in cookies:
		if cookie.pos == to:
			cookies.erase(cookie)
			cookiesToFree.append(cookie)
			sounds.eat()
			eaten = true

	for fire in fires:
		if fire.pos == to:
			firesToFree.append(fire)
	
	if !eaten:
		sounds.move()

	if(randi() % 4 == 0):
		createFire(from)

	generateFires(1)

func cursorMoved(_from: Vector2, _to: Vector2):
	for i in range(0, cookiesToFree.size()):
		score += 1
		cookiesToFree[i].queue_free()

	cookiesToFree = []

	if firesToFree.size() >= 1:
		lose()
		return


func cursorLeft():
	print("Cursor left the map")
	win()

func createFire(pos: Vector2):
	var fire = fireScene.instantiate()
	fire.init(pos)
	fire.global_position = worldPos(pos)
	fires.append(fire)
	firesParent.add_child(fire)
	
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

func win() -> void:
	gameEnded = true
	if((score as float)/(cookieNum as float) <= 0.5):
		winButton.text = "More luck"
		winLabel.text = "You saved \na few biscuits: "+ str(score) + "/"+ str(cookieNum)
	elif(cookieNum - score >= 1):
		winButton.text = "Try harder"
		winLabel.text = "You saved \nsome biscuits: "+ str(score) + "/"+ str(cookieNum)
	else:
		winButton.text = "Good job!"
		winLabel.text = "You saved \nall biscuits: "+ str(score) + "/"+ str(cookieNum)
	winUI.visible = true
	sounds.win()

func lose() -> void:
	gameEnded = true
	loseUI.visible = true
	sounds.lose()

func restart() -> void:
	get_tree().reload_current_scene()

func updateScore() -> void:
	label.text = str(score) + "/" + str(cookieNum) 
func createCookie(startPos: Vector2):
	var newCookie = cookieScene.instantiate()
	newCookie.init(startPos)
	newCookie.global_position = worldPos(startPos)
	newCookie.rotation = randf_range(0, 2*PI)
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
