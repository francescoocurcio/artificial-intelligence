(define (problem classical_planning_problem)
  (:domain industrial_manufacturing_service)

  (:objects
    robot - robot
    warehouse location1 location2 - location
    workstation1 workstation2 workstation3 - workstation
    box1 box2 box3 - box
    bolt screw - content
  )

  (:init
    
    ;il robot si trova nella warehouse
    (at_loc robot warehouse)
    
    ;si identifica una location come warehouse
    (is_warehouse warehouse)

    ;le box sono collocate nella warehouse
    (at_loc box1 warehouse)
    (at_loc box2 warehouse)
    (at_loc box3 warehouse)

    ;i materiali (content) da mettere nelle box sono nella warehouse
    (at_loc bolt warehouse)
    (at_loc screw warehouse)
    
    ;le scatole sono vuote
    (is_empty box1)
    (is_empty box2)
    (is_empty box3)
    
    ;si posizionano le workstation associandole alle location in cui si trovano
    (at_loc workstation1 location1)
    (at_loc workstation2 location2)
    (at_loc workstation3 location2)
    
    ;si stabiliscono le connessioni tra location
    ;si tenga presente che il predicato connected non è simmetrico per cui è necessario specificare le connessioni reciproche
    (connected warehouse location1)
    (connected location1 warehouse)
    (connected location1 location2)
    (connected location2 location1)
    
    ;il robot è libero
    (free robot)
  )

  (:goal

    (and

      ;almeno una workstation necessita un materiale (bullone)
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