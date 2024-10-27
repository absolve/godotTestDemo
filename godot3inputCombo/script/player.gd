extends KinematicBody2D


onready var ani=$ani
onready var player=$player
onready var aniTree=$AnimationTree
onready var animation_state=aniTree.get("parameters/playback")

const inpnutListSize=50
var combo=[]

var inputList=[]  #按键列表记录
var timer=0 # 定时器
var timeDelay=5
var velocity=Vector2.ZERO #速度
var state=Game.state.idle



func _ready():
	aniTree.active=true


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


	if state==Game.state.idle ||state==Game.state.move:
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		input_vector = input_vector.normalized()
		if input_vector != Vector2.ZERO:
			state=Game.state.move
			velocity=velocity.move_toward(input_vector*200,delta*1000)
			animation_state.travel("move")
		else:
			velocity=input_vector
			animation_state.travel("idle")
		if Input.is_action_just_pressed("punch"):
			state=Game.state.attack
				
		if velocity.x>0:
			ani.flip_h=false
		elif velocity.x<0:
			ani.flip_h=true	
			
		velocity = move_and_slide(velocity)
	elif state==Game.state.attack:
		
		animation_state.start("punch1")
		print(animation_state.get_current_node())
		if animation_state.get_current_node():
			pass
			
		if !animation_state.is_playing():
			state=Game.state.idle
		
#		state=Game.state.idle
		
		
