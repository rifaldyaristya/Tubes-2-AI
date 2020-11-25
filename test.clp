(defrule perkenalan
    (person ?nama ?usia)
    (not (kakek ?nama ?usia))
    =>
    (printout t "Nama " ?nama " umur " ?usia  crlf)

)



