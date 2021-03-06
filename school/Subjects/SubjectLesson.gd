extends Control

const LESSON_DB = preload("res://school/Lessons/LessonDB.gd")
const BLUE = Color(.2, .2, 1)
const GREEN = Color(0, 1, 0)
const RED = Color(1.5, 0, 0)

var title : String
var id : int
var type
var completed = false
var locked_time
var lock_duration


func setup(name, size):
	var db = LESSON_DB.new()
	
	self.id = db.get_lesson_id(name)
	self.title = name
	self.rect_min_size = size
	self.text = name
	$Background.rect_size = size
	$Lock.rect_size = Vector2(size.y - 10, size.y - 10)
	$Lock.rect_position = Vector2(size.x - $Lock.rect_size.x - 5, 5)
	$Check.rect_size = Vector2(size.y - 10, size.y - 10)
	$Check.rect_position = Vector2(size.x - $Lock.rect_size.x - 5, 5)
	$Book.rect_size = Vector2(size.y - 10, size.y - 10)
	$Book.rect_position = Vector2(size.x - $Lock.rect_size.x - 5, 5)
	
	type = db.get_lesson_type(self.id)
	if type == "question":
		$Background.set_modulate(BLUE)
	
	if Save.completed_lessons.has(id): # lesson previously completed
		set_completed()
	elif Save.failed_questions.has(id): # questionnaire locked
		var index = Save.failed_questions.find(id)
		
		self.lock_duration = db.get_questionnaire_locktime(id)
		self.locked_time = Save.failed_questions_time[index]
		if can_be_unlocked(locked_time, lock_duration):
			unlock()
		else:
			$Lock.show()
			self.disabled = true
			
			var remaining_time = get_remaining_locktime(locked_time, lock_duration)
			var remain_string = ""
			for r in remaining_time:
				remain_string += str(":", r)
			remain_string.erase(0, 1) # removes first ":"
			self.text = str("Time remaning: ", remain_string)
			$Background.set_modulate(RED)
			$Timer.start()


func can_be_unlocked(locked_time, lock_duration):
	var current_time = OS.get_datetime()
	var remaining_time = get_remaining_locktime(locked_time, lock_duration)
	
	if locked_time.year - current_time.year < 0:
		return true
	elif locked_time.month - current_time.month < 0:
		return true
	
	if remaining_time[0] > 0 or remaining_time[1] > 0 or remaining_time[2] > 0 or remaining_time[3] > 0:
		return false
	return true


func complete():
	var School = get_tree().get_root().get_node("School")
	
	School.complete_lesson(id)
	set_completed()


func unlock():
	var School = get_tree().get_root().get_node("School")
	
	School.unlock_questionnaire(id)
	$Lock.hide()
	self.disabled = false
	self.text = self.title
	$Background.set_modulate(BLUE)


func set_completed():
	$Background.set_modulate(GREEN)
	if type == 'question':
		$Book.show()
	else:
		$Check.show()
	completed = true


func get_remaining_locktime(locked_time, lock_duration):
	var current_time = OS.get_datetime()
	var lock
	var cur
	var r
	var remain = [0, 0, 0, 0] # [days, hours, minutes, seconds]
	
	lock = (lock_duration[0] + locked_time.day) * 86400 + (lock_duration[1] + locked_time.hour) * 3600 + \
	       (lock_duration[2] + locked_time.minute) * 60 + locked_time.second
	cur = current_time.day * 86400 + current_time.hour * 3600 + current_time.minute * 60 + current_time.second
	r = lock - cur
	remain[0] = int(r / 86400)
	remain[1] = int(r / 3600) % 24
	remain[2] = int(r / 60 ) % 60
	remain[3] = int(r) % 60
	
	return remain


func _on_SubjectLesson_pressed():
	var db = LESSON_DB.new()
	var School = get_tree().get_root().get_node("School")
	
	if type == "info":
		School.add_lesson(title, db.get_lesson_content(id))
		if not completed:
			complete()
	elif type == "question":
		var SubjTree = get_parent().get_parent().get_parent().get_parent()
		if completed:
			School.add_question(title, db.get_lesson_content(id), id)
		else:
			SubjTree.get_node("CanvasLayer/ConfirmationPanel").add_questionnaire_info(title, id, db.get_lesson_content(id))


func _on_Timer_timeout():
	if can_be_unlocked(locked_time, lock_duration):
		$Timer.stop()
		unlock()
		return
	
	var remaining_time = get_remaining_locktime(locked_time, lock_duration)
	var remain_string = ""
	
	for r in remaining_time:
		remain_string += str(":", r)
	remain_string.erase(0, 1) # removes first ":"
	self.text = str("Time remaning: ", remain_string)
	$Background.set_modulate(RED)
