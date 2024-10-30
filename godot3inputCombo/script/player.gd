extends KinematicBody2D


onready var ani=$ani
onready var player=$player
onready var aniTree=$AnimationTree
onready var animation_state=aniTree.get("parameters/playback")

const inpnutListSize=50  #输入缓冲的大小
var combo=[]  #连招列表

var inputList=[]  #按键列表记录
var timer=0 # 定时器
var timeDelay=30
export var velocity=Vector2.ZERO #速度
var state=Game.state.idle
var dir=Game.direction.right


func _ready():
	aniTree.active=true
	combo.append_array(Game.combos)
	print(combo)


func add2InputList(key:String):
	if inputList.size()>=inpnutListSize:
		inputList.pop_front()
	inputList.push_back(key)

func sortCombo(a,b):
	if a.priority>b.priority:
		return true
	else:
		return false	

#检查连招
func checkCombo():
	var temp = "".join(inputList)
#	print(temp)
	var existCombo=[]
	for i in combo:
		var combosList=i['combos']
		for y in combosList:
			var str1="".join(y)
			if temp.find_last(str1)!=-1:
				existCombo.append(i)
				break
	#如果有连招被触发就执行连招,根据优先级进行排序
	if existCombo.size()>0:
		print(existCombo)
		existCombo.sort_custom(self,"sortCombo")
		print('=====',existCombo)
		var skill=existCombo[0].name
		state=Game.state.skill
		animation_state.travel(skill)
		print(skill)
	
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
			animation_state.travel("punch1")
#		if Input.is_action_just_pressed("jump"):
#			state=Game.state.skill
#			animation_state.travel("skill2")
				
		if velocity.x>0:
			ani.flip_h=false
			dir=Game.direction.right
		elif velocity.x<0:
			ani.flip_h=true	
			dir=Game.direction.left
			
		velocity = move_and_slide(velocity)
	elif state==Game.state.attack:		
		if !player.is_playing():
			if inputList.size()>0&&inputList[inputList.size()-1]=="punch":
				if animation_state.get_current_node()=="punch1":
					animation_state.travel("punch2")
				elif animation_state.get_current_node()=="punch2":
					animation_state.travel("punch3")
				else:
					state=Game.state.idle	
			else:
				state=Game.state.idle
	elif state==Game.state.skill:
#		print(animation_state.get_current_node())
#		print(animation_state.is_playing())
#		print(player.is_playing())
		if !animation_state.get_current_node().begins_with("skill"):
			state=Game.state.idle
		if dir==Game.direction.left:
			velocity=-velocity
		velocity = move_and_slide(velocity)
	#检查连招		
	checkCombo()
		
