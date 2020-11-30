import PySimpleGUI as sg
from random import randint

sg.theme('DarkBlue')

STATES = []
STATE_COUNTER = 0

# RECEIVE STATES FROM CLIPS

MAX_ROWS = MAX_COL = 10

for _ in range(10):
	board = [[str(randint(-2, 8)) for j in range(MAX_COL)] for i in range(MAX_ROWS)]
	for i in range(len(board)):
		for j in range(len(board[i])):
			if(board[i][j] == '-1'):
				board[i][j] = '?'
			if(board[i][j] == '-2'):
				board[i][j] = 'B'
	STATES.append(board)

# END

layout =  [[sg.Button(' ', size=(2, 2), key=(i,j), pad=(2,2), button_color=('#1C6E8C', '#B1EDE8')) for j in range(MAX_COL)] for i in range(MAX_ROWS)]
layout.append([
	sg.Button('<', size=(2, 2), pad=(0, 10), button_color=('#202231', '#fffcf9'), disabled=True),
	sg.Button('>', size=(2, 2), pad=(0, 10), button_color=('#202231', '#fffcf9'), focus=True)
])

window = sg.Window('Minesweeper Agent', layout, background_color='#202231')

def render_cell(x, y, status):
	
	# num = B if bomb detected
	# num = ? if not opened yet
	# num = 0 if safe but no num
	# num = 1 .. 8 if safe w/ num

	if(status == 'B'):
		window[(x, y)].update(status, button_color=('#d80032', '#ffa45b'))
		return

	if(status == '?'):
		status = ''
		window[(x, y)].update(status, button_color=('#1C6E8C', '#B1EDE8'))
		return

	if(status == '0'):
		status = ''
	window[(x, y)].update(status, button_color=('#1C6E8C', '#fffcf9'))

def render_state(state):
	for y, row in enumerate(state):
		for x, cell in enumerate(row):
			render_cell(x, y, str(state[y][x]))

def next_state():
	global STATE_COUNTER, STATES
	STATE_COUNTER = min(STATE_COUNTER+1, len(STATES)-1)
	if(STATE_COUNTER == len(STATES)-1):
		window['>'].update(disabled=True)
	if(STATE_COUNTER > 0):
		window['<'].update(disabled=False)
	render_state(STATES[STATE_COUNTER])

def prev_state():
	global STATE_COUNTER, STATES
	STATE_COUNTER = max(STATE_COUNTER-1, 0)
	if(STATE_COUNTER == 0):
		window['<'].update(disabled=True)
	if(STATE_COUNTER < len(STATES)-1):
		window['>'].update(disabled=False)
	render_state(STATES[STATE_COUNTER])

while True:
	event, values = window.read()
	if event in (sg.WIN_CLOSED, 'Exit'):
		break
	if(event == '<'):
		prev_state()
	elif(event == '>'):
		next_state()

window.close()
