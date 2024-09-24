(define (problem classical_planning_problem)
  (:domain industrial_manufacturing_service)

  (:objects
    robot1 robot2 - robot
    carrier1 carrier2 - carrier
    warehouse location1 location2 - location
    workstation1 workstation2 workstation3 - workstation
    box1 box2 box3 - box
    bolt screw - content
    slot1 slot2 slot3 slot4 slot5 - slot
  )

  (:init
    ;i robot si trovano nella warehouse
    (at_loc robot1 warehouse)
    (at_loc robot2 warehouse)
    
    ;ogni robot viene collegato ad un carrier
    (attached robot1 carrier1)
    (attached robot2 carrier2)
    
    ;si identifica la warehouse
    (is_warehouse warehouse)

    ;le box sono collocate nella warehouse
    (at_loc box1 warehouse)
    (at_loc box2 warehouse)
    (at_loc box3 warehouse)

    ;i materiali sono nella warehouse
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
    
    ;si stabiliscono i collegamenti tra le varie location
    (connected warehouse location1)
    (connected location1 location2)
    (connected location1 warehouse)
    (connected location2 location1)
    
    ;si imposta la capacità di ciascun carrier
    ;il carrier1 ha capacità 3
    (holds carrier1 slot1)
    (holds carrier1 slot2) 
    (holds carrier1 slot3)
    ;il carrier2 ha capacità 2
    (holds carrier2 slot4)
    (holds carrier2 slot5)
  
    ;i carrier sono vuoti per cui gli slot risultano tutti liberi
    (free slot1)
    (free slot2)
    (free slot3)
    (free slot4)
    (free slot5)
  )

  (:goal

    (and

      ;almeno una workstation necessita di un materiale (bullone)
      (at_ws bolt workstation2)

      ;almeno una workstation che non necessita di materiali 
      (not (at_ws bolt workstation1))
      (not (at_ws screw workstation1))

      ;almeno una workstation che necessita di più materiali (bulloni e viti)
      (at_ws bolt workstation3)
      (at_ws screw workstation3)

    )
  )
)