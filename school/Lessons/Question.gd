extends Control

const OFFSET = Vector2(10, 5)
const TEXT_OFFSET = 10
const ALTERNATIVE_SCN = preload("res://school/Lessons/Alternative.tscn")
const ALTER_HEIGHT = 50
const WINDOW_SIZE = Vector2(576, 1024)

var questions = []
var answers = []
var selected_answers = []
var correct_answers = []
var current_question = 0
var text_font
var id
var done = false


func _ready():
	var Result = $CanvasLayer/ResultPanel
	var BackButton = get_tree().get_root().get_node("School/HUD/Back")
	
	BackButton.connect("pressed", self, "confirm_exit")
	randomize()
	rect_size = WINDOW_SIZE - OFFSET
	rect_position = OFFSET/2
	$Title.rect_size.x = WINDOW_SIZE.x - OFFSET.x
	text_font = DynamicFont.new()
	text_font.font_data = load("res://school/Lessons/LessonFont.otf")
	text_font.use_filter = true
	Result.rect_position = Vector2((WINDOW_SIZE.x - Result.rect_size.x)/2, -WINDOW_SIZE.y)


func _input(event):
	if done:
		if event.is_pressed() and (event is InputEventScreenTouch or event is InputEventMouseButton):
			var School = get_tree().get_root().get_node("School")
			School._on_HUD_on_Back_pressed()


# Must be setup after being added to tree, or label height will be gotten incorrectly
func setup(name, content, id):
	self.id = id
	get_all_questions_and_answers(content)
	var title_height = add_title(name)
	for i in range(questions.size()):
		var question_height = add_question(i, title_height + 60)
		add_answers(i, question_height + 80)
	var answers_height = show_question_and_answer(0)
	set_questionnaire_size(answers_height)
	lock()


func add_title(title):
	$Title.text = title
	
	return $Title.rect_size.y


func add_text(parent, content, pos_y, centralize=false):
	var l = Label.new()
	
	l.add_color_override("font_color", Color(0, 0, 0))
	l.rect_position = Vector2(TEXT_OFFSET, pos_y)
	l.text = content
	l.set("custom_fonts/font", text_font)
	if centralize:
		l.rect_size.x = parent.rect_size.x - 2 * TEXT_OFFSET
		l.align = Label.ALIGN_CENTER
	parent.add_child(l)
	
	return l.rect_size.y


func add_image(parent, pos_y, texture_name):
	var texture = load(str("res://school/Lessons/", texture_name))
	var tr = TextureRect.new()
	var tex_size = texture.get_size()
	
	tr.texture = texture
	if tex_size.x > parent.rect_size.x - 2 * TEXT_OFFSET:
		var scale = (parent.rect_size.x - 2 * TEXT_OFFSET)/tex_size.x
		tex_size *= scale
		tr.expand = true
		tr.rect_size = tex_size
	tr.rect_position = Vector2((parent.rect_size.x - tex_size.x)/2, pos_y)
	parent.add_child(tr)
	
	return tex_size.y


func add_question(index, pos_y):
	var Cont = Control.new()
	
	Cont.set_name(str("Question", index))
	Cont.rect_position = Vector2(0, pos_y)
	add_child(Cont)
	text_font.size = 30
	Cont.rect_size.x = WINDOW_SIZE.x - OFFSET.x
	Cont.rect_size.y = parse_content(Cont, questions[index], true)
	
	return 20 + Cont.rect_size.y + Cont.rect_position.y


# Randomizes answer order and creates a Conteiner containing all the Alternatives
func add_answers(index, pos_y):
	var Cont = Control.new()
	var current_answers = answers[index]
	var correct = current_answers[0]
	var answer_pos = 0
	
	current_answers.shuffle()
	correct_answers[index] = current_answers.find(correct)
	Cont.set_name(str("Answer", index))
	Cont.rect_position = Vector2(0, pos_y)
	add_child(Cont)
	
	for i in range(current_answers.size()):
		var Alt = ALTERNATIVE_SCN.instance()
		
		Alt.rect_position = Vector2(TEXT_OFFSET, answer_pos)
		Alt.set_name(str("Alternative", i))
		Cont.add_child(Alt)
		Alt.rect_size.x = WINDOW_SIZE.x - 3 * TEXT_OFFSET
		Alt.rect_size.y = max(parse_content(Alt, current_answers[i]), 50)
		Alt.get_node("Panel").rect_size = Alt.rect_size
		Alt.connect("pressed", self, "Alternative_selected", [Alt])
		
		answer_pos += Alt.rect_size.y + 5
	Cont.rect_size.y = answer_pos


func parse_content(parent, content, centralize=false):
	var vpos = 0
	
	for c in content:
		if c.find(".png") != -1: # is an image
			vpos += add_image(parent, vpos, c) + 5
		else:
			vpos += add_text(parent, c, vpos, centralize) + 5
	
	return vpos


func position_back_next_count(pos_y):
	$Back.rect_position = Vector2(WINDOW_SIZE.x/4 - $Back.rect_size.x/2, pos_y + 50)
	$Next.rect_position = Vector2(3 * WINDOW_SIZE.x/4 - $Next.rect_size.x/2, pos_y + 50)
	$PageCount.rect_position = Vector2(WINDOW_SIZE.x/2 - $PageCount.rect_size.x/2, pos_y + 70)
	
	return $Next.rect_size.y + $Next.rect_position.y + 20


