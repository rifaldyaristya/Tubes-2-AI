(defrule test
    (or (r1 ?x ?y) (r2 ?x ?y))
    =>
    (printout t "Hello" ?x ?y crlf)
)

(deffacts init
    (r2 1 2)
)
