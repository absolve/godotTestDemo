extends KinematicBody2D

const inpnutListSize=50
var combo=[]

var inputList=[]  #按键列表记录
var timer=0 # 定时器
var timeDelay=5


func _ready():
	
	pass # Replace with function body.


func add2InputList(key:String):
	if inputList.size()>=inpnutListSize:
		inputList.pop_front()
	inputList.push_back(key)
	
func _physics_process(delta):
	
	if Input.is_action_just_pressed("down"):
		add2InputList("down")
	if Input.is_action_just_pressed("up"):
		add2InputList("up")
	if Input.is_action_just_pressed("left"):
		add2InputList("left")
	if Input.is_action_just_pressed("right"):
		add2InputList("right")
	if Input.is_action_just_pressed("punch"):
		add2InputList("punch")
	if Input.is_action_just_pressed("jump"):
		add2InputList("jump")
		
	timer+=1	
	if timer>timeDelay:
		timer=0
		inputList.pop_back()
