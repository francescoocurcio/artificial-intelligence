(define (problem temporal_planning_problem)
  
  (:domain industrial_manufacturing_service_durative_actions)

  (:objects
    robot - robot
    carrier - carrier
    warehouse location1 location2 - location
    workstation1 workstation2 workstation3 - workstation
    box1 box2 box3 - box
    bolt screw - content
  )

  (:init
    ;il robot si trova nella warehouse
    (at_loc robot warehouse)
    
    ;si collega il carrier al robot
    (joined robot carrier)
    
    ;si identifica la warehouse
    (is_warehouse warehouse)

    ;le box sono collocati nella warehouse
    (at_loc box1 warehouse)
    (at_loc box2 warehouse)
    (at_loc box3 warehouse)

    ;i materiali da mettere nei box sono nella warehouse
    (at_loc bolt warehouse)
    (at_loc screw warehouse)
    
    ;le scatole sono vuote
    (is_empty box1)
    (is_empty box2)
    (is_empty box3)
    
    ;si posizionano le workstation
    (at_loc workstation1 location1)
    (at_loc workstation2 location2)
    (at_loc workstation3 location2)
    
    ;connessioni
    (connected warehouse location1)
    (connected location1 location2)
    (connected location1 warehouse)
    (connected location2 location1)
    
    ;inizializzazione delle funzioni
    (= (capacity carrier) 2)  ;capacità iniziale del carrier
    (= (load carrier) 0)      ;carico iniziale del carrier
  )

  (:goal
    (and

      ;almeno una workstation che necessita di un materiale 
      (at_ws bolt workstation2)

      ;almeno una workstation che non necessita di nulla
      (not (at_ws bolt workstation1))
      (not (at_ws screw workstation1))

      ;almeno una workstation che necessita di più materiali 
      (at_ws bolt workstation3)
      (at_ws screw workstation3)

    )
  )
)