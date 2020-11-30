import PySimpleGUI as sg
from random import randint

class GUI():
	def __init__(self, size, states):
		self.states = states
		self.size = size
		self.counter = 0

		sg.theme('DarkBlue')

		layout =  [[sg.Button(' ', size=(2, 2), key=(i,j), pad=(2,2), button_color=('#1C6E8C', '#B1EDE8')) for j in range(self.size)] for i in range(self.size)]
		layout.append([
			sg.Button('<', size=(2, 2), pad=(0, 10), button_color=('#202231', '#fffcf9'), disabled=True),
			sg.Button('>', size=(2, 2), pad=(0, 10), button_color=('#202231', '#fffcf9'), focus=True)
		])

		self.window = sg.Window('Minesweeper Agent', layout, background_color='#202231')

	def render_cell(self, x, y, status):
		
		# num = B if bomb detected
		# num = ? if not opened yet
		# num = 0 if safe but no num
		# num = 1 .. 8 if safe w/ num

		if(status == 'B'):
			self.window[(x, y)].update(status, button_color=('#d80032', '#ffa45b'))
			return

		if(status == '?'):
			status = ''
			self.window[(x, y)].update(status, button_color=('#1C6E8C', '#B1EDE8'))
			return

		if(status == '0'):
			status = ''
		self.window[(x, y)].update(status, button_color=('#1C6E8C', '#fffcf9'))

	def render_state(self, state):
		for y, row in enumerate(state):
			for x, cell in enumerate(row):
				self.render_cell(x, y, str(state[y][x]))

	def next_state(self):
		self.counter = min(self.counter+1, len(self.states)-1)
		if(self.counter == len(self.states)-1):
			self.window['>'].update(disabled=True)
		if(self.counter > 0):
			self.window['<'].update(disabled=False)
		self.render_state(self.states[self.counter])

	def prev_state(self):
		self.counter = max(self.counter-1, 0)
		if(self.counter == 0):
			self.window['<'].update(disabled=True)
		if(self.counter < len(self.states)-1):
			self.window['>'].update(disabled=False)
		self.render_state(self.states[self.counter])

	def run(self):
		while True:
			event, values = self.window.read()
			if event in (sg.WIN_CLOSED, 'Exit'):
				break
			if(event == '<'):
				self.prev_state()
			elif(event == '>'):
				self.next_state()

		self.window.close()