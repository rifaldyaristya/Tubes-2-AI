from clips import *

environment = Environment()
environment.load('minesweeper.clp')

environment.reset()
environment.run()

facts = []
for fact in environment.facts():
	facts.append(str(fact))

print(facts)