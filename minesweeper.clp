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
; safe-pos x y
; discovered-bomb-pos x y
; sure-pos ?x ?y
; discovered-bomb-pos ?x1 ?y1
; num-discovered-pos ?x1 ?y1 ?num


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
	(declare (salience 19))
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

; mark cells around bomb
(defrule place-num-around-bomb-0
	(declare (salience 18))
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
	(declare (salience 17))
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
	(declare(salience 16))
	?placed-by-fact <- (placed-by ?x ?y ?x1 ?y1)
	=>
	(retract ?placed-by-fact)
	(assert (bomb-set))
)


; ============== OPEN SAFE CELL ================

; expand safe cell until it meets numbered cells
(defrule open-safe-cell
	(declare(salience 15))
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
	(assert (recently-discovered (+ ?x ?dirx) (+ ?y ?diry)))
	(assert (safe-pos (+ ?x ?dirx) (+ ?y ?diry)))

)

; mark safe numbered cell as discoverd
(defrule open-number
	(declare(salience 14))
	(safe-pos ?x ?y)
	(num-pos ?x ?y ?num)
	=>
	(assert(num-discovered-pos ?x ?y ?num))
)

; substract num according to the number of bombs around -> BELUM TESTED
(defrule num-request-update
	(declare(salience 13))
	(arena-size ?size)
	(recently-discovered ?x ?y)
	?old-num <- (num-discovered-pos ?x ?y ?num)
	(not (stop-updating-0 ?x ?y))
	(direction ?dirx ?diry)
	(not (placed-by-0 ?x ?y ?dirx ?diry))
	(discovered-bomb-pos ?x1 ?y1)
	(test (= (+ ?x ?dirx) ?x1))
	(test (= (+ ?y ?diry) ?y1))
	=>
	(retract ?old-num)
	(assert (placed-by-0 ?x ?y ?dirx ?diry))
	(assert (num-discovered-pos ?x ?y (- ?num 1)))

)

;cleanup
(defrule num-request-update-1
	(declare(salience 12))
	?placed-by-fact <- (placed-by-0 ?x ?y ?dirx ?diry)
	=>
	(retract ?placed-by-fact)
	(assert (stop-updating-0 ?x ?y))
)

;cleanup
(defrule num-request-update-2
	(declare(salience 12))
	?recently-discovered-fact <- (recently-discovered ?x ?y)
	=>
	(retract ?recently-discovered-fact)
)

; ============== AGENT MOVE ================

; create the template to count unknown cells
(defrule count-unknown-around-num-0
	(declare(salience 11))
	(num-discovered-pos ?x ?y ?num)
	=>
	(assert(known-cells-count ?x ?y 0))
)

; increase according to num of safe cells around
(defrule count-unknown-around-num-1
	(declare(salience 10))
	(arena-size ?size)
	(bomb-set)
	(direction ?dirx ?diry)
	?old-count <- (known-cells-count ?x ?y ?num)
	(safe-pos ?x1 ?y1)
	(and (test (= (+ ?y ?diry) ?y1)) (test (= (+ ?x ?dirx) ?x1))) 
	(not (placed-by-2 ?x ?y ?x1 ?y1))
	(test (< (+ ?y ?diry) ?size))
	(test (>= (+ ?y ?diry) 0))
	(test (< (+ ?x ?dirx) ?size))
	(test (>= (+ ?x ?dirx) 0))
	=>
	(retract ?old-count)
	(assert (known-cells-count ?x ?y (+ ?num 1)))
	(assert (placed-by-2 ?x ?y ?x1 ?y1))
)

(deffunction to-int (?bool)
   (if ?bool then 1 else 0))

