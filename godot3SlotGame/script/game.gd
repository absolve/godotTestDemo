extends Node


enum cardType{
	s=0,
	n=1,
	o=2,
	w=3,
	man=4,
	x=5,
}

enum state{
	idle,
	scroll,
	stop,
	finish,
}

enum gameState{
	idle,
	wait,
	start,
	finish,
}

signal getResult
