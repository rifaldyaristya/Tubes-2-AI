(deffacts directions
	(direction 0 -1)
	(direction 1 -1)
	(direction 1 0)
	(direction 1 1)
	(direction 0 1)
	(direction -1 1)
	(direction -1 0)
	(direction -1 -1)
	(safe-pos 0 0)
)

; definitions:
; arena-size size
; bomb-pos x y
; num-pos x y num-of-bombs-around


; ============= INITIALIZE ===============

; start
(defrule start
	?init <- (initial-fact)
	=>
	(retract ?init)
	(printout t "START" crlf)
	(assert (input-size-trigger))
)

; input size
(defrule input-size
	?trigger <- (input-size-trigger)
	=>
	(retract ?trigger)
	(printout t "Input size (4-10): ")
	(assert (arena-size =(read)))
	(assert (input-bomb-num-trigger))
)

; input num of bombs
(defrule input-bomb-num
	?trigger <- (input-bomb-num-trigger)
	=>
	(retract ?trigger)
	(printout t "Input num of bombs: ")
	(assert (num-bombs =(read)))
	(assert (input-bomb-pos-start-trigger))
)

; start input bomb coordinates
(defrule input-bomb-pos-start
	?trigger <- (input-bomb-pos-start-trigger)
	(num-bombs ?num)
	=>
	(retract ?trigger)
	(printout t "Input position of " ?num " bombs" crlf)
	(assert (input-num-bombs 0))
)

; input bomb coordinate
(defrule input-bomb-pos
	(declare (salience 9))
	?num-bombs-input <- (input-num-bombs ?num)
	(num-bombs ?num-total)
	(test (< ?num ?num-total))
	=>
	(retract ?num-bombs-input)
	(printout t "Bomb " (+ ?num 1) ": " crlf)
	(bind ?string (readline))
	(assert-string (str-cat "(bomb-pos " ?string ")"))
	(assert (input-num-bombs (+ ?num 1)))
)

; end input position
(defrule input-pos-end
	(num-bombs ?num-total)
	?num-bombs-input <- (input-num-bombs ?num-total)
	=>
	(retract ?num-bombs-input)
)

; ============== SETUP NUM AROUND BOMB ================

; replace existing num w/ bomb
(defrule replace-num-with-bomb
	(declare (salience 10))
	(bomb-pos ?x ?y)
	?num-fact <- (num-pos ?x ?y)
	=>
	(retract ?num-fact)
)

; mark cells around bomb
(defrule place-num-around-bomb-0
	(declare (salience 8))
	(arena-size ?size)
	(bomb-pos ?x ?y)
	(direction ?dirx ?diry)
	; the cell hasn't marked yet
	(not (and
		(num-pos ?x1 ?y1 ?num)
		(and (test (= (+ ?y ?diry) ?y1)) (test (= (+ ?x ?dirx) ?x1))) 
		)
	)
	; the cell doesn't contain bomb
	(not (and
		(bomb-pos ?x1 ?y1)
		(and (test (= (+ ?y ?diry) ?y1)) (test (= (+ ?x ?dirx) ?x1))) 
		)
	)
	(not (bomb-set))
	(test (< (+ ?y ?diry) ?size))
	(test (>= (+ ?y ?diry) 0))
	(test (< (+ ?x ?dirx) ?size))
	(test (>= (+ ?x ?dirx) 0))
	=>
	(assert (num-pos (+ ?x ?dirx) (+ ?y ?diry) 0))
)