; convert known to unknown
(defrule count-unknown-around-num-2
	(declare(salience 9))
	(arena-size ?size)
	?known-count <- (known-cells-count ?x ?y ?num)
	=>
	(retract ?known-count)
	(bind ?y-wall
		(or 
			(= (+ ?y 1) ?size)
			(< (- ?y 1) 0)
	))
	(bind ?x-wall
		(or 
			(= (+ ?x 1) ?size)
			(< (- ?x 1) 0)
	))
	(bind ?num-wall
		(-
			(+
				(* (to-int ?y-wall) 3)
				(* (to-int ?x-wall) 3)
			)
			(to-int (and ?y-wall ?x-wall))
		)
	)
	(assert (unknown-cells-count ?x ?y (- (- 8 ?num-wall) ?num)))
)

; cleanup
(defrule count-unknown-around-num-3
	(declare(salience 8))
	?placed-by-fact-2 <- (placed-by-2 ?x ?y ?x1 ?y1)
	=>
	(retract ?placed-by-fact-2)
)


; mark cells that is sure where to put their bombs
(defrule discover-bombs
	(declare(salience 7))
	(unknown-cells-count ?x ?y ?num)
	(num-discovered-pos ?x ?y ?num)
	(test (> ?num 0))
	=>
	(assert (sure-pos ?x ?y))
)

; create every possible location for the sure cells to put their bombs
(defrule discover-bombs-1
	(declare(salience 6))
	(arena-size ?size)
	(sure-pos ?x ?y)
	(direction ?dirx ?diry)
	(test (< (+ ?y ?diry) ?size))
	(test (>= (+ ?y ?diry) 0))
	(test (< (+ ?x ?dirx) ?size))
	(test (>= (+ ?x ?dirx) 0))
	=>
	(assert (sure-bomb-possible-pos ?x ?y (+ ?x ?dirx) (+ ?y ?diry)))
)

; remove wrong possibility
(defrule discover-bombs-2
	(declare(salience 5))
	?wrong-pos <- (sure-bomb-possible-pos ?x ?y ?x1 ?y1)
	(safe-pos ?x1 ?y1)
	=>
	(retract ?wrong-pos)
)

;discover the bomb based on its right possible position
(defrule discover-bombs-3
	(declare(salience 4))
	(sure-bomb-possible-pos ?x ?y ?x1 ?y1)
	=>
	(assert (discovered-bomb-pos ?x1 ?y1))
)

;generate safe cell near discovered bomb pos equals num unknown
(defrule generateSafeCell
	(declare(salience 3))
	(direction ?dirx ?diry)
	(arena-size ?size)
	(num-discovered-pos ?x ?y 0)
	(test (< (+ ?y ?diry) ?size))
	(test (>= (+ ?y ?diry) 0))
	(test (< (+ ?x ?dirx) ?size))
	(test (>= (+ ?x ?dirx) 0))
	(not (and (safe-pos ?x1 ?y1) (discovered-bomb-pos ?x1 ?y1)
          (and(test (= (+ ?x ?diry) ?x1))(test (= (+ ?y ?diry) ?y1)))))
 	=>
	(assert (safe-pos (+ ?x ?dirx) (+ ?y ?diry)))
)


;substract the num value among number around the bombs
(defrule update-number-value
	(declare (salience 2))
	(discovered-bomb-pos ?x ?y)
	(not (stop-updating ?x ?y))
	?old-discovered-num <- (num-discovered-pos ?x1 ?y1 ?num)
	(direction ?dirx ?diry)
	(and (test (= ?x1 (+ ?x ?dirx))) (test (= ?y1 (+ ?y ?diry))))
	(not (placed-by-fact-3 ?x ?y ?x1 ?y1))
	=>
	(assert (placed-by-fact-3 ?x ?y ?x1 ?y1))
	(retract ?old-discovered-num)
	(assert (num-discovered-pos ?x1 ?y1 (- ?num 1)))
)

;cleanup
(defrule update-number-value-2
	(declare (salience 1))
	?placed-by-fact-3 <- (placed-by-fact-3 ?x ?y ?x1 ?y1)
	=>
	(retract ?placed-by-fact-3)
	(assert (stop-updating ?x ?y))
)

