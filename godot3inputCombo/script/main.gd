extends Node2D


onready var _inputList=$inputList
var inputList=PoolStringArray([])
var inputStr=''

func _ready():
	OS.center_window()


func addInputList(name):
	if inputList.size()>=10:
		inputList.remove(0)
	inputList.append(name)	

func _physics_process(delta):
	inputStr=''
	for i in inputList:
		inputStr+=i+" "
	_inputList.setInputName(inputStr)
	
	
	
func _unhandled_input(event):
	if event.is_action_pressed("down") :
		addInputList("down")
	if event.is_action_pressed("up"):
		addInputList("up")
	if event.is_action_pressed("left"):
		addInputList("left")
	if event.is_action_pressed("right"):
		addInputList("right")
	if event.is_action_pressed("punch"):
		addInputList("punch")
	if event.is_action_pressed("jump"):
		addInputList("jump")
	
