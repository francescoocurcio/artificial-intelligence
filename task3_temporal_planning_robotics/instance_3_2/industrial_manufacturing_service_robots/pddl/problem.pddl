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
    (attached robot carrier)
    
    ;si identifica la warehouse
    (is_warehouse warehouse)

    ;le box sono collocati nella warehouse
    (at_loc box1 warehouse)
    (at_loc box2 warehouse)
    (at_loc box3 warehouse)

    ;i materiali da mettere nei box sono nella warehouse
    (at_loc bolt warehouse)
    (at_loc screw warehouse)
    
    ;le box sono vuote
    (is_empty box1)
    (is_empty box2)
    (is_empty box3)
    
    ;si allocano le workstation nelle location
    (at_loc workstation1 location1)
    (at_loc workstation2 location2)
    (at_loc workstation3 location2)
    
    ;si stabiliscono i collegamenti tra location
    (connected warehouse location1)
    (connected location1 location2)
    (connected location1 warehouse)
    (connected location2 location1)
    
    ;si inizializzano le funzioni necessarier
    (= (capacity carrier) 2)  ;cacità del carrier pari a 2
    (= (load carrier) 0)      ;carico iniziale del carrier nullo
  )

  (:goal

    (and
      ;almeno una workstation necessita di un materiale (bullone)
      (at_ws bolt workstation2)

      ;almeno una workstation non necessita di alcun materiale
      (not (at_ws bolt workstation1))
      (not (at_ws screw workstation1))

      ;almeno una workstation necessita di più materiali (bulloni e viti)
      (at_ws bolt workstation3)
      (at_ws screw workstation3)

    )
  )
)