# Returns bottom of current answers
func show_question_and_answer(index):
	for i in range(questions.size()):
		get_node(str("Question",i)).hide()
		get_node(str("Answer",i)).hide()
	get_node(str("Question",index)).show()
	var CurAns = get_node(str("Answer",index))
	CurAns.show()
	$PageCount.text = str(index + 1, "/", questions.size())
	
	return CurAns.rect_size.y + CurAns.rect_position.y


func display_results():
	var wrong_answers = 0
	
	for i in range(selected_answers.size()):
		if selected_answers[i] != correct_answers[i]:
			wrong_answers += 1
	
	if wrong_answers == 0:
		var panel = $CanvasLayer/ResultPanel.get("custom_styles/panel")
		panel.border_color = Color(.1, .7, .0)
		disable_all()
		tween_result()
		
		if not Save.completed_lessons.has(id): # if not completed, complete
			complete()
	else:
		disable_all()
		$CanvasLayer/ResultPanel/Text.text = "FALHOU"
		$CanvasLayer/ResultPanel/Text.set("custom_colors/font_color", Color(.5, .08, .08))
		var panel = $CanvasLayer/ResultPanel.get("custom_styles/panel")
		panel.border_color = Color(.5, .08, .08)
		$CanvasLayer/ResultPanel/Info.show()
		if wrong_answers == 1:
			$CanvasLayer/ResultPanel/Info.text = str(wrong_answers, " resposta incorreta") # singular
		else:
			$CanvasLayer/ResultPanel/Info.text = str(wrong_answers, " respostas incorretas") # plural
		tween_result()
		
		if not Save.completed_lessons.has(id): # if not completed, lock
			var School = get_tree().get_root().get_node("School")
			lock()
			School._on_HUD_on_Back_pressed()


func disable_all():
	$Next.disabled = true
	$Back.disabled = true
	for child in get_node(str("Answer",current_question)).get_children():
		child.disabled = true


func tween_result():
	var Twn = $CanvasLayer/ResultPanel/Tween
	
	Twn.interpolate_property($CanvasLayer/ResultPanel, "rect_position:y", null,  (WINDOW_SIZE.y - $CanvasLayer/ResultPanel.rect_size.y)/2, 1, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	Twn.start()
	yield(Twn, "tween_completed")
	done = true


func confirm_exit():
	if Save.completed_lessons.has(id):
		var School = get_tree().get_root().get_node("School")
		School.add_subject_tree(School.theme_entered)
	if not done:
		$CanvasLayer/ConfirmationPanel.id = id
		$CanvasLayer/ConfirmationPanel.show()
	else:
		var School = get_tree().get_root().get_node("School")
	
		School.lock_questionnaire(id)
		School.add_subject_tree(School.theme_entered)


func complete():
	var School = get_tree().get_root().get_node("School")
	
	School.complete_lesson(id)
	School.unlock_questionnaire(id)
	School._on_HUD_on_Back_pressed()


func lock():
	var School = get_tree().get_root().get_node("School")
	
	School.lock_questionnaire(id)


func get_all_questions_and_answers(content):
	var odd = false
	
	for c in content:
		if odd:
			answers.append(c)
		else:
			questions.append(c)
			selected_answers.append(-1)
			correct_answers.append(-1)
		odd = not odd


func set_camera_limits(height):
	var LocalCamera = $SwipeHandler/SwipingCamera
	LocalCamera.limit_right = WINDOW_SIZE.x
	LocalCamera.limit_bottom = height + 10


func set_height(height):
	var h = max(WINDOW_SIZE.y, height)
	rect_size.y = h


func set_questionnaire_size(answers_height):
	var total_height = position_back_next_count(answers_height + 60)

	set_camera_limits(total_height)
	set_height(total_height + 25)


func _on_Next_pressed():
	if current_question == questions.size() - 1:
		display_results()
	else:
		$Back.set_modulate(Color(1, 1, 1))
		current_question += 1
		var answers_height = show_question_and_answer(current_question)
		set_questionnaire_size(answers_height)
		
		if current_question == questions.size() - 1:
			$Next.text = "ACABAR"
			$Next.set_modulate(Color(.3, 1, .3))
			for answer in selected_answers:
				if answer == -1: # Questions were still not answered
					$Next.disabled = true


func _on_Back_pressed():
	$Next.text = "PRÓXIMO"
	$Next.disabled = false
	$Next.set_modulate(Color(1, 1, 1))
	current_question = max(current_question - 1, 0)
	var answers_height = show_question_and_answer(current_question)
	set_questionnaire_size(answers_height)
	
	if current_question == 0:
		$Back.set_modulate(Color(.6, .6, .6))


func Alternative_selected(Alternative):
	var Answers = Alternative.get_parent()
	var alt_num = int(Alternative.get_name()[-1])
	
	for Alt in Answers.get_children():
		Alt.get_node("Panel").set_modulate(Color(1, 1, 1))
	Alternative.get_node("Panel").set_modulate(Color(.95, .95, .6))
	selected_answers[current_question] = alt_num
	
	var done = true # Unlocks 'Next' button if all answers were selected
	for answer in selected_answers:
		if answer == -1:
			done = false
	if done:
		$Next.disabled = false


func _on_Leave_pressed():
	var School = get_tree().get_root().get_node("School")
	
	School.add_subject_tree(School.theme_entered)
