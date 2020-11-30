from clips import *
from gui import GUI
from copy import deepcopy

environment = Environment()
environment.load('minesweeper.clp')

environment.reset()
environment.run()

facts = []
size = 0
for fact in environment.facts():
	str_fact = str(fact)
	print(str_fact)
	facts.append(str_fact)
	if 'arena-size' in str_fact:
		str_size = str_fact[str_fact.find('(')+len('arena-size ')+1:str_fact.find(')')]
		size = int(str_size)


states = []
arr = [['?' for i in range(size)] for j in range(size)]

states.append(deepcopy(arr))

ctr = 0

while ctr < len(facts):
	current = facts[ctr]
	if 'arena-size' in facts[ctr]:
		str_size = current[current.find('(')+len('arena-size ')+1:current.find(')')]
		size = int(str_size)

	if 'safe-pos' in facts[ctr]:
		while ctr < len(facts) and 'num-discovered-pos-agent' not in facts[ctr]:
			if 'safe-pos' in facts[ctr]:
				str_safepos = facts[ctr][facts[ctr].find('(')+len('safe-pos ')+1:facts[ctr].find(')')]
				str_x, str_y = str_safepos.split(' ')
				arr[int(str_y)][int(str_x)] = '0'
			ctr += 1
		# print('====', facts[ctr])
		ctr -= 1

	if 'num-discovered-pos-agent' in facts[ctr]:
		# print('=>>', facts[ctr])
		while ctr < len(facts) and 'discovered-bomb-pos' not in facts[ctr] and 'safe-pos' not in facts[ctr]:
			if 'num-discovered-pos-agent' in facts[ctr]:
				str_discovered = facts[ctr][facts[ctr].find('(')+len('num-discovered-pos-agent ')+1:facts[ctr].find(')')]
				str_x, str_y, str_num = str_discovered.split(' ')
				arr[int(str_y)][int(str_x)] = str_num
			ctr += 1
		ctr -= 1

		states.append(deepcopy(arr))

	if 'discovered-bomb-pos' in facts[ctr]:
		str_discovered = facts[ctr][facts[ctr].find('(')+len('discovered-bomb-pos ')+1:facts[ctr].find(')')]
		str_x, str_y = str_discovered.split(' ')
		arr[int(str_y)][int(str_x)] = 'B'
		states.append(deepcopy(arr))

	ctr += 1

states.append(arr.copy())

# for el in states:
# 	print(el)

# states.append(arr)

# print(states)



g = GUI(size, states)
g.run()

# print(facts)

# 10
# 10
# 0 5
# 2 4
# 2 9
# 3 7
# 4 6
# 4 7
# 4 9
# 5 3
# 5 9
# 9 8