; increase according to num of bombs
(defrule place-num-around-bomb-1
	(declare (salience 7))
	(arena-size ?size)
	(bomb-pos ?x ?y)
	(direction ?dirx ?diry)
	?num-fact <- (num-pos ?x1 ?y1 ?num)
	(and (test (= (+ ?y ?diry) ?y1)) (test (= (+ ?x ?dirx) ?x1))) 
	(not (and
		(bomb-pos ?x1 ?y1)
		(and (test (= (+ ?y ?diry) ?y1)) (test (= (+ ?x ?dirx) ?x1))) 
		)
	)
	(not (placed-by ?x ?y ?x1 ?y1))
	(not (bomb-set))
	(test (< (+ ?y ?diry) ?size))
	(test (>= (+ ?y ?diry) 0))
	(test (< (+ ?x ?dirx) ?size))
	(test (>= (+ ?x ?dirx) 0))
	=>
	(retract ?num-fact)
	(assert (num-pos (+ ?x ?dirx) (+ ?y ?diry) (+ ?num 1)))
	(assert (placed-by ?x ?y ?x1 ?y1))
)


; cleanup facts
(defrule place-num-around-bomb-2
	(declare(salience 2))
	?placed-by-fact <- (placed-by ?x ?y ?x1 ?y1)
	=>
	(retract ?placed-by-fact)
	(assert (bomb-set))
)

; 

; ============== OPEN SAFE CELL ================

; expand safe cell until it meets numbered cells
(defrule open-safe-cell
	(declare(salience 1))
	(bomb-set)
	(safe-pos ?x ?y)
	(arena-size ?size)
	(direction ?dirx ?diry)
	(not (num-pos ?x ?y ?))
	(test (< (+ ?y ?diry) ?size))
	(test (>= (+ ?y ?diry) 0))
	(test (< (+ ?x ?dirx) ?size))
	(test (>= (+ ?x ?dirx) 0))
	=>
	(assert (safe-pos (+ ?x ?dirx) (+ ?y ?diry)))

)

; mark safe numbered cell as discoverd
(defrule open-number
	(safe-pos ?x ?y)
	(num-pos ?x ?y ?num)
	=>
	(assert(num-discovered-pos ?x ?y ?num))
)

; ============== AGENT MOVE ================

; create the template to count unknown cells
(defrule check-discovered-number
	(num-discovered-pos ?x ?y ?num)
	=>
	(assert(unknown-cells-count ?x ?y 0))
)

; count unknown cells for a each number cell
; rusak gara" variabel di not gak bsa direfer
;(defrule increase-cells-count
;	(arena-size ?size)
;	(bomb-set)
;	?old-count <- (unknown-cells-count ?x ?y ?num)
;	(direction ?dirx ?diry)
;	(and (not(safe-pos ?x1 ?y1)) (not(discovered-bomb-pos ?x1 ?y1)))
;	(test (and (= ?x1 (+ ?dirx ?x)) (= ?y1 (+ ?diry ?y))) )
;	(not (placed-by ?x1 ?y1 ?x ?y))
;	(test (< (+ ?y ?diry) ?size))
;	(test (>= (+ ?y ?diry) 0))
;	(test (< (+ ?x ?dirx) ?size))
;	(test (>= (+ ?x ?dirx) 0))
;	=>
;	(retract ?old-count)
;	(assert (placed-by ?x1 ?y1 ?x ?y))
;	(assert (unknown-cells-count ?x ?y (+ ?num 1)))
;)

; count unknown cells for a each number cell
; rusak gara" not gak disupport
;(defrule increase-cells-count
;	(arena-size ?size)
;	(bomb-set)
;	?old-count <- (unknown-cells-count ?x ?y ?num)
;	(direction ?dirx ?diry)
;	(and (not(safe-pos (+ ?x ?dirx) (+ ?y ?diry))) (not(discovered-bomb-pos (+ ?x ?dirx) (+ ?y ?diry))))
;	(not (placed-by ?x1 ?y1 ?x ?y))
;	(test (< (+ ?y ?diry) ?size))
;	(test (>= (+ ?y ?diry) 0))
;	(test (< (+ ?x ?dirx) ?size))
;	(test (>= (+ ?x ?dirx) 0))
;	=>
;	(retract ?old-count)
;	(assert (placed-by ?x1 ?y1 ?x ?y))
;	(assert (unknown-cells-count ?x ?y (+ ?num 1)))
;)



